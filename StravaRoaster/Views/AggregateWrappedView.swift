import SwiftUI

struct AggregateWrappedView: View {
    let activities: [StravaActivity]
    let timeframe: String
    
    @Environment(\.dismiss) var dismiss
    @State private var currentSlide = 0
    
    var slides: [AggregateSlideType] {
        [.title, .totalStats, .bestPerformance, .worstPerformance, .social, .achievements, .finalRoast]
    }
    
    enum AggregateSlideType {
        case title
        case totalStats
        case bestPerformance
        case worstPerformance
        case social
        case achievements
        case finalRoast
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $currentSlide) {
                ForEach(Array(slides.enumerated()), id: \.offset) { index, slideType in
                    slideView(for: slideType)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            .onChange(of: currentSlide) {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding()
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentSlide ? Color.white : Color.white.opacity(0.5))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentSlide ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentSlide)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    @ViewBuilder
    func slideView(for type: AggregateSlideType) -> some View {
        switch type {
        case .title:
            AggregateTitleSlide(timeframe: timeframe)
        case .totalStats:
            AggregateTotalStatsSlide(activities: activities, timeframe: timeframe)
        case .bestPerformance:
            AggregateBestSlide(activities: activities)
        case .worstPerformance:
            AggregateWorstSlide(activities: activities)
        case .social:
            AggregateSocialSlide(activities: activities)
        case .achievements:
            AggregateAchievementsSlide(activities: activities)
        case .finalRoast:
            AggregateFinalSlide(activities: activities, timeframe: timeframe)
        }
    }
}

// MARK: - Title Slide
struct AggregateTitleSlide: View {
    let timeframe: String
    @State private var showFlame = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.roastOrange, Color.roastRed],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 20) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .shadow(color: .orange.opacity(0.6), radius: 20)
                    .scaleEffect(showFlame ? 1.0 : 0.5)
                    .opacity(showFlame ? 1.0 : 0.0)
                
                Text("Your \(timeframe)")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(y: showTitle ? 0 : 20)
                    .opacity(showTitle ? 1.0 : 0.0)
                
                Text("Roasted")
                    .font(.system(size: 48, weight: .heavy))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(y: showSubtitle ? 0 : 20)
                    .opacity(showSubtitle ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showFlame = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                showTitle = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
                showSubtitle = true
            }
        }
    }
}

// MARK: - Total Stats Slide
struct AggregateTotalStatsSlide: View {
    let activities: [StravaActivity]
    let timeframe: String
    @State private var showContent = false
    
    var totalDistance: Double {
        activities.reduce(0) { $0 + $1.distanceMiles }
    }
    
    var totalTime: Int {
        activities.reduce(0) { $0 + $1.moving_time }
    }
    
    var totalElevation: Double {
        activities.reduce(0) { $0 + $1.total_elevation_gain }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.roastOrange.opacity(0.9), Color.roastOrange.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 30) {
                Text("The Numbers")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4)
                    .opacity(showContent ? 1.0 : 0.0)
                
