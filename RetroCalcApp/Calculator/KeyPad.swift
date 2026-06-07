import SwiftUI

struct KeyPad: View {
    @Environment(\.openWords) private var openWords
    
    private let spacing: CGFloat = 15
    @Binding var calculator: CalculatorModel

    var body: some View {
        Grid(
            horizontalSpacing: spacing,
            verticalSpacing: spacing
        ) {
            GridRow {
                Key(systemImage: "delete.left") {
                    calculator.removeLast()
                }

                Key("C") {
                    calculator.clear()
                }

                Key(systemImage: "plusminus") {

                }

                Key(systemImage: "divide") {
                    calculator.enterOperator(.divide)
                }
                .tint(.tintTeal)
            }
            .tint(.tintYellow)

            GridRow {
                Key(7) {
                    calculator.enterDigit(7)
                }

                Key(8) {
                    calculator.enterDigit(8)
                }

                Key(9) {
                    calculator.enterDigit(9)
                }

                Key(systemImage: "multiply") {
                    calculator.enterOperator(.multiply)
                }
                .tint(.tintTeal)
            }

            GridRow {
                Key(4) {
                    calculator.enterDigit(4)
                }

                Key(5) {
                    calculator.enterDigit(5)
                }

                Key(6) {
                    calculator.enterDigit(6)
                }

                Key(systemImage: "minus") {
                    calculator.enterOperator(.subtract)
                }
                .tint(.tintTeal)
            }

            GridRow {
                Key(1) {
                    calculator.enterDigit(1)
                }

                Key(2) {
                    calculator.enterDigit(2)
                }

                Key(3) {
                    calculator.enterDigit(3)
                }

                Key(systemImage: "plus") {
                    calculator.enterOperator(.add)
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
                    calculator.enterDigit(0)
                }

                Key(".") {
                    calculator.enterDecimal()
                }

                Key(systemImage: "equal") {
                    calculator.evaluate()
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

        KeyPad(calculator: .constant(.init()))
            .padding(15)
    }
}
