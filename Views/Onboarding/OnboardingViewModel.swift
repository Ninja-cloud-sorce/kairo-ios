import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var selectedLevel: String? = nil
    @Published var isLoading = false
    @Published var error: String? = nil

    private let lessonRepository: LessonRepository
    private let authRepository: AuthRepository
    private let userPreferences: UserPreferences

    init(
        lessonRepository: LessonRepository,
        authRepository: AuthRepository,
        userPreferences: UserPreferences
    ) {
        self.lessonRepository = lessonRepository
        self.authRepository = authRepository
        self.userPreferences = userPreferences
    }

    func selectLevel(_ level: String) {
        selectedLevel = level
    }

    func confirmLevel(onComplete: @escaping () -> Void) {
        guard let level = selectedLevel, let userId = authRepository.currentUserId() else { return }
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try await lessonRepository.setLevelOverride(userId: userId, level: level)
                userPreferences.setOnboardingDone(level: level)
                onComplete()
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}
