import Foundation
import MLX
import MLXLLM
import MLXLMCommon
import UIKit
import Vision

@MainActor
class MLXModelManager: ObservableObject {
    @Published var isModelLoaded = false
    @Published var isLoading = false
    @Published var loadingProgress = 0.0
    @Published var errorMessage: String?
    @Published var isOfflineReady = false
    @Published var modelName = "No Model"
    @Published var currentModelId = ""
    @Published var supportsVision = true
    
    private var chatSession: ChatSession?
    private var currentModel: ModelContext?
    
    // OPTIMIZED: Reduced timeouts for faster responses
    private let generationTimeout: TimeInterval = 8.0  // Reduced from 15s to 8s
    private let imageProcessingTimeout: TimeInterval = 5.0  // Reduced from 10s to 5s
    
    enum MLXError: Error, LocalizedError {
        case modelNotLoaded
        case generationFailed
        case imageProcessingFailed
        case loadingTimeout
        case generationTimeout
        
        var errorDescription: String? {
            switch self {
            case .modelNotLoaded:
                return "Model is not loaded. Please load a model first."
            case .generationFailed:
                return "Failed to generate response."
            case .imageProcessingFailed:
                return "Failed to process image."
            case .loadingTimeout:
                return "Model loading timed out."
            case .generationTimeout:
                return "Response generation timed out."
            }
        }
    }
    
    // MARK: - Public Methods
    func loadDefaultModel() async {
        await loadModel(modelId: "mlx-community/gemma-2-2b-it-4bit")
    }
    
    func loadFastestModel() async {
        // Use the smallest, fastest model for maximum speed
        await loadModel(modelId: "mlx-community/Qwen2.5-0.5B-Instruct-4bit")
    }
    
    func loadBestModel() async {
        await loadModel(modelId: "mlx-community/gemma-2-2b-it-4bit")
    }
    
    func loadBestVisionModel() async {
        // Use fastest model even for vision - we handle images via Apple Vision
        await loadModel(modelId: "mlx-community/Qwen2.5-0.5B-Instruct-4bit")
    }
    
    func getAvailableModels() -> [String] {
        return [
            "mlx-community/Qwen2.5-0.5B-Instruct-4bit",  // Fastest first
            "mlx-community/gemma-2-2b-it-4bit",
            "mlx-community/Phi-3.5-mini-instruct-4bit"
        ]
    }
    
    func getModelInfo(for modelId: String) -> ModelInfo {
        switch modelId {
        case "mlx-community/Qwen2.5-0.5B-Instruct-4bit":
            return ModelInfo(
                name: "Qwen2.5-0.5B",
                size: "~0.3GB",
                speed: "Ultra Fast",
                quality: "Good",
                description: "Smallest, fastest model - optimized for speed",
                supportsVision: true
            )
        case "mlx-community/gemma-2-2b-it-4bit":
            return ModelInfo(
                name: "Gemma 2-2B",
                size: "~1.3GB",
                speed: "Fast",
                quality: "Excellent",
                description: "Balanced performance and quality",
                supportsVision: true
            )
        default:
            return ModelInfo(
                name: "AI Model",
                size: "Variable",
                speed: "Variable",
                quality: "Variable",
                description: "Model with Vision support",
                supportsVision: true
            )
        }
    }
    
