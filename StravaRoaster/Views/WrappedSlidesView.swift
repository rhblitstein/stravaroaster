import SwiftUI

struct WrappedSlidesView: View {
    let activity: StravaActivity
    let severity: MockRoastService.RoastSeverity
    @Environment(\.dismiss) var dismiss
    
    @State private var currentSlide = 0
    @State private var slideRoasts: [String?] = []
    @State private var showingShareSheet = false
    @State private var shareImage: UIImage?
    @State private var generalRoast: String = ""
    
    private let roastService = MockRoastService()
    
    var slides: [SlideType] {
        var result: [SlideType] = [.title]
        
        result.append(.stats)
        
        if activity.stoppageTime > 60 {
            result.append(.stoppage)
        }
        
        if activity.total_elevation_gain > 100 || activity.total_elevation_gain < 30 {
            result.append(.elevation)
        }
        
        result.append(.social)
        
        if let segments = activity.segment_efforts, !segments.isEmpty {
            result.append(.segments)
        }
        
        result.append(.final)
        
        return result
    }
    
    enum SlideType {
        case title
        case stats
        case stoppage
        case elevation
        case social
        case segments
        case final
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $currentSlide) {
                ForEach(Array(slides.enumerated()), id: \.offset) { index, slideType in
                    slideView(for: slideType, index: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            .onChange(of: currentSlide) {
                // Haptic feedback on slide change
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
        .sheet(isPresented: $showingShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
        .onAppear {
            slideRoasts = Array(repeating: nil, count: slides.count)
            loadGeneralRoast()
        }
    }
    
    @ViewBuilder
    func slideView(for type: SlideType, index: Int) -> some View {
        switch type {
        case .title:
            TitleSlide(activityName: activity.name)
        case .stats:
            StatsSlide(activity: activity, roast: binding(for: index), severity: severity)
        case .stoppage:
            StoppageSlide(activity: activity, roast: binding(for: index), severity: severity)
        case .elevation:
            ElevationSlide(activity: activity, roast: binding(for: index), severity: severity)
        case .social:
            SocialSlide(activity: activity, roast: binding(for: index), severity: severity)
        case .segments:
            SegmentsSlide(activity: activity, roast: binding(for: index), severity: severity)
        case .final:
            FinalSlide(
                activity: activity,
                roast: binding(for: index),
                severity: severity,
                generalRoast: generalRoast,
                onShare: { shareCompositeSlide() }
            )
        }
    }
    
    func binding(for index: Int) -> Binding<String?> {
        Binding(
            get: { slideRoasts[safe: index] ?? nil },
            set: { newValue in
                if index < slideRoasts.count {
                    slideRoasts[index] = newValue
                }
            }
        )
    }
    
    func loadGeneralRoast() {
        Task {
            do {
                generalRoast = try await roastService.generateRoast(for: activity, severity: severity)
            } catch {
                generalRoast = "This workout was... a choice."
            }
        }
    }
    
    @MainActor
    func shareCompositeSlide() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        guard !generalRoast.isEmpty else {
            print("Roast not loaded yet")
            return
        }
        
        let composite = CompositeShareSlide(activity: activity, roast: generalRoast)
        let controller = UIHostingController(rootView: composite)
        controller.view.frame = CGRect(x: 0, y: 0, width: 1080, height: 1920)
        
        let renderer = UIGraphicsImageRenderer(size: controller.view.bounds.size)
        let image = renderer.image { ctx in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        
        shareImage = image
        showingShareSheet = true
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Animated Counter
struct AnimatedCounter: View {
    let value: Double
    let formatter: (Double) -> String
    @State private var displayValue: Double = 0
    
    var body: some View {
        Text(formatter(displayValue))
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    displayValue = value
                }
            }
    }
}

// MARK: - Typing Text Animation
struct TypingText: View {
    let text: String
    let speed: Double
    @State private var displayedText = ""
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                displayedText = ""
                for (index, character) in text.enumerated() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * speed) {
                        displayedText.append(character)
                    }
                }
            }
    }
}

// MARK: - Composite Share Slide
struct CompositeShareSlide: View {
    let activity: StravaActivity
    let roast: String
    
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
                    
