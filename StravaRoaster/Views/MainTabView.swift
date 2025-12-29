import SwiftUI

struct MainTabView: View {
    @ObservedObject var stravaService: StravaService
    
    var body: some View {
        TabView {
            ActivitiesView(stravaService: stravaService)
                .tabItem {
                    Label("Activities", systemImage: "figure.run")
                }
            
            YouView(stravaService: stravaService)
                .tabItem {
                    Label("You", systemImage: "person.fill")
                }
        }
        .accentColor(.roastOrange)
    }
}
