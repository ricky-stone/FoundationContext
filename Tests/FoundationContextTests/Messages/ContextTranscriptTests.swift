import FoundationContext
import Testing

@Test
func formatsMessagesWithRolesAndContentInOrder() {
    let transcript = ContextTranscript(messages: [
        ContextMessage(role: .system, content: "You are helpful."),
        ContextMessage(role: .user, content: "Explain Swift actors."),
        ContextMessage(role: .assistant, content: "Actors protect shared mutable state.")
    ])
    
    let expectedText = """
    System: You are helpful.
    User: Explain Swift actors.
    Assistant: Actors protect shared mutable state.
    """
    
    #expect(transcript.formattedText == expectedText)
}

@Test
func preservesMultilineMessageContentWhenFormattingTranscript() {
    let transcript = ContextTranscript(messages: [
        ContextMessage(
            role: .user,
            content: """
            First line
            Second line
            Third line
            """
        )
    ])
    
    let expectedText = """
    User: First line
    Second line
    Third line
    """
    
    #expect(transcript.formattedText == expectedText)
}

@Test
func emptyTranscriptFormatsAsEmptyString() {
    let transcript = ContextTranscript(messages: [])
    
    #expect(transcript.formattedText == "")
}
