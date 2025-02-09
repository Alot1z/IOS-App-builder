import UIKit
import WebKit
import UserNotifications
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var mainViewController: MainViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Create and set main view controller
        mainViewController = MainViewController()
        let navigationController = UINavigationController(rootViewController: mainViewController!)
        
        // Configure navigation bar for iOS 16+
        if #available(iOS 16.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
            navigationController.navigationItem.preferredSearchBarPlacement = .stacked
        }
        
        window?.rootViewController = navigationController
        
        // Configure appearance
        configureAppearance()
        
        // Request notification permissions with iOS 16+ features
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermissions()
        
        // Show window
        window?.makeKeyAndVisible()
        return true
    }
    
    private func configureAppearance() {
        // Navigation bar appearance for iOS 16+
        if #available(iOS 16.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            // Support for dynamic type
            appearance.titleTextAttributes[.font] = UIFont.preferredFont(forTextStyle: .headline)
            appearance.largeTitleTextAttributes[.font] = UIFont.preferredFont(forTextStyle: .largeTitle)
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            
            // iOS 16+ specific customization
            if let windowScene = window?.windowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .all))
            }
        }
        
        // Status bar style with iOS 16+ support
        if #available(iOS 16.0, *) {
            window?.overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: "darkMode") ? .dark : .light
            window?.windowScene?.keyWindow?.insetsLayoutMarginsFromSafeArea = true
        }
    }
    
    private func requestNotificationPermissions() {
        if #available(iOS 16.0, *) {
            // Request time sensitive notification permissions for iOS 16+
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge, .timeSensitive]
            ) { granted, error in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                if let error = error {
                    print("Error requesting notification permissions: \(error)")
                }
            }
        } else {
            // Fallback for earlier iOS versions
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            ) { granted, error in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                if let error = error {
                    print("Error requesting notification permissions: \(error)")
                }
            }
        }
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 16.0, *) {
            completionHandler([.banner, .sound, .badge, .list])
        } else {
            completionHandler([.banner, .sound, .badge])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let urlString = response.notification.request.content.userInfo["url"] as? String,
           let url = URL(string: urlString) {
            mainViewController?.loadURL(url)
        }
        completionHandler()
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
