import FoundationContext
import Testing

@Test
func preservesSystemMessagesAndKeepsMostRecentNonSystemMessages() async throws {
    let compactor = try SystemPreservingRecentContextCompactor(
        keptMessageCount: 2
    )
    
    let messages = [
        ContextMessage(role: .system, content: "You are helpful."),
        ContextMessage(role: .user, content: "Old question."),
        ContextMessage(role: .assistant, content: "Old answer."),
        ContextMessage(role: .user, content: "New question."),
        ContextMessage(role: .assistant, content: "New answer.")
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
        ContextMessage(role: .system, content: "You are helpful."),
        ContextMessage(role: .user, content: "New question."),
        ContextMessage(role: .assistant, content: "New answer.")
    ])
    
    let expectedRemovedMessages = [
        ContextMessage(role: .user, content: "Old question."),
        ContextMessage(role: .assistant, content: "Old answer.")
    ]
    
    #expect(result.transcript == expectedTranscript)
    #expect(result.removedMessages == expectedRemovedMessages)
    #expect(result.didCompact)
}

@Test
func preservesSystemMessagesAndRemovesAllNonSystemMessagesWhenKeptMessageCountIsZero() async throws {
    let compactor = try SystemPreservingRecentContextCompactor(
        keptMessageCount: 0
    )
    
    let messages = [
        ContextMessage(role: .system, content: "You are helpful."),
        ContextMessage(role: .user, content: "Old question."),
        ContextMessage(role: .assistant, content: "Old answer.")
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
        ContextMessage(role: .system, content: "You are helpful.")
    ])
    
    let expectedRemovedMessages = [
        ContextMessage(role: .user, content: "Old question."),
        ContextMessage(role: .assistant, content: "Old answer.")
    ]
    
    #expect(result.transcript == expectedTranscript)
    #expect(result.removedMessages == expectedRemovedMessages)
    #expect(result.didCompact)
}

@Test
func keepsMostRecentMessagesWhenThereAreNoSystemMessages() async throws {
    let compactor = try SystemPreservingRecentContextCompactor(
        keptMessageCount: 2
    )
    
    let messages = [
        ContextMessage(role: .user, content: "Old question."),
        ContextMessage(role: .assistant, content: "Old answer."),
        ContextMessage(role: .user, content: "New question."),
        ContextMessage(role: .assistant, content: "New answer.")
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
        ContextMessage(role: .user, content: "New question."),
        ContextMessage(role: .assistant, content: "New answer.")
    ])
    
    let expectedRemovedMessages = [
        ContextMessage(role: .user, content: "Old question."),
        ContextMessage(role: .assistant, content: "Old answer.")
    ]
    
    #expect(result.transcript == expectedTranscript)
    #expect(result.removedMessages == expectedRemovedMessages)
    #expect(result.didCompact)
}

@Test
func preservesMultipleSystemMessages() async throws {
    let compactor = try SystemPreservingRecentContextCompactor(
        keptMessageCount: 1
    )
    
    let messages = [
        ContextMessage(role: .system, content: "You are helpful."),
        ContextMessage(role: .user, content: "Old question."),
        ContextMessage(role: .system, content: "Use short answers."),
        ContextMessage(role: .assistant, content: "Old answer."),
        ContextMessage(role: .user, content: "New question.")
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
        ContextMessage(role: .system, content: "You are helpful."),
        ContextMessage(role: .system, content: "Use short answers."),
        ContextMessage(role: .user, content: "New question.")
    ])
    
    let expectedRemovedMessages = [
        ContextMessage(role: .user, content: "Old question."),
        ContextMessage(role: .assistant, content: "Old answer.")
    ]
    
    #expect(result.transcript == expectedTranscript)
    #expect(result.removedMessages == expectedRemovedMessages)
    #expect(result.didCompact)
}

