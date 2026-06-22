import FoundationModels

public final class FoundationContext {
    private let model: SystemLanguageModel
    private let instructions: String?
    private let tokenLimit: Int
    private var session: LanguageModelSession
    
    public init(
        model: SystemLanguageModel = .default,
        instructions: String? = nil,
        tokenLimit: Int = 4096
    ) {
        self.model = model
        self.instructions = instructions
        self.tokenLimit = tokenLimit
        self.session = LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }
    
    public func respond(to message: String) async throws -> String {
        if try await isTooLarge() {
            reset()
        }
        
        do {
            let response = try await session.respond(to: message)
            return response.content
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            return try await recoverAndRetry(message)
        }
    }
    
    public func tokenCount() async throws -> Int {
        try await model.tokenCount(for: session.transcript)
    }
    
    public func isTooLarge() async throws -> Bool {
        try await tokenCount() > tokenLimit
    }
    
    public func reset() {
        self.session = LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }
    
    private func recoverAndRetry(_ message: String) async throws -> String {
        reset()
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
        to: "Please remember that my name is Ricky."
    )
    
    let second = try await context.respond(
        to: "What name did I tell you?"
    )
    
    let beforeReset = try await context.tokenCount()
    
    let isTooLarge = try await context.isTooLarge()
    
    context.reset()
    
    let afterResetTokens = try await context.tokenCount()
    
    let afterReset = try await context.respond(to: "What name did I tell you?")
}
#endif
