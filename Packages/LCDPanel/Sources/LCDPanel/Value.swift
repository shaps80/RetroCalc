import Foundation

public extension LCDPanel {
    /// A calculator entry buffer that preserves editing intent.
    ///
    /// `Value` starts with an empty entry buffer, normalizes integer leading
    /// zeros once entry begins, and preserves fractional zeros during entry:
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
        internal enum Entry: Equatable {
            case digit(UInt8)
            case decimalSeparator
        }

        internal private(set) var entries: [Entry] = []

        /// Creates a value initialized to zero.
        public init() {}

        /// Appends every digit from an unsigned integer.
        ///
        /// - Parameter value: The unsigned integer whose digits should be appended.
        public mutating func append(_ value: UInt) {
            for digit in String(value).compactMap(\.wholeNumberValue) {
                appendDigit(UInt8(digit))
            }
        }

        /// Appends a decimal separator if the value does not already contain one.
        public mutating func appendDecimal() {
            guard !entries.contains(.decimalSeparator) else { return }

            if entries.isEmpty {
                entries.append(.digit(0))
            }

            entries.append(.decimalSeparator)
        }

        /// Removes the last entered digit or decimal separator.
        ///
        /// Removing past the final digit leaves the value at zero.
        public mutating func removeLast() {
            _ = entries.popLast()
        }

        /// The numeric value represented by the entry buffer.
        public var decimal: Decimal {
            Decimal(string: text) ?? Decimal(0)
        }

        internal var firstDigit: Int? {
            guard case let .digit(digit) = entries.first else { return nil }

            return Int(digit)
        }

        private var text: String {
            guard !entries.isEmpty else { return "0" }

            return entries.map { entry in
                switch entry {
                case let .digit(digit):
                    return String(digit)
                case .decimalSeparator:
                    return "."
                }
            }.joined()
        }

        private mutating func appendDigit(_ digit: UInt8) {
            guard digit <= 9 else { return }

            if entries.isEmpty || entries == [.digit(0)] {
                entries = digit == 0 ? [.digit(0)] : [.digit(digit)]
            } else {
                entries.append(.digit(digit))
            }
        }
    }
}
