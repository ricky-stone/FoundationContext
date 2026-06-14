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
func returnsTrueWhenUsageExceedsAvailableInputTokens() throws {
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
