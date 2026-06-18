public protocol ContextCompacting: Sendable {
    func compact(
        transcript: ContextTranscript,
        evaluation: ContextBudgetEvaluation
    ) async throws -> ContextCompactionResult
}
