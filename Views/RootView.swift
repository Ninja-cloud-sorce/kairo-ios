import SwiftUI

private enum RootRoute {
    case splash
    case login
    case onboarding
    case main
}

struct RootView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var route: RootRoute = .splash

    var body: some View {
        ZStack {
            KairoColor.background.ignoresSafeArea()

            switch route {
            case .splash:
                ProgressView()
                    .tint(KairoColor.accent)
                    .task { await resolveInitialRoute() }

            case .login:
                LoginView(authRepository: env.authRepository) {
                    await resolveInitialRoute()
                }

            case .onboarding:
                OnboardingView(
                    lessonRepository: env.lessonRepository,
                    authRepository: env.authRepository,
                    userPreferences: env.userPreferences,
                    onComplete: { route = .main }
                )

            case .main:
                MainTabView()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func resolveInitialRoute() async {
        if env.authRepository.isLoggedIn() {
            route = env.userPreferences.isOnboardingDone ? .main : .onboarding
        } else {
            route = .login
        }
    }
}
