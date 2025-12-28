import SwiftUI

struct ActivitiesView: View {
    @ObservedObject var stravaService: StravaService
    @State private var activities: [StravaActivity] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingLogoutAlert = false
    
    var body: some View {
        List {
            ForEach(activities) { activity in
                NavigationLink(destination: ActivityDetailView(
                    activity: activity,
                    stravaService: stravaService
                )) {
                    HStack(spacing: 12) {
                        if let photoCount = activity.photo_count, photoCount > 0 {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.roastOrange.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.roastOrange)
                            }
                        } else {
                            Image(systemName: activityIcon(for: activity.type))
                                .font(.title2)
                                .foregroundColor(.roastOrange)
                                .frame(width: 50, height: 50)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(activity.name)
                                .font(.headline)
                                .lineLimit(1)
                            
                            HStack(spacing: 12) {
                                Label("\(String(format: "%.1f", activity.distanceMiles)) mi",
                                      systemImage: "arrow.right")
                                
                                Label(activity.pacePerMile,
                                      systemImage: "gauge.medium")
                                
                                Label(activity.movingTimeFormatted,
                                      systemImage: "clock")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Image(systemName: "hand.thumbsup.fill")
                                    Text("\(activity.kudos_count)")
                                }
                                
                                if let photoCount = activity.photo_count, photoCount > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "camera.fill")
                                        Text("\(photoCount)")
                                    }
                                }
                                
                                if let achievements = activity.achievement_count, achievements > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "trophy.fill")
                                        Text("\(achievements)")
                                    }
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.roastOrange)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Activities")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Logout") {
                    showingLogoutAlert = true
                }
                .foregroundColor(.roastOrange)
            }
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                stravaService.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .overlay {
            if isLoading && activities.isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading your activities...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.backgroundGray)
            }
        }
        .alert("Error Loading Activities", isPresented: .constant(errorMessage != nil)) {
            Button("Retry") {
                errorMessage = nil
                Task { await loadActivities() }
            }
            Button("Cancel", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
        .task {
            await loadActivities()
        }
    }
    
    func loadActivities() async {
        isLoading = true
        do {
            activities = try await stravaService.fetchActivities()
        } catch {
            errorMessage = "Failed to load activities: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func activityIcon(for type: String) -> String {
        switch type.lowercased() {
        case "run", "trailrun": return "figure.run"
        case "ride": return "bicycle"
        case "swim": return "figure.pool.swim"
        case "hike": return "figure.hiking"
        case "walk": return "figure.walk"
        default: return "figure.mixed.cardio"
        }
    }
}
