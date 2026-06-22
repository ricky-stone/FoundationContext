import Testing
@testable import FoundationContext

struct SummarizingContextCompactorTests {
    @Test
    func preservesSystemMessagesAddsSummaryAndKeepsRecentMessages() async throws {
        let transcript = ContextTranscript(messages: [
            ContextMessage(role: .system, content: "You are helpful."),
            ContextMessage(role: .user, content: "Old question."),
            ContextMessage(role: .assistant, content: "Old answer."),
            ContextMessage(role: .user, content: "New question."),
            ContextMessage(role: .assistant, content: "New answer.")
        ])
        
        let budget = try ContextBudget(
            maximumTokenCount: 4096,
            reservedResponseTokenCount: 800
        )
        
        let usage = try ContextUsage(inputTokenCount: 5000)
        
        let evaluation = ContextBudgetEvaluation(
            budget: budget,
            usage: usage
        )
        
        let compactor = try SummarizingContextCompactor(
            keptMessageCount: 2,
            summarizer: StubSummarizer(
                summary: "Summary of older messages."
            )
        )
        
        let result = try await compactor.compact(
            transcript: transcript,
            evaluation: evaluation
        )
        
        #expect(result.transcript.messages == [
            ContextMessage(role: .system, content: "You are helpful."),
            ContextMessage(role: .summary, content: "Summary of older messages."),
            ContextMessage(role: .user, content: "New question."),
            ContextMessage(role: .assistant, content: "New answer.")
        ])
    }
}

private struct StubSummarizer: ContextSummarizing {
    let summary: String
    
    func summary(for messages: [ContextMessage]) async throws -> String {
        summary
    }
}
