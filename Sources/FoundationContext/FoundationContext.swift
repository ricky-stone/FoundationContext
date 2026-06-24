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
    
    public var isResponding: Bool {
        session.isResponding
    }
    
    public func respond(
        to message: String,
        options: GenerationOptions = GenerationOptions()
    ) async throws -> String {
        do {
            return try await send(
                message,
                options: options
            )
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            compact()
            
            return try await send(
                message,
                options: options
            )
        }
    }
    
    public func reset() {
        session = LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }
    
    private func send(
        _ message: String,
        options: GenerationOptions
    ) async throws -> String {
        let response = try await session.respond(
            to: message,
            options: options
        )
        return response.content
    }
    
    private func compact() {
        let newTranscript = compactTranscript(
            session.transcript,
            keepLast: 2
        )
        
        session = LanguageModelSession(
            model: model,
            transcript: newTranscript
        )
    }
    
    internal func compactTranscript(
        _ transcript: Transcript,
        keepLast: Int = 2
    ) -> Transcript {
        let instructions = transcript.filter { entry in
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
            .suffix(keepLast)
        
        return Transcript(
            entries: instructions + recentEntries
        )
    }
}
