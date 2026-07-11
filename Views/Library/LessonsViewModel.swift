import Foundation

enum LessonsUiState {
    case loading
    case success([Lesson])
    case error(String)
}

@MainActor
final class LessonsViewModel: ObservableObject {
    @Published var uiState: LessonsUiState = .loading

    private let collectionRepository: CollectionRepository
    private let authRepository: AuthRepository
    private let collectionId: String

    init(
        collectionRepository: CollectionRepository,
        authRepository: AuthRepository,
        collectionId: String
    ) {
        self.collectionRepository = collectionRepository
        self.authRepository = authRepository
        self.collectionId = collectionId
        load()
    }

    func load() {
        guard let userId = authRepository.currentUserId() else { return }
        Task {
            uiState = .loading
            do {
                let lessons = try await collectionRepository.getLessons(collectionId: collectionId, userId: userId)
                uiState = .success(lessons)
            } catch {
                uiState = .error(error.localizedDescription)
            }
        }
    }
}
