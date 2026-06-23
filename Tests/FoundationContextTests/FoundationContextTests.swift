import FoundationContext
import Testing

@Test
func createsContext() {
    _ = FoundationContext()
}

@Test
func createsContextWithInstructions() {
    _ = FoundationContext(
        instructions: "You are helpful."
    )
}

@Test
func resetsContext() {
    let context = FoundationContext()
    context.reset()
}

@Test
func createsContextWithTokenLimit() {
    _ = FoundationContext(
        tokenLimit: 4096
    )
}

@Test
func startsWithEmptyTranscript() {
    let context = FoundationContext()
    
    #expect(context.transcript == [])
}

@Test
func exposesAvailability() {
    let context = FoundationContext()
    _ = context.availability
}
