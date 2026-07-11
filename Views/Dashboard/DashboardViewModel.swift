import Foundation

struct DashboardUiState {
    var profile: Profile? = nil
    var nextLesson: Lesson? = nil
    var isLoading = true
    var error: String? = nil
}

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var uiState = DashboardUiState()

    private let profileRepository: ProfileRepository
    private let lessonRepository: LessonRepository
    private let authRepository: AuthRepository

    init(
        profileRepository: ProfileRepository,
        lessonRepository: LessonRepository,
        authRepository: AuthRepository
    ) {
        self.profileRepository = profileRepository
        self.lessonRepository = lessonRepository
        self.authRepository = authRepository
        load()
    }

    func load() {
        guard let userId = authRepository.currentUserId() else { return }
        Task {
            uiState = DashboardUiState(isLoading: true, error: nil)
            do {
                let profile = try await profileRepository.fetchProfile(userId: userId)
                let lessons = try await lessonRepository.getCatalog(level: profile.currentLevel)
                let nextLesson = lessons.first { $0.status == "CURRENT" } ?? lessons.first
                uiState = DashboardUiState(profile: profile, nextLesson: nextLesson, isLoading: false)
            } catch {
                uiState = DashboardUiState(isLoading: false, error: error.localizedDescription)
            }
        }
    }
}
