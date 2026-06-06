import Foundation

public extension LCDPanel {
    /// A calculator entry buffer that preserves editing intent.
    ///
    /// `Value` normalizes integer leading zeros while preserving fractional
    /// zeros during entry:
    ///
    /// ```swift
    /// var value = LCDPanel.Value()
    /// value.append(1)
    /// value.appendDecimal()
    /// value.append(0)
    ///
    /// value.decimal // 1.0
    /// ```
    struct Value {
        private var text = "0"

        /// Creates a value initialized to zero.
        public init() {}

        /// Appends every digit from an unsigned integer.
        ///
        /// - Parameter value: The unsigned integer whose digits should be appended.
        public mutating func append(_ value: UInt) {
            let digits = String(value)

            if text == "0" {
                text = digits == "0" ? "0" : digits
            } else {
                text += digits
            }
        }

        /// Appends a decimal separator if the value does not already contain one.
        public mutating func appendDecimal() {
            guard !text.contains(".") else { return }

            text += "."
        }

        /// Removes the last entered digit or decimal separator.
        ///
        /// Removing past the final digit leaves the value at zero.
        public mutating func removeLast() {
            guard text.count > 1 else {
                text = "0"
                return
            }

            text.removeLast()

            if text.isEmpty {
                text = "0"
            }
        }

        /// The numeric value represented by the entry buffer.
        public var decimal: Decimal {
            Decimal(string: text) ?? Decimal(0)
        }

        var firstDigit: Int {
            text.first?.wholeNumberValue ?? 0
        }
    }
}
