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
///     .font(.custom("Digital-7", size: 240))
/// ```
///
/// The panel renders the current value directly, allowing the active font to
/// define character widths and alignment.
public struct LCDPanel: View {
    private let activeText: String
    private let previousExpressionText: String?
    private let isPlaceholder: Bool

    /// Creates an LCD panel with no entered digit.
    public init() {
        self.init(value: Value())
    }

    /// Creates an LCD panel displaying the entries from `value`.
    ///
    /// - Parameters:
    ///   - value: The calculator entry value to render.
    public init(value: Value) {
        self.init(activeText: value.text, isPlaceholder: value.isEmpty)
    }

    /// Creates an LCD panel displaying active calculator text and optional
    /// previous expression context.
    ///
    /// - Parameters:
    ///   - activeText: The current expression or result to render.
    ///   - previousExpressionText: The most recently evaluated expression.
    ///   - isPlaceholder: Whether `activeText` is placeholder content.
    public init(
        activeText: String,
        previousExpressionText: String? = nil,
        isPlaceholder: Bool = false
    ) {
        self.activeText = activeText
        self.previousExpressionText = previousExpressionText
        self.isPlaceholder = isPlaceholder
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Text(activeText)
                .multilineTextAlignment(.trailing)
                .opacity(isPlaceholder ? 0.1 : 1)
                .font(.custom("Digital-7", size: 128))
                .lineLimit(1)
                .minimumScaleFactor(0.2)

            if let previousExpressionDisplayText {
                Text(previousExpressionDisplayText)
                    .multilineTextAlignment(.trailing)
                    .opacity(0.45)
                    .font(.custom("Digital-7", size: 38))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .offset(y: -82)
            }
        }
    }

    private var previousExpressionDisplayText: String? {
        guard let text = previousExpressionText?.replacingOccurrences(of: "=", with: ""),
              !text.isEmpty
        else { return nil }

        return text
    }
}
