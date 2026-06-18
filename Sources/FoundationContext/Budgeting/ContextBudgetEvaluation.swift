public struct ContextBudgetEvaluation: Sendable, Equatable {
    public let budget: ContextBudget
    public let usage: ContextUsage
    public let policy: ContextBudgetPolicy
    
    public var remainingInputTokenCount: Int {
        budget.availableInputTokenCount - usage.inputTokenCount
    }
    
    public var isOverBudget: Bool {
        remainingInputTokenCount < 0
    }
    
    public var status: ContextBudgetStatus {
        if isOverBudget {
            return .overBudget
        }
        
        if remainingInputTokenCount <= policy.nearLimitThresholdTokenCount {
            return .nearLimit
        }
        
        return .withinBudget
    }
    
    public init(
        budget: ContextBudget,
        usage: ContextUsage,
        policy: ContextBudgetPolicy = .standard
    ) {
        self.budget = budget
        self.usage = usage
        self.policy = policy
    }
}
