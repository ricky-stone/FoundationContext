public struct ContextTranscript: Sendable, Equatable {
    public let messages: [ContextMessage]
    
    public var formattedText: String {
        messages.map { message in
            "\(message.role.transcriptLabel): \(message.content)"
        }
        .joined(separator: "\n")
    }
    
    public init(messages: [ContextMessage]) {
        self.messages = messages
    }
}
