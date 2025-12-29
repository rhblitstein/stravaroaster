import SwiftUI

struct ActivityDetailView: View {
    let activity: StravaActivity
    @ObservedObject var stravaService: StravaService
    @State private var roastCache = RoastCache()
    
    @State private var detailedActivity: StravaActivity?
    @State private var isLoadingDetails = false
    @State private var roast: String = ""
    @State private var isGenerating = false
    
    @AppStorage("defaultSpiceLevel") private var defaultSpiceLevel = "Spicy"
    @AppStorage("runSpiceLevel") private var runSpiceLevel = "Spicy"
    @AppStorage("rideSpiceLevel") private var rideSpiceLevel = "Spicy"
    @AppStorage("swimSpiceLevel") private var swimSpiceLevel = "Spicy"
    @AppStorage("hikeSpiceLevel") private var hikeSpiceLevel = "Spicy"
    
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
                                Text("Athlete Unintelligence")
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
            await loadOrGenerateRoast()
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
    
    func loadOrGenerateRoast() async {
        let severity = getSpiceLevelForActivity(activity.type)
        let severityString = getSeverityString(severity)
        
        if let cachedRoast = roastCache.getRoast(for: activity.id, spiceLevel: severityString) {
            roast = cachedRoast
            return
        }
        
        isGenerating = true
        do {
            let generatedRoast = try await roastService.generateRoast(for: activity, severity: severity)
            roast = generatedRoast
            roastCache.saveRoast(generatedRoast, for: activity.id, spiceLevel: severityString)
        } catch {
            roast = "Failed to generate roast: \(error)"
        }
        isGenerating = false
    }

    func getSeverityString(_ severity: MockRoastService.RoastSeverity) -> String {
        switch severity {
        case .mild: return "Mild"
        case .spicy: return "Spicy"
        case .caliente: return "Caliente"
        case .ghostPepper: return "GhostPepper"
        }
    }
    
    func getSpiceLevelForActivity(_ type: String) -> MockRoastService.RoastSeverity {
        let levelString: String
        
        switch type.lowercased() {
        case "run", "trailrun":
            levelString = runSpiceLevel
        case "ride":
            levelString = rideSpiceLevel
        case "swim":
            levelString = swimSpiceLevel
        case "hike":
            levelString = hikeSpiceLevel
        default:
            levelString = defaultSpiceLevel
        }
        
        switch levelString {
        case "Mild": return .mild
        case "Spicy": return .spicy
        case "Caliente": return .caliente
        case "🌶️🌶️🌶️": return .ghostPepper
        default: return .spicy
        }
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
