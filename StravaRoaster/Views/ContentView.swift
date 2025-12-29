import SwiftUI

struct ContentView: View {
    @StateObject private var stravaService = StravaService()
    @State private var showingAuth = false
    
    var body: some View {
        if stravaService.isAuthenticated {
            MainTabView(stravaService: stravaService)
        } else {
            NavigationView {
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "flame.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 140)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.roastOrange, .roastRed],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Get Roasted")
                            .font(.system(size: 42, weight: .bold))
                        
                        Text("Get the truth your Strava friends\nare too afraid to tell you")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Button {
                            showingAuth = true
                        } label: {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                Text("Connect with Strava")
                                    .bold()
                            }
                        }
                        .roastButtonStyle()
                        
                        Text("Your data stays private")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
                .background(Color.backgroundGray.ignoresSafeArea())
                .sheet(isPresented: $showingAuth) {
                    StravaAuthView(stravaService: stravaService, isPresented: $showingAuth)
                }
            }
        }
    }
}
