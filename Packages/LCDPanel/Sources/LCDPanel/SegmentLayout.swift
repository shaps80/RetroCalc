import SwiftUI

struct SegmentLayout: Layout {
    static let gapRatio: CGFloat = 0.12

    struct Metrics {
        let thickness: CGFloat
        let inset: CGFloat
        let segmentGap: CGFloat
        let middleY: CGFloat
        let topY: CGFloat
        let bottomY: CGFloat
        let verticalTopY: CGFloat
        let verticalBottomY: CGFloat
        let topVerticalHeight: CGFloat
        let bottomVerticalHeight: CGFloat
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
        let middleY = rect.midY - thickness / 2
        let topY = rect.minY + inset
        let bottomY = rect.maxY - inset - thickness
        let centerY = middleY
        let segmentGap = thickness * Self.gapRatio
        let bottomOverlap = thickness * 0.85
        let centerOverlap = thickness * 0.25
        let verticalTopY = topY
        let verticalBottomY = centerY + thickness - centerOverlap

        return Metrics(
            thickness: thickness,
            inset: inset,
            segmentGap: segmentGap,
            middleY: middleY,
            topY: topY,
            bottomY: bottomY,
            verticalTopY: verticalTopY,
            verticalBottomY: verticalBottomY,
            topVerticalHeight: max(0, centerY - verticalTopY + centerOverlap),
            bottomVerticalHeight: max(0, bottomY - verticalBottomY + bottomOverlap)
        )
    }

    static func frame(for segment: Segment, in rect: CGRect, metrics: Metrics) -> CGRect {
        switch segment {
        case .top:
            return horizontalFrame(in: rect, y: metrics.topY, metrics: metrics)
        case .center:
            return horizontalFrame(in: rect, y: metrics.middleY, metrics: metrics)
        case .bottom:
            return horizontalFrame(in: rect, y: metrics.bottomY, metrics: metrics)
        case .topLeft:
            return leftVerticalFrame(
                in: rect,
                y: metrics.verticalTopY,
                height: metrics.topVerticalHeight,
                xOffset: metrics.segmentGap,
                metrics: metrics
            )
        case .bottomLeft:
            return leftVerticalFrame(
                in: rect,
                y: metrics.verticalBottomY,
                height: metrics.bottomVerticalHeight,
                xOffset: metrics.segmentGap,
                metrics: metrics
            )
        case .topRight:
            return rightVerticalFrame(
                in: rect,
                y: metrics.verticalTopY,
                height: metrics.topVerticalHeight,
                metrics: metrics
            )
        case .bottomRight:
            return rightVerticalFrame(
                in: rect,
                y: metrics.verticalBottomY,
                height: metrics.bottomVerticalHeight,
                metrics: metrics
            )
        }
    }

    private static func horizontalFrame(in rect: CGRect, y: CGFloat, metrics: Metrics) -> CGRect {
        CGRect(
            x: rect.minX + metrics.inset + metrics.thickness * 0.45,
            y: y,
            width: rect.width - (metrics.inset * 2) - metrics.thickness * 0.9,
            height: metrics.thickness
        )
    }

    private static func leftVerticalFrame(
        in rect: CGRect,
        y: CGFloat,
        height: CGFloat,
        xOffset: CGFloat,
        metrics: Metrics
    ) -> CGRect {
        CGRect(
            x: rect.minX + metrics.inset - xOffset,
            y: y,
            width: metrics.thickness,
            height: height
        )
    }

    private static func rightVerticalFrame(
        in rect: CGRect,
        y: CGFloat,
        height: CGFloat,
        metrics: Metrics
    ) -> CGRect {
        CGRect(
            x: rect.maxX - metrics.inset - metrics.thickness,
            y: y,
            width: metrics.thickness,
            height: height
        )
    }
}

struct SegmentLayoutValueKey: LayoutValueKey {
    static let defaultValue: Segment = .top
}
