import SwiftUI
import FirebaseCore
import FirebaseAuth
import Firebase
import UIKit
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate { // Remove GIDToken - it's not needed here

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        GIDSignIn.sharedInstance.restorePreviousSignIn { result, error in
            if error != nil {
                // Handle error or simply proceed as a new sign-in flow will happen later
                print("Error restoring previous sign-in: \(error?.localizedDescription ?? "Unknown error")")
            } else {
                // User already signed in previously, you can update your UI accordingly
                guard let user = result else { return }
                print("User restored from previous sign-in: \(user.profile?.name ?? "User")")
                // You might want to notify your app state here that a user is already signed in.
            }
        }

        return true
    }

    // Handle URL callback for Google Sign-in
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct PresubmitApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
