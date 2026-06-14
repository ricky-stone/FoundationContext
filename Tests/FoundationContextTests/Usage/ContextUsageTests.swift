import FoundationContext
import Testing

@Test
func storesInputTokenCount() throws {
    let usage = try ContextUsage(inputTokenCount: 88)
    
    #expect(usage.inputTokenCount == 88)
}

@Test
func throwsWhenInputTokenCountIsNegative() {
    #expect(throws: ContextUsageError.inputTokenCountCannotBeNegative) {
        try ContextUsage(inputTokenCount: -1)
    }
}
