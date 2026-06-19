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
