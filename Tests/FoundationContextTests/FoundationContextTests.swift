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
func storesTokenLimit() {
    let context = FoundationContext(
        tokenLimit: 2048
    )
    
    #expect(context.tokenLimit == 2048)
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
        keptEntryCount: 6
    )
    
    #expect(context.keptEntryCount == 6)
}

@Test
func clampsLowTokenLimit() {
    let context = FoundationContext(
        tokenLimit: 0
    )
    
    #expect(context.tokenLimit == 1)
}

@Test
func clampsNegativeKeptEntryCount() {
    let context = FoundationContext(
        keptEntryCount: -1
    )
    
    #expect(context.keptEntryCount == 0)
}

@Test
func compactsContext() {
    let context = FoundationContext()
    context.compact()
}
