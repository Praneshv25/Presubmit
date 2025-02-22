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
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "doc.text.viewfinder") // SF Symbol for document scanning
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)

                    Text("PRESUBMIT")
                        .font(.system(size: 50, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Your Digital Proofreader for Physical Documents.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .italic()
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding([.leading, .bottom, .trailing], 20)
                }
                
                
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
                
                Spacer(minLength: 30)
                
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
                CameraView()
            }
        }
    }
}

#Preview {
    LoginView()
}
