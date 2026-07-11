import SwiftUI

struct FlashcardView: View {
    @StateObject private var vm: FlashcardViewModel

    init(flashcardRepository: FlashcardRepository, authRepository: AuthRepository) {
        _vm = StateObject(wrappedValue: FlashcardViewModel(
            flashcardRepository: flashcardRepository,
            authRepository: authRepository
        ))
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

            case .done:
                DoneView()

            case .reviewing(let cards, let index, let isFlipped):
                ReviewContent(
                    cards: cards,
                    currentIndex: index,
                    isFlipped: isFlipped,
                    onFlip: { vm.flip() },
                    onGrade: { vm.grade($0) }
                )
            }
        }
        .navigationTitle("Flashcards")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ReviewContent: View {
    let cards: [Flashcard]
    let currentIndex: Int
    let isFlipped: Bool
    let onFlip: () -> Void
    let onGrade: (Int) -> Void

    var card: Flashcard { cards[currentIndex] }
    var remaining: Int { cards.count - currentIndex }

    var body: some View {
        VStack(spacing: 20) {
            Text("\(remaining) card\(remaining == 1 ? "" : "s") remaining")
                .font(.subheadline)
                .foregroundColor(KairoColor.textMuted)

            ProgressView(value: Double(currentIndex) / Double(cards.count))
                .tint(KairoColor.accent)
                .scaleEffect(x: 1, y: 0.8, anchor: .center)

            Spacer().frame(height: 8)

            FlipCard(card: card, isFlipped: isFlipped, onFlip: onFlip)

            if !isFlipped {
                Text("Tap card to reveal")
                    .font(.subheadline)
                    .foregroundColor(KairoColor.textMuted)
            }

            if isFlipped {
                HStack(spacing: 8) {
                    GradeButton(label: "Again", color: KairoColor.error,   grade: 0) { onGrade(0) }
                    GradeButton(label: "Hard",  color: KairoColor.warning, grade: 2) { onGrade(2) }
                    GradeButton(label: "Good",  color: KairoColor.accent,  grade: 4) { onGrade(4) }
                    GradeButton(label: "Easy",  color: KairoColor.success, grade: 5) { onGrade(5) }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(20)
        .animation(.easeInOut(duration: 0.2), value: isFlipped)
    }
}

private struct FlipCard: View {
    let card: Flashcard
    let isFlipped: Bool
    let onFlip: () -> Void

    var body: some View {
        ZStack {
            // Front face
            CardFace(content: {
                VStack(spacing: 12) {
                    Text(card.front)
                        .font(.system(size: 72, weight: .bold))
                        .foregroundColor(KairoColor.text)
                        .multilineTextAlignment(.center)
                    Text("Front")
                        .font(.caption)
                        .foregroundColor(KairoColor.textMuted)
                }
            })
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

            // Back face
            CardFace(content: {
                VStack(spacing: 8) {
                    Text(card.back)
                        .font(.title2.bold())
                        .foregroundColor(KairoColor.accentSoft)
                        .multilineTextAlignment(.center)
                    Text(card.reviewState)
                        .font(.caption)
                        .foregroundColor(KairoColor.textMuted)
                }
            })
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .onTapGesture { onFlip() }
        .animation(.easeInOut(duration: 0.5), value: isFlipped)
    }
}

private struct CardFace<Content: View>: View {
    let content: () -> Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(KairoColor.surface)
            content()
                .padding(24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
    }
}

private struct GradeButton: View {
    let label: String
    let color: Color
    let grade: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.caption.bold())
                    .foregroundColor(color)
                Text("\(grade)")
                    .font(.caption2)
                    .foregroundColor(color.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.15))
            .cornerRadius(12)
        }
    }
}

private struct DoneView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("🎴").font(.system(size: 64))
            Text("All caught up!")
                .font(.largeTitle.bold())
                .foregroundColor(KairoColor.text)
            Text("No cards due for review right now.\nCome back later!")
                .font(.subheadline)
                .foregroundColor(KairoColor.textMuted)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(32)
    }
}
