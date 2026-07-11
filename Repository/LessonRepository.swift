import Foundation

final class LessonRepository {
    private let api: KairoAPI

    init(api: KairoAPI) {
        self.api = api
    }

    func getCatalog(level: String) async throws -> [Lesson] {
        try await api.getLessonCatalog(level: level)
    }

    func getLessonDetail(lessonId: String) async throws -> LessonDetail {
        try await api.getLessonDetail(lessonId: lessonId)
    }

    func setLevelOverride(userId: String, level: String) async throws {
        try await api.setLevelOverride(userId: userId, level: level)
    }

    func completeLesson(_ request: CompleteLessonRequest) async throws -> CompleteLessonResponse {
        try await api.completeLesson(request)
    }
}
