import SwiftUI

struct OpenWordsAction {
    @Binding var openWords: Bool

    func callAsFunction() {
        openWords.toggle()
    }
}

extension EnvironmentValues {
    @Entry var openWords: OpenWordsAction = .init(openWords: .constant(false))
}

extension View {
    func openWords<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        environment(\.openWords, .init(openWords: isPresented))
            .sheet(isPresented: isPresented) {
                content()
                    .presentationDetents([.medium, .large])
            }
    }
}