    // MARK: - Model Loading
    func loadModel(modelId: String = "mlx-community/Qwen2.5-0.5B-Instruct-4bit") async {
        isLoading = true
        errorMessage = nil
        loadingProgress = 0.0
        isModelLoaded = false
        currentModelId = modelId
        
        print("Loading FASTEST model for speed: \(modelId)")
        
        do {
            updateProgress(0.1, "Initializing...")
            
            updateProgress(0.2, "Downloading model files...")
            let modelContainer = try await MLXLMCommon.loadModel(id: modelId)
            
            updateProgress(0.8, "Creating chat session...")
            self.currentModel = modelContainer
            self.chatSession = ChatSession(modelContainer)
            self.modelName = extractDisplayName(from: modelId)
            
            updateProgress(0.95, "Testing model...")
            try await testModel()
            
            updateProgress(1.0, "Model ready!")
            
            isModelLoaded = true
            isOfflineReady = true
            
            print("✅ FAST Model loaded successfully: \(modelId)")
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load model: \(error.localizedDescription)"
                print("❌ Model loading failed: \(error)")
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    // MARK: - ULTRA-OPTIMIZED Response Generation
    func generateResponse(for message: String, image: UIImage? = nil) async throws -> String {
        guard let session = chatSession else {
            throw MLXError.modelNotLoaded
        }
        
        if let image = image {
            print("🖼️ FAST image processing...")
            
            do {
                // OPTIMIZATION: Use only the fastest image analysis
                let imageDescription = try await analyzeImageFast(image)
                print("✅ Fast image analysis: \(imageDescription)")
                
                // OPTIMIZATION: Ultra-concise prompt for speed
                let combinedPrompt = """
                Image: \(imageDescription)
                Q: \(message.isEmpty ? "Describe this image" : message)
                A:
                """
                
                return try await generateTextResponseUltraFast(session: session, prompt: combinedPrompt)
                
            } catch {
                print("⚠️ Image processing failed, using text-only")
                return try await generateTextResponseUltraFast(session: session, prompt: message)
            }
            
        } else {
            // OPTIMIZATION: Direct ultra-fast text processing
            print("💬 FAST text processing...")
            return try await generateTextResponseUltraFast(session: session, prompt: message)
        }
    }
    
    // OPTIMIZATION: Ultra-fast image analysis - minimal processing
    private func analyzeImageFast(_ image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw MLXError.imageProcessingFailed
        }
        
        return try await withThrowingTaskGroup(of: String.self) { group in
            // Much shorter timeout for speed
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(self.imageProcessingTimeout * 1_000_000_000))
                throw MLXError.imageProcessingFailed
            }
            
            // SIMPLIFIED: Only basic classification for maximum speed
            group.addTask {
                await withCheckedContinuation { continuation in
                    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    
                    // Single, fast request only
                    let classificationRequest = VNClassifyImageRequest { request, error in
                        if let observations = request.results as? [VNClassificationObservation] {
                            let topResults = observations.prefix(2).compactMap { observation -> String? in
                                guard observation.confidence > 0.1 else { return nil } // Lower threshold for speed
                                return observation.identifier.replacingOccurrences(of: "_", with: " ")
                            }
                            
                            let result = topResults.isEmpty ? "image content" : topResults.joined(separator: ", ")
                            continuation.resume(returning: result)
                        } else {
                            continuation.resume(returning: "visual content")
                        }
                    }
                    
                    // Execute immediately on background thread
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            try handler.perform([classificationRequest])
                        } catch {
                            continuation.resume(returning: "image")
                        }
                    }
                }
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    // OPTIMIZATION: Ultra-fast text generation with minimal prompt
    // In MLXModelManager.swift - Fix the timeout mechanism
    private func generateTextResponseUltraFast(session: ChatSession, prompt: String) async throws -> String {
        let fastPrompt = "\(prompt)\nResponse:"
        
        return try await withThrowingTaskGroup(of: String.self) { group in
            // Generation task
            group.addTask {
                try Task.checkCancellation()
                let response = try await session.respond(to: fastPrompt)
                return response.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            // Timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(self.generationTimeout * 1_000_000_000))
                throw MLXError.generationTimeout
            }
            
            // Get first result and cancel others
            guard let result = try await group.next() else {
                throw MLXError.generationFailed
            }
            group.cancelAll()
            
            // CRITICAL: Reset session if we timed out
            if Task.isCancelled {
                await self.resetSessionAfterError()
            }
            
            return result
        }
    }

    // Add this method to reset session after errors
    private func resetSessionAfterError() async {
        if let model = currentModel {
            chatSession = ChatSession(model)
            print("⚠️ Session reset after error")
        }
    }
    
    // OPTIMIZATION: Ultra-fast medical responses
    func generateFastMedicalResponse(for message: String) async throws -> String {
        guard let session = chatSession else {
            throw MLXError.modelNotLoaded
        }
        
        // ULTRA-MINIMAL: Shortest possible prompt for speed
        let fastPrompt = "Medical: \(message)\nAnswer:"
        
        return try await generateTextResponseUltraFast(session: session, prompt: fastPrompt)
    }
    
