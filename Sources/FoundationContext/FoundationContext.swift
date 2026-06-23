import FoundationModels

/// A lightweight wrapper around Foundation Models that can summarize and compact context as it grows.
public final class FoundationContext {
    private let model: SystemLanguageModel
    private let instructions: String?
    
    /// The token count where the context should be compacted before continuing.
    public let maxTokens: Int
    
    /// The number of recent transcript entries to keep when compacting.
    public let keepLast: Int
    
    private var session: LanguageModelSession
    private var transcriptHistory: [String] = []
    private var summary: String?
    private var summaryInputLimit: Int {
        max(1, maxTokens / 2)
    }
    
    /// Creates a context for sending messages to a Foundation Models session.
    ///
    /// - Parameters:
    ///   - model: The system language model to use.
    ///   - instructions: Optional instructions for the model.
    ///   - maxTokens: The token count where the context should be compacted.
    ///   - keepLast: The number of recent transcript entries to keep when compacting.
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
    
    // MARK: - Public API
    
    /// The current availability of the underlying system language model.
    public var availability: SystemLanguageModel.Availability {
        model.availability
    }
    
    /// Prepares the model session so the next response can start sooner.
    public func prewarm() {
        session.prewarm()
    }
    
    /// A simple text transcript of messages sent and received through this context.
    public var transcript: [String] {
        return transcriptHistory
    }
    
    /// Sends a message to the model and returns the response text.
    ///
    /// If the context is too large, the context is summarized and compacted before sending.
    ///
    /// - Parameter message: The message to send to the model.
    /// - Returns: The response text from the model.
    /// - Throws: An error from Foundation Models if token counting or generation fails.
    public func respond(to message: String) async throws -> String {
        if try await needsCompact() {
            await summarize()
            compactSession()
        }
        
        do {
            return try await send(message)
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            return try await recoverAndRetry(message)
        }
    }
    
    /// Returns the current token count for the model session transcript.
    ///
    /// - Throws: An error from Foundation Models if token counting fails.
    public func tokenCount() async throws -> Int {
        try await model.tokenCount(for: session.transcript)
    }
    
    /// Returns whether the current context is over `maxTokens` and should be compacted.
    ///
    /// - Throws: An error from Foundation Models if token counting fails.
    public func needsCompact() async throws -> Bool {
        try await tokenCount() > maxTokens
    }
    
    /// Manually compacts the current context without generating a new summary.
    public func compact() {
        compactSession()
    }
    
    /// Clears the transcript and summary, then starts a fresh model session.
    public func reset() {
        transcriptHistory.removeAll()
        summary = nil
        session = LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }
    
    // MARK: - Sending
    
    private func send(_ message: String) async throws -> String {
        let response = try await session.respond(to: message)
        transcriptHistory.append("User: \(message)")
        transcriptHistory.append("Assistant: \(response.content)")
        return response.content
    }
    
    private func recoverAndRetry(_ message: String) async throws -> String {
        await summarize()
        compactSession()
        return try await send(message)
    }
    
    // MARK: - Summarizing
    
    private func summarize() async {
        let text = await summaryText()
        
        guard text.isEmpty == false else {
            return
        }
        
        let summarySession = LanguageModelSession(
            model: model,
            instructions: """
            Summarize the conversation for future context.
            Keep important facts, decisions, names, and open questions.
            Keep it short.
            """
        )
        
        do {
            let response = try await summarySession.respond(
                to: text,
                options: GenerationOptions(maximumResponseTokens: 200)
            )
            summary = response.content
        } catch {
            return
        }
    }
    
    private func summaryText() async -> String {
        let withSummary = await boundedSummaryText(
            history: transcriptHistory,
            includeSummary: true
        )
        
        if withSummary.keptHistoryCount > 0 || transcriptHistory.isEmpty || summary == nil {
            return withSummary.text
        }
        
        let withoutSummary = await boundedSummaryText(
            history: transcriptHistory,
            includeSummary: false
        )
        
        if withoutSummary.text.isEmpty == false {
            return withoutSummary.text
        }
        
        return withSummary.text
    }
    
    private func boundedSummaryText(
        history originalHistory: [String],
        includeSummary: Bool
    ) async -> (text: String, keptHistoryCount: Int) {
        var history = originalHistory
        var text = makeSummaryText(history: history, includeSummary: includeSummary)
        
        while await isSummaryTextTooLarge(text), history.isEmpty == false {
            history.removeFirst()
            text = makeSummaryText(history: history, includeSummary: includeSummary)
        }
        
        guard await isSummaryTextTooLarge(text) == false else {
            return ("", 0)
        }
        
        return (text, history.count)
    }
    
    private func makeSummaryText(history: [String], includeSummary: Bool) -> String {
        var parts: [String] = []
        
        if includeSummary, let summary = summary {
            parts.append("Existing summary:\n\(summary)")
        }
        
        if history.isEmpty == false {
            parts.append("Recent conversation:\n\(history.joined(separator: "\n"))")
        }
        
        return parts.joined(separator: "\n\n")
    }
    
    private func isSummaryTextTooLarge(_ text: String) async -> Bool {
        if let tokenCount = try? await model.tokenCount(for: text) {
            return tokenCount > summaryInputLimit
        }
        
        return text.count > summaryInputLimit * 3
    }
    
    // MARK: - Compacting
    
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
