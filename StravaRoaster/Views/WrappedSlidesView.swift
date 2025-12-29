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
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                    .padding()
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentSlide ? Color.white : Color.white.opacity(0.5))
                            .frame(width: 8, height: 8)
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
                generalRoast = "Failed to generate roast"
            }
        }
    }
    
    @MainActor
    func shareCompositeSlide() {
        guard !generalRoast.isEmpty else {
            print("Roast not loaded yet")
            return
        }
        
        // Create the view
        let composite = CompositeShareSlide(activity: activity, roast: generalRoast)
        
        // Use hosting controller instead of ImageRenderer
        let controller = UIHostingController(rootView: composite)
        controller.view.frame = CGRect(x: 0, y: 0, width: 1080, height: 1920)
        
        // Render to image
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
                }
                
                VStack(spacing: 20) {
                    HStack(spacing: 40) {
                        VStack(spacing: 8) {
                            Text(String(format: "%.1f", activity.distanceMiles))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                            Text("miles")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack(spacing: 8) {
                            Text(activity.pacePerMile)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                            Text("pace")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack(spacing: 8) {
                            Text(activity.movingTimeFormatted)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
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
                            Text("elevation (m)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack(spacing: 8) {
                            Text("\(activity.kudos_count)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
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
                }
                
                Spacer()
                
                Text("Roasted by Spicy Strava")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 40)
            }
        }
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

struct TitleSlide: View {
    let activityName: String
    
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
                
                Text(activityName)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Let's talk about this...")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .italic()
            }
        }
    }
}

struct StatsSlide: View {
    let activity: StravaActivity
    @Binding var roast: String?
    let severity: MockRoastService.RoastSeverity
    
    @State private var isLoading = false
    private let roastService = MockRoastService()
    
    var body: some View {
        ZStack {
            Color.roastOrange.opacity(0.9)
            
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    StatRow(label: "Distance", value: String(format: "%.2f mi", activity.distanceMiles))
                    StatRow(label: "Pace", value: activity.pacePerMile)
                    StatRow(label: "Moving Time", value: activity.movingTimeFormatted)
                }
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let roastText = roast {
                    Text(roastText)
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                } else {
                    Text("")
                        .frame(height: 100)
                }
            }
        }
        .onAppear {
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
                }
            } catch {
                await MainActor.run {
                    roast = "Your stats speak for themselves."
                    isLoading = false
                }
            }
        }
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
        }
        .padding(.horizontal, 40)
    }
}

struct StoppageSlide: View {
    let activity: StravaActivity
    @Binding var roast: String?
    let severity: MockRoastService.RoastSeverity
    
    @State private var isLoading = false
    private let roastService = MockRoastService()
    
    var body: some View {
        ZStack {
            Color.orange
            
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("You stopped for")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(activity.stoppageTimeFormatted)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let roastText = roast {
                    Text(roastText)
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
        }
        .onAppear {
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
                }
            } catch {
                await MainActor.run {
                    roast = "Time well spent, I'm sure."
                    isLoading = false
                }
            }
        }
    }
}

struct ElevationSlide: View {
    let activity: StravaActivity
    @Binding var roast: String?
    let severity: MockRoastService.RoastSeverity
    
    @State private var isLoading = false
    private let roastService = MockRoastService()
    
    var body: some View {
        ZStack {
            Color.red.opacity(0.8)
            
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Elevation Gain")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(Int(activity.total_elevation_gain))m")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let roastText = roast {
                    Text(roastText)
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
        }
        .onAppear {
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
                }
            } catch {
                await MainActor.run {
                    roast = "Hills are optional, apparently."
                    isLoading = false
                }
            }
        }
    }
}

struct SocialSlide: View {
    let activity: StravaActivity
    @Binding var roast: String?
    let severity: MockRoastService.RoastSeverity
    
    @State private var isLoading = false
    private let roastService = MockRoastService()
    
    var body: some View {
        ZStack {
            Color.purple.opacity(0.8)
            
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    HStack(spacing: 40) {
                        VStack {
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            Text("\(activity.kudos_count)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                            Text("Kudos")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        if let photos = activity.photo_count, photos > 0 {
                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                Text("\(photos)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Photos")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                }
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let roastText = roast {
                    Text(roastText)
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
        }
        .onAppear {
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
                }
            } catch {
                await MainActor.run {
                    roast = "The people have spoken."
                    isLoading = false
                }
            }
        }
    }
}

struct SegmentsSlide: View {
    let activity: StravaActivity
    @Binding var roast: String?
    let severity: MockRoastService.RoastSeverity
    
    @State private var isLoading = false
    private let roastService = MockRoastService()
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.8)
            
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    if let segments = activity.segment_efforts {
                        Text("\(segments.count) Segments")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        let prs = segments.filter { $0.isPR }.count
                        let legends = segments.filter { $0.isLocalLegend }.count
                        
                        HStack(spacing: 30) {
                            if prs > 0 {
                                VStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text("\(prs) PR\(prs == 1 ? "" : "s")")
                                        .foregroundColor(.white)
                                }
                            }
                            
                            if legends > 0 {
                                VStack {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.orange)
                                    Text("\(legends) Legend\(legends == 1 ? "" : "s")")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let roastText = roast {
                    Text(roastText)
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
        }
        .onAppear {
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
                }
            } catch {
                await MainActor.run {
                    roast = "Segment hunting, are we?"
                    isLoading = false
                }
            }
        }
    }
}

struct FinalSlide: View {
    let activity: StravaActivity
    @Binding var roast: String?
    let severity: MockRoastService.RoastSeverity
    let onShare: () -> Void
    
    @State private var isLoading = false
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
                
                Text("Final Verdict")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let roastText = roast {
                    Text(roastText)
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
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
                }
                .padding(.top, 20)
            }
        }
        .onAppear {
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
                }
            } catch {
                await MainActor.run {
                    roast = "You showed up. That's something."
                    isLoading = false
                }
            }
        }
    }
}
