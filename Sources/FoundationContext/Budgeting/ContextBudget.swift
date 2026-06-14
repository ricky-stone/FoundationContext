public struct ContextBudget: Sendable, Equatable {
    public let maximumTokenCount: Int
    public let reservedResponseTokenCount: Int
    
    public var availableInputTokenCount: Int {
        maximumTokenCount - reservedResponseTokenCount
    }
    
    public init(maximumTokenCount: Int, reservedResponseTokenCount: Int) throws {
        guard maximumTokenCount > 0 else {
            throw ContextBudgetError.maximumTokenCountMustBePositive
        }
        
        guard reservedResponseTokenCount >= 0 else {
            throw ContextBudgetError.reservedResponseTokenCountCannotBeNegative
        }
        
        guard reservedResponseTokenCount < maximumTokenCount else {
            throw ContextBudgetError.reservedResponseTokenCountMustBeLessThanMaximum
        }
        
        self.maximumTokenCount = maximumTokenCount
        self.reservedResponseTokenCount = reservedResponseTokenCount
    }
}
