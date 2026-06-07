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
                CalcButton("C") {
                    value.clear()
                }

                CalcButton(systemImage: "plusminus") {

                }

                CalcButton(systemImage: "percent") {

                }

                CalcButton(systemImage: "divide") {

                }
                .tint(.tintTeal)
            }
            .tint(.tintYellow)

            GridRow {
                CalcButton(7) {
                    value.append(7)
                }

                CalcButton(8) {
                    value.append(8)
                }

                CalcButton(9) {
                    value.append(9)
                }

                CalcButton(systemImage: "multiply") {

                }
                .tint(.tintTeal)
            }

            GridRow {
                CalcButton(4) {
                    value.append(4)
                }

                CalcButton(5) {
                    value.append(5)
                }

                CalcButton(6) {
                    value.append(6)
                }

                CalcButton(systemImage: "minus") {

                }
                .tint(.tintTeal)
            }

            GridRow {
                CalcButton(1) {
                    value.append(1)
                }

                CalcButton(2) {
                    value.append(2)
                }

                CalcButton(3) {
                    value.append(3)
                }

                CalcButton(systemImage: "plus") {

                }
                .tint(.tintTeal)
            }

            GridRow {
                CalcButton(systemImage: "chevron.down.2") {
                    openWords()
                }
                .tint(.secondary)
                .imageScale(.small)

                CalcButton(0) {
                    value.append(0)
                }

                CalcButton(".") {
                    value.appendDecimal()
                }

                CalcButton(systemImage: "equal") {

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

