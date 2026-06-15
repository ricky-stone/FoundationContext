public protocol ContextTokenCounting: Sendable {
    func usage(for text: String) async throws -> ContextUsage
}
