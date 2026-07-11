import SwiftUI

struct LessonsView: View {
    @StateObject private var vm: LessonsViewModel
    let onLessonTap: (String, String) -> Void

    init(
        collectionRepository: CollectionRepository,
        authRepository: AuthRepository,
        collectionId: String,
        onLessonTap: @escaping (String, String) -> Void
    ) {
        _vm = StateObject(wrappedValue: LessonsViewModel(
            collectionRepository: collectionRepository,
            authRepository: authRepository,
            collectionId: collectionId
        ))
        self.onLessonTap = onLessonTap
    }

    var body: some View {
        ZStack {
            KairoColor.background.ignoresSafeArea()

            switch vm.uiState {
            case .loading:
                ProgressView().tint(KairoColor.accent)

            case .error(let msg):
                VStack(spacing: 12) {
                    Text(msg).foregroundColor(KairoColor.textMuted)
                    Button("Retry") { vm.load() }
                        .foregroundColor(KairoColor.text)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(KairoColor.accent).cornerRadius(10)
                }

            case .success(let lessons):
                List {
                    ForEach(lessons) { lesson in
                        LessonRow(lesson: lesson) {
                            if lesson.status != "LOCKED" {
                                onLessonTap(lesson.id, "N5")
                            }
                        }
                        .listRowBackground(KairoColor.background)
                        .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Lessons")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LessonRow: View {
    let lesson: Lesson
    let onTap: () -> Void

    var isLocked: Bool { lesson.status == "LOCKED" }
    var isCompleted: Bool { lesson.status == "COMPLETED" }

    var iconName: String {
        if isCompleted { return "checkmark.circle.fill" }
        if isLocked    { return "lock.fill" }
        return "play.fill"
    }

    var iconColor: Color {
        if isCompleted { return KairoColor.success }
        if isLocked    { return KairoColor.textMuted }
        return KairoColor.accent
    }

    var iconBg: Color {
        if isCompleted { return KairoColor.success.opacity(0.18) }
        if isLocked    { return KairoColor.surfaceVariant }
        return KairoColor.accent.opacity(0.18)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconBg)
                        .frame(width: 40, height: 40)
                    Image(systemName: iconName)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(KairoColor.text)
                    Text(lesson.subtitle)
                        .font(.subheadline)
                        .foregroundColor(KairoColor.textMuted)
                        .lineLimit(1)
                }

                Spacer()

                if !isLocked {
                    Text(lesson.status)
                        .font(.caption.bold())
                        .foregroundColor(isCompleted ? KairoColor.success : KairoColor.accentSoft)
                }
            }
            .padding(16)
            .background(KairoColor.surface)
            .cornerRadius(14)
            .opacity(isLocked ? 0.5 : 1.0)
        }
        .disabled(isLocked)
    }
}
