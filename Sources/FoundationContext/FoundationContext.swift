import FoundationModels

public final class FoundationContext {
    private let model: SystemLanguageModel
    private let instructions: String?
    private let tokenLimit: Int
    private let keptEntryCount: Int
    private var session: LanguageModelSession
    private var history: [String] = []
    
    public init(
        model: SystemLanguageModel = .default,
        instructions: String? = nil,
        tokenLimit: Int = 4096,
        keptEntryCount: Int = 4
    ) {
        self.model = model
        self.instructions = instructions
        self.tokenLimit = tokenLimit
        self.keptEntryCount = keptEntryCount
        self.session = LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }
    
    public var availability: SystemLanguageModel.Availability {
        model.availability
    }
    
    public func prewarm() {
        session.prewarm()
    }
    
    public var transcript: [String] {
        return history
    }
    
    private var transcriptText: String {
        history.joined(separator: "\n")
    }
    
    public func respond(to message: String) async throws -> String {
        if try await isTooLarge() {
            reset()
        }
        
        do {
            return try await send(message)
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
        history.removeAll()
        self.session = LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }
    
    private func send(_ message: String) async throws -> String {
        let response = try await session.respond(to: message)
        history.append("User: \(message)")
        history.append("Assistant: \(response.content)")
        return response.content
    }
    
    private func recoverAndRetry(_ message: String) async throws -> String {
        let transcript = compactTranscript()
        self.session = LanguageModelSession(
            model: model,
            transcript: transcript
        )
        
        return try await send(message)
    }
    
    private func compactTranscript() -> Transcript {
        let transcript = session.transcript
        
        let instructionEntries = transcript.filter { entry in
            if case .instructions = entry {
                return true
            }
            
            return false
        }
        
        let recentEntries = transcript.filter { entry in
            if case .instructions = entry {
                return false
            }
            
            return true
        }
            .suffix(keptEntryCount)
        
        return Transcript(
            entries: instructionEntries + recentEntries
        )
    }
}

#if DEBUG
import Playgrounds

#Playground {
    let context = FoundationContext(
        instructions: "You are a helpful assistant. Keep replies short."
    )
    
    context.prewarm()
    
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
