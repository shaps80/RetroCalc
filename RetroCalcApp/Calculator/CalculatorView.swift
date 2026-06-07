import LCDPanel
import SwiftUI

struct CalculatorView: View {
    @State private var value = LCDPanel.Value()
    @State private var isShowingWords = false
    @State private var wordSearchText = ""
    @State private var wordScrollPosition: String?

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.bg
                .ignoresSafeArea()

            VStack(spacing: 28) {
                LCDPanel(value: value)
                    .frame(maxWidth: .infinity, maxHeight: 100, alignment: .bottomTrailing)

                KeyPad(value: $value)
            }
            .padding(15)
            .openWords(isPresented: $isShowingWords) {
                WordsList(
                    searchText: $wordSearchText,
                    scrollPosition: $wordScrollPosition
                ) { word in
                    value = LCDPanel.Value(inputText: word.input)
                    isShowingWords = false
                }
            }
        }
    }
}
