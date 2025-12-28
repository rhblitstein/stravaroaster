import Foundation

class MockRoastService {
    
    enum RoastSeverity: String, CaseIterable {
        case mild = "MILD"
        case spicy = "SPICY"
        case caliente = "CALIENTE"
        case ghostPepper = "🌶️🌶️🌶️"
    }
    
    func generateRoast(for activity: StravaActivity, severity: RoastSeverity) async throws -> String {
        // Simulate API delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Mock roasts based on severity
        let roasts: [String] = {
            switch severity {
            case .mild:
                return [
                    "Nice job on \"\(activity.name)\"! That \(activity.pacePerMile) pace is... well, it's a pace. At least you got out there!",
                    "Look at you, racking up \(activity.kudos_count) whole kudos! The people love mediocrity.",
                    "\(String(format: "%.1f", activity.distanceMiles)) miles of pure determination. Or stubbornness. Hard to tell."
                ]
            case .spicy:
                return [
                    "'\(activity.name)' - did you come up with that title before or after the run knocked the creativity out of you?",
                    "\(activity.kudos_count) kudos for a \(activity.pacePerMile) pace? Your friends are very generous.",
                    "You stopped \(activity.photo_count ?? 0) times for photos on a \(String(format: "%.1f", activity.distanceMiles)) mile run. We call that 'hiking with extra steps.'"
                ]
            case .caliente:
                return [
                    "A \(activity.pacePerMile) pace? My grandma power-walks faster than that, and she's been dead for three years.",
                    "\(activity.kudos_count) people felt bad enough to give you kudos. That's called pity, not support.",
                    "You titled it '\(activity.name)' and then proceeded to embarrass that title for \(activity.movingTimeFormatted). Impressive commitment to mediocrity."
                ]
            case .ghostPepper:
                return [
                    "This isn't running, this is aggressive walking with delusions of grandeur. \(activity.pacePerMile) per mile? Are you okay?",
                    "\(activity.kudos_count) kudos. Even your mom couldn't be bothered. Maybe she saw the \(activity.pacePerMile) pace and felt secondhand embarrassment.",
                    "You covered \(String(format: "%.1f", activity.distanceMiles)) miles in \(activity.movingTimeFormatted). Congratulations on completing what most people do as a warm-up. Slowly."
                ]
            }
        }()
        
        return roasts.randomElement()!
    }
}
