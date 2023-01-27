import Foundation
import APIClient
import Common

@MainActor
class LoginViewModel: ObservableObject {
    
    @Published var error: UserFacingError? = nil {
        didSet {
            showError = error != nil
        }
    }
    @Published var showError = false
    @Published var isLoading = false
    
    func login(username: String, password: String, rememberMe: Bool) async {
        isLoading = true
        let response = await LoginServiceFactory.shared.login(username: username, password: password, rememberMe: rememberMe)

        switch response {
        case .failure(let error):
            isLoading = false
            self.error = error
        default:
            isLoading = false
            return
        }
    }
}
