import SwiftUI

public struct LCDPanel: View {
    public struct Value {
        private var text = "0"

        public init() {}

        public mutating func append(_ value: UInt) {
            let digits = String(value)

            if text == "0" {
                text = digits == "0" ? "0" : digits
            } else {
                text += digits
            }
        }

        public mutating func appendDecimal() {
            guard !text.contains(".") else { return }

            text += "."
        }

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

        public var decimal: Decimal {
            Decimal(string: text) ?? Decimal(0)
        }
    }

    public init() {}

    public var body: some View {
        Color.red
    }
}

public struct LCDPanelView: View {
    public init() {}

    public var body: some View {
        Color.red
    }
}
