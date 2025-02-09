import SwiftUI

@available(iOS 16.0, *)
struct SettingsView: View {
    @AppStorage("darkMode") private var isDarkMode = false
    @AppStorage("fontSize") private var fontSize: Double = 16
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("enableOfflineReading") private var enableOfflineReading = true
    @State private var showClearCacheAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                    
                    VStack(alignment: .leading) {
                        Text("Font Size: \(Int(fontSize))")
                        Slider(value: $fontSize, in: 12...24, step: 1)
                    }
                }
                
                Section(header: Text("Features")) {
                    Toggle("Push Notifications", isOn: $enableNotifications)
                    Toggle("Offline Reading", isOn: $enableOfflineReading)
                }
                
                Section(header: Text("Storage")) {
                    Button(action: { showClearCacheAlert = true }) {
                        HStack {
                            Text("Clear Cache")
                            Spacer()
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Clear Cache", isPresent: $showClearCacheAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearCache()
                }
            } message: {
                Text("This will clear all cached data. Are you sure?")
            }
        }
    }
    
    private func clearCache() {
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: Date(timeIntervalSince1970: 0)
        ) {
            // Cache cleared
        }
    }
}

@available(iOS 16.0, *)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
