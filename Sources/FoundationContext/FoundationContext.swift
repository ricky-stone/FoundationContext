import FoundationModels

public final class FoundationContext {
    private let session: LanguageModelSession
    
    public init(instructions: String? = nil) {
        self.session = LanguageModelSession(instructions: instructions)
    }
    
    public func respond(to message: String) async throws -> String {
        let response = try await session.respond(to: message)
        return response.content
    }
}

#if DEBUG
import Playgrounds

#Playground {
    let context = FoundationContext(
        instructions: "You are a helpful assistant. Keep replies short."
    )
    
    let first = try await context.respond(
        to: "My name is Ricky. Reply with OK."
    )
    
    let second = try await context.respond(
        to: "What is my name?"
    )
}
#endif
