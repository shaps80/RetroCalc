import SwiftUI

struct BottomLeft: Shape {
    func path(in rect: CGRect) -> Path {
        let bevel = min(rect.width, rect.height) * 0.55

        return Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + bevel))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bevel))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}
