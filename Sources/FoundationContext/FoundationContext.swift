import FoundationModels

public final class FoundationContext {
    private let model: SystemLanguageModel
    private let session: LanguageModelSession
    
    public init(
        model: SystemLanguageModel = .default,
        instructions: String? = nil
    ) {
        self.model = model
        self.session = LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }
    
    public func respond(to message: String) async throws -> String {
        let response = try await session.respond(to: message)
        return response.content
    }
    
    public func tokenCount() async throws -> Int {
        try await model.tokenCount(for: session.transcript)
    }
    
    public func needsSummary(limit: Int = 4096) async throws -> Bool {
        try await tokenCount() > limit
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
    
    let tokens = try await context.tokenCount()
    
    let needsSummary = try await context.needsSummary()
}
#endif
