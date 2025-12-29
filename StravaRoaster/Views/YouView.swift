import SwiftUI

struct YouView: View {
    @ObservedObject var stravaService: StravaService
    @State private var selectedTimeframe: Timeframe = .month
    @State private var showingSettings = false
    @State private var showingWrapped = false
    @State private var activities: [StravaActivity] = []
    @State private var isLoading = false
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        case sixMonths = "6 Months"
        case oneYear = "Year"
        case twoYears = "2 Years"
        case allTime = "All Time"
        
        var dateRange: (start: Date, end: Date) {
            let now = Date()
            let calendar = Calendar.current
            let start: Date
            
            switch self {
            case .week:
                start = calendar.date(byAdding: .day, value: -7, to: now)!
            case .month:
                start = calendar.date(byAdding: .month, value: -1, to: now)!
            case .threeMonths:
                start = calendar.date(byAdding: .month, value: -3, to: now)!
            case .sixMonths:
                start = calendar.date(byAdding: .month, value: -6, to: now)!
            case .oneYear:
                start = calendar.date(byAdding: .year, value: -1, to: now)!
            case .twoYears:
                start = calendar.date(byAdding: .year, value: -2, to: now)!
            case .allTime:
                start = calendar.date(byAdding: .year, value: -10, to: now)!
            }
            
            return (start, now)
        }
    }
    
    var totalDistance: Double {
        activities.reduce(0) { $0 + $1.distanceMiles }
    }
    
    var totalMovingTime: Int {
        activities.reduce(0) { $0 + $1.moving_time }
    }
    
    var totalElevation: Double {
        activities.reduce(0) { $0 + $1.total_elevation_gain }
    }
    
    var totalKudos: Int {
        activities.reduce(0) { $0 + $1.kudos_count }
    }
    
    var averagePace: String {
        let runs = activities.filter { $0.type.lowercased().contains("run") }
        guard !runs.isEmpty else { return "N/A" }
        
        let totalTime = runs.reduce(0) { $0 + $1.moving_time }
        let totalDist = runs.reduce(0) { $0 + $1.distanceMiles }
        
        guard totalDist > 0 else { return "N/A" }
        
        let avgPaceMinPerMile = Double(totalTime) / 60.0 / totalDist
        let minutes = Int(avgPaceMinPerMile)
        let seconds = Int((avgPaceMinPerMile - Double(minutes)) * 60)
        
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                                Button {
                                    selectedTimeframe = timeframe
                                    Task { await loadStats() }
                                } label: {
                                    Text(timeframe.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(selectedTimeframe == timeframe ? .bold : .regular)
                                        .foregroundColor(selectedTimeframe == timeframe ? .white : .roastOrange)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedTimeframe == timeframe ? Color.roastOrange : Color.roastOrange.opacity(0.1))
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                    
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("\(selectedTimeframe.rawValue) of Suffering")
                                .font(.title2)
                                .bold()
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                StatsCard(
                                    title: "Total Distance",
                                    value: String(format: "%.1f mi", totalDistance),
                                    icon: "arrow.right"
                                )
                                
                                StatsCard(
                                    title: "Activities",
                                    value: "\(activities.count)",
                                    icon: "list.bullet"
                                )
                                
                                StatsCard(
                                    title: "Moving Time",
                                    value: formatTotalTime(totalMovingTime),
                                    icon: "clock"
                                )
                                
                                StatsCard(
                                    title: "Avg Pace",
                                    value: averagePace,
                                    icon: "gauge.medium"
                                )
                                
                                StatsCard(
                                    title: "Total Elevation",
                                    value: "\(Int(totalElevation))m",
                                    icon: "arrow.up"
                                )
                                
                                StatsCard(
                                    title: "Total Kudos",
                                    value: "\(totalKudos)",
                                    icon: "hand.thumbsup.fill"
                                )
                            }
                        }
                        
                        Button {
                            showingWrapped = true
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "flame.fill")
                                Text("Generate \(selectedTimeframe.rawValue) Roasted")
                                    .bold()
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.roastOrange)
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(20)
            }
            .navigationTitle("The Receipts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.roastOrange)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(stravaService: stravaService)
            }
            .fullScreenCover(isPresented: $showingWrapped) {
                AggregateWrappedView(
                    activities: activities,
                    timeframe: selectedTimeframe.rawValue
                )
            }
            .task {
                await loadStats()
            }
        }
    }
    
    func loadStats() async {
        isLoading = true
        do {
            let range = selectedTimeframe.dateRange
            activities = try await stravaService.fetchActivities(after: range.start, before: range.end, perPage: 200)
        } catch {
            print("Failed to load stats: \(error)")
        }
        isLoading = false
    }
    
    func formatTotalTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.roastOrange)
            
            Text(value)
                .font(.title3)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.backgroundGray)
        .cornerRadius(12)
    }
}
