import Foundation

class RoastService {
    
    enum RoastSeverity: String, CaseIterable {
        case mild = "MILD"
        case spicy = "SPICY"
        case caliente = "CALIENTE"
        case ghostPepper = "GHOST PEPPER"
        
        var systemPrompt: String {
            switch self {
            case .mild:
                return "You're a supportive running coach who gently ribs athletes about their activities. Be encouraging but point out funny inconsistencies. Keep it light and friendly."
            case .spicy:
                return "You're a sarcastic friend who loves to roast people's Strava activities. Be funny and take the piss, but keep it good-natured."
            case .caliente:
                return "You're brutally honest about people's athletic performance. Roast them hard on their stats, titles, and effort. Be mean but hilarious."
            case .ghostPepper:
                return "You're absolutely savage. Destroy their ego. No survivors. Make them question why they even run. Be ruthless and hilarious."
            }
        }
    }
    
    func generateRoast(for activity: StravaActivity, severity: RoastSeverity) async throws -> String {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Config.anthropicAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        let activityContext = """
        Activity: \(activity.name)
        Type: \(activity.type)
        Distance: \(String(format: "%.2f", activity.distanceMiles)) miles
        Time: \(activity.movingTimeFormatted)
        Pace: \(activity.pacePerMile) per mile
        Elevation: \(Int(activity.total_elevation_gain)) meters
        Kudos: \(activity.kudos_count)
        Photos: \(activity.photo_count ?? 0)
        """
        
        let requestBody: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 1000,
            "system": severity.systemPrompt,
            "messages": [
                [
                    "role": "user",
                    "content": "Roast this Strava activity in 2-3 sentences:\n\n\(activityContext)"
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Print raw response for debugging
        if let httpResponse = response as? HTTPURLResponse {
            print("Status: \(httpResponse.statusCode)")
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Raw response: \(responseString)")
        }
        
        // Try to decode error first
        if let errorResponse = try? JSONDecoder().decode(AnthropicError.self, from: data) {
            throw RoastError.apiError(errorResponse.error.message)
        }
        
        // Then try normal response
        let apiResponse = try JSONDecoder().decode(AnthropicResponse.self, from: data)
        
        guard let textContent = apiResponse.content.first(where: { $0.type == "text" }) else {
            throw RoastError.noContent
        }
        
        return textContent.text
    }
}

// Response models
struct AnthropicResponse: Codable {
    let content: [ContentBlock]
}

struct ContentBlock: Codable {
    let type: String
    let text: String
}

enum RoastError: Error {
    case noContent
    case apiError(String)
}

struct AnthropicError: Codable {
    let error: ErrorDetail
}

struct ErrorDetail: Codable {
    let type: String
    let message: String
}
