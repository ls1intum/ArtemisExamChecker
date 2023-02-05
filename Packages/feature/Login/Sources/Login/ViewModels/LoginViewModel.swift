import Foundation
import APIClient
import Common
import UserStore
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var rememberMe = true

    @Published var error: UserFacingError? {
        didSet {
            showError = error != nil
        }
    }
    @Published var showError = false
    @Published var isLoading = false

    @Published var loginExpired = false

    private var cancellables: Set<AnyCancellable> = Set()

    init() {
        UserSession.shared.objectWillChange.sink {
            DispatchQueue.main.async { [weak self] in
                self?.username = UserSession.shared.username ?? ""
                self?.password = UserSession.shared.password ?? ""
                self?.rememberMe = UserSession.shared.rememberMe
                self?.loginExpired = UserSession.shared.tokenExpired
            }
        }.store(in: &cancellables)

        username = UserSession.shared.username ?? ""
        password = UserSession.shared.password ?? ""
        rememberMe = UserSession.shared.rememberMe
        loginExpired = UserSession.shared.tokenExpired
    }

    func login() async {
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

    func resetLoginExpired() {
        UserSession.shared.setTokenExpired(expired: false)
    }
}
