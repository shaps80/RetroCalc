# RetroCalc Context

## Product

RetroCalc is a small iOS 26 calculator app with a retro LCD-style display. It is meant to feel like a focused calculator, not a general-purpose math notebook.

The app shows:

- the active expression or result in the main display
- the previous evaluated expression above it in smaller secondary text
- a keypad with digits, decimal, arithmetic operators, clear, backspace, sign toggle, equals, and word lookup

## Glossary

- **Active expression**: The expression currently shown in the large display. Stored by `CalculatorModel.activeText`.
- **Previous expression**: The last expression evaluated by equals. Stored by `CalculatorModel.previousExpressionText`. It is shown above the active expression, without an equals sign.
- **Result**: The value shown after evaluation. It replaces the active expression and becomes the seed for the next calculation.
- **Expression**: The internal editable string in `CalculatorModel`. It uses display glyphs directly: `+`, `-`, `*`, and `÷`.
- **Operand**: A number in an expression. Negative operands can appear at expression start or after `*`/`÷`, and are also represented during parsing.
- **Pending operator**: An operator entered at the end of the active expression while waiting for the next operand.
- **Repeated equals**: Pressing equals again after a result repeats the last operation against the current result. Example: `2+3===` gives `5`, `8`, `11`.
- **Undefined**: The display state for division by zero. Operators are ignored. Digits or decimal start a fresh expression.
- **Word lookup**: The word list feature that converts words into calculator-style digit input. Selecting a word replaces only the active input; previous expression is preserved.
- **Restore previous expression**: Tapping the previous-expression label moves it back into the active expression and clears the previous label.
- **LCD panel**: The reusable display view in `Packages/LCDPanel`.

## Arithmetic Rules

`CalculatorModel` owns calculator behavior and is the source of truth.

- Arithmetic must respect normal precedence: multiplication and division before addition and subtraction.
- Brackets and implicit multiplication are not supported.
- Results are formatted without grouping and without unnecessary trailing zeroes.
- Scientific notation should not be introduced by result formatting.
- Division by zero shows `Undefined`.
- Pressing equals with an incomplete trailing operator evaluates the completed portion.

## Operator Entry Rules

Typed operators are intentionally simple and Apple Calculator-like:

- While a pending operator exists, another operator replaces it.
- Users cannot type multiple inline operators.
- Typing `6`, `+`, `-`, `6` becomes `6-6`.
- Typing repeated minus after subtract, like `6---3`, stays `6-3`.
- To make the second operand negative, use `+/-`.
- `+/-` simplifies visible expressions for addition/subtraction:
  - `6+6`, then `+/-`, becomes `6-6`
  - `6-3`, then `+/-`, becomes `6+3`
- `+/-` keeps explicit negative operands for multiplication/division:
  - `7*2`, then `+/-`, becomes `7*-2`

## Display Rules

- The main expression/result uses the Digital-7 font at the large display size.
- The previous expression uses the same font, smaller, in secondary/placeholder styling.
- Do not constrain the LCD panel to a fixed height that cannot contain both labels. The active expression must not shrink just because a previous expression exists.
- The previous expression is tappable and restores itself into the active expression.
- Keypad styling is intentionally polished. Avoid UI changes unless explicitly requested.

## Clear And Backspace

- `C` clears the active expression first.
- Pressing `C` again when active display is empty/default clears previous expression.
- Backspace removes from the visible active expression.
- Backspace after a completed result clears active display to `0` and starts editing fresh.

## Word Lookup

Word data lives in localized `words.txt` files under `RetroCalcApp/Resources`.

`Word.input` maps letters to calculator digits and reverses the word. Selecting a word should call `CalculatorModel.replaceActiveInput(with:)`, not replace the whole model.

## Project Structure

- `RetroCalcApp/Calculator/CalculatorModel.swift`: core calculator state, expression parsing, arithmetic, formatting, repeated equals, restore behavior.
- `RetroCalcApp/Calculator/CalculatorView.swift`: app-level composition of LCD panel and keypad.
- `RetroCalcApp/Calculator/KeyPad.swift`: keypad layout and button actions.
- `RetroCalcApp/Calculator/Key.swift`: keypad button styling.
- `RetroCalcApp/Words`: word list loading and presentation.
- `Packages/LCDPanel`: reusable display package.
- `Tests/CalculatorCoreTests`: unit tests for calculator behavior.
- `Package.swift`: exposes `CalculatorCore` from app source for fast model tests.
- `RetroCalc.xcodeproj`: app project used for iOS builds.
- `project.yml`: XcodeGen-style project description. Check it before regenerating; it may lag behind `RetroCalc.xcodeproj`.

## Verification Commands

Use these before claiming behavior changes are done:

```sh
swift test
xcodebuild -project RetroCalc.xcodeproj -scheme RetroCalc -configuration Debug -derivedDataPath /tmp/RetroCalcDerivedData build
```

`swift test --package-path Packages/LCDPanel` can fail on macOS because `LCDPanel` uses newer SwiftUI styling such as `.placeholder`; use the app build as the authoritative LCDPanel compile check unless the package target is also being fixed.
