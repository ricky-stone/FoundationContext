public struct NoOpContextCompactor: ContextCompacting {
    public init() {}
    
    public func compact(
        transcript: ContextTranscript,
        evaluation: ContextBudgetEvaluation
    ) async throws -> ContextCompactionResult {
        ContextCompactionResult(
            transcript: transcript,
            removedMessages: []
        )
    }
}
