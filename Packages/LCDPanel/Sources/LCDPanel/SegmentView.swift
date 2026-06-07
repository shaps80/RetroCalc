import SwiftUI

struct SegmentView: View {
    let segment: Segment

    var body: some View {
        Rectangle()
            .layoutValue(key: SegmentLayoutValueKey.self, value: segment)
    }
}
