public struct ContextBudgetEvaluation: Sendable, Equatable {
    public let budget: ContextBudget
    public let usage: ContextUsage
    
    public var remainingInputTokenCount: Int {
        budget.availableInputTokenCount - usage.inputTokenCount
    }
    
    public var isOverBudget: Bool {
        remainingInputTokenCount < 0
    }
    
    public init(budget: ContextBudget, usage: ContextUsage) {
        self.budget = budget
        self.usage = usage
    }
}
