//
//  ProductApp.swift
//  Product
//
//  Created by German Tihiy on 15.03.2026.
//

import SwiftUI

@main
struct ProductApp: App {
    init() {
        // Отключаем кнопку Cancel во всех поисковых полях
        UISearchBar.appearance().showsCancelButton = false
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
