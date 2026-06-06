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
/// This first rendering slice shows the first digit in the value as a
/// seven-segment LCD digit.
public struct LCDPanel: View {
    private let value: Value

    /// Creates an LCD panel displaying zero.
    public init() {
        self.init(value: Value())
    }

    /// Creates an LCD panel displaying the first digit from `value`.
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
