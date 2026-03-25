//
//  NotificationPage.swift
//  Product
//
//  Created by German Tihiy on 24.03.2026.
//

import SwiftUI

struct NotifPage: View {
    var general: General
    
    var body: some View {
        ZStack {
            Color(red: 28/255, green: 28/255, blue: 28/255)
                .ignoresSafeArea()
            
            if general.exit == true {
                // Авторизован, но уведомлений нет
                VStack(spacing: 20) {
                    // Перечеркнутый звоночек
                    Image(systemName: "bell.slash")
                        .font(.system(size: 70))
                        .foregroundColor(.gray)
                    
                    Text("У вас сейчас нет уведомлений")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Когда появятся новые уведомления, они отобразятся здесь")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                // Не авторизован
                VStack(spacing: 20) {
                    // Перечеркнутый звоночек
                    Image(systemName: "bell.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Войдите в аккаунт")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Text("Чтобы видеть уведомления, нужно авторизоваться")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    


                }
            }
        }
    }
}

#Preview {
    NotifPage(general: General())
}
