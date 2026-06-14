import Foundation

public enum ContextBudgetPolicyError: Error, Sendable, Equatable {
    case nearLimitThresholdTokenCountCannotBeNegative
}

extension ContextBudgetPolicyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .nearLimitThresholdTokenCountCannotBeNegative:
            return "Near-limit threshold token count cannot be negative."
        }
    }
}
