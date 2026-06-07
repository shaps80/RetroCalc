import Foundation

struct Word: Identifiable {
    let word: String
    let input: String

    var id: String {
        "\(word):\(input)"
    }

    var sectionTitle: String {
        word.prefix(1).uppercased()
    }

    static func loadAll() -> [Word] {
        guard let url = Bundle.main.url(forResource: "words", withExtension: "txt"),
              let contents = try? String(contentsOf: url, encoding: .utf8)
        else {
            return []
        }

        return contents
            .split(whereSeparator: \.isNewline)
            .compactMap { line in
                let word = line.trimmingCharacters(in: .whitespacesAndNewlines)

                guard !word.isEmpty, let input = input(for: word) else { return nil }

                return Word(word: word, input: input)
            }
    }

    private static func input(for word: String) -> String? {
        let digitsByLetter: [Character: Character] = [
            "b": "8",
            "d": "0",
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
