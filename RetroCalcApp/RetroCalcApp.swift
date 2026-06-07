import LCDPanel
import SwiftUI

@main
struct RetroCalcApp: App {
    var body: some Scene {
        WindowGroup {
            CalculatorView()
        }
    }
}

private struct CalculatorView: View {
    @State private var value = LCDPanel.Value()
    @State private var isShowingWords = false
    @State private var wordSearchText = ""
    @State private var wordScrollPosition: String?

    private let rows: [[CalculatorButton]] = [
        [.percentage, .clear, .percent, .divide],
        [.digit(7), .digit(8), .digit(9), .multiply],
        [.digit(4), .digit(5), .digit(6), .subtract],
        [.digit(1), .digit(2), .digit(3), .add],
        [.plusMinus, .digit(0), .decimal, .equals]
    ]

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
                CalculatorWordsSheet(
                    searchText: $wordSearchText,
                    scrollPosition: $wordScrollPosition
                ) { word in
                    value = LCDPanel.Value(inputText: word.input)
                    isShowingWords = false
                }
            }
        }
    }

    private func handle(_ button: CalculatorButton) {
        switch button {
        case let .digit(digit):
            value.append(UInt(digit))
        case .decimal:
            value.appendDecimal()
        case .clear:
            value = LCDPanel.Value()
        case .percentage:
            value.removeLast()
        case .percent, .divide, .multiply, .subtract, .add, .equals, .plusMinus:
            break
        }
    }
}

private struct CalculatorWordsSheet: View {
    @ScaledMetric private var fontSize: Double = 20

    @Binding var searchText: String
    @Binding var scrollPosition: String?

    let onSelect: (CalculatorWord) -> Void

    private let words = CalculatorWord.loadAll()

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    ForEach(sections) { section in
                        Section(section.title) {
                            ForEach(section.words) { word in
                                Button {
                                    onSelect(word)
                                } label: {
                                    LabeledContent(word.input, value: word.word)
                                }
                                .buttonStyle(.plain)
                                .id(word.id)
                                .background {
                                    GeometryReader { geometry in
                                        Color.clear.preference(
                                            key: CalculatorWordRowPositionKey.self,
                                            value: [word.id: geometry.frame(in: .named("CalculatorWordsList")).minY]
                                        )
                                    }
                                }
                            }
                        }
                        .sectionIndexLabel(section.title)
                    }
                }
                .coordinateSpace(name: "CalculatorWordsList")
                .onAppear {
                    guard let scrollPosition else { return }

                    DispatchQueue.main.async {
                        proxy.scrollTo(scrollPosition, anchor: .top)
                    }
                }
                .onPreferenceChange(CalculatorWordRowPositionKey.self) { positions in
                    guard let nearestVisibleRow = positions
                        .filter({ $0.value >= 0 })
                        .min(by: { $0.value < $1.value })?
                        .key
                    else { return }

                    scrollPosition = nearestVisibleRow
                }
            }
            .listSectionIndexVisibility(.visible)
            .navigationTitle("Words")
            .searchable(text: $searchText)
        }
    }

    private var sections: [CalculatorWordSection] {
        let filteredWords = words.filter { word in
            guard !searchText.isEmpty else { return true }

            return word.word.localizedStandardContains(searchText)
                || word.input.localizedStandardContains(searchText)
        }

        return Dictionary(grouping: filteredWords, by: \.sectionTitle)
            .map { title, words in
                CalculatorWordSection(title: title, words: words)
            }
            .sorted { $0.title < $1.title }
    }
}

private struct CalculatorWordRowPositionKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]

    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

private struct CalculatorWordSection: Identifiable {
    let title: String
    let words: [CalculatorWord]

    var id: String {
        title
    }
}

private struct CalculatorWord: Identifiable {
    let word: String
    let input: String

    var id: String {
        "\(word):\(input)"
    }

    var sectionTitle: String {
        word.prefix(1).uppercased()
    }

    static func loadAll() -> [CalculatorWord] {
        guard let url = Bundle.main.url(forResource: "CalculatorWordsUltimate", withExtension: "txt"),
              let contents = try? String(contentsOf: url, encoding: .utf8)
        else {
            return []
        }

        return contents
            .split(whereSeparator: \.isNewline)
            .compactMap { line in
                let word = String(line)

                guard let input = input(for: word) else { return nil }

                return CalculatorWord(word: word, input: input)
            }
    }

    private static func input(for word: String) -> String? {
        let digitsByLetter: [Character: Character] = [
            "b": "8",
            "e": "3",
            "g": "6",
            "h": "4",
            "i": "1",
            "l": "7",
            "o": "0",
            "s": "5",
            "z": "2"
        ]

        var input = ""

        for letter in word.lowercased().reversed() {
            guard let digit = digitsByLetter[letter] else { return nil }

            input.append(digit)
        }

        return input
    }
}

private enum CalculatorButton: Hashable {
    case percentage
    case clear
    case percent
    case divide
    case multiply
    case subtract
    case add
    case equals
    case plusMinus
    case decimal
    case digit(UInt8)

    var title: String {
        switch self {
        case .percentage:
            return "⌫"
        case .clear:
            return "AC"
        case .percent:
            return "%"
        case .divide:
            return "÷"
        case .multiply:
            return "×"
        case .subtract:
            return "−"
        case .add:
            return "+"
        case .equals:
            return "="
        case .plusMinus:
            return "+/-"
        case .decimal:
            return "."
        case let .digit(digit):
            return String(digit)
        }
    }

    var isEnabled: Bool {
        switch self {
        case .percent, .divide, .multiply, .subtract, .add, .equals, .plusMinus:
            return false
        case .percentage, .clear, .decimal, .digit:
            return true
        }
    }
}
