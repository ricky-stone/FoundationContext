import Foundation

public enum ContextUsageError: Error, Equatable, Sendable {
    case inputTokenCountCannotBeNegative
}

extension ContextUsageError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .inputTokenCountCannotBeNegative:
            return "Input token count cannot be negative."
        }
    }
}
