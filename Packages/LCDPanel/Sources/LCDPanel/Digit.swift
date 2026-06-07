import SwiftUI

struct Digit: View {
    private let value: UInt8?

    init(_ value: UInt8?) {
        self.value = value
    }

    var body: some View {
        ZStack {
            Text("8")
                .foregroundStyle(.quinary)

            if let value {
                Text(String(value))
                    .foregroundStyle(.foreground)
            }
        }
        .monospacedDigit()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
