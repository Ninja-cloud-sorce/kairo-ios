import Foundation

enum FlashcardUiState {
    case loading
    case reviewing(cards: [Flashcard], currentIndex: Int, isFlipped: Bool)
    case done
    case error(String)
}

@MainActor
final class FlashcardViewModel: ObservableObject {
    @Published var uiState: FlashcardUiState = .loading

    private let flashcardRepository: FlashcardRepository
    private let authRepository: AuthRepository

    init(flashcardRepository: FlashcardRepository, authRepository: AuthRepository) {
        self.flashcardRepository = flashcardRepository
        self.authRepository = authRepository
        load()
    }

    func load() {
        guard let userId = authRepository.currentUserId() else { return }
        Task {
            uiState = .loading
            do {
                let cards = try await flashcardRepository.getDueCards(userId: userId)
                uiState = cards.isEmpty ? .done : .reviewing(cards: cards, currentIndex: 0, isFlipped: false)
            } catch {
                uiState = .error(error.localizedDescription)
            }
        }
    }

    func flip() {
        guard case .reviewing(let cards, let index, let flipped) = uiState else { return }
        uiState = .reviewing(cards: cards, currentIndex: index, isFlipped: !flipped)
    }

    func grade(_ grade: Int) {
        guard case .reviewing(let cards, let index, _) = uiState else { return }
        let card = cards[index]
        Task {
            _ = try? await flashcardRepository.reviewCard(cardId: card.id, grade: grade)
            let nextIndex = index + 1
            uiState = nextIndex >= cards.count
                ? .done
                : .reviewing(cards: cards, currentIndex: nextIndex, isFlipped: false)
        }
    }
}
