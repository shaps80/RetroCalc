import SwiftUI

@main
struct RetroCalcApp: App {
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottomTrailing) {
                Color.bg
                    .ignoresSafeArea()

                HStack(alignment: .bottom) {
                    CalculatorView()
                }
            }
        }
    }
}
