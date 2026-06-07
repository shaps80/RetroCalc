# Agent Instructions

When talking to the user, sacrifice grammar for concision.

## Working Rules

- Read `CONTEXT.md` before changing behavior.
- Do not redesign the keypad, display, colors, fonts, or layout unless explicitly asked.
- Do not add disabled button states unless explicitly asked.
- Keep changes scoped. This app is intentionally small.
- Preserve user changes. Do not revert dirty files unless user asks.
- Use `rg` for searches.
- Use `apply_patch` for manual file edits.
- Commit only when user asks. If user says commit everything, include all dirty changes.

## Core Behavior Source

`CalculatorModel` is the behavioral source of truth. Prefer adding model methods and tests there instead of spreading logic through SwiftUI views.

Important model APIs:

- `enterDigit(_:)`
- `enterDecimal()`
- `enterOperator(_:)`
- `toggleSign()`
- `evaluate()`
- `removeLast()`
- `clear()`
- `replaceActiveInput(with:)`
- `restorePreviousExpression()`

## UX Constraints

- Active display shows the full expression while editing.
- Equals replaces active expression with the result.
- Previous expression appears above active expression, smaller, no equals sign.
- Tapping previous expression restores it into active input.
- Repeated equals repeats the last operation.
- Division by zero shows `Undefined`.
- Numbers or decimal after `Undefined` start fresh; operators are ignored.
- Operators replace pending operators. No multiple inline operators.
- `+/-` is the way to enter negative second operands.
- `+/-` simplifies addition/subtraction expressions live.

## Arithmetic Constraints

- Arithmetic must be correct with precedence: `12+3*4` is `24`.
- Do not use ad hoc UI-side math.
- Keep Decimal-based calculation unless deliberately changing numeric model.
- Keep display glyphs consistent:
  - addition: `+`
  - subtraction: `-`
  - multiplication in expression text: `*`
  - division in expression text: `÷`
- Keypad multiply uses the SF Symbol button; do not swap it just because expression text uses `*`.

## Testing

Primary fast test:

```sh
swift test
```

App build:

```sh
xcodebuild -project RetroCalc.xcodeproj -scheme RetroCalc -configuration Debug -derivedDataPath /tmp/RetroCalcDerivedData build
```

Use a custom `-derivedDataPath` if Xcode DerivedData gives stale generated-file or build database errors.

Known caveat:

```sh
swift test --package-path Packages/LCDPanel
```

may fail on macOS availability for SwiftUI styling. Do not treat that as a regression unless the task is specifically to make the LCDPanel package portable.

## Project Generation

`project.yml` exists but may be behind the checked-in `RetroCalc.xcodeproj`. Before running any project-generation tool, compare current project settings and update `project.yml` first.

Current app-specific project/plist concerns:

- iOS deployment target is 26.0.
- App includes iPad device family.
- `UIRequiresFullScreen` is present, but deprecated starting iOS 26.
- `Digital7.ttf` is the registered display font.

## Code Review Focus

When reviewing or modifying:

- Prioritize calculator behavior regressions.
- Check previous expression behavior and repeated equals after changes.
- Check `Undefined` recovery paths.
- Check backspace and clear semantics.
- Check that layout changes do not shrink the active display when previous expression appears.
- Add tests for every behavior change in `Tests/CalculatorCoreTests/CalculatorModelTests.swift`.
