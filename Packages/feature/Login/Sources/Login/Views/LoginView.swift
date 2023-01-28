import Foundation
import SwiftUI
import Common

public struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var rememberMe = false

    public init() { }

    public var body: some View {
        VStack {
            Spacer()

            Text("Welcome to Artemis!")
                .font(.system(size: 35, weight: .bold))
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            Text("Please login with your TUM login credentials.")
                .font(.system(size: 25))
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                Toggle("Automatic login", isOn: $rememberMe)
                    .toggleStyle(.switch)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 40)

            Button("Login", action: {
                Task {
                    await viewModel.login(username: username, password: password, rememberMe: rememberMe)
                }
            })
            .frame(maxWidth: .infinity)
            .disabled(username.isEmpty || password.isEmpty)
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .loadingIndicator(isLoading: $viewModel.isLoading)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(viewModel.error?.description ?? "Login failed", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {
                viewModel.error = nil
            }
        }
    }
}
