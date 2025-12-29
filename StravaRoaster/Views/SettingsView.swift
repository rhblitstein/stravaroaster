import SwiftUI

struct SettingsView: View {
    @ObservedObject var stravaService: StravaService
    @Environment(\.dismiss) var dismiss
    @State private var showingLogoutAlert = false
    
    @AppStorage("defaultSpiceLevel") private var defaultSpiceLevel = "Spicy"
    @AppStorage("runSpiceLevel") private var runSpiceLevel = "Spicy"
    @AppStorage("rideSpiceLevel") private var rideSpiceLevel = "Spicy"
    @AppStorage("swimSpiceLevel") private var swimSpiceLevel = "Spicy"
    @AppStorage("hikeSpiceLevel") private var hikeSpiceLevel = "Spicy"
    @AppStorage("autoPostRoasts") private var autoPostRoasts = false
    
    let spiceLevels = ["Mild", "Spicy", "Caliente", "🌶️🌶️🌶️"]
    
    var body: some View {
        NavigationView {
            List {
                Section("Roast Preferences") {
                    Picker("Default Spice Level", selection: $defaultSpiceLevel) {
                        ForEach(spiceLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    
                    Picker("Run", selection: $runSpiceLevel) {
                        ForEach(spiceLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    
                    Picker("Ride", selection: $rideSpiceLevel) {
                        ForEach(spiceLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    
                    Picker("Swim", selection: $swimSpiceLevel) {
                        ForEach(spiceLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    
                    Picker("Hike", selection: $hikeSpiceLevel) {
                        ForEach(spiceLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                }
                
                Section {
                    Toggle("Auto-post roasts to Strava", isOn: $autoPostRoasts)
                } header: {
                    Text("Strava Integration")
                } footer: {
                    Text("When enabled, roasts will be automatically added to your activity descriptions on Strava.")
                }
                
                Section("Account") {
                    Button(role: .destructive) {
                        showingLogoutAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Logout")
                                .bold()
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Can't handle the heat?", isPresented: $showingLogoutAlert) {
                Button("I can handle it!", role: .cancel) { }
                Button("Get out of the kitchen", role: .destructive) {
                    stravaService.logout()
                    dismiss()
                }
            } message: {
                Text("Logging out will end your roasting session.")
            }
        }
    }
}
