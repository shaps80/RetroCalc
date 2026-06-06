import SwiftUI

struct Digit: View {
    private let activeSegments: Set<Segment>

    init(_ value: Int?) {
        activeSegments = value.map(Self.segments(for:)) ?? []
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Segment.allCases, id: \.self) { segment in
                    SegmentShape(segment: segment)
                        .fill(activeSegments.contains(segment) ? activeColor : inactiveColor)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private var activeColor: Color {
        Color.black.opacity(0.78)
    }

    private var inactiveColor: Color {
        Color.black.opacity(0.10)
    }

    private static func segments(for value: Int) -> Set<Segment> {
        switch value {
        case 0:
            return [.topLeft, .top, .topRight, .bottomLeft, .bottom, .bottomRight]
        case 1:
            return [.topRight, .bottomRight]
        case 2:
            return [.top, .topRight, .center, .bottomLeft, .bottom]
        case 3:
            return [.top, .topRight, .center, .bottom, .bottomRight]
        case 4:
            return [.topLeft, .topRight, .center, .bottomRight]
        case 5:
            return [.topLeft, .top, .center, .bottom, .bottomRight]
        case 6:
            return [.topLeft, .top, .center, .bottomLeft, .bottom, .bottomRight]
        case 7:
            return [.top, .topRight, .bottomRight]
        case 8:
            return Set(Segment.allCases)
        case 9:
            return [.topLeft, .top, .topRight, .center, .bottom, .bottomRight]
        default:
            return []
        }
    }
}
