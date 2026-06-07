import SwiftUI

struct LCDLayout: Layout {
    private let digitAspectRatio: CGFloat = 0.55
    private let decimalPointWidthRatio: CGFloat = 0.12

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let height = proposal.height ?? 100

        return CGSize(
            width: subviews.reduce(0) { width, subview in
                width + slotWidth(for: subview[LCDLayoutRoleKey.self], height: height)
            },
            height: height
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX

        for subview in subviews {
            let width = slotWidth(for: subview[LCDLayoutRoleKey.self], height: bounds.height)

            subview.place(
                at: CGPoint(x: x, y: bounds.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: width, height: bounds.height)
            )

            x += width
        }
    }

    private func slotWidth(for role: LCDLayoutRole, height: CGFloat) -> CGFloat {
        switch role {
        case .digit:
            return height * digitAspectRatio
        case .decimalPoint:
            return height * decimalPointWidthRatio
        }
    }
}

enum LCDLayoutRole {
    case digit
    case decimalPoint
}

struct LCDLayoutRoleKey: LayoutValueKey {
    static let defaultValue: LCDLayoutRole = .digit
}
