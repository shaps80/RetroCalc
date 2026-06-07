import SwiftUI

struct WordsList: View {
    @Binding var searchText: String
    @Binding var scrollPosition: String?

    let onSelect: (Word) -> Void

    private let words = Word.loadAll()

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
                                    LabeledContent(word.word, value: word.input)
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
    let words: [Word]

    var id: String {
        title
    }
}
