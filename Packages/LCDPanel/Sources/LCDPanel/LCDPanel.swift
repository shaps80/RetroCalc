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
/// ```
///
/// This first rendering slice shows the first entered digit in the value as a
/// seven-segment LCD digit. An empty value leaves every segment inactive.
public struct LCDPanel: View {
    private let value: Value

    /// Creates an LCD panel with no entered digit.
    public init() {
        self.init(value: Value())
    }

    /// Creates an LCD panel displaying the first entered digit from `value`.
    ///
    /// - Parameter value: The calculator entry value to render.
    public init(value: Value) {
        self.value = value
    }

    public var body: some View {
        Digit(value.firstDigit)
            .aspectRatio(0.55, contentMode: .fit)
    }
}
