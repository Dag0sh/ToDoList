import SwiftUI
import LocalAuthentication

struct mainView: View {
    @State private var isAuthenticated = false
    @State private var showPasswordPrompt = false
    @State private var passwordInput = ""
    @State private var authenticationError: String?
    
    private let correctPassword = "1008"
    
    var body: some View {
        if isAuthenticated {
            TabView {
                ContentView()
                    .padding()
                    .tabItem {
                        Image(systemName: "plus.app")
                        Text("Add page")
                    }
                    .tag(1)
                
                ExpiredTasksView()
                    .padding()
                    .tabItem {
                        Image(systemName: "eraser")
                        Text("Delete")
                    }
                    .tag(2)
            }
        } else {
            VStack {
                Text("Авторизация")
                    .font(.largeTitle)
                    .padding()
                
                if let error = authenticationError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button(action: {
                    authenticateWithFaceID()
                }) {
                    Text("Войти с Face ID")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    showPasswordPrompt = true
                }) {
                    Text("Войти с паролем")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .alert("Введите пароль", isPresented: $showPasswordPrompt) {
                SecureField("Пароль", text: $passwordInput)
                    .keyboardType(.decimalPad)
                    .textContentType(.password)
                Button("OK") {
                    authenticateWithPassword()
                }
                Button("Отмена", role: .cancel) { }
            }
        }
    }
    
    private func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?
        
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Для доступа к задачам") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        
                        self.isAuthenticated = true
                        self.authenticationError = nil
                    } else {
                        print("Ошибка Face ID: \(authenticationError?.localizedDescription ?? "Неизвестная ошибка")")
                        self.authenticationError = "Ошибка Face ID: \(authenticationError?.localizedDescription ?? "Неизвестная ошибка")"
                    }
                }
            }
        } else {
            print("Face ID недоступен: \(error?.localizedDescription ?? "Неизвестная ошибка")")
            self.authenticationError = "Face ID недоступен: \(error?.localizedDescription ?? "Неизвестная ошибка")"
        }
    }
    
    private func authenticateWithPassword() {
        if passwordInput == correctPassword {
            isAuthenticated = true
            authenticationError = nil
            passwordInput = ""
        } else {
            authenticationError = "Неверный пароль"
            passwordInput = ""
        }
    }
}


#Preview {
    mainView()
}
