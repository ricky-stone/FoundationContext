public struct SummarizingContextCompactor: ContextCompacting {
    public let keptMessageCount: Int
    
    private let summarizer: any ContextSummarizing
    
    public init(
        keptMessageCount: Int,
        summarizer: any ContextSummarizing
    ) throws {
        
        guard keptMessageCount >= 0 else {
            throw RecentContextCompactorError.keptMessageCountCannotBeNegative
        }
        
        self.keptMessageCount = keptMessageCount
        self.summarizer = summarizer
    }
    
    public func compact(
        transcript: ContextTranscript,
        evaluation: ContextBudgetEvaluation
    ) async throws -> ContextCompactionResult {
        
        let systemMessages = transcript.messages.filter { $0.role == .system }
        let nonSystemMessages = transcript.messages.filter { $0.role != .system }
        
        let keptMessages = nonSystemMessages.suffix(keptMessageCount)
        let messagesToSummarize = nonSystemMessages.dropLast(keptMessageCount)
        
        guard !messagesToSummarize.isEmpty else {
            return ContextCompactionResult(
                transcript: ContextTranscript(messages: systemMessages + Array(keptMessages)),
                removedMessages: []
            )
        }
        
        let summary = try await summarizer.summary(
            for: Array(messagesToSummarize)
        )
        
        let summaryMessage = ContextMessage(
            role: .summary,
            content: summary
        )
        
        return ContextCompactionResult(
            transcript: ContextTranscript(
                messages: systemMessages + [summaryMessage] + Array(keptMessages)
            ), removedMessages: Array(messagesToSummarize)
        )
    }
}

#if DEBUG
import Playgrounds

private struct PreviewSummarizer: ContextSummarizing {
    func summary(for messages: [ContextMessage]) async throws -> String {
        "The user asked an old question and the assistant gave an old answer."
    }
}

#Playground {
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
    
    let compactor = try SummarizingContextCompactor(
        keptMessageCount: 2,
        summarizer: PreviewSummarizer()
    )
    
    let result = try await compactor.compact(
        transcript: transcript,
        evaluation: evaluation
    )
    
    print("Before compaction:")
    print(transcript.formattedText)
    
    print("")
    print("After compaction:")
    print(result.transcript.formattedText)
    
    print("")
    print("Removed messages:")
    print(ContextTranscript(messages: result.removedMessages).formattedText)
    
    print("")
    print("Did compact: \(result.didCompact)")
}
#endif
