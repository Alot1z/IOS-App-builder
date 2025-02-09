import SwiftUI
import WebKit
import Combine

@available(iOS 16.0, *)
struct SettingsView: View {
    @AppStorage("fontSize") private var fontSize: Double = 18
    @AppStorage("lineHeight") private var lineHeight: Double = 1.6
    @AppStorage("fontFamily") private var fontFamily: String = "-apple-system"
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("isNotificationsEnabled") private var isNotificationsEnabled: Bool = true
    @AppStorage("autoSaveEnabled") private var autoSaveEnabled: Bool = true
    @AppStorage("downloadPath") private var downloadPath: String = "Downloads"
    
    @State private var showResetAlert = false
    @State private var showClearCacheAlert = false
    @State private var showingDownloadPicker = false
    
    private let fontFamilies = [
        "-apple-system",
        "Helvetica Neue",
        "Arial",
        "Georgia",
        "Times New Roman"
    ]
    
    var body: some View {
        List {
            Section(header: Text("Reading Preferences")) {
                VStack(alignment: .leading) {
                    Text("Font Size: \(Int(fontSize))pt")
                    Slider(value: $fontSize, in: 12...24, step: 1)
                }
                
                VStack(alignment: .leading) {
                    Text("Line Height: \(String(format: "%.1f", lineHeight))")
                    Slider(value: $lineHeight, in: 1.0...2.0, step: 0.1)
                }
                
                Picker("Font Family", selection: $fontFamily) {
                    ForEach(fontFamilies, id: \.self) { font in
                        Text(font).tag(font)
                    }
                }
            }
            
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $isDarkMode)
                    .onChange(of: isDarkMode) { newValue in
                        updateAppearance(isDark: newValue)
                    }
            }
            
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: $isNotificationsEnabled)
                    .onChange(of: isNotificationsEnabled) { newValue in
                        updateNotificationSettings(enabled: newValue)
                    }
            }
            
            Section(header: Text("Storage")) {
                Toggle("Auto Save Progress", isOn: $autoSaveEnabled)
                
                HStack {
                    Text("Download Location")
                    Spacer()
                    Button(downloadPath) {
                        showingDownloadPicker = true
                    }
                }
                
                Button("Clear Cache") {
                    showClearCacheAlert = true
                }
                .foregroundColor(.red)
            }
            
            Section {
                Button("Reset All Settings") {
                    showResetAlert = true
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Settings")
        .alert("Reset Settings", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetSettings()
            }
        } message: {
            Text("Are you sure you want to reset all settings to default values?")
        }
        .alert("Clear Cache", isPresented: $showClearCacheAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearCache()
            }
        } message: {
            Text("This will clear all cached data. Continue?")
        }
        .sheet(isPresented: $showingDownloadPicker) {
            DocumentPicker(downloadPath: $downloadPath)
        }
    }
    
    private func updateAppearance(isDark: Bool) {
        // Update app appearance
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = isDark ? .dark : .light
            }
        }
        
        // Update WebView appearance
        NotificationCenter.default.post(name: .init("UpdateWebViewAppearance"), object: nil)
    }
    
    private func updateNotificationSettings(enabled: Bool) {
        if enabled {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                UIApplication.shared.unregisterForRemoteNotifications()
            }
        }
    }
    
    private func clearCache() {
        // Clear WKWebView cache
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: Date(timeIntervalSince1970: 0)
        ) {
            print("Cache cleared")
        }
        
        // Clear URLCache
        URLCache.shared.removeAllCachedResponses()
    }
    
    private func resetSettings() {
        fontSize = 18
        lineHeight = 1.6
        fontFamily = "-apple-system"
        isDarkMode = false
        isNotificationsEnabled = true
        autoSaveEnabled = true
        downloadPath = "Downloads"
        
        // Clear all cached data
        clearCache()
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var downloadPath: String
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.downloadPath = url.lastPathComponent
        }
    }
}

@available(iOS 16.0, *)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
