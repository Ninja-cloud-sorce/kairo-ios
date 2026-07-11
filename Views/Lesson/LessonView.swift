import SwiftUI

struct LessonView: View {
    @StateObject private var vm: LessonViewModel
    let onFinish: () -> Void

    init(
        lessonRepository: LessonRepository,
        authRepository: AuthRepository,
        lessonId: String,
        level: String,
        onFinish: @escaping () -> Void
    ) {
        _vm = StateObject(wrappedValue: LessonViewModel(
            lessonRepository: lessonRepository,
            authRepository: authRepository,
            lessonId: lessonId,
            level: level
        ))
        self.onFinish = onFinish
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
                    Button("Go Back", action: onFinish)
                        .foregroundColor(KairoColor.text)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(KairoColor.accent).cornerRadius(10)
                }

            case .quiz(let detail, let index, let selected, let showFeedback, _):
                if let questions = detail.questions, index < questions.count {
                    QuizContent(
                        detail: detail,
                        question: questions[index],
                        currentIndex: index,
                        total: questions.count,
                        selectedAnswer: selected,
                        showFeedback: showFeedback,
                        onSelectAnswer: { vm.selectAnswer($0) },
                        onNext: { vm.nextQuestion() },
                        onClose: onFinish
                    )
                }

            case .summary(let score, let total, let xpGained):
                SummaryView(score: score, total: total, xpGained: xpGained, onDone: onFinish)
            }
        }
        .navigationBarHidden(true)
    }
}

private struct QuizContent: View {
    let detail: LessonDetail
    let question: QuizQuestion
    let currentIndex: Int
    let total: Int
    let selectedAnswer: String?
    let showFeedback: Bool
    let onSelectAnswer: (String) -> Void
    let onNext: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Top bar
            HStack(spacing: 12) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(KairoColor.textMuted)
                }
                ProgressView(value: Double(currentIndex + 1) / Double(total))
                    .tint(KairoColor.accent)
                Text("\(currentIndex + 1)/\(total)")
                    .font(.caption)
                    .foregroundColor(KairoColor.textMuted)
            }

            Spacer().frame(height: 12)

            // Lesson title
            Text(detail.title)
                .font(.title2.bold())
                .foregroundColor(KairoColor.text)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Question card
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(KairoColor.surface)
                Text(question.question)
                    .font(.title2)
                    .foregroundColor(KairoColor.text)
                    .multilineTextAlignment(.center)
                    .padding(24)
            }

            // Answer options
            ForEach(question.options, id: \.self) { option in
                AnswerOption(
                    text: option,
                    correctAnswer: question.correctAnswer,
                    selectedAnswer: selectedAnswer,
                    showFeedback: showFeedback,
                    onTap: { onSelectAnswer(option) }
                )
            }

            Spacer()
        }
        .padding(20)
        .onChange(of: showFeedback) { _, show in
            if show {
                Task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    onNext()
                }
            }
        }
    }
}

private struct AnswerOption: View {
    let text: String
    let correctAnswer: String
    let selectedAnswer: String?
    let showFeedback: Bool
    let onTap: () -> Void

    var isSelected: Bool { selectedAnswer == text }
    var isCorrect: Bool { text == correctAnswer }

    var borderColor: Color {
        if showFeedback && isCorrect                  { return KairoColor.success }
        if showFeedback && isSelected && !isCorrect   { return KairoColor.error }
        if isSelected                                 { return KairoColor.accent }
        return KairoColor.surfaceVariant
    }

    var bgColor: Color {
        if showFeedback && isCorrect                  { return KairoColor.success.opacity(0.12) }
        if showFeedback && isSelected && !isCorrect   { return KairoColor.error.opacity(0.12) }
        if isSelected                                 { return KairoColor.accent.opacity(0.12) }
        return KairoColor.surface
    }

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(.body)
                .foregroundColor(KairoColor.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(bgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(borderColor, lineWidth: 1.5)
                )
                .cornerRadius(14)
        }
        .disabled(selectedAnswer != nil)
        .animation(.easeInOut(duration: 0.25), value: showFeedback)
    }
}

private struct SummaryView: View {
    let score: Int
    let total: Int
    let xpGained: Int
    let onDone: () -> Void

    var emoji: String {
        if score >= 90 { return "🎉 Excellent!" }
        if score >= 70 { return "✨ Well done!" }
        if score >= 50 { return "👍 Good effort!" }
        return "📚 Keep practicing!"
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(emoji)
                .font(.largeTitle.bold())
                .foregroundColor(KairoColor.text)
                .multilineTextAlignment(.center)

            // Score circle
            ZStack {
                Circle()
                    .fill(KairoColor.surface)
                    .frame(width: 140, height: 140)
                VStack(spacing: 4) {
                    Text("\(score)%")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(KairoColor.accent)
                    Text("Score")
                        .font(.subheadline)
                        .foregroundColor(KairoColor.textMuted)
                }
            }

            if xpGained > 0 {
                Text("+\(xpGained) XP earned")
                    .font(.headline)
                    .foregroundColor(KairoColor.accentSoft)
            }

            if total > 0 {
                Text("\(Int(Double(score) * Double(total) / 100.0))/\(total) correct")
                    .font(.subheadline)
                    .foregroundColor(KairoColor.textMuted)
            }

            Spacer()

            Button(action: onDone) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(KairoColor.text)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(KairoColor.accent)
                    .cornerRadius(14)
            }
        }
        .padding(32)
    }
}
