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
