import FoundationModels

/// A lightweight wrapper around Foundation Models that compacts context before responding and retries once if the context window is too large.
public final class FoundationContext {
    private let model: SystemLanguageModel
    private let instructions: String?
    private var session: LanguageModelSession
    private let keepTurns: Int
    private let compactAtTokens: Int
    
    /// Creates a context for sending messages to a Foundation Models session.
    ///
    /// - Parameters:
    ///   - model: The system language model to use.
    ///   - instructions: Optional instructions for the model.
    ///   - keepTurns: The number of recent text turns to keep when compacting.
    ///   - compactAtTokens: The transcript token count that triggers compacting before responding.
    public init(
        model: SystemLanguageModel = .default,
        instructions: String? = nil,
        keepTurns: Int = 1,
        compactAtTokens: Int = 3096
    ) {
        self.model = model
        self.instructions = instructions
        self.session = LanguageModelSession(
            model: model,
            instructions: instructions
        )
        self.keepTurns = max(0, keepTurns)
        self.compactAtTokens = max(0, compactAtTokens)
    }
    
    /// A Boolean value that indicates whether the model is currently generating a response.
    public var isResponding: Bool {
        session.isResponding
    }
    
    /// The current Foundation Models transcript for this context.
    public var transcript: Transcript {
        session.transcript
    }
    
    /// Sends a message to the model and returns the response text.
    ///
    /// Before sending, the current transcript is compacted when it reaches `compactAtTokens`.
    /// If Foundation Models still reports that the context window is too large, the context is compacted and the message is retried once.
    ///
    /// - Parameters:
    ///   - message: The message to send to the model.
    ///   - options: Options that control response generation.
    /// - Returns: The response text from the model.
    /// - Throws: An error from Foundation Models if generation fails.
    public func respond(
        to message: String,
        options: GenerationOptions = GenerationOptions()
    ) async throws -> String {
        do {
            let tokenCount = try await model.tokenCount(for: session.transcript)
            
            if shouldCompact(
                tokenCount: tokenCount,
                compactAtTokens: compactAtTokens
            ) {
                compact()
            }
            
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
    
    /// Starts a fresh model session using the original model and instructions.
    public func reset() {
        session = LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }
    
    // MARK: - Sending
    
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
    
    // MARK: - Compacting
    
    private func compact() {
        let newTranscript = compactTranscript(
            session.transcript,
            keepTurns: keepTurns
        )
        
        session = LanguageModelSession(
            model: model,
            transcript: newTranscript
        )
    }
    
    internal func compactTranscript(
        _ transcript: Transcript,
        keepTurns: Int
    ) -> Transcript {
        let instructions = transcript.filter { entry in
            if case .instructions = entry {
                return true
            }
            
            return false
        }
        
        if keepTurns <= 0 {
            return Transcript(
                entries: instructions
            )
        }
        
        let keepEntries = keepTurns * 2
        
        let recentEntries = transcript.filter { entry in
            if case .instructions = entry {
                return false
            }
            
            return true
        }
            .suffix(keepEntries)
        
        return Transcript(
            entries: instructions + recentEntries
        )
    }
    
    internal func shouldCompact(
        tokenCount: Int,
        compactAtTokens: Int
    ) -> Bool {
        return tokenCount >= compactAtTokens
    }
}
