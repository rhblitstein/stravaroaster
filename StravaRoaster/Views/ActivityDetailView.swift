import SwiftUI

struct ActivityDetailView: View {
    let activity: StravaActivity
    @ObservedObject var stravaService: StravaService
    
    @State private var detailedActivity: StravaActivity?
    @State private var isLoadingDetails = false
    @State private var roast: String = ""
    @State private var isGenerating = false
    @State private var selectedSeverity: MockRoastService.RoastSeverity = .spicy
    
    private let roastService = MockRoastService()
    
    var body: some View {
        let displayActivity = detailedActivity ?? activity
        
        return ScrollView {
            VStack(spacing: 0) {
                
                if let photosData = displayActivity.photos, let primary = photosData.primary,
                   let urlString = primary.urls.url_600, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .clipped()
                        case .failure:
                            VStack {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("Photo unavailable")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(displayActivity.name)
                            .font(.title2)
                            .bold()
                        
                        if let description = displayActivity.description, !description.isEmpty {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            StatCard(icon: "figure.run", label: "Distance", value: String(format: "%.2f mi", displayActivity.distanceMiles))
                            StatCard(icon: "clock", label: "Moving", value: displayActivity.movingTimeFormatted)
                            StatCard(icon: "speedometer", label: "Pace", value: displayActivity.pacePerMile)
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            StatCard(icon: "arrow.up", label: "Elevation", value: "\(Int(displayActivity.total_elevation_gain))m")
                            
                            if displayActivity.stoppageTime > 0 {
                                StatCard(icon: "pause.circle", label: "Stopped", value: displayActivity.stoppageTimeFormatted)
                            }
                            
                            if let hr = displayActivity.average_heartrate {
                                StatCard(icon: "heart.fill", label: "Avg HR", value: "\(Int(hr))")
                            }
                        }
                        
                        HStack(spacing: 12) {
                            StatCard(icon: "hand.thumbsup.fill", label: "Kudos", value: "\(displayActivity.kudos_count)")
                            
                            if let photos = displayActivity.photo_count, photos > 0 {
                                StatCard(icon: "camera.fill", label: "Photos", value: "\(photos)")
                            }
                            
                            if let achievements = displayActivity.achievement_count, achievements > 0 {
                                StatCard(icon: "trophy.fill", label: "Achievements", value: "\(achievements)")
                            }
                        }
                    }
                    .padding()
                    .background(Color.backgroundGray)
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Roast Severity")
                            .font(.headline)
                        
                        Picker("Severity", selection: $selectedSeverity) {
                            ForEach(MockRoastService.RoastSeverity.allCases, id: \.self) { severity in
                                Text(severity.rawValue)
                                    .minimumScaleFactor(0.5)
                                    .tag(severity)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Button(action: generateRoast) {
                        HStack {
                            Image(systemName: roast.isEmpty ? "flame.fill" : "arrow.clockwise")
                            Text(roast.isEmpty ? "GET ROASTED" : "RE-ROAST")
                                .bold()
                        }
                    }
                    .roastButtonStyle()
                    .disabled(isGenerating)
                    
                    if isGenerating {
                        ProgressView("Generating roast...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    
                    if !roast.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text("Your Roast")
                                    .font(.headline)
                            }
                            
                            Text(roast)
                                .font(.body)
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    if let segments = detailedActivity?.segment_efforts, !segments.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "flag.checkered")
                                    .foregroundColor(.roastOrange)
                                Text("Segments (\(segments.count))")
                                    .font(.headline)
                            }
                            
                            ForEach(segments) { segment in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(segment.name)
                                            .font(.subheadline)
                                            .bold()
                                        
                                        Spacer()
                                        
                                        if segment.isLocalLegend {
                                            Image(systemName: "crown.fill")
                                                .foregroundColor(.orange)
                                        }
                                        
                                        if segment.isPR {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                    
                                    HStack {
                                        Label(segment.movingTimeFormatted, systemImage: "clock")
                                        
                                        if let rank = segment.kom_rank {
                                            Label("#\(rank)", systemImage: "list.number")
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .scrollIndicators(.visible)
        .navigationTitle("Activity Roast")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadActivityDetails()
        }
    }
    
    func generateRoast() {
        Task {
            isGenerating = true
            do {
                roast = try await roastService.generateRoast(for: activity, severity: selectedSeverity)
            } catch {
                roast = "Failed to generate roast: \(error)"
            }
            isGenerating = false
        }
    }
    
    func loadActivityDetails() async {
        isLoadingDetails = true
        do {
            detailedActivity = try await stravaService.fetchActivityDetail(id: activity.id)
        } catch {
            print("Failed to load activity details: \(error)")
        }
        isLoadingDetails = false
    }
}

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.roastOrange)
            
            Text(value)
                .font(.headline)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(8)
    }
}

extension SegmentEffort {
    var movingTimeFormatted: String {
        let minutes = moving_time / 60
        let seconds = moving_time % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
