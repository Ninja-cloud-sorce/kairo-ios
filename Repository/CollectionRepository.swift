import Foundation

final class CollectionRepository {
    private let api: KairoAPI

    init(api: KairoAPI) {
        self.api = api
    }

    func getCollections(userId: String) async throws -> [StudyCollection] {
        try await api.getCollections(userId: userId)
    }

    func getLessons(collectionId: String, userId: String) async throws -> [Lesson] {
        try await api.getLessons(collectionId: collectionId, userId: userId)
    }
}
