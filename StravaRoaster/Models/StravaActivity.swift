import Foundation

struct StravaActivity: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let distance: Double // meters
    let moving_time: Int // seconds
    let elapsed_time: Int // seconds
    let total_elevation_gain: Double // meters
    let type: String // "Run", "Ride", etc
    let start_date: String
    let kudos_count: Int
    let photo_count: Int?
    let achievement_count: Int?
    let pr_count: Int?
    
    // Heart rate data (optional)
    let average_heartrate: Double?
    let max_heartrate: Double?
    let has_heartrate: Bool?
    
    // Suffer score
    let suffer_score: Int?
    
    // Gear
    let gear_id: String?
    
    // Photos from the activity detail endpoint
    let photos: PhotosMetadata?
    
    // All photos fetched separately
    var allPhotos: [StravaPhoto]?
    
    // Segments
    var segment_efforts: [SegmentEffort]?
    
    // Map
    let map: ActivityMap?
    
    struct ActivityMap: Codable {
        let id: String
        let summary_polyline: String?
        let polyline: String?
    }
    
    struct PhotosMetadata: Codable {
        let count: Int
        let primary: StravaPhoto?
        let use_primary_photo: Bool?
    }
    
    // Computed properties for display
    var distanceMiles: Double {
        distance * 0.000621371
    }
    
    var movingTimeFormatted: String {
        formatTime(moving_time)
    }
    
    var elapsedTimeFormatted: String {
        formatTime(elapsed_time)
    }
    
    var stoppageTime: Int {
        elapsed_time - moving_time
    }
    
    var stoppageTimeFormatted: String {
        formatTime(stoppageTime)
    }
    
    var pacePerMile: String {
        guard distanceMiles > 0 else { return "N/A" }
        let minutesPerMile = Double(moving_time) / 60.0 / distanceMiles
        let minutes = Int(minutesPerMile)
        let seconds = Int((minutesPerMile - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}

// Photo model
struct StravaPhoto: Codable, Identifiable {
    let unique_id: String?
    let media_type: Int?
    let source: Int?
    let urls: PhotoUrls
    
    var id: String {
        unique_id ?? UUID().uuidString
    }
    
    struct PhotoUrls: Codable {
        let url_100: String?
        let url_600: String?
        
        enum CodingKeys: String, CodingKey {
            case url_100 = "100"
            case url_600 = "600"
        }
    }
}

// Segment effort model
struct SegmentEffort: Codable, Identifiable {
    let id: Int
    let name: String
    let elapsed_time: Int
    let moving_time: Int
    let distance: Double
    let pr_rank: Int?
    let achievements: [Achievement]?
    let kom_rank: Int?
    let segment: SegmentDetail?
    
    struct Achievement: Codable {
        let type: String
        let type_id: Int
    }
    
    struct SegmentDetail: Codable {
        let id: Int
        let name: String
        let activity_type: String
        let distance: Double
        let average_grade: Double
        let maximum_grade: Double
        let elevation_high: Double
        let elevation_low: Double
    }
    
    var isLocalLegend: Bool {
        achievements?.contains(where: { $0.type == "segment_effort_count_leader" }) ?? false
    }
    
    var isPR: Bool {
        pr_rank != nil
    }
}
