import FoundationContext
import Testing

@Test
func calculatesRemainingInputTokenCount() throws {
    let budget = try ContextBudget(
        maximumTokenCount: 4096,
        reservedResponseTokenCount: 96
    )
    
    let usage = try ContextUsage(inputTokenCount: 100)
    
    let evaluation = ContextBudgetEvaluation(
        budget: budget,
        usage: usage
    )
    
    #expect(evaluation.remainingInputTokenCount == 3900)
}

@Test
func isOverBudgetReturnsTrueWhenUsageExceedsAvailableInputTokens() throws {
    let budget = try ContextBudget(
        maximumTokenCount: 4096,
        reservedResponseTokenCount: 800
    )
    
    let usage = try ContextUsage(inputTokenCount: 5000)
    
    let evaluation = ContextBudgetEvaluation(
        budget: budget,
        usage: usage
    )
    
    #expect(evaluation.isOverBudget)
}

@Test
func returnsWithinBudgetWhenUsageIsBelowNearLimitThreshold() throws {
    let budget = try ContextBudget(
        maximumTokenCount: 4096,
        reservedResponseTokenCount: 800
    )
    
    let usage = try ContextUsage(inputTokenCount: 100)
    
    let evaluation = ContextBudgetEvaluation(
        budget: budget,
        usage: usage
    )
    
    #expect(evaluation.status == .withinBudget)
}

@Test
func returnsOverBudgetWhenUsageExceedsAvailableInputTokens() throws {
    let budget = try ContextBudget(
        maximumTokenCount: 4096,
        reservedResponseTokenCount: 800
    )
    
    let usage = try ContextUsage(inputTokenCount: 8000)
    
    let evaluation = ContextBudgetEvaluation(
        budget: budget,
        usage: usage
    )
    
    #expect(evaluation.status == .overBudget)
}

@Test
func returnsNearLimitWhenUsageIsCloseToAvailableInputTokens() throws {
    let budget = try ContextBudget(
        maximumTokenCount: 4096,
        reservedResponseTokenCount: 800
    )
    
    let usage = try ContextUsage(inputTokenCount: 3200)
    
    let evaluation = ContextBudgetEvaluation(
        budget: budget,
        usage: usage
    )
    
    #expect(evaluation.status == .nearLimit)
}

@Test
func returnsNearLimitWhenRemainingInputTokenCountEqualsThreshold() throws {
    let budget = try ContextBudget(
        maximumTokenCount: 1000,
        reservedResponseTokenCount: 200
    )
    
    let policy = try ContextBudgetPolicy(nearLimitThresholdTokenCount: 500)
    let usage = try ContextUsage(inputTokenCount: 300)
    
    let evaluation = ContextBudgetEvaluation(
        budget: budget,
        usage: usage,
        policy: policy
    )
    
    #expect(evaluation.remainingInputTokenCount == 500)
    #expect(evaluation.status == .nearLimit)
}

@Test
func returnsWithinBudgetWhenRemainingInputTokenCountIsAboveThreshold() throws {
    let budget = try ContextBudget(
        maximumTokenCount: 1000,
        reservedResponseTokenCount: 200
    )
    
    let policy = try ContextBudgetPolicy(nearLimitThresholdTokenCount: 500)
    let usage = try ContextUsage(inputTokenCount: 299)
    
    let evaluation = ContextBudgetEvaluation(
        budget: budget,
        usage: usage,
        policy: policy
    )
    
    #expect(evaluation.remainingInputTokenCount == 501)
    #expect(evaluation.status == .withinBudget)
}
