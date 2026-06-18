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

#if DEBUG
import Playgrounds

#Playground {
    let counter = FoundationModelTokenCounter()
    
    let usage = try await counter.usage(
        for: "Explain Swift actors in one sentence."
    )
    
    print("Input token count: \(usage.inputTokenCount)")
}
#endif
