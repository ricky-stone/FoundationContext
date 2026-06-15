#if DEBUG
import FoundationModels
import Playgrounds

#Playground {
    let counter = FoundationModelTokenCounter()
    
    let usage = try await counter.usage(
        for: "Explain Swift actors in one sentence."
    )
    
    print("Input token count: \(usage.inputTokenCount)")
}
#endif


