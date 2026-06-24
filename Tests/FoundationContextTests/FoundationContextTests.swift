import FoundationContext
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
