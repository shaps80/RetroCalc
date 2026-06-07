import SwiftUI

struct Center: Shape {
    func path(in rect: CGRect) -> Path {
        let bevel = min(rect.width, rect.height) * 0.55

        return Path { path in
            path.move(to: CGPoint(x: rect.minX + bevel, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - bevel, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX - bevel, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + bevel, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.closeSubpath()
        }
    }
}
