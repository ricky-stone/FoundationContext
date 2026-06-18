import FoundationContext
import Testing

@Test
func returnsOriginalTranscriptWithoutRemovedMessages() async throws {
    let compactor = NoOpContextCompactor()
    
    let transcript = ContextTranscript(messages: [
        ContextMessage(role: .system, content: "You are helpful."),
        ContextMessage(role: .user, content: "Explain Swift actors.")
    ])
    
    let budget = try ContextBudget(
        maximumTokenCount: 4096,
        reservedResponseTokenCount: 800
    )
    
    let usage = try ContextUsage(inputTokenCount: 100)
    
    let evaulation = ContextBudgetEvaluation(
        budget: budget,
        usage: usage
    )
    
    let result = try await compactor.compact(
        transcript: transcript,
        evaluation: evaulation
    )
    
    #expect(result.transcript == transcript)
    #expect(result.removedMessages == [])
    #expect(!result.didCompact)
}
