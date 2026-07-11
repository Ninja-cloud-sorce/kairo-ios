import Foundation
import Supabase

final class AppEnvironment: ObservableObject {
    let supabase: SupabaseClient
    let userPreferences: UserPreferences
    let api: KairoAPI

    let authRepository: AuthRepository
    let profileRepository: ProfileRepository
    let collectionRepository: CollectionRepository
    let lessonRepository: LessonRepository
    let flashcardRepository: FlashcardRepository

    init() {
        supabase = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey
        )
        userPreferences = UserPreferences()
        api = KairoAPI(baseURL: URL(string: Config.apiBaseURL)!, supabase: supabase)

        authRepository = AuthRepository(supabase: supabase)
        profileRepository = ProfileRepository(api: api)
        collectionRepository = CollectionRepository(api: api)
        lessonRepository = LessonRepository(api: api)
        flashcardRepository = FlashcardRepository(api: api)
    }
}
