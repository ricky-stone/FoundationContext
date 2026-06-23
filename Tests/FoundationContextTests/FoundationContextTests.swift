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
func storesMaxTokens() {
    let context = FoundationContext(
        maxTokens: 2048
    )
    
    #expect(context.maxTokens == 2048)
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

@Test
func prewarmsContext() {
    let context = FoundationContext()
    context.prewarm()
}

@Test
func storesKeptEntryCount() {
    let context = FoundationContext(
        keepLast: 6
    )
    
    #expect(context.keepLast == 6)
}

@Test
func clampsLowMaxTokens() {
    let context = FoundationContext(
        maxTokens: 0
    )
    
    #expect(context.maxTokens == 1)
}

@Test
func clampsNegativeKeptEntryCount() {
    let context = FoundationContext(
        keepLast: -1
    )
    
    #expect(context.keepLast == 0)
}

@Test
func compactsContext() {
    let context = FoundationContext()
    context.compact()
}

@Test
func compactsWithNoKeptEntries() {
    let context = FoundationContext(
        keepLast: 0
    )
    
    context.compact()
    
    #expect(context.transcript == [])
}
