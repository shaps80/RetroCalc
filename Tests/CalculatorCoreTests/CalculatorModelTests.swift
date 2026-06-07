import Testing
@testable import CalculatorCore

@Suite
struct CalculatorModelTests {
    @Test
    func enteringExpressionShowsActiveExpressionBeforeEquals() {
        var calculator = CalculatorModel()

        calculator.enterDigit(1)
        calculator.enterDigit(2)
        calculator.enterOperator(.add)
        calculator.enterDigit(3)
        calculator.enterOperator(.multiply)
        calculator.enterDigit(4)

        #expect(calculator.activeText == "12+3x4")
        #expect(calculator.previousExpressionText == nil)
    }

    @Test
    func equalsEvaluatesUsingMultiplicationPrecedenceAndStoresPreviousExpression() {
        var calculator = CalculatorModel()

        enter("12+3x4", into: &calculator)
        calculator.evaluate()

        #expect(calculator.activeText == "24")
        #expect(calculator.previousExpressionText == "12+3x4")
    }

    @Test
    func operatorAfterResultContinuesFromResult() {
        var calculator = CalculatorModel()

        enter("12+3", into: &calculator)
        calculator.evaluate()
        enter("x2", into: &calculator)
        calculator.evaluate()

        #expect(calculator.activeText == "30")
        #expect(calculator.previousExpressionText == "15x2")
    }

    @Test
    func digitAfterResultStartsFreshExpressionAndKeepsPreviousExpression() {
        var calculator = CalculatorModel()

        enter("12+3", into: &calculator)
        calculator.evaluate()
        calculator.enterDigit(9)

        #expect(calculator.activeText == "9")
        #expect(calculator.previousExpressionText == "12+3")
    }

    @Test
    func emptyEqualsIsNoOp() {
        var calculator = CalculatorModel()

        calculator.evaluate()

        #expect(calculator.activeText == "0")
        #expect(calculator.previousExpressionText == nil)
    }

    @Test
    func singleNumberEqualsKeepsNumberAsResultAndPreviousExpression() {
        var calculator = CalculatorModel()

        enter("12", into: &calculator)
        calculator.evaluate()

        #expect(calculator.activeText == "12")
        #expect(calculator.previousExpressionText == "12")
    }

    @Test
    func decimalAtOperandStartDisplaysLeadingZero() {
        var calculator = CalculatorModel()

        calculator.enterDecimal()

        #expect(calculator.activeText == "0.")
    }

    @Test
    func decimalAfterOperatorStartsNextOperandWithLeadingZero() {
        var calculator = CalculatorModel()

        enter("1+", into: &calculator)
        calculator.enterDecimal()

        #expect(calculator.activeText == "1+0.")
    }

    @Test
    func decimalEntryAllowsOnlyOneSeparatorPerOperand() {
        var calculator = CalculatorModel()

        enter("1.2", into: &calculator)
        calculator.enterDecimal()
        enter("+3.4", into: &calculator)
        calculator.enterDecimal()

        #expect(calculator.activeText == "1.2+3.4")
    }

    @Test
    func activeDecimalTypingPreservesUnfinishedDecimalsAndFractionalZeroes() {
        var calculator = CalculatorModel()

        enter("12.", into: &calculator)
        #expect(calculator.activeText == "12.")

        enter("300", into: &calculator)
        #expect(calculator.activeText == "12.300")
    }

    @Test
    func equalsNormalizesPreviousExpressionDecimalOperands() {
        var calculator = CalculatorModel()

        enter("001.2300+4.", into: &calculator)
        calculator.evaluate()

        #expect(calculator.previousExpressionText == "1.23+4")
    }

    @Test
    func resultFormattingRemovesUnnecessaryFractionalZeroes() {
        var calculator = CalculatorModel()

        enter("1.50+1.50", into: &calculator)
        calculator.evaluate()

        #expect(calculator.activeText == "3")
    }

    @Test
    func resultFormattingPreservesNeededDecimals() {
        var calculator = CalculatorModel()

        enter("1÷4", into: &calculator)
        calculator.evaluate()

        #expect(calculator.activeText == "0.25")
    }

    @Test
    func resultFormattingDoesNotIntroduceScientificNotation() {
        var calculator = CalculatorModel()

        enter("1000000000000000x1000", into: &calculator)
        calculator.evaluate()

        #expect(calculator.activeText == "1000000000000000000")
    }

    private func enter(_ text: String, into calculator: inout CalculatorModel) {
        for character in text {
            switch character {
            case "0"..."9":
                calculator.enterDigit(UInt8(character.wholeNumberValue ?? 0))
            case ".":
                calculator.enterDecimal()
            case "+":
                calculator.enterOperator(.add)
            case "-":
                calculator.enterOperator(.subtract)
            case "x":
                calculator.enterOperator(.multiply)
            case "÷":
                calculator.enterOperator(.divide)
            default:
                break
            }
        }
    }
}
