import LCDPanel
import SwiftUI

struct CalculatorView: View {
    @State private var calculator = CalculatorModel()
    @State private var isShowingWords = false
    @State private var wordSearchText = ""
    @State private var wordScrollPosition: String?

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.bg
                .ignoresSafeArea()

            VStack(spacing: 28) {
                LCDPanel(
                    activeText: calculator.activeText,
                    previousExpressionText: calculator.previousExpressionText,
                    isPlaceholder: calculator.isEmpty
                )
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)

                KeyPad(calculator: $calculator)
            }
            .padding(15)
            .openWords(isPresented: $isShowingWords) {
                WordsList(
                    searchText: $wordSearchText,
                    scrollPosition: $wordScrollPosition
                ) { word in
                    calculator.replaceActiveInput(with: word.input)
                    isShowingWords = false
                }
            }
        }
    }
}