                VStack(spacing: 20) {
                    HStack(spacing: 30) {
                        VStack(spacing: 8) {
                            Text("\(activities.count)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("Activities")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack(spacing: 8) {
                            Text(String(format: "%.0f", totalDistance))
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("Miles")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    HStack(spacing: 30) {
                        VStack(spacing: 8) {
                            Text(formatTime(totalTime))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("Moving Time")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack(spacing: 8) {
                            Text("\(Int(totalElevation))")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("Elevation (m)")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .scaleEffect(showContent ? 1.0 : 0.8)
                .opacity(showContent ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }
    
    func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Best Performance Slide
struct AggregateBestSlide: View {
    let activities: [StravaActivity]
    @State private var showContent = false
    
    var fastestPace: (activity: StravaActivity, pace: String)? {
        let runs = activities.filter { $0.type.lowercased().contains("run") && $0.distanceMiles > 1.0 }
        guard let fastest = runs.min(by: { $0.pacePerMileSeconds < $1.pacePerMileSeconds }) else { return nil }
        return (fastest, fastest.pacePerMile)
    }
    
    var longestDistance: StravaActivity? {
        activities.max(by: { $0.distanceMiles < $1.distanceMiles })
    }
    
    var mostElevation: StravaActivity? {
        activities.max(by: { $0.total_elevation_gain < $1.total_elevation_gain })
    }
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.7)
            
            VStack(spacing: 30) {
                Text("Best Performances")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4)
                    .opacity(showContent ? 1.0 : 0.0)
                
                VStack(spacing: 20) {
                    if let fastest = fastestPace {
                        VStack(spacing: 8) {
                            Image(systemName: "hare.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            Text("Fastest Pace")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            Text(fastest.pace)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text(fastest.activity.name)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    
                    if let longest = longestDistance {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            Text("Longest Distance")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            Text(String(format: "%.1f mi", longest.distanceMiles))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text(longest.name)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                }
                .scaleEffect(showContent ? 1.0 : 0.8)
                .opacity(showContent ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }
}

// MARK: - Worst Performance Slide
struct AggregateWorstSlide: View {
    let activities: [StravaActivity]
    @State private var showContent = false
    
    var slowestPace: (activity: StravaActivity, pace: String)? {
        let runs = activities.filter { $0.type.lowercased().contains("run") && $0.distanceMiles > 1.0 }
        guard let slowest = runs.max(by: { $0.pacePerMileSeconds < $1.pacePerMileSeconds }) else { return nil }
        return (slowest, slowest.pacePerMile)
    }
    
    var mostStopped: StravaActivity? {
        activities.max(by: { $0.stoppageTime < $1.stoppageTime })
    }
    
    var body: some View {
        ZStack {
            Color.red.opacity(0.7)
            
            VStack(spacing: 30) {
                Text("Room for Improvement")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4)
                    .opacity(showContent ? 1.0 : 0.0)
                
                VStack(spacing: 20) {
                    if let slowest = slowestPace {
                        VStack(spacing: 8) {
                            Image(systemName: "tortoise.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            Text("Slowest Pace")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            Text(slowest.pace)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text(slowest.activity.name)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    
                    if let stopped = mostStopped, stopped.stoppageTime > 60 {
                        VStack(spacing: 8) {
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            Text("Most Time Stopped")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            Text(stopped.stoppageTimeFormatted)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text(stopped.name)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                }
                .scaleEffect(showContent ? 1.0 : 0.8)
                .opacity(showContent ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }
}

// MARK: - Social Slide
struct AggregateSocialSlide: View {
    let activities: [StravaActivity]
    @State private var showContent = false
    
    var totalKudos: Int {
        activities.reduce(0) { $0 + $1.kudos_count }
    }
    
    var mostKudos: StravaActivity? {
        activities.max(by: { $0.kudos_count < $1.kudos_count })
    }
    
    var totalPhotos: Int {
        activities.reduce(0) { $0 + ($1.photo_count ?? 0) }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 30) {
                Text("Social Stats")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4)
                    .opacity(showContent ? 1.0 : 0.0)
                
                VStack(spacing: 20) {
                    HStack(spacing: 40) {
                        VStack(spacing: 8) {
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            Text("\(totalKudos)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("Total Kudos")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            Text("\(totalPhotos)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("Total Photos")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    if let popular = mostKudos, popular.kudos_count > 0 {
                        VStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.yellow)
                                .shadow(color: .yellow.opacity(0.5), radius: 8)
                            Text("Most Popular")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            Text(popular.name)
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Text("\(popular.kudos_count) kudos")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top)
                    }
                }
                .scaleEffect(showContent ? 1.0 : 0.8)
                .opacity(showContent ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }
}

// MARK: - Achievements Slide
struct AggregateAchievementsSlide: View {
    let activities: [StravaActivity]
    @State private var showContent = false
    
    var totalPRs: Int {
        activities.compactMap { $0.segment_efforts }.flatMap { $0 }.filter { $0.isPR }.count
    }
    
    var totalLegends: Int {
        activities.compactMap { $0.segment_efforts }.flatMap { $0 }.filter { $0.isLocalLegend }.count
    }
    
    var totalAchievements: Int {
        activities.reduce(0) { $0 + ($1.achievement_count ?? 0) }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 30) {
                Text("Achievements")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4)
                    .opacity(showContent ? 1.0 : 0.0)
                
                VStack(spacing: 20) {
                    if totalPRs > 0 {
                        VStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.yellow)
                                .shadow(color: .yellow.opacity(0.5), radius: 8)
                            Text("\(totalPRs)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("Personal Records")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    if totalLegends > 0 {
                        VStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                                .shadow(color: .orange.opacity(0.5), radius: 8)
                            Text("\(totalLegends)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("Local Legends")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    if totalAchievements > 0 {
                        VStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            Text("\(totalAchievements)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("Total Achievements")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    if totalPRs == 0 && totalLegends == 0 && totalAchievements == 0 {
                        VStack(spacing: 8) {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.5))
                            Text("No achievements yet")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.7))
                            Text("Time to step it up")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .scaleEffect(showContent ? 1.0 : 0.8)
                .opacity(showContent ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }
}

// MARK: - Final Roast Slide
struct AggregateFinalSlide: View {
    let activities: [StravaActivity]
    let timeframe: String
    @State private var showContent = false
    @State private var showRoast = false
    @State private var showButton = false
    @State private var roast = ""
    @State private var showingShareSheet = false
    @State private var shareImage: UIImage?
    
    var totalDistance: Double {
        activities.reduce(0) { $0 + $1.distanceMiles }
    }
    
    var totalTime: Int {
        activities.reduce(0) { $0 + $1.moving_time }
    }
    
    var totalKudos: Int {
        activities.reduce(0) { $0 + $1.kudos_count }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.roastRed, Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 30) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .shadow(color: .red.opacity(0.6), radius: 20)
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .opacity(showContent ? 1.0 : 0.0)
                
                Text("Overall Verdict")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4)
                    .opacity(showContent ? 1.0 : 0.0)
                
                Text(roast)
                    .font(.title2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .shadow(color: .black.opacity(0.2), radius: 4)
                    .opacity(showRoast ? 1.0 : 0.0)
                    .offset(y: showRoast ? 0 : 20)
                
                Button {
                    shareWrapped()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share This Roast")
                            .bold()
                    }
                    .foregroundColor(.roastRed)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.3), radius: 8)
                }
                .scaleEffect(showButton ? 1.0 : 0.8)
                .opacity(showButton ? 1.0 : 0.0)
                .padding(.top, 20)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }
            generateRoast()
        }
    }
    
    func generateRoast() {
        let totalDistance = activities.reduce(0.0) { $0 + $1.distanceMiles }
        let avgKudos = activities.isEmpty ? 0 : activities.reduce(0) { $0 + $1.kudos_count } / activities.count
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if activities.isEmpty {
                roast = "You didn't do anything this \(timeframe.lowercased()). Impressive laziness."
            } else if activities.count == 1 {
                roast = "One whole activity this \(timeframe.lowercased()). Truly a dedicated athlete."
            } else if totalDistance < 10 {
                roast = "You covered \(String(format: "%.0f", totalDistance)) miles this \(timeframe.lowercased()). Some people do that in a day."
            } else if avgKudos == 0 {
                roast = "Zero average kudos this \(timeframe.lowercased()). Even your friends couldn't be bothered."
            } else if totalDistance > 100 {
                roast = "\(String(format: "%.0f", totalDistance)) miles this \(timeframe.lowercased()). Quality over quantity isn't your thing, apparently."
            } else {
                roast = "\(activities.count) activities, \(String(format: "%.0f", totalDistance)) miles. You showed up. That's... something."
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                showRoast = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
                showButton = true
            }
        }
    }
    
    @MainActor
    func shareWrapped() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        let composite = AggregateShareSlide(
            activities: activities,
            timeframe: timeframe,
            roast: roast
        )
        
        let controller = UIHostingController(rootView: composite)
        controller.view.frame = CGRect(x: 0, y: 0, width: 1080, height: 1920)
        
        let renderer = UIGraphicsImageRenderer(size: controller.view.bounds.size)
        let image = renderer.image { ctx in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        
        shareImage = image
        showingShareSheet = true
    }
    
    func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Aggregate Share Slide
struct AggregateShareSlide: View {
    let activities: [StravaActivity]
    let timeframe: String
    let roast: String
    
    var totalDistance: Double {
        activities.reduce(0) { $0 + $1.distanceMiles }
    }
    
    var totalTime: Int {
        activities.reduce(0) { $0 + $1.moving_time }
    }
    
    var totalKudos: Int {
        activities.reduce(0) { $0 + $1.kudos_count }
    }
    
    var totalElevation: Double {
        activities.reduce(0) { $0 + $1.total_elevation_gain }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.roastOrange, Color.roastRed],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 12) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Your \(timeframe)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Text("Roasted")
                        .font(.system(size: 42, weight: .heavy))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                
                VStack(spacing: 20) {
                    HStack(spacing: 40) {
                        VStack(spacing: 8) {
                            Text("\(activities.count)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("activities")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack(spacing: 8) {
                            Text(String(format: "%.0f", totalDistance))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("miles")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack(spacing: 8) {
                            Text(formatTime(totalTime))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("time")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    HStack(spacing: 40) {
                        VStack(spacing: 8) {
                            Text("\(Int(totalElevation))")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("elevation (m)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack(spacing: 8) {
                            Text("\(totalKudos)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("kudos")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.vertical, 20)
                
                VStack(spacing: 16) {
                    Text("The Verdict")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(roast)
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .lineLimit(6)
                        .minimumScaleFactor(0.8)
                        .shadow(color: .black.opacity(0.2), radius: 2)
                }
                
                Spacer()
                
                Text("Roasted by Spicy Strava")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 40)
            }
        }
        .frame(width: 1080, height: 1920)
    }
    
    func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
