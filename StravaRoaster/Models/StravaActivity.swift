import Foundation

struct StravaActivity: Codable, Identifiable {
    let id: Int
    let name: String
    let distance: Double
    let moving_time: Int
    let elapsed_time: Int
    let total_elevation_gain: Double
    let type: String
    let start_date: String
    let kudos_count: Int
    let photo_count: Int?
    let achievement_count: Int?
    let average_heartrate: Double?
    let description: String?
    
    let photos: PhotosSummary?
    let segment_efforts: [SegmentEffort]?
}

struct PhotosSummary: Codable {
    let primary: Photo?
    let count: Int?
}

struct Photo: Codable {
    let urls: PhotoURLs
}

struct PhotoURLs: Codable {
    let url_100: String?
    let url_600: String?
    
    enum CodingKeys: String, CodingKey {
        case url_100 = "100"
        case url_600 = "600"  
    }
}

struct SegmentEffort: Codable, Identifiable {
    let id: Int
    let name: String
    let elapsed_time: Int
    let moving_time: Int
    let start_date: String
    let achievements: [Achievement]?
    let kom_rank: Int?
    let pr_rank: Int?
    
    var isPR: Bool {
        pr_rank != nil && pr_rank! <= 3
    }
    
    var isLocalLegend: Bool {
        achievements?.contains { $0.type == "overall" && $0.rank == 1 } ?? false
    }
}

struct Achievement: Codable {
    let type: String
    let rank: Int?
}

extension StravaActivity {
    var distanceMiles: Double {
        distance / 1609.34
    }
    
    var pacePerMile: String {
        guard distanceMiles > 0 else { return "N/A" }
        let paceMinPerMile = Double(moving_time) / 60.0 / distanceMiles
        let minutes = Int(paceMinPerMile)
        let seconds = Int((paceMinPerMile - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var pacePerMileSeconds: Double {
        guard distanceMiles > 0 else { return Double.infinity }
        return Double(moving_time) / distanceMiles
    }
    
    var movingTimeFormatted: String {
        let hours = moving_time / 3600
        let minutes = (moving_time % 3600) / 60
        let seconds = moving_time % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var stoppageTime: Int {
        return elapsed_time - moving_time
    }
    
    var stoppageTimeFormatted: String {
        let minutes = stoppageTime / 60
        let seconds = stoppageTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
