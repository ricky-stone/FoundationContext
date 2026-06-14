import Foundation

public enum ContextBudgetError: Error, Equatable, Sendable {
    case maximumTokenCountMustBePositive
    case reservedResponseTokenCountCannotBeNegative
    case reservedResponseTokenCountMustBeLessThanMaximum
}

extension ContextBudgetError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .maximumTokenCountMustBePositive:
            return "Maximum token count must be greater than zero."
        case .reservedResponseTokenCountCannotBeNegative:
            return "Reserved response token count cannot be negative."
        case .reservedResponseTokenCountMustBeLessThanMaximum:
            return "Reserved response token count must be less than the maximum token count."
        }
    }
}
