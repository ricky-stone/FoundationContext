public struct ContextBudgetPolicy: Sendable, Equatable {
    public let nearLimitThresholdTokenCount: Int
    
    public static var `default`: ContextBudgetPolicy {
        return try! ContextBudgetPolicy(nearLimitThresholdTokenCount: 500)
    }
    
    public init(nearLimitThresholdTokenCount: Int) throws {
        guard nearLimitThresholdTokenCount >= 0 else {
            throw ContextBudgetPolicyError.nearLimitThresholdTokenCountCannotBeNegative
        }
        self.nearLimitThresholdTokenCount = nearLimitThresholdTokenCount
    }
}
