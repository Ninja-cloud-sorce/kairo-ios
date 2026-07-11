import Foundation

enum AuthState {
    case idle
    case loading
    case success
    case error(String)
}

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var state: AuthState = .idle

    private let repo: AuthRepository

    init(repo: AuthRepository) {
        self.repo = repo
    }

    func signIn(email: String, password: String) {
        Task {
            state = .loading
            do {
                try await repo.signIn(email: email, password: password)
                state = .success
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func signUp(email: String, password: String) {
        Task {
            state = .loading
            do {
                try await repo.signUp(email: email, password: password)
                state = .success
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func resetState() { state = .idle }
}
