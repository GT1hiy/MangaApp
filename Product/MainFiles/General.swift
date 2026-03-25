import SwiftUI

class General: ObservableObject {
    @Published var selectedTab = 0
    @Published var reg = false
    @Published var exit = false
    @Published var userEmail = ""
    @Published var welcomeMessage = ""
    
    func exitFromAcc() {
        exit = false
    }
}
