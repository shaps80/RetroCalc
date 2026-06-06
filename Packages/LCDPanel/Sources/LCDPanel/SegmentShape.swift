import SwiftUI

struct SegmentShape: Shape {
    let segment: Segment

    func path(in rect: CGRect) -> Path {
        let thickness = min(rect.width, rect.height) * 0.14
        let inset = thickness * 0.55
        let middleY = rect.midY - thickness / 2
        let verticalHeight = (rect.height - (inset * 2) - (thickness * 3)) / 2

        let segmentRect: CGRect
        switch segment {
        case .top:
            segmentRect = CGRect(
                x: inset + thickness * 0.35,
                y: inset,
                width: rect.width - (inset * 2) - (thickness * 0.7),
                height: thickness
            )
        case .center:
            segmentRect = CGRect(
                x: inset + thickness * 0.35,
                y: middleY,
                width: rect.width - (inset * 2) - (thickness * 0.7),
                height: thickness
            )
        case .bottom:
            segmentRect = CGRect(
                x: inset + thickness * 0.35,
                y: rect.maxY - inset - thickness,
                width: rect.width - (inset * 2) - (thickness * 0.7),
                height: thickness
            )
        case .topLeft:
            segmentRect = CGRect(
                x: inset,
                y: inset + thickness * 0.7,
                width: thickness,
                height: verticalHeight
            )
        case .topRight:
            segmentRect = CGRect(
                x: rect.maxX - inset - thickness,
                y: inset + thickness * 0.7,
                width: thickness,
                height: verticalHeight
            )
        case .bottomLeft:
            segmentRect = CGRect(
                x: inset,
                y: middleY + thickness * 1.3,
                width: thickness,
                height: verticalHeight
            )
        case .bottomRight:
            segmentRect = CGRect(
                x: rect.maxX - inset - thickness,
                y: middleY + thickness * 1.3,
                width: thickness,
                height: verticalHeight
            )
        }

        return Path(roundedRect: segmentRect, cornerRadius: thickness / 2)
    }
}
