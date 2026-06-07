import SwiftUI

struct SegmentView: View {
    let segment: Segment

    var body: some View {
        shape
            .layoutValue(key: SegmentLayoutValueKey.self, value: segment)
    }

    @ViewBuilder
    private var shape: some View {
        switch segment {
        case .topLeft:
            TopLeft()
        case .top:
            Top()
        case .topRight:
            Color.clear//TopRight()
        case .center:
            Color.clear//Center()
        case .bottomLeft:
            Color.clear//BottomLeft()
        case .bottom:
            Bottom()
        case .bottomRight:
            Color.clear//BottomRight()
        }
    }
}
