import Foundation

enum LibraryUiState {
    case loading
    case success([StudyCollection])
    case error(String)
}

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var uiState: LibraryUiState = .loading

    private let collectionRepository: CollectionRepository
    private let authRepository: AuthRepository

    init(collectionRepository: CollectionRepository, authRepository: AuthRepository) {
        self.collectionRepository = collectionRepository
        self.authRepository = authRepository
        load()
    }

    func load() {
        guard let userId = authRepository.currentUserId() else { return }
        Task {
            uiState = .loading
            do {
                let collections = try await collectionRepository.getCollections(userId: userId)
                uiState = .success(collections)
            } catch {
                uiState = .error(error.localizedDescription)
            }
        }
    }
}
