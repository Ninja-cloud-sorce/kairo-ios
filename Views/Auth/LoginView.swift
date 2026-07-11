import SwiftUI

struct LoginView: View {
    @StateObject private var vm: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var passwordVisible = false
    @State private var isSignUp = false

    let onSuccess: () async -> Void

    init(authRepository: AuthRepository, onSuccess: @escaping () async -> Void) {
        _vm = StateObject(wrappedValue: AuthViewModel(repo: authRepository))
        self.onSuccess = onSuccess
    }

    private var isLoading: Bool {
        if case .loading = vm.state { return true }
        return false
    }

    var body: some View {
        ZStack {
            KairoColor.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 60)

                    // Logo
                    Text("海路")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(KairoColor.accent)
                    Text("Kairo")
                        .font(.largeTitle.bold())
                        .foregroundColor(KairoColor.text)
                    Text("Master Japanese, one step at a time")
                        .font(.subheadline)
                        .foregroundColor(KairoColor.textMuted)
                        .multilineTextAlignment(.center)

                    Spacer().frame(height: 16)

                    // Email field
                    HStack(spacing: 12) {
                        Image(systemName: "envelope")
                            .foregroundColor(KairoColor.textMuted)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .foregroundColor(KairoColor.text)
                    }
                    .padding()
                    .background(KairoColor.surface)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(KairoColor.accentSoft.opacity(0.3)))
                    .cornerRadius(12)

                    // Password field
                    HStack(spacing: 12) {
                        Image(systemName: "lock")
                            .foregroundColor(KairoColor.textMuted)
                        if passwordVisible {
                            TextField("Password", text: $password)
                                .foregroundColor(KairoColor.text)
                        } else {
                            SecureField("Password", text: $password)
                                .foregroundColor(KairoColor.text)
                        }
                        Button {
                            passwordVisible.toggle()
                        } label: {
                            Image(systemName: passwordVisible ? "eye.slash" : "eye")
                                .foregroundColor(KairoColor.textMuted)
                        }
                    }
                    .padding()
                    .background(KairoColor.surface)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(KairoColor.accentSoft.opacity(0.3)))
                    .cornerRadius(12)

                    // Error message
                    if case .error(let msg) = vm.state {
                        Text(msg)
                            .font(.subheadline)
                            .foregroundColor(KairoColor.error)
                            .multilineTextAlignment(.center)
                            .transition(.opacity.animation(.easeInOut))
                    }

                    // Primary action button
                    Button {
                        if isSignUp {
                            vm.signUp(email: email, password: password)
                        } else {
                            vm.signIn(email: email, password: password)
                        }
                    } label: {
                        ZStack {
                            if isLoading {
                                ProgressView().tint(KairoColor.text)
                            } else {
                                Text(isSignUp ? "Create Account" : "Sign In")
                                    .font(.headline)
                                    .foregroundColor(KairoColor.text)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(KairoColor.accent)
                        .cornerRadius(14)
                    }
                    .disabled(email.isEmpty || password.isEmpty || isLoading)

                    // Toggle sign-in / sign-up
                    Button {
                        isSignUp.toggle()
                        vm.resetState()
                    } label: {
                        Text(isSignUp ? "Already have an account? Sign in" : "New here? Create account")
                            .font(.subheadline)
                            .foregroundColor(KairoColor.accentSoft)
                    }
                }
                .padding(.horizontal, 28)
            }
        }
        .onChange(of: vm.state) { _, new in
            if case .success = new {
                Task { await onSuccess() }
            }
        }
    }
}
