import Foundation

public extension LCDPanel {
    /// A calculator entry buffer that preserves editing intent.
    ///
    /// `Value` starts with an empty entry buffer and preserves the entered text,
    /// including leading integer zeros and fractional zeros:
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
        public var isEmpty: Bool { entries.isEmpty }

        /// Creates a value initialized to zero.
        public init() {}

        /// Creates a value from already-formatted calculator input text.
        public init(inputText: String) {
            entries = inputText.compactMap { character in
                switch character {
                case "0"..."9":
                    return character.wholeNumberValue.map { .digit(UInt8($0)) }
                case ".":
                    return .decimalSeparator
                default:
                    return nil
                }
            }
        }

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

        public mutating func clear() {
            entries.removeAll()
        }

        internal var firstDigit: Int? {
            guard case let .digit(digit) = entries.first else { return nil }

            return Int(digit)
        }

        internal var text: String {
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

            entries.append(.digit(digit))
        }
    }
}
