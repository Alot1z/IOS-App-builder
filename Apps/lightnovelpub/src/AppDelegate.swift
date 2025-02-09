import UIKit
import WebKit
import UserNotifications
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var mainViewController: MainViewController?
    
    // Root/Jailbreak detection
    private var isRootAvailable: Bool {
        if #available(iOS 16.0, *) {
            // Check for root/jailbreak on iOS 16+
            let rootPath = Bundle.main.path(forResource: "giveMeRoot", ofType: "m", inDirectory: "root")
            let exploitPath = Bundle.main.path(forResource: "exploit", ofType: nil, inDirectory: "exploits")
            return rootPath != nil && exploitPath != nil
        }
        return false
    }
    
    private var isJailbroken: Bool {
        // Common jailbreak paths
        let paths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]
        
        // Check for jailbreak paths
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        // Check for app sandbox violation
        let stringToWrite = "Jailbreak Test"
        do {
            try stringToWrite.write(toFile: "/private/jailbreak.txt", atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: "/private/jailbreak.txt")
            return true
        } catch {
            return false
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Create and set main view controller
        mainViewController = MainViewController()
        
        // Configure root features if available
        if isRootAvailable {
            print("Root features available")
            configureRootFeatures()
        }
        
        // Check for jailbreak
        if isJailbroken {
            print("Device is jailbroken")
            configureJailbreakFeatures()
        }
        
        let navigationController = UINavigationController(rootViewController: mainViewController!)
        
        // Configure navigation bar
        if #available(iOS 16.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
            navigationController.navigationItem.preferredSearchBarPlacement = .stacked
        } else {
            // Fallback for older iOS versions
            navigationController.navigationBar.prefersLargeTitles = false
        }
        
        window?.rootViewController = navigationController
        
        // Configure appearance
        configureAppearance()
        
        // Request notification permissions
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermissions()
        
        // Show window
        window?.makeKeyAndVisible()
        return true
    }
    
    private func configureRootFeatures() {
        if #available(iOS 16.0, *) {
            // Load root helper
            if let rootPath = Bundle.main.path(forResource: "giveMeRoot", ofType: "m", inDirectory: "root") {
                // Initialize root functionality
                print("Initializing root features from: \(rootPath)")
                // Root features will be enabled when needed
            }
            
            // Load exploit
            if let exploitPath = Bundle.main.path(forResource: "exploit", ofType: nil, inDirectory: "exploits") {
                print("Exploit available at: \(exploitPath)")
                // Exploit will be used when needed
            }
        }
    }
    
    private func configureJailbreakFeatures() {
        // Enable additional features for jailbroken devices
        print("Configuring jailbreak features")
        // These features will be available regardless of iOS version
    }
    
    private func configureAppearance() {
        if #available(iOS 16.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            // Support for dynamic type
            appearance.titleTextAttributes[.font] = UIFont.preferredFont(forTextStyle: .headline)
            appearance.largeTitleTextAttributes[.font] = UIFont.preferredFont(forTextStyle: .largeTitle)
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            // Fallback appearance for older iOS versions
            UINavigationBar.appearance().barTintColor = .systemBackground
            UINavigationBar.appearance().tintColor = .systemBlue
        }
    }
    
    private func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let urlString = response.notification.request.content.userInfo["url"] as? String,
           let url = URL(string: urlString) {
            mainViewController?.loadURL(url)
        }
        completionHandler()
    }
    
    // MARK: - Push Notification Handling
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        UserDefaults.standard.set(token, forKey: "pushToken")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error)")
    }
    
    // MARK: - iOS 16+ Specific Features
    
    @available(iOS 16.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Configure window scene
        if #available(iOS 17.0, *) {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .all))
            windowScene.keyWindow?.windowLevel = .normal
        }
    }
}
