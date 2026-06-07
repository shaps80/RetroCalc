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

    private func enter(_ text: String, into calculator: inout CalculatorModel) {
        for character in text {
            switch character {
            case "0"..."9":
                calculator.enterDigit(UInt8(character.wholeNumberValue ?? 0))
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
