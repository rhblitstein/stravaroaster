import Foundation
import Combine

class StravaService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var accessToken: String?
    
    func getAuthorizationURL() -> URL? {
        var components = URLComponents(string: "https://www.strava.com/oauth/mobile/authorize")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: Config.stravaClientID),
            URLQueryItem(name: "redirect_uri", value: Config.stravaRedirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "approval_prompt", value: "auto"),
            URLQueryItem(name: "scope", value: "read,activity:read_all")
        ]
        return components?.url
    }
    
    func exchangeToken(code: String) async throws {
        let url = URL(string: "https://www.strava.com/oauth/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "client_id": Config.stravaClientID,
            "client_secret": Config.stravaClientSecret,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(TokenResponse.self, from: data)
        
        await MainActor.run {
            self.accessToken = response.access_token
            self.isAuthenticated = true
        }
    }
    
    func fetchActivities() async throws -> [StravaActivity] {
        guard let token = accessToken else {
            throw StravaError.notAuthenticated
        }
        
        var components = URLComponents(string: "https://www.strava.com/api/v3/athlete/activities")!
        components.queryItems = [
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let activities = try JSONDecoder().decode([StravaActivity].self, from: data)
        
        return activities
    }
    
    func fetchActivityDetail(id: Int) async throws -> StravaActivity {
        guard let token = accessToken else {
            throw StravaError.notAuthenticated
        }
        
        let url = URL(string: "https://www.strava.com/api/v3/activities/\(id)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let activity = try JSONDecoder().decode(StravaActivity.self, from: data)
        
        return activity
    }
    
    func logout() {
        accessToken = nil
        isAuthenticated = false
    }
}

struct TokenResponse: Codable {
    let access_token: String
    let refresh_token: String
    let expires_at: Int
}

enum StravaError: Error {
    case notAuthenticated
}
