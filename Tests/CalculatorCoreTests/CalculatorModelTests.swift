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

        #expect(calculator.activeText == "12+3*4")
        #expect(calculator.previousExpressionText == nil)
    }

    @Test
    func equalsEvaluatesUsingMultiplicationPrecedenceAndStoresPreviousExpression() {
        var calculator = CalculatorModel()

        enter("12+3*4", into: &calculator)
        calculator.evaluate()

        #expect(calculator.activeText == "24")
        #expect(calculator.previousExpressionText == "12+3*4")
    }

    @Test
    func operatorAfterResultContinuesFromResult() {
        var calculator = CalculatorModel()

        enter("12+3", into: &calculator)
        calculator.evaluate()
        enter("*2", into: &calculator)
        calculator.evaluate()

        #expect(calculator.activeText == "30")
        #expect(calculator.previousExpressionText == "15*2")
    }

    @Test
    func repeatedEqualsRepeatsLastAdditionAgainstCurrentResult() {
        var calculator = CalculatorModel()

        enter("2+3", into: &calculator)
        calculator.evaluate()
        #expect(calculator.activeText == "5")

        calculator.evaluate()
        #expect(calculator.activeText == "8")

        calculator.evaluate()
        #expect(calculator.activeText == "11")
    }

    @Test
    func repeatedEqualsRepeatsLastOperationForOtherOperators() {
        var subtraction = CalculatorModel()
        enter("10-4", into: &subtraction)
        subtraction.evaluate()
        #expect(subtraction.activeText == "6")
        subtraction.evaluate()
        #expect(subtraction.activeText == "2")

        var multiplication = CalculatorModel()
        enter("3*4", into: &multiplication)
        multiplication.evaluate()
        #expect(multiplication.activeText == "12")
        multiplication.evaluate()
        #expect(multiplication.activeText == "48")

        var division = CalculatorModel()
        enter("20÷2", into: &division)
        division.evaluate()
        #expect(division.activeText == "10")
        division.evaluate()
        #expect(division.activeText == "5")
    }

    @Test
    func digitAfterResultClearsRepeatedEqualsOperationForFreshCalculation() {
        var calculator = CalculatorModel()

        enter("2+3", into: &calculator)
        calculator.evaluate()
        calculator.enterDigit(9)
        calculator.evaluate()
        calculator.evaluate()

        #expect(calculator.activeText == "9")
        #expect(calculator.previousExpressionText == "9")
    }

    @Test
    func operatorAfterResultUpdatesRepeatedEqualsOperationAfterNextEvaluation() {
        var calculator = CalculatorModel()

        enter("2+3", into: &calculator)
        calculator.evaluate()
        enter("*2", into: &calculator)
        calculator.evaluate()
        calculator.evaluate()

        #expect(calculator.activeText == "20")
        #expect(calculator.previousExpressionText == "10*2")
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
    func replacingActiveInputKeepsPreviousExpression() {
        var calculator = CalculatorModel()

        enter("12+3", into: &calculator)
        calculator.evaluate()
        calculator.replaceActiveInput(with: "5307")

        #expect(calculator.activeText == "5307")
        #expect(calculator.previousExpressionText == "12+3")
    }

    @Test
    func replacingActiveInputStartsFreshCalculation() {
        var calculator = CalculatorModel()

        enter("2+3", into: &calculator)
        calculator.evaluate()
        calculator.replaceActiveInput(with: "5307")
        calculator.enterOperator(.add)
        calculator.enterDigit(1)
        calculator.evaluate()
        calculator.evaluate()

        #expect(calculator.activeText == "5309")
        #expect(calculator.previousExpressionText == "5308+1")
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

        enter("1000000000000000*1000", into: &calculator)
        calculator.evaluate()

        #expect(calculator.activeText == "1000000000000000000")
    }

    @Test
    func minusAfterOperatorStartsNegativeOperandAndEvaluatesProduct() {
        var calculator = CalculatorModel()

        enter("7*-2", into: &calculator)
        #expect(calculator.activeText == "7*-2")

        calculator.evaluate()
        #expect(calculator.activeText == "-14")
        #expect(calculator.previousExpressionText == "7*-2")
    }

    @Test
    func minusAtExpressionStartEntersNegativeNumber() {
        var calculator = CalculatorModel()

        enter("-12", into: &calculator)

        #expect(calculator.activeText == "-12")
    }

    @Test
    func repeatedBinaryOperatorsReplacePreviousOperator() {
        var calculator = CalculatorModel()

        enter("7+*2", into: &calculator)

        #expect(calculator.activeText == "7*2")
    }

    @Test
    func plusAfterOperatorReplacesOperatorInsteadOfEnteringUnaryPlus() {
        var calculator = CalculatorModel()

        enter("7*+2", into: &calculator)

        #expect(calculator.activeText == "7+2")
    }

    @Test
    func unaryPlusAtExpressionStartIsUnsupported() {
        var calculator = CalculatorModel()

        enter("+2", into: &calculator)

        #expect(calculator.activeText == "2")
    }

    @Test
    func plusMinusTogglesCurrentOperandWhileEditing() {
        var calculator = CalculatorModel()

        enter("7*2", into: &calculator)
        calculator.toggleSign()
        #expect(calculator.activeText == "7*-2")

        calculator.toggleSign()
        #expect(calculator.activeText == "7*2")
    }

    @Test
    func plusMinusTogglesCompletedResultIntoActiveExpression() {
        var calculator = CalculatorModel()

        enter("12+3", into: &calculator)
        calculator.evaluate()
        calculator.toggleSign()

        #expect(calculator.activeText == "-15")
        #expect(calculator.previousExpressionText == "12+3")

        calculator.enterOperator(.multiply)
        calculator.enterDigit(2)
        calculator.evaluate()
        #expect(calculator.activeText == "-30")
        #expect(calculator.previousExpressionText == "-15*2")
    }

    @Test
    func divisionByZeroShowsUndefinedAndStoresAttemptedExpression() {
        var calculator = CalculatorModel()

        enter("0012÷0", into: &calculator)
        calculator.evaluate()

        #expect(calculator.activeText == "Undefined")
        #expect(calculator.previousExpressionText == "12÷0")
    }

    @Test
    func undefinedIgnoresOperatorsAndRecoversWithFreshDigitOrDecimal() {
        var calculator = CalculatorModel()

        enter("4÷0", into: &calculator)
        calculator.evaluate()
        calculator.enterOperator(.add)

        #expect(calculator.activeText == "Undefined")

        calculator.enterDigit(9)
        #expect(calculator.activeText == "9")
        #expect(calculator.previousExpressionText == "4÷0")

        var decimalCalculator = CalculatorModel()

        enter("5÷0", into: &decimalCalculator)
        decimalCalculator.evaluate()
        decimalCalculator.enterOperator(.multiply)
        decimalCalculator.enterDecimal()

        #expect(decimalCalculator.activeText == "0.")
        #expect(decimalCalculator.previousExpressionText == "5÷0")
    }

    @Test
    func clearRemovesActiveValueBeforePreviousExpression() {
        var calculator = CalculatorModel()

        enter("12+3", into: &calculator)
        calculator.evaluate()
        calculator.clear()

        #expect(calculator.activeText == "0")
        #expect(calculator.previousExpressionText == "12+3")

        calculator.clear()

        #expect(calculator.activeText == "0")
        #expect(calculator.previousExpressionText == nil)
    }

    @Test
    func backspaceCorrectsIncompleteInputBeforeEvaluation() {
        var calculator = CalculatorModel()

        enter("12÷0", into: &calculator)
        calculator.removeLast()
        enter("3", into: &calculator)
        calculator.evaluate()

        #expect(calculator.activeText == "4")
        #expect(calculator.previousExpressionText == "12÷3")

        calculator.clear()
        enter("12*-", into: &calculator)
        calculator.removeLast()
        enter("3", into: &calculator)
        calculator.evaluate()

        #expect(calculator.activeText == "36")
        #expect(calculator.previousExpressionText == "12*3")
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
            case "*":
                calculator.enterOperator(.multiply)
            case "÷":
                calculator.enterOperator(.divide)
            default:
                break
            }
        }
    }
}