                    Text(activity.name)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                
                VStack(spacing: 20) {
                    HStack(spacing: 40) {
                        VStack(spacing: 8) {
                            Text(String(format: "%.1f", activity.distanceMiles))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("miles")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack(spacing: 8) {
                            Text(activity.pacePerMile)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("pace")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack(spacing: 8) {
                            Text(activity.movingTimeFormatted)
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
                            Text("\(Int(activity.total_elevation_gain))")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("elevation (m)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack(spacing: 8) {
                            Text("\(activity.kudos_count)")
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
                    Text("The Roast")
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
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Title Slide
struct TitleSlide: View {
    let activityName: String
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
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .shadow(color: .orange.opacity(0.6), radius: 20)
                    .scaleEffect(showFlame ? 1.0 : 0.5)
                    .opacity(showFlame ? 1.0 : 0.0)
                
                Text(activityName)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(y: showTitle ? 0 : 20)
                    .opacity(showTitle ? 1.0 : 0.0)
                
                Text("Let's talk about this...")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .italic()
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

// MARK: - Stats Slide
struct StatsSlide: View {
    let activity: StravaActivity
    @Binding var roast: String?
    let severity: MockRoastService.RoastSeverity
    
    @State private var isLoading = false
    @State private var showStats = false
    @State private var showRoast = false
    private let roastService = MockRoastService()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.roastOrange, Color.roastOrange.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    AnimatedStatRow(
                        label: "Distance",
                        value: String(format: "%.2f mi", activity.distanceMiles),
                        delay: 0.1,
                        show: showStats
                    )
                    AnimatedStatRow(
                        label: "Pace",
                        value: activity.pacePerMile,
                        delay: 0.2,
                        show: showStats
                    )
                    AnimatedStatRow(
                        label: "Moving Time",
                        value: activity.movingTimeFormatted,
                        delay: 0.3,
                        show: showStats
                    )
                }
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                } else if let roastText = roast {
                    Text(roastText)
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .shadow(color: .black.opacity(0.2), radius: 4)
                        .opacity(showRoast ? 1.0 : 0.0)
                        .offset(y: showRoast ? 0 : 20)
                } else {
                    Text("")
                        .frame(height: 100)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showStats = true
            }
            
            if roast == nil {
                loadRoast()
            }
        }
    }
    
    func loadRoast() {
        isLoading = true
        Task {
            do {
                let roastText = try await roastService.generateStatsRoast(for: activity, severity: severity)
                await MainActor.run {
                    roast = roastText
                    isLoading = false
                    withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                        showRoast = true
                    }
                }
            } catch {
                await MainActor.run {
                    roast = "Your stats speak for themselves."
                    isLoading = false
                    showRoast = true
                }
            }
        }
    }
}

struct AnimatedStatRow: View {
    let label: String
    let value: String
    let delay: Double
    let show: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 2)
        }
        .padding(.horizontal, 40)
        .offset(x: show ? 0 : -30)
        .opacity(show ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.4).delay(delay), value: show)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 2)
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Stoppage Slide
struct StoppageSlide: View {
    let activity: StravaActivity
    @Binding var roast: String?
    let severity: MockRoastService.RoastSeverity
    
    @State private var isLoading = false
    @State private var showContent = false
    @State private var showRoast = false
    private let roastService = MockRoastService()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.orange, Color.orange.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 8)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0.0)
                    
                    Text("You stopped for")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(showContent ? 1.0 : 0.0)
                    
                    Text(activity.stoppageTimeFormatted)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4)
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                }
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                } else if let roastText = roast {
                    Text(roastText)
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .shadow(color: .black.opacity(0.2), radius: 4)
                        .opacity(showRoast ? 1.0 : 0.0)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }
            
            if roast == nil {
                loadRoast()
            }
        }
    }
    
    func loadRoast() {
        isLoading = true
        Task {
            do {
                let roastText = try await roastService.generateStoppageRoast(for: activity, severity: severity)
                await MainActor.run {
                    roast = roastText
                    isLoading = false
                    withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                        showRoast = true
                    }
                }
            } catch {
                await MainActor.run {
                    roast = "Time well spent, I'm sure."
                    isLoading = false
                    showRoast = true
                }
            }
        }
    }
}

// MARK: - Elevation Slide
struct ElevationSlide: View {
    let activity: StravaActivity
    @Binding var roast: String?
    let severity: MockRoastService.RoastSeverity
    
    @State private var isLoading = false
    @State private var showContent = false
    @State private var showRoast = false
    private let roastService = MockRoastService()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.red.opacity(0.8), Color.red.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 8)
                        .rotationEffect(.degrees(showContent ? 0 : -45))
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0.0)
                    
                    Text("Elevation Gain")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(showContent ? 1.0 : 0.0)
                    
                    Text("\(Int(activity.total_elevation_gain))m")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4)
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1.0 : 0.0)
                }
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                } else if let roastText = roast {
                    Text(roastText)
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .shadow(color: .black.opacity(0.2), radius: 4)
                        .opacity(showRoast ? 1.0 : 0.0)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }
            
            if roast == nil {
                loadRoast()
            }
        }
    }
    
    func loadRoast() {
        isLoading = true
        Task {
            do {
                let roastText = try await roastService.generateElevationRoast(for: activity, severity: severity)
                await MainActor.run {
                    roast = roastText
                    isLoading = false
                    withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                        showRoast = true
                    }
                }
            } catch {
                await MainActor.run {
                    roast = "Hills are optional, apparently."
                    isLoading = false
                    showRoast = true
                }
            }
        }
    }
}

