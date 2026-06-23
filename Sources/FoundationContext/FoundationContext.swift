import FoundationModels

public final class FoundationContext {
    private let model: SystemLanguageModel
    private let instructions: String?
    public let maxTokens: Int
    public let keptEntryCount: Int
    private var session: LanguageModelSession
    private var transcriptHistory: [String] = []
    
    public init(
        model: SystemLanguageModel = .default,
        instructions: String? = nil,
        maxTokens: Int = 4096,
        keptEntryCount: Int = 4
    ) {
        self.model = model
        self.instructions = instructions
        self.maxTokens = max(1, maxTokens)
        self.keptEntryCount = max(0, keptEntryCount)
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
        return transcriptHistory
    }
    
    public func respond(to message: String) async throws -> String {
        if try await needsCompact() {
            compactSession()
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
    
    public func needsCompact() async throws -> Bool {
        try await tokenCount() > maxTokens
    }
    
    public func compact() {
        compactSession()
    }
    
    public func reset() {
        transcriptHistory.removeAll()
        self.session = LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }
    
    private func send(_ message: String) async throws -> String {
        let response = try await session.respond(to: message)
        transcriptHistory.append("User: \(message)")
        transcriptHistory.append("Assistant: \(response.content)")
        return response.content
    }
    
    private func recoverAndRetry(_ message: String) async throws -> String {
        compactSession()
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
    
    private func compactTranscriptHistory() {
        transcriptHistory = Array(transcriptHistory.suffix(keptEntryCount))
    }
    
    private func compactSession() {
        let transcript = compactTranscript()
        self.session = LanguageModelSession(
            model: model,
            transcript: transcript
        )
        
        compactTranscriptHistory()
    }
}
