import SwiftUI

struct DashboardView: View {
    @StateObject private var vm: DashboardViewModel

    let onNavigateToLesson: (String, String) -> Void
    let onNavigateToLibrary: () -> Void
    let onNavigateToFlashcards: () -> Void

    init(
        profileRepository: ProfileRepository,
        lessonRepository: LessonRepository,
        authRepository: AuthRepository,
        onNavigateToLesson: @escaping (String, String) -> Void,
        onNavigateToLibrary: @escaping () -> Void,
        onNavigateToFlashcards: @escaping () -> Void
    ) {
        _vm = StateObject(wrappedValue: DashboardViewModel(
            profileRepository: profileRepository,
            lessonRepository: lessonRepository,
            authRepository: authRepository
        ))
        self.onNavigateToLesson = onNavigateToLesson
        self.onNavigateToLibrary = onNavigateToLibrary
        self.onNavigateToFlashcards = onNavigateToFlashcards
    }

    var body: some View {
        ZStack {
            KairoColor.background.ignoresSafeArea()

            if uiState.isLoading {
                ProgressView().tint(KairoColor.accent)
            } else if let error = uiState.error {
                ErrorStateView(message: error, onRetry: { vm.load() })
            } else if let profile = uiState.profile {
                DashboardContent(
                    profile: profile,
                    nextLesson: uiState.nextLesson,
                    onNavigateToLesson: onNavigateToLesson,
                    onNavigateToLibrary: onNavigateToLibrary,
                    onNavigateToFlashcards: onNavigateToFlashcards
                )
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }

    private var uiState: DashboardUiState { vm.uiState }
}

private struct DashboardContent: View {
    let profile: Profile
    let nextLesson: Lesson?
    let onNavigateToLesson: (String, String) -> Void
    let onNavigateToLibrary: () -> Void
    let onNavigateToFlashcards: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Greeting row
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("おはよう!")
                            .font(.subheadline)
                            .foregroundColor(KairoColor.textMuted)
                        Text(profile.displayName)
                            .font(.title2.bold())
                            .foregroundColor(KairoColor.text)
                    }
                    Spacer()
                    LevelBadge(level: profile.currentLevel)
                }

                // Stats row
                HStack(spacing: 12) {
                    StatCard(label: "⚡ XP",      value: "\(profile.xp)")
                    StatCard(label: "🔥 Streak",  value: "\(profile.streak)d")
                    StatCard(label: "📊 Score",   value: "\(profile.readinessScore)%")
                }

                // Continue card
                if let lesson = nextLesson {
                    Button {
                        onNavigateToLesson(lesson.id, "N5")
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Continue Learning")
                                .font(.caption.bold())
                                .foregroundColor(KairoColor.accentSoft)
                            Text(lesson.title)
                                .font(.title3.bold())
                                .foregroundColor(KairoColor.text)
                            Text(lesson.subtitle)
                                .font(.subheadline)
                                .foregroundColor(KairoColor.accentSoft)
                            Spacer().frame(height: 4)
                            Text("▶ Resume →")
                                .font(.subheadline.bold())
                                .foregroundColor(KairoColor.text)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(
                            LinearGradient(
                                colors: [KairoColor.accentDim, KairoColor.accent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(18)
                    }
                }

                // Quick access
                Text("Quick Access")
                    .font(.headline)
                    .foregroundColor(KairoColor.text)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    QuickActionCard(icon: "books.vertical", label: "Library") {
                        onNavigateToLibrary()
                    }
                    QuickActionCard(icon: "rectangle.on.rectangle", label: "Flashcards") {
                        onNavigateToFlashcards()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
    }
}

private struct StatCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundColor(KairoColor.accentSoft)
            Text(label)
                .font(.caption)
                .foregroundColor(KairoColor.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(KairoColor.surface)
        .cornerRadius(14)
    }
}

private struct QuickActionCard: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(KairoColor.accent)
                Text(label)
                    .font(.headline)
                    .foregroundColor(KairoColor.text)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(KairoColor.surface)
            .cornerRadius(14)
        }
    }
}

private struct LevelBadge: View {
    let level: String

    var body: some View {
        let color = KairoColor.level(level)
        Text(level)
            .font(.subheadline.bold())
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.18))
            .cornerRadius(8)
    }
}

struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Something went wrong")
                .font(.headline)
                .foregroundColor(KairoColor.text)
            Text(message)
                .font(.subheadline)
                .foregroundColor(KairoColor.textMuted)
                .multilineTextAlignment(.center)
            Button("Retry", action: onRetry)
                .foregroundColor(KairoColor.text)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(KairoColor.accent)
                .cornerRadius(12)
        }
        .padding(32)
    }
}
