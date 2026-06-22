import FoundationModels

public final class FoundationContext {
    private let model: SystemLanguageModel
    private let instructions: String?
    private var session: LanguageModelSession
    
    public init(
        model: SystemLanguageModel = .default,
        instructions: String? = nil
    ) {
        self.model = model
        self.instructions = instructions
        self.session = LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }
    
    public func respond(to message: String) async throws -> String {
        do {
            let response = try await session.respond(to: message)
            return response.content
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            reset()
            let response = try await session.respond(to: message)
            return response.content
        }
    }
    
    public func tokenCount() async throws -> Int {
        try await model.tokenCount(for: session.transcript)
    }
    
    public func needsSummary(limit: Int = 4096) async throws -> Bool {
        try await tokenCount() > limit
    }
    
    public func reset() {
        self.session = LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }
}

#if DEBUG
import Playgrounds

#Playground {
    let context = FoundationContext(
        instructions: "You are a helpful assistant. Keep replies short."
    )
    
    let first = try await context.respond(
        to: "Please remember that my name is Ricky."
    )
    
    let second = try await context.respond(
        to: "What name did I tell you?"
    )
    
    let beforeReset = try await context.tokenCount()
    
    context.reset()
    
    let afterResetTokens = try await context.tokenCount()
    
    let afterReset = try await context.respond(to: "What name did I tell you?")
}
#endif
