# FoundationContext
![Tests](https://github.com/ricky-stone/FoundationContext/actions/workflows/tests.yml/badge.svg)
![Swift](https://img.shields.io/badge/Swift-6-orange)
![Platforms](https://img.shields.io/badge/platforms-iOS%2026.4%2B%20%7C%20macOS%2026.4%2B%20%7C%20visionOS%2026.4%2B-lightgrey)
![License](https://img.shields.io/badge/license-MIT-blue)
![Release](https://img.shields.io/github/v/release/ricky-stone/FoundationContext?include_prereleases)

A small Swift package for using Foundation Models with simple context management.

FoundationContext wraps `LanguageModelSession`, compacts the transcript when it reaches a token threshold, and retries once with a compacted transcript if the model reaches its context limit.

## Requirements

- iOS 26.4+
- macOS 26.4+
- visionOS 26.4+
- Swift 6

## Installation

Add FoundationContext to your project using Swift Package Manager.

In Xcode:

```text
File > Add Package Dependencies...
```

Then enter:

```text
https://github.com/ricky-stone/FoundationContext
```

Or add it to your `Package.swift` file:

```swift
.package(
    url: "https://github.com/ricky-stone/FoundationContext.git",
    from: "0.2.0"
)
```

## Basic Usage

```swift
import FoundationContext

let context = FoundationContext(
    instructions: "You are a helpful assistant.",
    keepTurns: 1
)

let reply = try await context.respond(
    to: "Say hello in one sentence."
)

print(reply)
```

## Keeping Recent Context

`compactAtTokens` controls when FoundationContext compacts before responding. It defaults to `3096` tokens.

`keepTurns` controls how much recent conversation is kept when the context needs to be compacted.

```swift
let context = FoundationContext(
    instructions: "You are helpful.",
    keepTurns: 2,
    compactAtTokens: 3096
)
```

A turn is usually one user message and one assistant response.
If `keepTurns` is `0`, FoundationContext keeps the instructions and removes the conversation history when compacting.

## Resetting

Use `reset()` to start again with the original model and instructions.

```swift
context.reset()
```

## Inspecting the Transcript

```swift
let transcript = context.transcript
```

## Author

Created by Ricky Stone.

## License

FoundationContext is available under the MIT license.

This means you can use, copy, modify, merge, publish, distribute, sublicense, and sell copies of the software, as long as the original copyright notice and license text are included.

See the `LICENSE` file for more details.
