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
    
    _ = try await context.respond(to: "Say hello in one sentence.")
}
#endif
