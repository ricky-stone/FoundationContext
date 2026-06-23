import FoundationModels

public final class FoundationContext {
    private let model: SystemLanguageModel
    private let instructions: String?
    public let maxTokens: Int
    public let keepLast: Int
    private var session: LanguageModelSession
    private var transcriptHistory: [String] = []
    private var summary: String?
    
    public init(
        model: SystemLanguageModel = .default,
        instructions: String? = nil,
        maxTokens: Int = 4096,
        keepLast: Int = 4
    ) {
        self.model = model
        self.instructions = instructions
        self.maxTokens = max(1, maxTokens)
        self.keepLast = max(0, keepLast)
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
        summary = nil
        session = LanguageModelSession(
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
        
        let recentEntries = transcript.filter { entry in
            if case .instructions = entry {
                return false
            }
            
            return true
        }
            .suffix(keepLast)
        
        var entries: [Transcript.Entry] = []
        
        if let instructionEntry = compactInstructionEntry() {
            entries.append(instructionEntry)
        }
        
        entries.append(contentsOf: recentEntries)
        
        return Transcript(entries: entries)
    }
    
    private func compactInstructionEntry() -> Transcript.Entry? {
        var parts: [String] = []
        
        if let instructions = instructions {
            parts.append(instructions)
        }
        
        if let summary = summary {
            parts.append("Previous context:\n\(summary)")
        }
        
        guard parts.isEmpty == false else {
            return nil
        }
        
        let text = parts.joined(separator: "\n\n")
        
        let instructions = Transcript.Instructions(
            segments: [
                .text(Transcript.TextSegment(content: text))
            ],
            toolDefinitions: []
        )
        
        return .instructions(instructions)
    }
    
    private func compactTranscriptHistory() {
        transcriptHistory = Array(transcriptHistory.suffix(keepLast))
    }
    
    private func compactSession() {
        let transcript = compactTranscript()
        session = LanguageModelSession(
            model: model,
            transcript: transcript
        )
        
        compactTranscriptHistory()
    }
}
