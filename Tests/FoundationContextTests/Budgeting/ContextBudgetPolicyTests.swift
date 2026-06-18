import FoundationContext
import Testing

@Test
func storesCustomNearLimitThresholdTokenCount() throws {
    let policy = try ContextBudgetPolicy(nearLimitThresholdTokenCount: 250)
    
    #expect(policy.nearLimitThresholdTokenCount == 250)
}

@Test
func throwsWhenNearLimitThresholdTokenCountIsNegative() {
    #expect(throws: ContextBudgetPolicyError.nearLimitThresholdTokenCountCannotBeNegative) {
        try ContextBudgetPolicy(nearLimitThresholdTokenCount: -1)
    }
}

@Test
func defaultPolicyUsesFiveHundredTokenThreshold() {
    let policy = ContextBudgetPolicy.standard
    
    #expect(policy.nearLimitThresholdTokenCount == 500)
}
