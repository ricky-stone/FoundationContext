import FoundationModels

public struct FoundationModelTokenCounter: ContextTokenCounting {
    private let model: SystemLanguageModel
    
    public init(model: SystemLanguageModel = .default) {
        self.model = model
    }
    
    public func usage(for text: String) async throws -> ContextUsage {
        let tokenCount = try await model.tokenCount(for: text)
        
        return try ContextUsage(inputTokenCount: tokenCount)
    }
}
