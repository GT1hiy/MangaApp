import SwiftUI

@Observable class General {
    var selectedTab = 0
    var reg = false
    var exit = false
    var userEmail = ""
    var welcomeMessage = ""
    
    func exitFromAcc() {
        exit = false
    }
}
