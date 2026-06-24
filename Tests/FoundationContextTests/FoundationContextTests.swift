@testable import FoundationContext
import FoundationModels
import Testing

@Test
func createsContext() {
    _ = FoundationContext()
}

@Test
func createsContextWithInstructions() {
    _ = FoundationContext(
        instructions: "You are a helpful assistant."
    )
}

@Test
func exposesIsResponding() {
    let context = FoundationContext()
    _ = context.isResponding
}

@Test
func exposesTranscript() {
    let context = FoundationContext()
    _ = context.transcript
}

@Test
func compactsTranscript() {
    let context = FoundationContext()
    
    let instructions = Transcript.Entry.instructions(
        Transcript.Instructions(
            segments: [
                .text(Transcript.TextSegment(content: "you are helpful."))
            ],
            toolDefinitions: []
        )
    )
    
    let firstPrompt = Transcript.Entry.prompt(
        Transcript.Prompt(
            segments: [
                .text(Transcript.TextSegment(content: "First"))
            ]
        )
    )
    
    let firstResponse = Transcript.Entry.response(
        Transcript.Response(
            assetIDs: [],
            segments: [
                .text(Transcript.TextSegment(content: "First response"))
            ]
        )
    )
    
    let secondPrompt = Transcript.Entry.prompt(
        Transcript.Prompt(
            segments: [
                .text(Transcript.TextSegment(content: "Second"))
            ]
        )
    )
    
    let secondResponse = Transcript.Entry.response(
        Transcript.Response(
            assetIDs: [],
            segments: [
                .text(Transcript.TextSegment(content: "Second response"))
            ]
        )
    )
    
    let transcript = Transcript(
        entries: [
            instructions,
            firstPrompt,
            firstResponse,
            secondPrompt,
            secondResponse
        ]
    )
    
    let compacted = context.compactTranscript(
        transcript,
        keepTurns: 1
    )
    
    #expect(Array(compacted) == [
        instructions,
        secondPrompt,
        secondResponse
    ])
}
