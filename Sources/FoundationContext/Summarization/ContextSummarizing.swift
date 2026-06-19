public protocol ContextSummarizing: Sendable {
    func summary(for messages: [ContextMessage]) async throws -> String
}
