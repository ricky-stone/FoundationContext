public struct ContextUsage: Sendable, Equatable {
    public let inputTokenCount: Int
    
    public init(inputTokenCount: Int) throws {
        guard inputTokenCount >= 0 else {
            throw ContextUsageError.inputTokenCountCannotBeNegative
        }
        self.inputTokenCount = inputTokenCount
    }
}
