import XCTest
@testable import LCDPanel

final class LCDPanelValueTests: XCTestCase {
    func testValueStartsEmptyWithZeroDecimalValue() {
        let value = LCDPanel.Value()

        XCTAssertEqual(value.decimal, Decimal(0))
        XCTAssertEqual(value.entries, [])
        XCTAssertNil(value.firstDigit)
    }

    func testAppendingZeroRecordsEnteredZero() {
        var value = LCDPanel.Value()

        value.append(0)

        XCTAssertEqual(value.decimal, Decimal(0))
        XCTAssertEqual(value.entries, [.digit(0)])
        XCTAssertEqual(value.firstDigit, 0)
    }

    func testAppendUnsignedIntegerDigits() {
        var value = LCDPanel.Value()

        value.append(12)
        value.append(34)

        XCTAssertEqual(value.decimal, Decimal(1234))
        XCTAssertEqual(value.entries, [.digit(1), .digit(2), .digit(3), .digit(4)])
    }

    func testAppendMultiDigitUnsignedIntegerStoresEachDigitEntry() {
        var value = LCDPanel.Value()

        value.append(123)

        XCTAssertEqual(value.entries, [.digit(1), .digit(2), .digit(3)])
    }

    func testIntegerLeadingZerosArePreserved() {
        var value = LCDPanel.Value()

        value.append(0)
        value.append(0)
        value.append(7)

        XCTAssertEqual(value.decimal, Decimal(7))
        XCTAssertEqual(value.text, "007")
        XCTAssertEqual(value.entries, [.digit(0), .digit(0), .digit(7)])
    }

    func testInputTextInitializerPreservesLeadingZeros() {
        let value = LCDPanel.Value(inputText: "007")

        XCTAssertEqual(value.decimal, Decimal(7))
        XCTAssertEqual(value.text, "007")
        XCTAssertEqual(value.entries, [.digit(0), .digit(0), .digit(7)])
    }

    func testAppendDecimalPlacesFollowingDigitsAfterSeparator() {
        var value = LCDPanel.Value()

        value.append(12)
        value.appendDecimal()
        value.append(3)

        XCTAssertEqual(value.text, "12.3")
        XCTAssertEqual(value.decimal, Decimal(string: "12.3"))
        XCTAssertEqual(value.entries, [.digit(1), .digit(2), .decimalSeparator, .digit(3)])
    }

    func testTrailingDecimalIsPreservedInDisplayText() {
        var value = LCDPanel.Value()

        value.append(6)
        value.appendDecimal()

        XCTAssertEqual(value.text, "6.")
        XCTAssertEqual(value.decimal, Decimal(6))
        XCTAssertEqual(value.entries, [.digit(6), .decimalSeparator])
    }

    func testAppendDecimalIsNoOpWhenSeparatorAlreadyExists() {
        var value = LCDPanel.Value()

        value.append(1)
        value.appendDecimal()
        value.appendDecimal()
        value.append(2)

        XCTAssertEqual(value.decimal, Decimal(string: "1.2"))
        XCTAssertEqual(value.entries, [.digit(1), .decimalSeparator, .digit(2)])
    }

    func testFractionalZerosArePreservedWhileEditing() {
        var value = LCDPanel.Value()

        value.appendDecimal()
        value.append(0)
        value.append(5)

        XCTAssertEqual(value.text, "0.05")
        XCTAssertEqual(value.decimal, Decimal(string: "0.05"))
        XCTAssertEqual(value.entries, [.digit(0), .decimalSeparator, .digit(0), .digit(5)])
    }

    func testRemoveLastRemovesDigitsAndReturnsToEmptyEntry() {
        var value = LCDPanel.Value()

        value.append(12)
        value.removeLast()
        XCTAssertEqual(value.decimal, Decimal(1))
        XCTAssertEqual(value.entries, [.digit(1)])

        value.removeLast()
        XCTAssertEqual(value.decimal, Decimal(0))
        XCTAssertEqual(value.entries, [])

        value.removeLast()
        XCTAssertEqual(value.decimal, Decimal(0))
        XCTAssertEqual(value.entries, [])
    }

    func testRemoveLastRemovesFractionalDigitsBeforeDecimalSeparator() {
        var value = LCDPanel.Value()

        value.append(1)
        value.appendDecimal()
        value.append(2)
        value.removeLast()
        value.append(3)
        XCTAssertEqual(value.decimal, Decimal(string: "1.3"))
        XCTAssertEqual(value.entries, [.digit(1), .decimalSeparator, .digit(3)])

        value.removeLast()
        value.removeLast()
        value.append(4)
        XCTAssertEqual(value.decimal, Decimal(14))
        XCTAssertEqual(value.entries, [.digit(1), .digit(4)])
    }
}
