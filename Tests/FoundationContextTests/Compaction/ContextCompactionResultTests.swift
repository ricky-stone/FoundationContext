import FoundationContext
import Testing

@Test
func storesTranscriptAndRemovedMessages() {
    let transcript = ContextTranscript(messages: [
        ContextMessage(role: .summary, content: "Earlier conversation summary."),
        ContextMessage(role: .user, content: "What should we do next?")
    ])
    
    let removedMessages = [
        ContextMessage(role: .user, content: "Old question."),
        ContextMessage(role: .assistant, content: "Old answer.")
    ]
    
    let result = ContextCompactionResult(
        transcript: transcript,
        removedMessages: removedMessages
    )
    
    #expect(result.transcript == transcript)
    #expect(result.removedMessages == removedMessages)
}

@Test
func didCompactReturnsTrueWhenMessagesWereRemoved() {
    let result = ContextCompactionResult(
        transcript: ContextTranscript(messages: []),
        removedMessages: [
            ContextMessage(role: .user, content: "Old question.")
        ]
    )
    
    #expect(result.didCompact)
}

@Test
func didCompactReturnsFalseWhenNoMessagesWereRemoved() {
    let result = ContextCompactionResult(
        transcript: ContextTranscript(messages: []),
        removedMessages: []
    )
    
    #expect(!result.didCompact)
}
