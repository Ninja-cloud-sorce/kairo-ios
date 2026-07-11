import Foundation

// MARK: - Profile

struct Profile: Codable {
    let userId: String
    let displayName: String
    let currentLevel: String
    let xp: Int
    let streak: Int
    let readinessScore: Int
}

// MARK: - Collection

struct StudyCollection: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let level: String
    let progressPercentage: Int
}

// MARK: - Lesson

struct Lesson: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let status: String // COMPLETED, CURRENT, LOCKED
}

struct LessonDetail: Codable {
    let id: String
    let title: String
    let subtitle: String?
    let content: String?
    let level: String?
    let questions: [QuizQuestion]?
}

struct QuizQuestion: Codable {
    let question: String
    let options: [String]
    let correctAnswer: String
}

// MARK: - Flashcard

struct Flashcard: Codable, Identifiable {
    let id: String
    let front: String
    let back: String
    let reviewState: String
}

// MARK: - API Request / Response Models

struct LevelOverrideRequest: Encodable {
    let level: String
}

struct CompleteLessonRequest: Encodable {
    let userId: String
    let lessonId: String
    let answers: [LessonAnswer]
    let score: Int
    let timeSpentSec: Int
    let level: String
}

struct LessonAnswer: Codable {
    let question: String
    let correctAnswer: String
    let isCorrect: Bool

    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case isCorrect = "is_correct"
    }
}

struct CompleteLessonResponse: Decodable {
    let xpGained: Int?
    let totalXp: Int?
    let message: String?
}

struct FlashcardReviewRequest: Encodable {
    let grade: Int
}

struct FlashcardReviewResponse: Decodable {
    let success: Bool
    let nextDue: String?
}
