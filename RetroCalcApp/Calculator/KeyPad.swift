import SwiftUI
import LCDPanel

struct KeyPad: View {
    @Environment(\.openWords) private var openWords
    
    private let spacing: CGFloat = 15
    @Binding var value: LCDPanel.Value

    var body: some View {
        Grid(
            horizontalSpacing: spacing,
            verticalSpacing: spacing
        ) {
            GridRow {
                Key(systemImage: "delete.left") {
                    value.removeLast()
                }

                Key("C") {
                    value.clear()
                }

                Key(systemImage: "plusminus") {

                }

                Key(systemImage: "divide") {

                }
                .tint(.tintTeal)
            }
            .tint(.tintYellow)

            GridRow {
                Key(7) {
                    value.append(7)
                }

                Key(8) {
                    value.append(8)
                }

                Key(9) {
                    value.append(9)
                }

                Key(systemImage: "multiply") {

                }
                .tint(.tintTeal)
            }

            GridRow {
                Key(4) {
                    value.append(4)
                }

                Key(5) {
                    value.append(5)
                }

                Key(6) {
                    value.append(6)
                }

                Key(systemImage: "minus") {

                }
                .tint(.tintTeal)
            }

            GridRow {
                Key(1) {
                    value.append(1)
                }

                Key(2) {
                    value.append(2)
                }

                Key(3) {
                    value.append(3)
                }

                Key(systemImage: "plus") {

                }
                .tint(.tintTeal)
            }

            GridRow {
                Key(systemImage: "chevron.down.2") {
                    openWords()
                }
                .tint(.secondary)
                .imageScale(.small)

                Key(0) {
                    value.append(0)
                }

                Key(".") {
                    value.appendDecimal()
                }

                Key(systemImage: "equal") {

                }
                .tint(.tintTeal)
            }
        }
        .tint(.fg)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.bg
            .ignoresSafeArea()

        KeyPad(value: .constant(.init()))
            .padding(15)
    }
}
