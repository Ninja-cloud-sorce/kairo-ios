import Foundation

enum LessonUiState {
    case loading
    case quiz(detail: LessonDetail, currentIndex: Int, selectedAnswer: String?, showFeedback: Bool, answers: [LessonAnswer])
    case summary(score: Int, total: Int, xpGained: Int)
    case error(String)
}

@MainActor
final class LessonViewModel: ObservableObject {
    @Published var uiState: LessonUiState = .loading

    private let lessonRepository: LessonRepository
    private let authRepository: AuthRepository
    private let lessonId: String
    private let level: String
    private let startTime = Date()

    init(
        lessonRepository: LessonRepository,
        authRepository: AuthRepository,
        lessonId: String,
        level: String
    ) {
        self.lessonRepository = lessonRepository
        self.authRepository = authRepository
        self.lessonId = lessonId
        self.level = level
        load()
    }

    private func load() {
        Task {
            do {
                let detail = try await lessonRepository.getLessonDetail(lessonId: lessonId)
                if detail.questions?.isEmpty ?? true {
                    uiState = .summary(score: 100, total: 0, xpGained: 0)
                } else {
                    uiState = .quiz(detail: detail, currentIndex: 0, selectedAnswer: nil, showFeedback: false, answers: [])
                }
            } catch {
                uiState = .error(error.localizedDescription)
            }
        }
    }

    func selectAnswer(_ answer: String) {
        guard case .quiz(let detail, let index, let selected, _, let answers) = uiState,
              selected == nil else { return }
        uiState = .quiz(detail: detail, currentIndex: index, selectedAnswer: answer, showFeedback: true, answers: answers)
    }

    func nextQuestion() {
        guard case .quiz(let detail, let index, let selectedAnswer, _, let answers) = uiState,
              let question = detail.questions?[safe: index] else { return }

        let isCorrect = selectedAnswer == question.correctAnswer
        let newAnswer = LessonAnswer(
            question: question.question,
            correctAnswer: question.correctAnswer,
            isCorrect: isCorrect
        )
        let updatedAnswers = answers + [newAnswer]
        let nextIndex = index + 1
        let total = detail.questions?.count ?? 0

        if nextIndex >= total {
            submitLesson(detail: detail, answers: updatedAnswers)
        } else {
            uiState = .quiz(
                detail: detail,
                currentIndex: nextIndex,
                selectedAnswer: nil,
                showFeedback: false,
                answers: updatedAnswers
            )
        }
    }

    private func submitLesson(detail: LessonDetail, answers: [LessonAnswer]) {
        guard let userId = authRepository.currentUserId() else { return }
        let score = answers.isEmpty ? 0 : (answers.filter { $0.isCorrect }.count * 100 / answers.count)
        let elapsed = Int(Date().timeIntervalSince(startTime))

        Task {
            do {
                let response = try await lessonRepository.completeLesson(
                    CompleteLessonRequest(
                        userId: userId,
                        lessonId: lessonId,
                        answers: answers,
                        score: score,
                        timeSpentSec: elapsed,
                        level: level
                    )
                )
                uiState = .summary(score: score, total: answers.count, xpGained: response.xpGained ?? 0)
            } catch {
                uiState = .summary(score: score, total: answers.count, xpGained: 0)
            }
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}
