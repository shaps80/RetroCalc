import LCDPanel
import SwiftUI

@main
struct RetroCalcApp: App {
    var body: some Scene {
        WindowGroup {
            LCDPanel()
                .frame(height: 300)
                .scenePadding()
        }
    }
}
