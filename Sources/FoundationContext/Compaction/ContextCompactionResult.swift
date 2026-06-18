public struct ContextCompactionResult: Sendable, Equatable {
    public let transcript: ContextTranscript
    public let removedMessages: [ContextMessage]
    
    public var didCompact: Bool {
        !removedMessages.isEmpty
    }
    
    public init(
        transcript: ContextTranscript,
        removedMessages: [ContextMessage]
    ) {
        self.transcript = transcript
        self.removedMessages = removedMessages
    }
}
