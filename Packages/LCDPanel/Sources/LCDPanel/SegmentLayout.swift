import SwiftUI

struct SegmentLayout: Layout {
    struct Metrics {
        let thickness: CGFloat
        let inset: CGFloat
        let topY: CGFloat
        let centerY: CGFloat
        let bottomY: CGFloat
        let leftX: CGFloat
        let rightX: CGFloat
        let horizontalWidth: CGFloat
        let upperVerticalHeight: CGFloat
        let lowerVerticalHeight: CGFloat
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        proposal.replacingUnspecifiedDimensions(by: CGSize(width: 55, height: 100))
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let metrics = Self.metrics(in: bounds)

        for subview in subviews {
            let segment = subview[SegmentLayoutValueKey.self]
            let frame = Self.frame(for: segment, in: bounds, metrics: metrics)

            subview.place(
                at: CGPoint(x: frame.midX, y: frame.midY),
                anchor: .center,
                proposal: ProposedViewSize(width: frame.width, height: frame.height)
            )
        }
    }

    static func metrics(in rect: CGRect) -> Metrics {
        let thickness = min(rect.width, rect.height) * 0.16
        let inset = thickness * 0.45
        let topY = rect.minY + inset
        let centerY = rect.midY - thickness / 2
        let bottomY = rect.maxY - inset - thickness
        let leftX = rect.minX + inset
        let rightX = rect.maxX - inset - thickness

        return Metrics(
            thickness: thickness,
            inset: inset,
            topY: topY,
            centerY: centerY,
            bottomY: bottomY,
            leftX: leftX,
            rightX: rightX,
            horizontalWidth: max(0, rightX - leftX + thickness),
            upperVerticalHeight: max(0, centerY - topY + thickness),
            lowerVerticalHeight: max(0, bottomY - centerY + thickness)
        )
    }

    static func frame(for segment: Segment, in rect: CGRect, metrics: Metrics) -> CGRect {
        switch segment {
        case .top:
            return horizontalFrame(y: metrics.topY, metrics: metrics)
        case .center:
            return horizontalFrame(y: metrics.centerY, metrics: metrics)
        case .bottom:
            return horizontalFrame(y: metrics.bottomY, metrics: metrics)
        case .topLeft:
            return verticalFrame(
                x: metrics.leftX,
                y: metrics.topY,
                height: metrics.upperVerticalHeight,
                metrics: metrics
            )
        case .bottomLeft:
            return verticalFrame(
                x: metrics.leftX,
                y: metrics.centerY,
                height: metrics.lowerVerticalHeight,
                metrics: metrics
            )
        case .topRight:
            return verticalFrame(
                x: metrics.rightX,
                y: metrics.topY,
                height: metrics.upperVerticalHeight,
                metrics: metrics
            )
        case .bottomRight:
            return verticalFrame(
                x: metrics.rightX,
                y: metrics.centerY,
                height: metrics.lowerVerticalHeight,
                metrics: metrics
            )
        }
    }

    private static func horizontalFrame(y: CGFloat, metrics: Metrics) -> CGRect {
        CGRect(
            x: metrics.leftX,
            y: y,
            width: metrics.horizontalWidth,
            height: metrics.thickness
        )
    }

    private static func verticalFrame(
        x: CGFloat,
        y: CGFloat,
        height: CGFloat,
        metrics: Metrics
    ) -> CGRect {
        CGRect(
            x: x,
            y: y,
            width: metrics.thickness,
            height: height
        )
    }
}

struct SegmentLayoutValueKey: LayoutValueKey {
    static let defaultValue: Segment = .top
}
