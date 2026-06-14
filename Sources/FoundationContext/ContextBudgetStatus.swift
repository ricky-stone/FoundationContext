public enum ContextBudgetStatus: Sendable, Equatable {
    case withinBudget
    case nearLimit
    case overBudget
}
