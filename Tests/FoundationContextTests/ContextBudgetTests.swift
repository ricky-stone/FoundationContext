import FoundationContext
import Testing

@Test
func availableInputTokenCountSubtractsReservedTokens() throws {
    let budget = try ContextBudget(
        maximumTokenCount: 4096,
        reservedResponseTokenCount: 800
    )
    #expect(budget.availableInputTokenCount == 3296)
}

@Test
func throwsWhenMaximumTokenCountIsZero() {
    #expect(throws: ContextBudgetError.maximumTokenCountMustBePositive) {
        try ContextBudget(
            maximumTokenCount: 0,
            reservedResponseTokenCount: 800
        )
    }
}

@Test
func throwsWhenReservedResponseTokenCountIsNegative() {
    #expect(throws: ContextBudgetError.reservedResponseTokenCountCannotBeNegative) {
        try ContextBudget(
            maximumTokenCount: 4096,
            reservedResponseTokenCount: -100
        )
    }
}

@Test
func throwsWhenReservedResponseTokenCountExceedsBudget() {
    #expect(throws: ContextBudgetError.reservedResponseTokenCountMustBeLessThanMaximum) {
        try ContextBudget(
            maximumTokenCount: 4096,
            reservedResponseTokenCount: 5000
        )
    }
}

@Test
func throwsWhenReservedResponseTokenCountEqualsMaximumTokenCount() {
    #expect(throws: ContextBudgetError.reservedResponseTokenCountMustBeLessThanMaximum) {
        try ContextBudget(
            maximumTokenCount: 4096,
            reservedResponseTokenCount: 4096
        )
    }
}
