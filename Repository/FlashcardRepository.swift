import Foundation

final class FlashcardRepository {
    private let api: KairoAPI

    init(api: KairoAPI) {
        self.api = api
    }

    func getDueCards(userId: String) async throws -> [Flashcard] {
        try await api.getDueFlashcards(userId: userId)
    }

    func reviewCard(cardId: String, grade: Int) async throws -> FlashcardReviewResponse {
        try await api.reviewFlashcard(cardId: cardId, grade: grade)
    }
}