    // MARK: - Helper Methods
    private func testModel() async throws {
        guard let session = chatSession else {
            throw MLXError.modelNotLoaded
        }
        
        let testMessage = "Hi"
        let testResponse = try await session.respond(to: testMessage)
        if testResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw MLXError.generationFailed
        }
        print("Fast model test passed")
    }
    
    func resetSession() {
        if let model = currentModel {
            chatSession = ChatSession(model)
            print("Session reset for \(currentModelId)")
        }
    }
    
    func checkOfflineStatus() {
        isOfflineReady = isModelLoaded
    }
    
    private func extractDisplayName(from modelId: String) -> String {
        if modelId.contains("Qwen2.5-0.5B") { return "Qwen2.5-0.5B" }
        if modelId.contains("gemma-2-2b") { return "Gemma 2-2B" }
        if modelId.contains("Phi-3.5") { return "Phi-3.5 Mini" }
        return "AI Model"
    }
    
    private func updateProgress(_ progress: Double, _ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.loadingProgress = progress
            print("Progress: \(Int(progress * 100))% - \(message)")
        }
    }
}

// MARK: - Supporting Types
struct ModelInfo {
    let name: String
    let size: String
    let speed: String
    let quality: String
    let description: String
    let supportsVision: Bool
    
    var displayText: String {
        let capability = supportsVision ? "Vision Enabled" : "Text Only"
        return "\(name) • \(size) • \(speed) • \(capability)"
    }
}


