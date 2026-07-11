import SwiftUI

struct LibraryView: View {
    @StateObject private var vm: LibraryViewModel
    let onCollectionTap: (String) -> Void

    init(
        collectionRepository: CollectionRepository,
        authRepository: AuthRepository,
        onCollectionTap: @escaping (String) -> Void
    ) {
        _vm = StateObject(wrappedValue: LibraryViewModel(
            collectionRepository: collectionRepository,
            authRepository: authRepository
        ))
        self.onCollectionTap = onCollectionTap
    }

    var body: some View {
        ZStack {
            KairoColor.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Library")
                        .font(.largeTitle.bold())
                        .foregroundColor(KairoColor.text)
                    Text("All your JLPT collections")
                        .font(.subheadline)
                        .foregroundColor(KairoColor.textMuted)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)

                switch vm.uiState {
                case .loading:
                    Spacer()
                    ProgressView().tint(KairoColor.accent).frame(maxWidth: .infinity)
                    Spacer()

                case .error(let msg):
                    Spacer()
                    VStack(spacing: 12) {
                        Text(msg).foregroundColor(KairoColor.textMuted).multilineTextAlignment(.center)
                        Button("Retry") { vm.load() }
                            .foregroundColor(KairoColor.text)
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .background(KairoColor.accent).cornerRadius(10)
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    Spacer()

                case .success(let collections):
                    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(collections) { collection in
                                CollectionCard(collection: collection) {
                                    onCollectionTap(collection.id)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

private struct CollectionCard: View {
    let collection: StudyCollection
    let onTap: () -> Void

    var levelColor: Color { KairoColor.level(collection.level) }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(collection.icon).font(.system(size: 32))
                    Spacer()
                    Text(collection.level)
                        .font(.caption.bold())
                        .foregroundColor(levelColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(levelColor.opacity(0.18))
                        .cornerRadius(6)
                }

                Text(collection.title)
                    .font(.headline)
                    .foregroundColor(KairoColor.text)
                    .lineLimit(1)

                Text(collection.subtitle)
                    .font(.caption)
                    .foregroundColor(KairoColor.textMuted)
                    .lineLimit(2)

                VStack(spacing: 4) {
                    HStack {
                        Text("Progress")
                            .font(.caption)
                            .foregroundColor(KairoColor.textMuted)
                        Spacer()
                        Text("\(collection.progressPercentage)%")
                            .font(.caption)
                            .foregroundColor(KairoColor.accentSoft)
                    }
                    ProgressView(value: Double(collection.progressPercentage) / 100.0)
                        .tint(levelColor)
                        .scaleEffect(x: 1, y: 0.6, anchor: .center)
                }
            }
            .padding(16)
            .background(KairoColor.surface)
            .cornerRadius(16)
        }
    }
}
