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
        ZStack{
            Color(red: 28/255, green: 28/255, blue: 28/255)
                .ignoresSafeArea()
        
        if general.exit == true {
            Text("Пусто")
                .foregroundColor(.white)
        } else {
            Text("Войдите в аккаунт")
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
    
    }
}
