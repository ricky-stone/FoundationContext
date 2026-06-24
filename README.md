# Foundation Context

A small Swift package for using Foundation Models with a simple context management.

FoundationContext wraps `LanguageModelSession` and retries with a compacted transcript if the model reaches its context limit.

## Requirements

- iOS 26.4+
- macOS 26.4+
- visionOS 26.4+
- Swift 6

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

`keepTurns` controls how much recent conversation is kept when the context needs to be compacted.

```swift
let context = FoundationContext(
    instructions: "You are helpful.",
    keepTurns: 2
)
```

A turn is usually one user message and one assistant response.
If `keepTurns` is `0`, FoundationContext keeps the instructions and removes the conversation history when compacting.

## Resetting

Use reset() to start again with the original model and instructions.

```swift
context.reset()
```

## Inspecting The Transcript

```swift
let transcript = context.transcript
```

## Author

Created by Ricky Stone.

## License

FoundationContext is available under the MIT license.

This means you can use, copy, modify, merge, publish, distribute, sublicense, and sell copies of the software, as long as the original copyright notice and license text are included.

See the `LICENSE` file for more details.