// MARK: - Social Slide
struct SocialSlide: View {
    let activity: StravaActivity
    @Binding var roast: String?
    let severity: MockRoastService.RoastSeverity
    
    @State private var isLoading = false
    @State private var showContent = false
    @State private var showRoast = false
    private let roastService = MockRoastService()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    HStack(spacing: 40) {
                        VStack {
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 4)
                            Text("\(activity.kudos_count)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                            Text("Kudos")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0.0)
                        
                        if let photos = activity.photo_count, photos > 0 {
                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 4)
                                Text("\(photos)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.2), radius: 2)
                                Text("Photos")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .scaleEffect(showContent ? 1.0 : 0.5)
                            .opacity(showContent ? 1.0 : 0.0)
                        }
                    }
                }
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                } else if let roastText = roast {
                    Text(roastText)
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .shadow(color: .black.opacity(0.2), radius: 4)
                        .opacity(showRoast ? 1.0 : 0.0)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }
            
            if roast == nil {
                loadRoast()
            }
        }
    }
    
    func loadRoast() {
        isLoading = true
        Task {
            do {
                let roastText = try await roastService.generateSocialRoast(for: activity, severity: severity)
                await MainActor.run {
                    roast = roastText
                    isLoading = false
                    withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                        showRoast = true
                    }
                }
            } catch {
                await MainActor.run {
                    roast = "The people have spoken."
                    isLoading = false
                    showRoast = true
                }
            }
        }
    }
}

// MARK: - Segments Slide
struct SegmentsSlide: View {
    let activity: StravaActivity
    @Binding var roast: String?
    let severity: MockRoastService.RoastSeverity
    
    @State private var isLoading = false
    @State private var showContent = false
    @State private var showRoast = false
    private let roastService = MockRoastService()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 8)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0.0)
                    
                    if let segments = activity.segment_efforts {
                        Text("\(segments.count) Segments")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 2)
                            .opacity(showContent ? 1.0 : 0.0)
                        
                        let prs = segments.filter { $0.isPR }.count
                        let legends = segments.filter { $0.isLocalLegend }.count
                        
                        HStack(spacing: 30) {
                            if prs > 0 {
                                VStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .shadow(color: .yellow.opacity(0.5), radius: 8)
                                    Text("\(prs) PR\(prs == 1 ? "" : "s")")
                                        .foregroundColor(.white)
                                }
                                .scaleEffect(showContent ? 1.0 : 0.5)
                                .opacity(showContent ? 1.0 : 0.0)
                            }
                            
                            if legends > 0 {
                                VStack {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.orange)
                                        .shadow(color: .orange.opacity(0.5), radius: 8)
                                    Text("\(legends) Legend\(legends == 1 ? "" : "s")")
                                        .foregroundColor(.white)
                                }
                                .scaleEffect(showContent ? 1.0 : 0.5)
                                .opacity(showContent ? 1.0 : 0.0)
                            }
                        }
                    }
                }
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                } else if let roastText = roast {
                    Text(roastText)
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .shadow(color: .black.opacity(0.2), radius: 4)
                        .opacity(showRoast ? 1.0 : 0.0)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }
            
            if roast == nil {
                loadRoast()
            }
        }
    }
    
    func loadRoast() {
        isLoading = true
        Task {
            do {
                let roastText = try await roastService.generateSegmentsRoast(for: activity, severity: severity)
                await MainActor.run {
                    roast = roastText
                    isLoading = false
                    withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                        showRoast = true
                    }
                }
            } catch {
                await MainActor.run {
                    roast = "Segment hunting, are we?"
                    isLoading = false
                    showRoast = true
                }
            }
        }
    }
}

// MARK: - Final Slide
struct FinalSlide: View {
    let activity: StravaActivity
    @Binding var roast: String?
    let severity: MockRoastService.RoastSeverity
    let generalRoast: String
    let onShare: () -> Void
    
    @State private var isLoading = false
    @State private var showContent = false
    @State private var showRoast = false
    @State private var showButton = false
    private let roastService = MockRoastService()
    
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
                
                Text("Final Verdict")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4)
                    .opacity(showContent ? 1.0 : 0.0)
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                } else if let roastText = roast {
                    Text(roastText)
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .shadow(color: .black.opacity(0.2), radius: 4)
                        .opacity(showRoast ? 1.0 : 0.0)
                        .offset(y: showRoast ? 0 : 20)
                }
                
                Button {
                    onShare()
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
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }
            
            if roast == nil {
                loadRoast()
            }
        }
    }
    
    func loadRoast() {
        isLoading = true
        Task {
            do {
                let roastText = try await roastService.generateFinalRoast(for: activity, severity: severity)
                await MainActor.run {
                    roast = roastText
                    isLoading = false
                    withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                        showRoast = true
                    }
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
                        showButton = true
                    }
                }
            } catch {
                await MainActor.run {
                    roast = "You showed up. That's something."
                    isLoading = false
                    showRoast = true
                    showButton = true
                }
            }
        }
    }
}
