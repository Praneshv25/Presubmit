//
//  LoginViewModel.swift
//  Presubmit
//
//  Created by Daniel Wu on 2/22/25.
//

import Foundation
import SwiftUI
import GoogleSignIn
import FirebaseAuth
import Firebase

class LoginViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var userToken: String?
    
    func signInWithGoogle() {
        isLoading = true
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Unable to get client ID"
            isLoading = false
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            errorMessage = "Unable to get root view controller"
            isLoading = false
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self?.errorMessage = "Unable to get user data"
                self?.isLoading = false
                return
            }
            
            // Obtain user access token
            self?.userToken = user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { [weak self] result, error in
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                // Successfully signed in
                print("Successfully signed in with Google")
                self?.isAuthenticated = true
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        DispatchQueue.main.async {
            self.isAuthenticated = false
            print("User signed out successfully")
        }
    }
}
