public struct ContextEvaluator: Sendable {
    public let budget: ContextBudget
    public let policy: ContextBudgetPolicy
    private let tokenCounter: any ContextTokenCounting
    
    public init(
        budget: ContextBudget,
        policy: ContextBudgetPolicy = .standard,
        tokenCounter: any ContextTokenCounting
    ) {
        self.budget = budget
        self.policy = policy
        self.tokenCounter = tokenCounter
    }
    
    public func evaluate(messages: [ContextMessage]) async throws -> ContextBudgetEvaluation {
        let transcript = ContextTranscript(messages: messages)
        
        return try await evaluate(transcript: transcript)
    }
    
    public func evaluate(transcript: ContextTranscript) async throws -> ContextBudgetEvaluation {
        return try await evaluate(text: transcript.formattedText)
    }
    
    public func evaluate(text: String) async throws -> ContextBudgetEvaluation {
        let usage = try await tokenCounter.usage(for: text)
        
        return ContextBudgetEvaluation(
            budget: budget,
            usage: usage,
            policy: policy
        )
    }
}
