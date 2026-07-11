import SwiftUI

private struct LevelInfo: Identifiable {
    let id: String
    let label: String
    let description: String
    let emoji: String
}

private let levels: [LevelInfo] = [
    LevelInfo(id: "N5", label: "N5 — Beginner",          description: "Hiragana, katakana & basic kanji",    emoji: "🌱"),
    LevelInfo(id: "N4", label: "N4 — Elementary",         description: "~300 kanji, everyday phrases",        emoji: "🌿"),
    LevelInfo(id: "N3", label: "N3 — Intermediate",       description: "~650 kanji, complex sentences",       emoji: "🍃"),
    LevelInfo(id: "N2", label: "N2 — Upper-Intermediate", description: "~1000 kanji, near-native reading",    emoji: "🌳"),
    LevelInfo(id: "N1", label: "N1 — Advanced",           description: "~2000+ kanji, full fluency",          emoji: "🏔️"),
]

struct OnboardingView: View {
    @StateObject private var vm: OnboardingViewModel
    let onComplete: () -> Void

    init(
        lessonRepository: LessonRepository,
        authRepository: AuthRepository,
        userPreferences: UserPreferences,
        onComplete: @escaping () -> Void
    ) {
        _vm = StateObject(wrappedValue: OnboardingViewModel(
            lessonRepository: lessonRepository,
            authRepository: authRepository,
            userPreferences: userPreferences
        ))
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            KairoColor.background.ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer().frame(height: 32)

                Text("What's your level?")
                    .font(.largeTitle.bold())
                    .foregroundColor(KairoColor.text)
                    .multilineTextAlignment(.center)

                Text("Pick your JLPT target. You can change it anytime.")
                    .font(.subheadline)
                    .foregroundColor(KairoColor.textMuted)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: 8)

                ForEach(levels) { level in
                    LevelCard(
                        level: level,
                        isSelected: vm.selectedLevel == level.id,
                        onTap: { vm.selectLevel(level.id) }
                    )
                }

                Spacer()

                Button {
                    vm.confirmLevel(onComplete: onComplete)
                } label: {
                    ZStack {
                        if vm.isLoading {
                            ProgressView().tint(KairoColor.text)
                        } else {
                            Text("Start Learning")
                                .font(.headline)
                                .foregroundColor(KairoColor.text)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(vm.selectedLevel != nil ? KairoColor.accent : KairoColor.surfaceVariant)
                    .cornerRadius(14)
                }
                .disabled(vm.selectedLevel == nil || vm.isLoading)

                Spacer().frame(height: 8)
            }
            .padding(.horizontal, 24)
        }
    }
}

private struct LevelCard: View {
    let level: LevelInfo
    let isSelected: Bool
    let onTap: () -> Void

    var levelColor: Color { KairoColor.level(level.id) }

    var body: some View {
        HStack(spacing: 16) {
            Text(level.emoji)
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: 2) {
                Text(level.label)
                    .font(.headline)
                    .foregroundColor(KairoColor.text)
                Text(level.description)
                    .font(.subheadline)
                    .foregroundColor(KairoColor.textMuted)
            }

            Spacer()

            if isSelected {
                Circle()
                    .fill(levelColor)
                    .frame(width: 22, height: 22)
            }
        }
        .padding(16)
        .background(isSelected ? levelColor.opacity(0.12) : KairoColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? levelColor : KairoColor.surfaceVariant, lineWidth: 1.5)
        )
        .cornerRadius(14)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .animation(.spring(stiffness: 300, damping: 20), value: isSelected)
    }
}
