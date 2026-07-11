import SwiftUI

enum LibraryDestination: Hashable {
    case collection(id: String)
    case lesson(id: String, level: String)
}

enum DashboardDestination: Hashable {
    case lesson(id: String, level: String)
}

struct MainTabView: View {
    @EnvironmentObject var env: AppEnvironment

    var body: some View {
        TabView {
            // MARK: Dashboard tab
            NavigationStack {
                DashboardTab()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            // MARK: Library tab
            NavigationStack {
                LibraryTab()
            }
            .tabItem {
                Label("Library", systemImage: "books.vertical.fill")
            }

            // MARK: Flashcards tab
            NavigationStack {
                FlashcardView(
                    flashcardRepository: env.flashcardRepository,
                    authRepository: env.authRepository
                )
            }
            .tabItem {
                Label("Flashcards", systemImage: "rectangle.on.rectangle")
            }
        }
        .tint(KairoColor.accent)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(KairoColor.surface)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Dashboard Tab

private struct DashboardTab: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var path: [DashboardDestination] = []

    var body: some View {
        NavigationStack(path: $path) {
            DashboardView(
                profileRepository: env.profileRepository,
                lessonRepository: env.lessonRepository,
                authRepository: env.authRepository,
                onNavigateToLesson: { lessonId, level in
                    path.append(.lesson(id: lessonId, level: level))
                },
                onNavigateToLibrary: { },
                onNavigateToFlashcards: { }
            )
            .navigationDestination(for: DashboardDestination.self) { dest in
                switch dest {
                case .lesson(let id, let level):
                    LessonView(
                        lessonRepository: env.lessonRepository,
                        authRepository: env.authRepository,
                        lessonId: id,
                        level: level,
                        onFinish: { path.removeLast() }
                    )
                }
            }
        }
    }
}

// MARK: - Library Tab

private struct LibraryTab: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var path: [LibraryDestination] = []

    var body: some View {
        NavigationStack(path: $path) {
            LibraryView(
                collectionRepository: env.collectionRepository,
                authRepository: env.authRepository,
                onCollectionTap: { id in path.append(.collection(id: id)) }
            )
            .navigationDestination(for: LibraryDestination.self) { dest in
                switch dest {
                case .collection(let id):
                    LessonsView(
                        collectionRepository: env.collectionRepository,
                        authRepository: env.authRepository,
                        collectionId: id,
                        onLessonTap: { lessonId, level in
                            path.append(.lesson(id: lessonId, level: level))
                        }
                    )
                case .lesson(let id, let level):
                    LessonView(
                        lessonRepository: env.lessonRepository,
                        authRepository: env.authRepository,
                        lessonId: id,
                        level: level,
                        onFinish: { path.removeLast() }
                    )
                }
            }
        }
    }
}
