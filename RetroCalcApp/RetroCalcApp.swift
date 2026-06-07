import LCDPanel
import SwiftUI

@main
struct RetroCalcApp: App {
    var body: some Scene {
        WindowGroup {
            CalculatorView()
        }
    }
}

private struct CalculatorView: View {
    @State private var value = LCDPanel.Value()

    private let rows: [[CalculatorButton]] = [
        [.backspace, .clear, .percent, .divide],
        [.digit(7), .digit(8), .digit(9), .multiply],
        [.digit(4), .digit(5), .digit(6), .subtract],
        [.digit(1), .digit(2), .digit(3), .add],
        [.plusMinus, .digit(0), .decimal, .equals]
    ]

    var body: some View {
        VStack(spacing: 28) {
            LCDPanel(value: value)
                .font(.custom("Calculator", size: 128))
                .frame(height: 96)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .scenePadding()

            VStack(spacing: 12) {
                ForEach(rows, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { button in
                            Button {
                                handle(button)
                            } label: {
                                Text(button.title)
                                    .font(.system(size: button.fontSize, weight: .regular))
                                    .frame(width: 50)
                                    .scaledToFit()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .scenePadding()
        }
    }

    private func handle(_ button: CalculatorButton) {
        switch button {
        case let .digit(digit):
            value.append(UInt(digit))
        case .decimal:
            value.appendDecimal()
        case .clear:
            value = LCDPanel.Value()
        case .backspace:
            value.removeLast()
        case .percent, .divide, .multiply, .subtract, .add, .equals, .plusMinus:
            break
        }
    }
}

private enum CalculatorButton: Hashable {
    case backspace
    case clear
    case percent
    case divide
    case multiply
    case subtract
    case add
    case equals
    case plusMinus
    case decimal
    case digit(UInt8)

    var title: String {
        switch self {
        case .backspace:
            return "⌫"
        case .clear:
            return "AC"
        case .percent:
            return "%"
        case .divide:
            return "÷"
        case .multiply:
            return "×"
        case .subtract:
            return "−"
        case .add:
            return "+"
        case .equals:
            return "="
        case .plusMinus:
            return "+/-"
        case .decimal:
            return "."
        case let .digit(digit):
            return String(digit)
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .plusMinus:
            return 28
        case .clear:
            return 30
        default:
            return 38
        }
    }
}
