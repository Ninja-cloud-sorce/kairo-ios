import Foundation

final class ProfileRepository {
    private let api: KairoAPI
    private var cache: [String: Profile] = [:]

    init(api: KairoAPI) {
        self.api = api
    }

    func fetchProfile(userId: String) async throws -> Profile {
        let profile = try await api.getProfile(userId: userId)
        cache[userId] = profile
        return profile
    }

    func getCachedProfile(userId: String) -> Profile? {
        cache[userId]
    }
}
