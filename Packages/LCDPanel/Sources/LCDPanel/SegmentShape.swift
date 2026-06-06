import SwiftUI

struct SegmentShape: Shape {
    let segment: Segment

    func path(in rect: CGRect) -> Path {
        let thickness = min(rect.width, rect.height) * 0.16
        let inset = thickness * 0.45
        let bevel = thickness * 0.55
        let middleY = rect.midY - thickness / 2
        let topY = rect.minY + inset
        let bottomY = rect.maxY - inset - thickness
        let verticalTopY = topY + thickness * 0.7
        let verticalBottomY = middleY + thickness * 1.3
        let verticalHeight = max(0, middleY - verticalTopY + thickness * 0.25)

        let segmentRect: CGRect
        switch segment {
        case .top:
            segmentRect = CGRect(
                x: rect.minX + inset + thickness * 0.45,
                y: topY,
                width: rect.width - (inset * 2) - thickness * 0.9,
                height: thickness
            )
        case .center:
            segmentRect = CGRect(
                x: rect.minX + inset + thickness * 0.45,
                y: middleY,
                width: rect.width - (inset * 2) - thickness * 0.9,
                height: thickness
            )
        case .bottom:
            segmentRect = CGRect(
                x: rect.minX + inset + thickness * 0.45,
                y: bottomY,
                width: rect.width - (inset * 2) - thickness * 0.9,
                height: thickness
            )
        case .topLeft:
            segmentRect = CGRect(
                x: rect.minX + inset,
                y: verticalTopY,
                width: thickness,
                height: verticalHeight
            )
        case .topRight:
            segmentRect = CGRect(
                x: rect.maxX - inset - thickness,
                y: verticalTopY,
                width: thickness,
                height: verticalHeight
            )
        case .bottomLeft:
            segmentRect = CGRect(
                x: rect.minX + inset,
                y: verticalBottomY,
                width: thickness,
                height: verticalHeight
            )
        case .bottomRight:
            segmentRect = CGRect(
                x: rect.maxX - inset - thickness,
                y: verticalBottomY,
                width: thickness,
                height: verticalHeight
            )
        }

        switch segment {
        case .top, .center, .bottom:
            return horizontalPath(in: segmentRect, bevel: bevel)
        case .topLeft, .bottomLeft:
            return leftVerticalPath(in: segmentRect, bevel: bevel)
        case .topRight, .bottomRight:
            return rightVerticalPath(in: segmentRect, bevel: bevel)
        }
    }

    private func horizontalPath(in rect: CGRect, bevel: CGFloat) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX + bevel, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - bevel, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX - bevel, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + bevel, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.closeSubpath()
        }
    }

    private func leftVerticalPath(in rect: CGRect, bevel: CGFloat) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX + bevel, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + bevel))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bevel))
            path.addLine(to: CGPoint(x: rect.minX + bevel, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - bevel))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + bevel))
            path.closeSubpath()
        }
    }

    private func rightVerticalPath(in rect: CGRect, bevel: CGFloat) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY + bevel))
            path.addLine(to: CGPoint(x: rect.maxX - bevel, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + bevel))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bevel))
            path.addLine(to: CGPoint(x: rect.maxX - bevel, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - bevel))
            path.closeSubpath()
        }
    }
}
