import SwiftUI

struct CalcButton<Content: View>: View {
    @ViewBuilder var content: Content
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            content
                .font(.system(size: 28))
        }
        .aspectRatio(1.1, contentMode: .fit)
        .buttonStyle(CalculatorButtonStyle())
    }
}

extension CalcButton {
    init(_ value: Int, action: @escaping () -> Void) where Content == Text {
        self.content = Text(value, format: .number)
        self.action = action
    }

    init(_ value: String, action: @escaping () -> Void) where Content == Text {
        self.content = Text(value)
        self.action = action
    }

    init(systemImage: String, action: @escaping () -> Void) where Content == Image {
        self.content = Image(systemName: systemImage)
        self.action = action
    }
}

private struct CalculatorButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var scheme

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Color.bg

            if configuration.isPressed {
                Rectangle()
                    .foregroundStyle(.tint)
                    .opacity(0.03)
            }

            configuration.label
                .foregroundStyle(.tint)
        }
        .clipShape(.rect(cornerRadius: 18))
        .shadow(
            color: darkShadow(isPressed: configuration.isPressed),
            radius: 2,
            x: 2,
            y: 2
        )
        .shadow(
            color: lightShadow(isPressed: configuration.isPressed),
            radius: 2,
            x: -2,
            y: -2
        )
        .offset(y: configuration.isPressed ? 1 : 0)
        .lineLimit(1)
        .minimumScaleFactor(1)
        .animation(.bouncy.speed(2), value: configuration.isPressed)
    }

    private func darkShadow(isPressed: Bool) -> Color {
        switch scheme {
        case .dark:
            .black.opacity(isPressed ? 0.05 : 0.35)
        default:
            .black.opacity(isPressed ? 0.05 : 0.15)
        }
    }

    private func lightShadow(isPressed: Bool) -> Color {
        switch scheme {
        case .dark:
            .white.opacity(isPressed ? 0.01 : 0.03)
        default:
            .white.opacity(isPressed ? 0.15 : 1)
        }
    }
}
