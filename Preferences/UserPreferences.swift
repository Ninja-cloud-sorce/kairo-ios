import Foundation

final class UserPreferences {
    private let defaults = UserDefaults.standard
    private let onboardingKey = "onboarding_done"
    private let levelKey = "selected_level"

    var isOnboardingDone: Bool {
        defaults.bool(forKey: onboardingKey)
    }

    var selectedLevel: String? {
        defaults.string(forKey: levelKey)
    }

    func setOnboardingDone(level: String) {
        defaults.set(true, forKey: onboardingKey)
        defaults.set(level, forKey: levelKey)
    }

    func clear() {
        defaults.removeObject(forKey: onboardingKey)
        defaults.removeObject(forKey: levelKey)
    }
}
