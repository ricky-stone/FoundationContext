public enum ContextMessageRole: Sendable, Equatable {
    case system
    case user
    case assistant
    case tool
    case summary
    
    public var displayName: String {
        switch self {
        case .system:
            return "System"
        case .user:
            return "User"
        case .assistant:
            return "Assistant"
        case .tool:
            return "Tool"
        case .summary:
            return "Summary"
        }
    }
}
