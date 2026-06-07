import CoreGraphics
import XCTest
@testable import LCDPanel

final class SegmentLayoutTests: XCTestCase {
    func testVerticalSegmentJoinsAreSymmetricAcrossDigit() {
        let rect = CGRect(x: 0, y: 0, width: 55, height: 100)
        let metrics = SegmentLayout.metrics(in: rect)

        let top = SegmentLayout.frame(for: .top, in: rect, metrics: metrics)
        let center = SegmentLayout.frame(for: .center, in: rect, metrics: metrics)
        let bottom = SegmentLayout.frame(for: .bottom, in: rect, metrics: metrics)

        let topLeft = SegmentLayout.frame(for: .topLeft, in: rect, metrics: metrics)
        let bottomLeft = SegmentLayout.frame(for: .bottomLeft, in: rect, metrics: metrics)
        let topRight = SegmentLayout.frame(for: .topRight, in: rect, metrics: metrics)
        let bottomRight = SegmentLayout.frame(for: .bottomRight, in: rect, metrics: metrics)

        assertVerticalJoinsAreSymmetric(
            top: top,
            center: center,
            bottom: bottom,
            upper: topLeft,
            lower: bottomLeft
        )
        assertVerticalJoinsAreSymmetric(
            top: top,
            center: center,
            bottom: bottom,
            upper: topRight,
            lower: bottomRight
        )
    }

    private func assertVerticalJoinsAreSymmetric(
        top: CGRect,
        center: CGRect,
        bottom: CGRect,
        upper: CGRect,
        lower: CGRect,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(top.maxY - upper.minY, lower.maxY - bottom.minY, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(upper.maxY - center.minY, center.maxY - lower.minY, accuracy: 0.001, file: file, line: line)
    }
}
