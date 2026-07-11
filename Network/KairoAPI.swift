import Foundation
import Supabase

final class KairoAPI {
    private let baseURL: URL
    private let supabase: SupabaseClient
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(baseURL: URL, supabase: SupabaseClient) {
        self.baseURL = baseURL
        self.supabase = supabase
    }

    // MARK: - Private helpers

    private func makeURL(_ path: String, queryItems: [URLQueryItem] = []) -> URL {
        var comps = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !queryItems.isEmpty { comps.queryItems = queryItems }
        return comps.url!
    }

    private func authorizedRequest(url: URL, method: String, body: Data? = nil) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body
        if let token = supabase.auth.currentSession?.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return req
    }

    private func fetch<T: Decodable>(_ req: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(T.self, from: data)
    }

    private func fetchVoid(_ req: URLRequest) async throws {
        let (_, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Profile

    func getProfile(userId: String) async throws -> Profile {
        let req = authorizedRequest(url: makeURL("api/profiles/\(userId)"), method: "GET")
        return try await fetch(req)
    }

    // MARK: - Level

    func setLevelOverride(userId: String, level: String) async throws {
        let body = try encoder.encode(LevelOverrideRequest(level: level))
        let req = authorizedRequest(url: makeURL("api/level-overrides/\(userId)"), method: "PUT", body: body)
        try await fetchVoid(req)
    }

    // MARK: - Lessons

    func getLessonCatalog(level: String) async throws -> [Lesson] {
        let req = authorizedRequest(
            url: makeURL("api/lessons/catalog", queryItems: [URLQueryItem(name: "level", value: level)]),
            method: "GET"
        )
        return try await fetch(req)
    }

    func getLessons(collectionId: String, userId: String) async throws -> [Lesson] {
        let req = authorizedRequest(
            url: makeURL("api/lessons", queryItems: [
                URLQueryItem(name: "collectionId", value: collectionId),
                URLQueryItem(name: "userId", value: userId)
            ]),
            method: "GET"
        )
        return try await fetch(req)
    }

    func getLessonDetail(lessonId: String) async throws -> LessonDetail {
        let req = authorizedRequest(url: makeURL("api/lessons/\(lessonId)"), method: "GET")
        return try await fetch(req)
    }

    func completeLesson(_ request: CompleteLessonRequest) async throws -> CompleteLessonResponse {
        let body = try encoder.encode(request)
        let req = authorizedRequest(url: makeURL("api/complete-lesson"), method: "POST", body: body)
        return try await fetch(req)
    }

    // MARK: - Collections

    func getCollections(userId: String) async throws -> [StudyCollection] {
        let req = authorizedRequest(
            url: makeURL("api/collections", queryItems: [URLQueryItem(name: "userId", value: userId)]),
            method: "GET"
        )
        return try await fetch(req)
    }

    // MARK: - Flashcards

    func getDueFlashcards(userId: String) async throws -> [Flashcard] {
        let req = authorizedRequest(url: makeURL("api/flashcards/\(userId)/due"), method: "GET")
        return try await fetch(req)
    }

    func reviewFlashcard(cardId: String, grade: Int) async throws -> FlashcardReviewResponse {
        let body = try encoder.encode(FlashcardReviewRequest(grade: grade))
        let req = authorizedRequest(url: makeURL("api/flashcards/\(cardId)/review"), method: "POST", body: body)
        return try await fetch(req)
    }
}
