import FoundationContext
import Testing

@Test
func keepsMostRecentMessagesAndRemovesOlderMessages() async throws {
    let compactor = try RecentContextCompactor(keptMessageCount: 2)
    
    let messages = [
        ContextMessage(role: .system, content: "System message."),
        ContextMessage(role: .user, content: "First user message."),
        ContextMessage(role: .assistant, content: "First assistant message."),
        ContextMessage(role: .user, content: "Second user message."),
        ContextMessage(role: .assistant, content: "Second assistant message.")
    ]
    
    let transcript = ContextTranscript(messages: messages)
    
    let budget = try ContextBudget(
        maximumTokenCount: 4096,
        reservedResponseTokenCount: 800
    )
    
    let usage = try ContextUsage(inputTokenCount: 5000)
    
    let evaluation = ContextBudgetEvaluation(
        budget: budget,
        usage: usage
    )
    
    let result = try await compactor.compact(
        transcript: transcript,
        evaluation: evaluation
    )
    
    let expectedTranscript = ContextTranscript(messages: [
        ContextMessage(role: .user, content: "Second user message."),
        ContextMessage(role: .assistant, content: "Second assistant message.")
    ])
    
    let expectedRemovedMessages = [
        ContextMessage(role: .system, content: "System message."),
        ContextMessage(role: .user, content: "First user message."),
        ContextMessage(role: .assistant, content: "First assistant message.")
    ]
    
    #expect(result.transcript == expectedTranscript)
    #expect(result.removedMessages == expectedRemovedMessages)
    #expect(result.didCompact)
}
