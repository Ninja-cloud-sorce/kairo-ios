import Foundation
import Supabase

final class AuthRepository {
    private let supabase: SupabaseClient

    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    func signIn(email: String, password: String) async throws {
        try await supabase.auth.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await supabase.auth.signUp(email: email, password: password)
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
    }

    func currentUserId() -> String? {
        supabase.auth.currentUser?.id.uuidString
    }

    func isLoggedIn() -> Bool {
        supabase.auth.currentSession != nil
    }

    func getAccessToken() -> String? {
        supabase.auth.currentSession?.accessToken
    }
}
