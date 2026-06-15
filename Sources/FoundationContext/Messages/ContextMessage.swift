public struct ContextMessage: Sendable, Equatable {
    public let role: ContextMessageRole
    public let content: String
    
    public init(role: ContextMessageRole, content: String) {
        self.role = role
        self.content = content
    }
}
