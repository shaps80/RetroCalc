import SwiftUI

/// A calculator-style text display.
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
/// The panel renders the current value directly, allowing the active font to
/// define character widths and alignment.
public struct LCDPanel: View {
    private let value: Value

    /// Creates an LCD panel with no entered digit.
    public init() {
        self.init(value: Value())
    }

    /// Creates an LCD panel displaying the entries from `value`.
    ///
    /// - Parameters:
    ///   - value: The calculator entry value to render.
    public init(value: Value) {
        self.value = value
    }

    public var body: some View {
        Text(value.text)
            .multilineTextAlignment(.trailing)
            .opacity(value.isEmpty ? 0.1 : 1)
            .font(.custom("Calculator", size: 128))
            .lineLimit(1)
            .minimumScaleFactor(0.2)
    }
}
