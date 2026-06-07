import SwiftUI

/// A calculator-style LCD panel.
///
/// Use `LCDPanel` as the display surface for calculator input state:
///
/// ```swift
/// var value = LCDPanel.Value()
/// value.append(42)
///
/// LCDPanel(value: value)
///     .font(.custom("Calculator", size: 240))
/// ```
///
/// The panel always renders every digit position as an inactive `8`, then
/// overlays the active digits entered by the user. Decimal points are narrow
/// placeholders between digit positions, so enabling one does not consume a
/// full digit slot.
public struct LCDPanel: View {
    private let value: Value
    private let digitCount: Int

    /// Creates an LCD panel with no entered digit.
    public init() {
        self.init(value: Value())
    }

    /// Creates an LCD panel displaying the entries from `value`.
    ///
    /// - Parameters:
    ///   - value: The calculator entry value to render.
    ///   - digitCount: The number of always-visible digit positions.
    public init(value: Value, digitCount: Int = 6) {
        self.value = value
        self.digitCount = max(1, digitCount)
    }

    public var body: some View {
        LCDLayout {
            ForEach(displayElements) { element in
                switch element.kind {
                case let .digit(digit):
                    Digit(digit)
                        .layoutValue(key: LCDLayoutRoleKey.self, value: .digit)
                case let .decimalPoint(isActive):
                    DecimalPoint(isActive: isActive)
                        .layoutValue(key: LCDLayoutRoleKey.self, value: .decimalPoint)
                }
            }
        }
    }

    private var displayElements: [DisplayElement] {
        let displayModel = DisplayModel(entries: value.entries, digitCount: digitCount)
        var elements: [DisplayElement] = []

        for slot in 0..<digitCount {
            elements.append(
                DisplayElement(
                    kind: .digit(displayModel.digitsBySlot[slot]),
                    index: elements.count
                )
            )

            if slot < digitCount - 1 {
                elements.append(
                    DisplayElement(
                        kind: .decimalPoint(isActive: displayModel.decimalPointSlot == slot),
                        index: elements.count
                    )
                )
            }
        }

        return elements
    }
}

private struct DisplayModel {
    let digitsBySlot: [Int: UInt8]
    let decimalPointSlot: Int?

    init(entries: [LCDPanel.Value.Entry], digitCount: Int) {
        guard digitCount > 0 else {
            digitsBySlot = [:]
            decimalPointSlot = nil
            return
        }

        var digits: [UInt8] = []
        var decimalPointIndex: Int?

        for entry in entries {
            switch entry {
            case let .digit(digit):
                digits.append(digit)
            case .decimalSeparator:
                decimalPointIndex = max(0, digits.count - 1)
            }
        }

        let needsTrailingDecimalSlot = decimalPointIndex == digits.count - 1
        let occupiedDigitCount = min(digitCount, digits.count + (needsTrailingDecimalSlot ? 1 : 0))
        let visibleDigits = Array(digits.suffix(min(digits.count, occupiedDigitCount)))
        let startSlot = max(0, digitCount - occupiedDigitCount)
        let droppedDigitCount = digits.count - visibleDigits.count

        digitsBySlot = Dictionary(
            uniqueKeysWithValues: visibleDigits.enumerated().map { offset, digit in
                (startSlot + offset, digit)
            }
        )

        if let decimalPointIndex {
            let visibleDecimalIndex = decimalPointIndex - droppedDigitCount
            let slot = startSlot + visibleDecimalIndex
            decimalPointSlot = (0..<max(0, digitCount - 1)).contains(slot) ? slot : nil
        } else {
            decimalPointSlot = nil
        }
    }
}

private struct DisplayElement: Identifiable {
    enum Kind {
        case digit(UInt8?)
        case decimalPoint(isActive: Bool)
    }

    let kind: Kind
    let index: Int

    var id: Int { index }
}

private struct DecimalPoint: View {
    let isActive: Bool

    var body: some View {
        Text(".")
            .foregroundStyle(isActive ? activeColor : inactiveColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private var activeColor: Color {
        Color.black.opacity(0.78)
    }

    private var inactiveColor: Color {
        Color.black.opacity(0.10)
    }
}
