import Foundation

public struct CalculatorModel {
    public enum Operator {
        case add
        case subtract
        case multiply
        case divide
    }

    public private(set) var activeText = "0"
    public private(set) var previousExpressionText: String?
    public var isEmpty: Bool {
        expression.isEmpty && activeText == "0" && !hasCompletedEvaluation
    }

    private var expression = ""
    private var hasCompletedEvaluation = false

    public init() {}

    public init(inputText: String) {
        let input = inputText.filter { $0.isNumber || $0 == "." }
        expression = input
        activeText = input.isEmpty ? "0" : input
    }

    public mutating func enterDigit(_ digit: UInt8) {
        guard digit <= 9 else { return }

        if hasCompletedEvaluation {
            expression = ""
            hasCompletedEvaluation = false
        }

        expression.append(String(digit))
        activeText = expression
    }

    public mutating func enterDecimal() {
        if hasCompletedEvaluation {
            expression = ""
            hasCompletedEvaluation = false
        }

        let operand = currentOperandText
        guard !operand.contains(".") else { return }

        if operand.isEmpty || operand == "-" {
            expression.append("0")
        }

        expression.append(".")
        activeText = expression
    }

    public mutating func enterOperator(_ operation: Operator) {
        guard !activeText.isEmpty else { return }

        if hasCompletedEvaluation {
            expression = activeText == "0" ? "" : activeText
            hasCompletedEvaluation = false
        }

        guard !expression.isEmpty else {
            if operation == .subtract {
                expression = operation.displayText
                activeText = expression
            }

            return
        }

        if let lastOperatorRange, currentOperandText.isEmpty {
            expression.replaceSubrange(lastOperatorRange, with: operation.displayText)
            activeText = expression
            return
        }

        expression.append(operation.displayText)
        activeText = expression
    }

    public mutating func evaluate() {
        guard !expression.isEmpty else { return }
        guard let parsedExpression = ParsedExpression(displayText: expression) else { return }

        previousExpressionText = parsedExpression.normalizedText
        activeText = format(parsedExpression.evaluate())
        expression = activeText
        hasCompletedEvaluation = true
    }

    public mutating func removeLast() {
        if hasCompletedEvaluation {
            expression = ""
            activeText = "0"
            hasCompletedEvaluation = false
            return
        }

        _ = expression.popLast()
        activeText = expression.isEmpty ? "0" : expression
    }

    public mutating func clear() {
        if expression.isEmpty && activeText == "0" {
            previousExpressionText = nil
            return
        }

        expression = ""
        activeText = "0"
        hasCompletedEvaluation = false
    }

    private var currentOperandText: Substring {
        guard let lastOperatorIndex = expression.lastIndex(where: { Operator(displayText: $0) != nil }) else {
            return expression[...]
        }

        return expression[expression.index(after: lastOperatorIndex)...]
    }

    private var lastOperatorRange: Range<String.Index>? {
        guard let lastIndex = expression.indices.last,
              Operator(displayText: expression[lastIndex]) != nil
        else { return nil }

        return lastIndex..<expression.index(after: lastIndex)
    }
}

private extension CalculatorModel.Operator {
    init?(displayText: Character) {
        switch displayText {
        case "+":
            self = .add
        case "-":
            self = .subtract
        case "x":
            self = .multiply
        case "÷":
            self = .divide
        default:
            return nil
        }
    }

    var displayText: String {
        switch self {
        case .add:
            "+"
        case .subtract:
            "-"
        case .multiply:
            "x"
        case .divide:
            "÷"
        }
    }
}

private struct ParsedExpression {
    let operands: [Decimal]
    let operators: [CalculatorModel.Operator]

    init?(displayText: String) {
        var operands: [Decimal] = []
        var operators: [CalculatorModel.Operator] = []
        var currentNumber = ""
        var isExpectingOperand = true

        func appendCurrentNumber() {
            guard currentNumber != "-", !currentNumber.isEmpty else { return }
            operands.append(Decimal(string: currentNumber) ?? 0)
            currentNumber = ""
        }

        for character in displayText {
            if character.isNumber || character == "." {
                currentNumber.append(character)
                isExpectingOperand = false
                continue
            }

            guard let operation = CalculatorModel.Operator(displayText: character) else { continue }

            if operation == .subtract && isExpectingOperand {
                currentNumber = "-"
                isExpectingOperand = false
                continue
            }

            appendCurrentNumber()

            guard operands.count > operators.count else { continue }

            operators.append(operation)
            isExpectingOperand = true
        }

        appendCurrentNumber()

        guard !operands.isEmpty else { return nil }

        if operators.count >= operands.count {
            operators.removeLast(operators.count - operands.count + 1)
        }

        self.operands = operands
        self.operators = operators
    }

    var normalizedText: String {
        var text = format(operands[0])

        for (index, operation) in operators.enumerated() {
            text.append(operation.displayText)
            text.append(format(operands[index + 1]))
        }

        return text
    }

    func evaluate() -> Decimal {
        var reducedOperands = [operands[0]]
        var reducedOperators: [CalculatorModel.Operator] = []

        for (index, operation) in operators.enumerated() {
            let nextOperand = operands[index + 1]

            switch operation {
            case .multiply:
                reducedOperands[reducedOperands.count - 1] *= nextOperand
            case .divide:
                reducedOperands[reducedOperands.count - 1] /= nextOperand
            case .add, .subtract:
                reducedOperators.append(operation)
                reducedOperands.append(nextOperand)
            }
        }

        var result = reducedOperands[0]

        for (index, operation) in reducedOperators.enumerated() {
            let nextOperand = reducedOperands[index + 1]

            switch operation {
            case .add:
                result += nextOperand
            case .subtract:
                result -= nextOperand
            case .multiply, .divide:
                break
            }
        }

        return result
    }
}

private func format(_ decimal: Decimal) -> String {
    let number = NSDecimalNumber(decimal: decimal)
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.numberStyle = .decimal
    formatter.usesGroupingSeparator = false
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 16

    return formatter.string(from: number) ?? number.stringValue
}
