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
    private var repeatedEqualsOperation: RepeatOperation?
    private var isUndefined: Bool {
        activeText == "Undefined"
    }

    public init() {}

    public init(inputText: String) {
        let input = inputText.filter { $0.isNumber || $0 == "." }
        expression = input
        activeText = input.isEmpty ? "0" : input
    }

    public mutating func replaceActiveInput(with inputText: String) {
        let input = inputText.filter { $0.isNumber || $0 == "." }
        expression = input
        activeText = input.isEmpty ? "0" : input
        hasCompletedEvaluation = false
        repeatedEqualsOperation = nil
    }

    public mutating func enterDigit(_ digit: UInt8) {
        guard digit <= 9 else { return }

        if hasCompletedEvaluation {
            expression = ""
            hasCompletedEvaluation = false
            repeatedEqualsOperation = nil
        }

        expression.append(String(digit))
        activeText = expression
    }

    public mutating func enterDecimal() {
        if hasCompletedEvaluation {
            expression = ""
            hasCompletedEvaluation = false
            repeatedEqualsOperation = nil
        }

        let operand = currentOperandText
        guard !operand.contains(".") else { return }

        if operand.isEmpty || operand == "-" {
            expression.append("0")
        }

        expression.append(".")
        activeText = expression
    }

    public mutating func toggleSign() {
        if hasCompletedEvaluation {
            expression = toggledSignText(for: activeText)
            activeText = expression
            hasCompletedEvaluation = false
            repeatedEqualsOperation = nil
            return
        }

        guard !expression.isEmpty else { return }

        let operandRange = currentOperandRange
        let operand = expression[operandRange]

        if operand.isEmpty {
            if let (operatorRange, operation) = binaryOperatorBeforeCurrentOperand(operandRange),
               operation == .add || operation == .subtract {
                expression.replaceSubrange(operatorRange, with: operation == .add ? "-" : "+")
                activeText = expression
                return
            }

            expression.append("-")
        } else if operand == "-" {
            expression.removeSubrange(operandRange)
        } else if operand.hasPrefix("-") {
            expression.remove(at: operandRange.lowerBound)
        } else if let (operatorRange, operation) = binaryOperatorBeforeCurrentOperand(operandRange),
                  operation == .add || operation == .subtract {
            expression.replaceSubrange(operatorRange, with: operation == .add ? "-" : "+")
        } else {
            expression.insert("-", at: operandRange.lowerBound)
        }

        activeText = expression.isEmpty ? "0" : expression
    }

    public mutating func enterOperator(_ operation: Operator) {
        guard !activeText.isEmpty else { return }
        guard !isUndefined else { return }

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

        if let lastBinaryOperatorRange, currentOperandText.isEmpty {
            expression.replaceSubrange(lastBinaryOperatorRange, with: operation.displayText)
            activeText = expression
            return
        }

        expression.append(operation.displayText)
        activeText = expression
    }

    public mutating func evaluate() {
        if hasCompletedEvaluation, let repeatedEqualsOperation {
            guard let currentValue = Decimal(string: activeText) else { return }

            previousExpressionText = "\(format(currentValue))\(repeatedEqualsOperation.operation.displayText)\(format(repeatedEqualsOperation.operand))"

            guard let result = repeatedEqualsOperation.evaluate(with: currentValue) else {
                activeText = "Undefined"
                expression = ""
                self.repeatedEqualsOperation = nil
                return
            }

            activeText = format(result)
            expression = activeText
            return
        }

        guard !expression.isEmpty else { return }
        guard let parsedExpression = ParsedExpression(displayText: expression) else { return }

        previousExpressionText = parsedExpression.normalizedText
        guard let result = parsedExpression.evaluate() else {
            activeText = "Undefined"
            expression = ""
            hasCompletedEvaluation = true
            repeatedEqualsOperation = nil
            return
        }

        activeText = format(result)
        expression = activeText
        hasCompletedEvaluation = true
        repeatedEqualsOperation = parsedExpression.repeatedEqualsOperation
    }

    public mutating func removeLast() {
        if hasCompletedEvaluation {
            expression = ""
            activeText = "0"
            hasCompletedEvaluation = false
            repeatedEqualsOperation = nil
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
        repeatedEqualsOperation = nil
    }

    private var currentOperandText: Substring {
        expression[currentOperandRange]
    }

    private var currentOperandRange: Range<String.Index> {
        var operandStart = expression.startIndex
        var index = expression.startIndex

        while index < expression.endIndex {
            if isBinaryOperator(at: index) {
                operandStart = expression.index(after: index)
            }

            index = expression.index(after: index)
        }

        return operandStart..<expression.endIndex
    }

    private var lastOperatorRange: Range<String.Index>? {
        guard let lastIndex = expression.indices.last,
              Operator(displayText: expression[lastIndex]) != nil
        else { return nil }

        return lastIndex..<expression.index(after: lastIndex)
    }

    private var lastBinaryOperatorRange: Range<String.Index>? {
        guard let lastOperatorRange else { return nil }
        return isBinaryOperator(at: lastOperatorRange.lowerBound) ? lastOperatorRange : nil
    }

    private func binaryOperatorBeforeCurrentOperand(
        _ operandRange: Range<String.Index>
    ) -> (Range<String.Index>, Operator)? {
        guard operandRange.lowerBound > expression.startIndex else { return nil }

        let operatorIndex = expression.index(before: operandRange.lowerBound)
        guard isBinaryOperator(at: operatorIndex),
              let operation = Operator(displayText: expression[operatorIndex])
        else { return nil }

        return (operatorIndex..<expression.index(after: operatorIndex), operation)
    }

    private func isBinaryOperator(at index: String.Index) -> Bool {
        guard let operation = Operator(displayText: expression[index]) else { return false }
        guard operation == .subtract else { return true }
        guard index != expression.startIndex else { return false }

        let previousIndex = expression.index(before: index)
        return Operator(displayText: expression[previousIndex]) == nil
    }
}

private struct RepeatOperation {
    let operation: CalculatorModel.Operator
    let operand: Decimal

    func evaluate(with currentValue: Decimal) -> Decimal? {
        switch operation {
        case .add:
            currentValue + operand
        case .subtract:
            currentValue - operand
        case .multiply:
            currentValue * operand
        case .divide:
            operand == 0 ? nil : currentValue / operand
        }
    }
}

private extension CalculatorModel.Operator {
    init?(displayText: Character) {
        switch displayText {
        case "+":
            self = .add
        case "-":
            self = .subtract
        case "*":
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
            "*"
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

    var repeatedEqualsOperation: RepeatOperation? {
        guard let operation = operators.last else { return nil }
        return RepeatOperation(operation: operation, operand: operands[operators.count])
    }

    func evaluate() -> Decimal? {
        var reducedOperands = [operands[0]]
        var reducedOperators: [CalculatorModel.Operator] = []

        for (index, operation) in operators.enumerated() {
            let nextOperand = operands[index + 1]

            switch operation {
            case .multiply:
                reducedOperands[reducedOperands.count - 1] *= nextOperand
            case .divide:
                guard nextOperand != 0 else { return nil }
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

private func toggledSignText(for text: String) -> String {
    if text.hasPrefix("-") {
        return String(text.dropFirst())
    }

    return text == "0" ? text : "-\(text)"
}
