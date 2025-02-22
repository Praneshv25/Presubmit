//
//  LoginView.swift
//  Presubmit
//
//  Created by Daniel Wu on 2/22/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 20) {
                Text("Welcome")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.bottom, 40)
                
                Button(action: { viewModel.signInWithGoogle() }) {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.white)
                        Text("Sign in with Google")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isLoading)
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
            .navigationDestination(isPresented: $viewModel.isAuthenticated) {
                CameraView(loginViewModel: self.viewModel)
            }
        }
    }
}

#Preview {
    LoginView()
}
