import FoundationContext
import Testing

private struct StubTokenCounter: ContextTokenCounting {
    let usage: ContextUsage
    
    func usage(for text: String) async throws -> ContextUsage {
        usage
    }
}

private actor RecordingTokenCounter: ContextTokenCounting {
    private(set) var receivedText: String?
    let usage: ContextUsage
    
    init(usage: ContextUsage) {
        self.usage = usage
    }
    
    func usage(for text: String) async throws -> ContextUsage {
        receivedText = text
        return usage
    }
}

@Test
func evaluatesMessagesUsingTokenCounterUsage() async throws {
    let budget = try ContextBudget(
        maximumTokenCount: 4096,
        reservedResponseTokenCount: 800
    )
    
    let usage = try ContextUsage(inputTokenCount: 100)
    let tokenCounter = StubTokenCounter(usage: usage)
    
    let evaluator = ContextEvaluator(
        budget: budget,
        tokenCounter: tokenCounter
    )
    
    let evaluation = try await evaluator.evaluate(messages: [
        ContextMessage(role: .user, content: "Explain Swift actors.")
    ])
    
    #expect(evaluation.usage == usage)
    #expect(evaluation.budget == budget)
    #expect(evaluation.status == .withinBudget)
}

@Test
func passesFormattedTranscriptTextToTokenCounter() async throws {
    let budget = try ContextBudget(
        maximumTokenCount: 4096,
        reservedResponseTokenCount: 800
    )
    
    let usage = try ContextUsage(inputTokenCount: 100)
    let tokenCounter = RecordingTokenCounter(usage: usage)
    
    let evaluator = ContextEvaluator(
        budget: budget,
        tokenCounter: tokenCounter
    )
    
    _ = try await evaluator.evaluate(messages: [
        ContextMessage(role: .system, content: "You are helpful."),
        ContextMessage(role: .user, content: "Explain Swift actors.")
    ])
    
    let expectedText = """
    System: You are helpful.
    User: Explain Swift actors.
    """
    
    let receivedText = await tokenCounter.receivedText
    
    #expect(receivedText == expectedText)
}

