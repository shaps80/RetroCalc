import SwiftUI

struct TopLeft: Shape {
    private let cutInsetRatio: CGFloat = 0.28

    func path(in rect: CGRect) -> Path {
        let thickness = min(rect.width, rect.height)
        let bevel = thickness * 0.55
        let cutInset = thickness * cutInsetRatio
        let cutEndX = rect.maxX - cutInset
        let capX = cutEndX - bevel
        let cutY = rect.minY + thickness
        let cornerRadius = capX - rect.minX

        return Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
            path.addQuadCurve(
                to: CGPoint(x: capX, y: rect.minY),
                control: CGPoint(x: rect.minX, y: rect.minY)
            )
            path.addLine(to: CGPoint(x: cutEndX, y: cutY))
            path.addLine(to: CGPoint(x: cutEndX, y: rect.maxY - bevel))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}
