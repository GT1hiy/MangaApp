import SwiftUI

@Observable class regInfo {
    var email = ""
    var password = ""
    var repeatPassword = ""
    var showingAlert = false
    var alertMessage = ""
}

struct RegPage: View {
    @State var info = regInfo()
    var general: General
    
    var body: some View {
        
        ZStack{
            Color(red: 28/255, green: 28/255, blue: 28/255)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Вход")
                    .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                    .shadow(color: Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.9), radius: 35, x: 0, y: 5)
                    .overlay(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.5),
                                .clear,
                                .white.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(
                            Text("Вход")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.bottom, 20)
                        )
                    )
                    
                
                VStack(alignment: .leading) {
                    TextField("Введите логин", text: $info.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .colorScheme(.light)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                VStack(alignment: .leading) {
                    SecureField("Введите пароль", text: $info.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .colorScheme(.light)
                    
                }
                
                // Кнопка входа
                Button(action: {
                    loginButtonTapped()
                }) {
                    Text("Войти")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: 100)
                        .padding()
                        .background(Color(red: 239/255, green: 191/255, blue: 4/255))
                        .cornerRadius(20)
                        .overlay(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.4),
                                    .clear,
                                    .white.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )).cornerRadius(30)
                    
                        .shadow(color: Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5), radius: 10, x: 0, y: 0)
        
                }
                .padding(.top, 20)
                
                Button("У меня еще нет аккаунта"){
                    general.reg = true
                }
                .foregroundStyle(Color(red: 239/255, green: 191/255, blue: 4/255))
                .shadow(color: Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5), radius: 10, x: 0, y: 0)
            
                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.6),
                            .clear,
                            .white.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(
                        Text("У меня еще нет аккаунта")
                    )
                    .allowsHitTesting(false)
                )
                .padding(.top, 10)
                
            }
            .padding(.horizontal, 50)
            .padding(.top, -105)
        }
        .alert(isPresented: $info.showingAlert) { 
            Alert(
                title: Text("Вход"),
                message: Text(info.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
        
        // Функция обработки нажатия на кнопку
        func loginButtonTapped() {
            if info.email.isEmpty || info.password.isEmpty {
                info.showingAlert = true
                info.alertMessage = "Заполните все поля"
            } else {
                general.welcomeMessage = "Добро пожаловать, \(info.email)!"
                general.userEmail = info.email
                general.exit = true
                info.showingAlert = true
            }
        }
    }

#Preview {
    RegPage(general: General())
}


