import SwiftUI

struct ActivitiesView: View {
    @ObservedObject var stravaService: StravaService
    @State private var activities: [StravaActivity] = []
    @State private var isLoading = false
    @State private var isLoadingMore = false
    @State private var errorMessage: String?
    @State private var currentPage = 1
    @State private var hasMoreActivities = true
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading && activities.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading your activities...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
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
                            .onAppear {
                                if activity.id == activities.last?.id && hasMoreActivities && !isLoadingMore {
                                    Task {
                                        await loadMoreActivities()
                                    }
                                }
                            }
                        }
                        
                        if isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Activities")
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
    }
    
    func loadActivities() async {
        isLoading = true
        currentPage = 1
        do {
            activities = try await stravaService.fetchActivitiesPaginated(page: currentPage, perPage: 20)
            hasMoreActivities = activities.count >= 20
        } catch {
            errorMessage = "Failed to load activities: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func loadMoreActivities() async {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        currentPage += 1
        
        do {
            let newActivities = try await stravaService.fetchActivitiesPaginated(page: currentPage, perPage: 20)
            activities.append(contentsOf: newActivities)
            hasMoreActivities = newActivities.count >= 20
        } catch {
            print("Failed to load more activities: \(error)")
            hasMoreActivities = false
        }
        
        isLoadingMore = false
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
