public struct SystemPreservingRecentContextCompactor: ContextCompacting {
    public let keptMessageCount: Int
    
    public init(keptMessageCount: Int) throws {
        guard keptMessageCount >= 0 else {
            throw RecentContextCompactorError.keptMessageCountCannotBeNegative
        }
        
        self.keptMessageCount = keptMessageCount
    }
    
    public func compact(
        transcript: ContextTranscript,
        evaluation: ContextBudgetEvaluation
    ) async throws -> ContextCompactionResult {
        let systemMessages = transcript.messages.filter { message in
            message.role == .system
        }
        
        let nonSystemMessages = transcript.messages.filter { message in
            message.role != .system
        }
        
        let keptNonSystemMessages = nonSystemMessages.suffix(keptMessageCount)
        let removedMessages = nonSystemMessages.dropLast(keptMessageCount)
        
        return ContextCompactionResult(
            transcript: ContextTranscript(
                messages: systemMessages + Array(keptNonSystemMessages)
            ),
            removedMessages: Array(removedMessages)
        )
    }
}

#if DEBUG
import Playgrounds

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
    
    let compactor = try SystemPreservingRecentContextCompactor(
        keptMessageCount: 2
    )
    
    let result = try await compactor.compact(
        transcript: transcript,
        evaluation: evaluation
    )
    
    print("Before compaction:")
    print(transcript.formattedText)
    
    print("After compaction:")
    print(result.transcript.formattedText)
    
    print("Removed messages:")
    print(ContextTranscript(messages: result.removedMessages).formattedText)
    
    print("Did compact: \(result.didCompact)")
}
#endif