//
//
//import Foundation
//import MLX
//import MLXLLM
//import MLXLMCommon
//
//@MainActor
//class MLXModelManager: ObservableObject {
//    @Published var isModelLoaded = false
//    @Published var isLoading = false
//    @Published var loadingProgress = 0.0
//    @Published var errorMessage: String?
//    @Published var isOfflineReady = false
//    @Published var modelName = "No Model"
//    @Published var currentModelId = ""
//    
//    private var chatSession: ChatSession?
//    private var currentModel: ModelContext?
//    
//    // GEMMA 2 MODELS ONLY - WORKING for iOS MLX Swift (December 2024)
//    private let gemmaModels = [
//        // Gemma 2 IT (Instruction Tuned) - FASTEST
//        "mlx-community/gemma-2-2b-it-4bit",              // 2B - RECOMMENDED for iOS
//        "mlx-community/gemma-2-9b-it-4bit",              // 9B - Larger, better quality
//        
//        // Alternative Gemma 2 models
//        "mlx-community/gemma-2-2b-it-8bit",              // 2B 8-bit (higher quality)
//        "mlx-community/Gemma-2-2B-IT-4bit",              // Alternative naming
//        
//        // Gemma 2 Base models (if IT versions don't work)
//        "mlx-community/gemma-2-2b-4bit",                 // Base 2B model
//    ]
//    
//    // MARK: - Public Methods
//    
//    func loadDefaultModel() async {
//        // Use Gemma 2-2B IT as default - most reliable and fast for iOS
//        await loadModel(modelId: "mlx-community/gemma-2-2b-it-4bit")
//    }
//    
//    func loadFastestModel() async {
//        // Use 4-bit 2B model for fastest performance
//        await loadModel(modelId: "mlx-community/gemma-2-2b-it-4bit")
//    }
//    
//    func loadBestQualityModel() async {
//        // Use 9B model for best quality (if device can handle it)
//        await loadModel(modelId: "mlx-community/gemma-2-9b-it-4bit")
//    }
//    
//    func getAvailableModels() -> [String] {
//        return gemmaModels
//    }
//    
//    func getModelInfo(for modelId: String) -> ModelInfo {
//        if modelId.contains("gemma-2-2b-it-4bit") || modelId.contains("Gemma-2-2B-IT-4bit") {
//            return ModelInfo(
//                name: "Gemma 2-2B IT (4-bit)",
//                size: "~1.3GB",
//                speed: "Very Fast",
//                quality: "Excellent",
//                description: "Google's Gemma 2 - BEST for iOS, instruction-tuned"
//            )
//        } else if modelId.contains("gemma-2-2b-it-8bit") {
//            return ModelInfo(
//                name: "Gemma 2-2B IT (8-bit)",
//                size: "~2.1GB",
//                speed: "Fast",
//                quality: "Excellent+",
//                description: "Higher quality Gemma 2, slightly larger"
//            )
//        } else if modelId.contains("gemma-2-9b-it-4bit") {
//            return ModelInfo(
//                name: "Gemma 2-9B IT (4-bit)",
//                size: "~5.2GB",
//                speed: "Moderate",
//                quality: "Outstanding",
//                description: "Largest Gemma 2 - highest quality but slower"
//            )
//        } else if modelId.contains("gemma-2-2b-4bit") {
//            return ModelInfo(
//                name: "Gemma 2-2B Base",
//                size: "~1.3GB",
//                speed: "Very Fast",
//                quality: "Good",
//                description: "Base model (not instruction-tuned)"
//            )
//        } else {
//            return ModelInfo(
//                name: "Gemma 2 Model",
//                size: "Variable",
//                speed: "Variable",
//                quality: "Variable",
//                description: "Gemma 2 family model"
//            )
//        }
//    }
//    
//    func loadModel(modelId: String) async {
//        isLoading = true
//        errorMessage = nil
//        loadingProgress = 0.0
//        isModelLoaded = false
//        currentModelId = modelId
//        
//        print("🔄 Starting Gemma 2 model load: \(modelId)")
//        
//        // Clear memory before loading
//        await clearMemory()
//        
//        // Validate model compatibility
//        guard validateGemmaModel(modelId) else {
//            errorMessage = "Only Gemma 2 models are supported. Gemma 3 and other models are not compatible with iOS."
//            isLoading = false
//            return
//        }
//        
//        do {
//            updateProgress(0.1, "Initializing Gemma 2...")
//            
//            // Set memory optimizations for Gemma 2
//            try optimizeMemoryForGemma(modelId)
//            
//            updateProgress(0.2, "Downloading Gemma 2 model files...")
//            
//            // Load the model with timeout handling and Gemma-specific settings
//            let modelContainer = try await withTimeout(seconds: 600) {
//                try await self.loadGemmaModelWithRetry(modelId: modelId)
//            }
//            
//            currentModel = modelContainer
//            modelName = extractGemmaDisplayName(from: modelId)
//            
//            updateProgress(0.7, "Creating Gemma 2 chat session...")
//            
//            // Create chat session with Gemma-specific configuration
//            chatSession = createGemmaChatSession(modelContainer)
//            
//            updateProgress(0.9, "Testing Gemma 2 model...")
//            
//            // Test with Gemma-friendly prompt
//            try await testGemmaModel()
//            
//            updateProgress(1.0, "Gemma 2 model ready!")
//            
//            isModelLoaded = true
//            isOfflineReady = true
//            
//            print("✅ Gemma 2 model loaded successfully: \(modelId)")
//            
//        } catch {
//            handleGemmaLoadingError(error, for: modelId)
//        }
//        
//        isLoading = false
//    }
//    
//    func generateResponse(for message: String) async throws -> String {
//        guard let session = chatSession else {
//            throw MLXError.modelNotLoaded
//        }
//        
//        print("🤖 Generating response with Gemma 2: \(currentModelId)")
//        
//        do {
//            // Format message for Gemma 2
//            let gemmaFormattedMessage = formatMessageForGemma(message)
//            
//            let response = try await session.respond(to: gemmaFormattedMessage)
//            let processedResponse = postProcessGemmaResponse(response)
//            
//            print("✅ Generated Gemma 2 response (\(response.count) chars)")
//            return processedResponse
//        } catch {
//            print("❌ Gemma 2 generation error: \(error)")
//            throw MLXError.generationFailed
//        }
//    }
//    
//    func resetSession() {
//        if let model = currentModel {
//            chatSession = createGemmaChatSession(model)
//            print("🔄 Gemma 2 chat session reset for \(currentModelId)")
//        }
//    }
//    
//    func checkOfflineStatus() {
//        isOfflineReady = isModelLoaded
//    }
//    
//    // MARK: - Private Gemma-Specific Helper Methods
//    
//    private func validateGemmaModel(_ modelId: String) -> Bool {
//        let lowercaseModelId = modelId.lowercased()
//        
//        // Must be Gemma 2, NOT Gemma 3
//        if lowercaseModelId.contains("gemma-3") || lowercaseModelId.contains("gemma3") {
//            return false
//        }
//        
//        // Must be Gemma 2
//        return lowercaseModelId.contains("gemma-2") || lowercaseModelId.contains("gemma2")
//    }
//    
//    private func loadGemmaModelWithRetry(modelId: String) async throws -> ModelContext {
//        var lastError: Error?
//        
//        // Try up to 3 times for Gemma models (they can be finicky)
//        for attempt in 1...3 {
//            do {
//                print("🔄 Gemma 2 load attempt \(attempt)/3")
//                
//                // Special handling for Gemma 2 models
//                let modelContainer = try await MLXLMCommon.loadModel(id: modelId)
//                
//                print("✅ Gemma 2 model loaded on attempt \(attempt)")
//                return modelContainer
//                
//            } catch {
//                lastError = error
//                print("❌ Gemma 2 load attempt \(attempt) failed: \(error)")
//                
//                if attempt < 3 {
//                    // Wait before retry
//                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
//                }
//            }
//        }
//        
//        throw lastError ?? MLXError.generationFailed
//    }
//    
//    private func createGemmaChatSession(_ model: ModelContext) -> ChatSession {
//        // Create chat session optimized for Gemma 2 models
//        return ChatSession(model)
//    }
//    
//    private func optimizeMemoryForGemma(_ modelId: String) throws {
//        print("🧠 Optimizing memory for Gemma 2 model: \(modelId)")
//        
//        // Set memory limits based on Gemma model size
//        if modelId.contains("9b") || modelId.contains("9B") {
//            // For Gemma 2-9B, need more memory
//            MLX.GPU.set(cacheLimit: 12 * 1024 * 1024 * 1024) // 12GB cache limit
//            print("📱 Set large memory cache for Gemma 2-9B")
//        } else {
//            // For Gemma 2-2B, standard memory is fine
//            MLX.GPU.set(cacheLimit: 6 * 1024 * 1024 * 1024) // 6GB cache limit
//            print("📱 Set standard memory cache for Gemma 2-2B")
//        }
//    }
//    
//    private func testGemmaModel() async throws {
//        print("🧪 Testing Gemma 2 model responsiveness...")
//        do {
//            let testResponse = try await generateResponse(for: "Hello! How are you?")
//            if testResponse.isEmpty {
//                throw MLXError.generationFailed
//            }
//            print("✅ Gemma 2 model test passed")
//        } catch {
//            print("❌ Gemma 2 model test failed: \(error)")
//            throw MLXError.modelNotLoaded
//        }
//    }
//    
//    private func formatMessageForGemma(_ message: String) -> String {
//        // Gemma 2 models work best with clean, direct prompts
//        return message.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//    
//    private func postProcessGemmaResponse(_ response: String) -> String {
//        var processed = response.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        // Remove Gemma-specific prefixes that might appear
//        let gemmaPrefixes = [
//            "model:", "gemma:", "assistant:", "ai:",
//            "Model:", "Gemma:", "Assistant:", "AI:",
//            "Response:", "Output:"
//        ]
//        
//        for prefix in gemmaPrefixes {
//            if processed.hasPrefix(prefix) {
//                processed = String(processed.dropFirst(prefix.count))
//                    .trimmingCharacters(in: .whitespacesAndNewlines)
//                break
//            }
//        }
//        
//        return processed
//    }
//    
//    private func extractGemmaDisplayName(from modelId: String) -> String {
//        if modelId.contains("gemma-2-2b-it-4bit") || modelId.contains("Gemma-2-2B-IT-4bit") {
//            return "Gemma 2-2B IT (4-bit)"
//        } else if modelId.contains("gemma-2-2b-it-8bit") {
//            return "Gemma 2-2B IT (8-bit)"
//        } else if modelId.contains("gemma-2-9b-it-4bit") {
//            return "Gemma 2-9B IT (4-bit)"
//        } else if modelId.contains("gemma-2-2b-4bit") {
//            return "Gemma 2-2B Base"
//        } else {
//            return "Gemma 2 Model"
//        }
//    }
//    
//    private func handleGemmaLoadingError(_ error: Error, for modelId: String) {
//        print("❌ Gemma 2 model loading failed: \(error)")
//        
//        let errorString = error.localizedDescription.lowercased()
//        
//        if errorString.contains("tokenizer") {
//            errorMessage = "Gemma 2 tokenizer issue. Try the alternative Gemma-2-2B-IT-4bit model."
//        } else if errorString.contains("memory") || errorString.contains("out of memory") {
//            if modelId.contains("9b") {
//                errorMessage = "Gemma 2-9B requires more memory. Try Gemma 2-2B instead."
//            } else {
//                errorMessage = "Not enough memory for Gemma 2. Close other apps and try again."
//            }
//        } else if errorString.contains("timeout") {
//            errorMessage = "Gemma 2 loading timeout. Check internet connection and try again."
//        } else if errorString.contains("network") || errorString.contains("download") {
//            errorMessage = "Network error downloading Gemma 2. Check internet connection."
//        } else if modelId.contains("gemma-3") || modelId.contains("gemma3") {
//            errorMessage = "Gemma 3 models are NOT supported on iOS. Only Gemma 2 models work."
//        } else {
//            errorMessage = "Failed to load Gemma 2 model. Try Gemma-2-2B-IT-4bit (most reliable)."
//        }
//    }
//    
//    // MARK: - Utility Methods
//    
//    private func clearMemory() async {
//        currentModel = nil
//        chatSession = nil
//        
//        // Force garbage collection for Gemma models
//        autoreleasepool {
//            // Clear any cached Gemma data
//        }
//        
//        // Allow cleanup time
//        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
//    }
//    
//    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
//        return try await withThrowingTaskGroup(of: T.self) { group in
//            group.addTask {
//                try await operation()
//            }
//            
//            group.addTask {
//                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
//                throw MLXError.loadingTimeout
//            }
//            
//            guard let result = try await group.next() else {
//                throw MLXError.loadingTimeout
//            }
//            
//            group.cancelAll()
//            return result
//        }
//    }
//    
//    private func updateProgress(_ progress: Double, _ message: String) {
//        DispatchQueue.main.async { [weak self] in
//            self?.loadingProgress = progress
//            print("📊 Gemma 2 Progress: \(Int(progress * 100))% - \(message)")
//        }
//    }
//}
//
//// MARK: - Supporting Structures
//
//struct ModelInfo {
//    let name: String
//    let size: String
//    let speed: String
//    let quality: String
//    let description: String
//    
//    var displayText: String {
//        return "\(name) • \(size) • Speed: \(speed) • Quality: \(quality)"
//    }
//}
//
//enum MLXError: Error, LocalizedError {
//    case modelNotLoaded
//    case generationFailed
//    case unsupportedModel
//    case memoryError
//    case loadingTimeout
//    
//    var errorDescription: String? {
//        switch self {
//        case .modelNotLoaded:
//            return "Gemma 2 model is not loaded. Please load a Gemma 2 model first."
//        case .generationFailed:
//            return "Failed to generate response with Gemma 2 model."
//        case .unsupportedModel:
//            return "Only Gemma 2 models are supported. Gemma 3 does not work on iOS."
//        case .memoryError:
//            return "Not enough memory for Gemma 2 model. Try Gemma 2-2B instead of 9B."
//        case .loadingTimeout:
//            return "Gemma 2 model loading timed out. Check internet connection."
//        }
//    }
//}
//
//// MARK: - Extensions
//
//extension MLXModelManager {
//    func getDebugInfo() -> String {
//        return """
//        Current Model: \(modelName)
//        Model ID: \(currentModelId)
//        Is Loaded: \(isModelLoaded)
//        Is Loading: \(isLoading)
//        Progress: \(Int(loadingProgress * 100))%
//        Offline Ready: \(isOfflineReady)
//        Error: \(errorMessage ?? "None")
//        
//        Supported Models: Gemma 2 ONLY
//        - gemma-2-2b-it-4bit (RECOMMENDED)
//        - gemma-2-9b-it-4bit (Higher quality)
//        - gemma-2-2b-it-8bit (Alternative)
//        
//        Note: Gemma 3 models are NOT supported on iOS
//        """
//    }
//    
//    func isGemma3Model(_ modelId: String) -> Bool {
//        let lowercased = modelId.lowercased()
//        return lowercased.contains("gemma-3") || lowercased.contains("gemma3")
//    }
//}
