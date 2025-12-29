import Foundation

class RoastCache {
    private let defaults = UserDefaults.standard
    private let roastsKey = "cached_roasts"
    
    func getRoast(for activityId: Int, spiceLevel: String) -> String? {
        let key = "\(activityId)_\(spiceLevel)"
        guard let data = defaults.data(forKey: roastsKey),
              let roasts = try? JSONDecoder().decode([String: String].self, from: data) else {
            return nil
        }
        return roasts[key]
    }
    
    func saveRoast(_ roast: String, for activityId: Int, spiceLevel: String) {
        let key = "\(activityId)_\(spiceLevel)"
        var roasts: [String: String] = [:]
        
        if let data = defaults.data(forKey: roastsKey),
           let existing = try? JSONDecoder().decode([String: String].self, from: data) {
            roasts = existing
        }
        
        roasts[key] = roast
        
        if let encoded = try? JSONEncoder().encode(roasts) {
            defaults.set(encoded, forKey: roastsKey)
        }
    }
}
