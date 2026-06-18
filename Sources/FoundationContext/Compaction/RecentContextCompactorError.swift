import Foundation

public enum RecentContextCompactorError: Error, Sendable, Equatable {
    case keptMessageCountCannotBeNegative
}

extension RecentContextCompactorError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .keptMessageCountCannotBeNegative:
            return "Kept message count cannot be negative."
        }
    }
}
