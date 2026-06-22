import FoundationModels

public final class FoundationContext {
    private let session: LanguageModelSession
    
    public init() {
        self.session = LanguageModelSession()
    }
    
    public func respond(to message: String) async throws -> String {
        let response = try await session.respond(to: message)
        return response.content
    }
}
