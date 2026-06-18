public struct RecentContextCompactor: ContextCompacting {
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
        let keptMessages = transcript.messages.suffix(keptMessageCount)
        let removedMessages = transcript.messages.dropLast(keptMessageCount)
        
        return ContextCompactionResult(
            transcript: ContextTranscript(messages: Array(keptMessages)),
            removedMessages: Array(removedMessages)
        )
    }
}
