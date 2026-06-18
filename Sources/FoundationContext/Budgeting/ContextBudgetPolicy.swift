public struct ContextBudgetPolicy: Sendable, Equatable {
    public let nearLimitThresholdTokenCount: Int
    
    public static let standard = ContextBudgetPolicy(
        nearLimitThresholdTokenCount: 500,
        validation: .unchecked
    )
    
    public init(nearLimitThresholdTokenCount: Int) throws {
        guard nearLimitThresholdTokenCount >= 0 else {
            throw ContextBudgetPolicyError.nearLimitThresholdTokenCountCannotBeNegative
        }
        self.nearLimitThresholdTokenCount = nearLimitThresholdTokenCount
    }
    
    private init(
        nearLimitThresholdTokenCount: Int,
        validation: Validation
    ) {
        self.nearLimitThresholdTokenCount = nearLimitThresholdTokenCount
    }
    
    private enum Validation {
        case unchecked
    }
}
