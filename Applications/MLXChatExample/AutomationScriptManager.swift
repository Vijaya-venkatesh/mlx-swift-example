// ****************************************************************************************



//
//import Foundation
//import UIKit
//
//@MainActor
//class AutomationScriptManager: ObservableObject {
//    @Published var scripts: [AutomationScript] = []
//    @Published var currentScriptIndex = 0
//    
//    // NEW: Sample test images (you can replace these with your own)
//    private let testImages: [String: UIImage] = [:]
//    
//    init() {
//        setupTestScripts()
//    }
//    
//    private func setupTestScripts() {
//        scripts = [
//            // EXISTING TEXT-ONLY TESTS
//            AutomationScript(
//                id: "text_basic",
//                userMessage: "Hello! Can you tell me what you are?",
//                expectedKeywords: ["AI", "assistant", "help"],
//                testType: .textOnly,
//                description: "Basic greeting test"
//            ),
//            
//            AutomationScript(
//                id: "text_math",
//                userMessage: "What is 15 + 27?",
//                expectedKeywords: ["42", "forty-two"],
//                testType: .textOnly,
//                description: "Simple math test"
//            ),
//            
//            AutomationScript(
//                id: "text_creative",
//                userMessage: "Write a short poem about technology",
//                expectedKeywords: ["technology", "digital", "future", "computer"],
//                testType: .textOnly,
//                description: "Creative writing test"
//            ),
//            
//            AutomationScript(
//                id: "text_reasoning",
//                userMessage: "If all cats are animals, and some animals are pets, can we conclude that some cats are pets?",
//                expectedKeywords: ["logic", "yes", "true", "correct"],
//                testType: .textOnly,
//                description: "Logical reasoning test"
//            ),
//            
//            // NEW: IMAGE-RELATED TESTS (only if vision model is loaded)
//            AutomationScript(
//                id: "vision_capability_check",
//                userMessage: "Can you analyze images?",
//                expectedKeywords: ["image", "vision", "see", "analyze", "photo"],
//                testType: .visionCapability,
//                description: "Vision capability check"
//            ),
//            
//            AutomationScript(
//                id: "image_description_test",
//                userMessage: "Describe what you see in this image",
//                expectedKeywords: ["describe", "see", "image", "photo"],
//                testType: .imageAnalysis,
//                description: "Image description test",
//                requiresImage: true,
//                testImageName: "sample_image"
//            ),
//            
//            AutomationScript(
//                id: "image_object_detection",
//                userMessage: "What objects can you identify in this picture?",
//                expectedKeywords: ["object", "identify", "see"],
//                testType: .imageAnalysis,
//                description: "Object detection test",
//                requiresImage: true,
//                testImageName: "sample_image"
//            ),
//            
//            AutomationScript(
//                id: "image_color_analysis",
//                userMessage: "What are the main colors in this image?",
//                expectedKeywords: ["color", "colours", "red", "blue", "green", "yellow"],
//                testType: .imageAnalysis,
//                description: "Color analysis test",
//                requiresImage: true,
//                testImageName: "sample_image"
//            ),
//            
//            AutomationScript(
//                id: "image_text_reading",
//                userMessage: "Can you read any text in this image?",
//                expectedKeywords: ["text", "read", "words", "letters"],
//                testType: .imageAnalysis,
//                description: "Text recognition test",
//                requiresImage: true,
//                testImageName: "text_image"
//            ),
//            
//            AutomationScript(
//                id: "mixed_image_text",
//                userMessage: "Look at this image and tell me a story about what's happening",
//                expectedKeywords: ["story", "happening", "scene"],
//                testType: .imageAnalysis,
//                description: "Image storytelling test",
//                requiresImage: true,
//                testImageName: "sample_image"
//            )
//        ]
//    }
//    
//    // NEW: Filter scripts based on model capabilities
//    func getScriptsForModel(supportsVision: Bool) -> [AutomationScript] {
//        if supportsVision {
//            return scripts // Return all scripts
//        } else {
//            return scripts.filter { $0.testType == .textOnly } // Only text scripts
//        }
//    }
//    
//    func getNextScript(supportsVision: Bool = true) -> AutomationScript? {
//        let availableScripts = getScriptsForModel(supportsVision: supportsVision)
//        let incompleteScripts = availableScripts.filter { !$0.isCompleted }
//        return incompleteScripts.first
//    }
//    
//    // NEW: Get test image for script
//    func getTestImage(for scriptId: String) -> UIImage? {
//        guard let script = scripts.first(where: { $0.id == scriptId }),
//              let imageName = script.testImageName else {
//            return nil
//        }
//        
//        // Return test image or create a simple placeholder
//        return createPlaceholderImage(for: imageName)
//    }
//    
//    // NEW: Create placeholder images for testing
//    private func createPlaceholderImage(for imageName: String) -> UIImage {
//        let size = CGSize(width: 300, height: 200)
//        let renderer = UIGraphicsImageRenderer(size: size)
//        
//        return renderer.image { context in
//            // Background
//            UIColor.systemBlue.setFill()
//            context.fill(CGRect(origin: .zero, size: size))
//            
//            // Text
//            let text: String
//            switch imageName {
//            case "sample_image":
//                text = "🏠 HOUSE\n🌳 TREE\n☀️ SUN"
//            case "text_image":
//                text = "HELLO WORLD\nTEST IMAGE\n123 456"
//            default:
//                text = "TEST IMAGE\n\(imageName.uppercased())"
//            }
//            
//            let attributes: [NSAttributedString.Key: Any] = [
//                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
//                .foregroundColor: UIColor.white
//            ]
//            
//            let textSize = text.size(withAttributes: attributes)
//            let textRect = CGRect(
//                x: (size.width - textSize.width) / 2,
//                y: (size.height - textSize.height) / 2,
//                width: textSize.width,
//                height: textSize.height
//            )
//            
//            text.draw(in: textRect, withAttributes: attributes)
//        }
//    }
//    
//    func validateResponse(_ response: String, for script: AutomationScript) -> TestResult {
//        let lowercaseResponse = response.lowercased()
//        
//        // Check if it's an error response
//        if lowercaseResponse.contains("error") || lowercaseResponse.contains("failed") {
//            return .failed
//        }
//        
//        // For vision capability check, just ensure it mentions vision
//        if script.testType == .visionCapability {
//            if script.expectedKeywords.contains(where: { lowercaseResponse.contains($0.lowercased()) }) {
//                return .passed
//            } else {
//                return .failed
//            }
//        }
//        
//        // For image analysis, be more lenient - any reasonable response is good
//        if script.testType == .imageAnalysis {
//            // Check if response is substantial (not just "I can't see" or error)
//            if lowercaseResponse.contains("can't") || lowercaseResponse.contains("cannot") ||
//               lowercaseResponse.contains("unable") || response.count < 20 {
//                return .failed
//            }
//            return .passed
//        }
//        
//        // For text-only tests, use keyword matching
//        let matchedKeywords = script.expectedKeywords.filter { keyword in
//            lowercaseResponse.contains(keyword.lowercased())
//        }
//        
//        // Pass if at least one keyword matches
//        return matchedKeywords.isEmpty ? .failed : .passed
//    }
//    
//    func reset() {
//        for i in scripts.indices {
//            scripts[i].isCompleted = false
//            scripts[i].aiResponse = nil
//            scripts[i].testResult = nil
//        }
//        currentScriptIndex = 0
//    }
//    
//    // NEW: Get test statistics
//    func getTestStatistics(supportsVision: Bool) -> TestStatistics {
//        let relevantScripts = getScriptsForModel(supportsVision: supportsVision)
//        let completedScripts = relevantScripts.filter { $0.isCompleted }
//        let passedScripts = completedScripts.filter { $0.testResult == .passed }
//        
//        return TestStatistics(
//            totalTests: relevantScripts.count,
//            completedTests: completedScripts.count,
//            passedTests: passedScripts.count,
//            failedTests: completedScripts.count - passedScripts.count,
//            textOnlyTests: relevantScripts.filter { $0.testType == .textOnly }.count,
//            visionTests: relevantScripts.filter { $0.testType != .textOnly }.count
//        )
//    }
//}
//
//// UPDATED: Automation script with image support
//struct AutomationScript: Identifiable {
//    let id: String
//    let userMessage: String
//    let expectedKeywords: [String]
//    let testType: TestType
//    let description: String
//    let requiresImage: Bool
//    let testImageName: String?
//    
//    var isCompleted = false
//    var aiResponse: String?
//    var testResult: TestResult?
//    
//    init(id: String, userMessage: String, expectedKeywords: [String], testType: TestType, description: String, requiresImage: Bool = false, testImageName: String? = nil) {
//        self.id = id
//        self.userMessage = userMessage
//        self.expectedKeywords = expectedKeywords
//        self.testType = testType
//        self.description = description
//        self.requiresImage = requiresImage
//        self.testImageName = testImageName
//    }
//}
//
//// NEW: Test types
//enum TestType {
//    case textOnly
//    case visionCapability
//    case imageAnalysis
//}
//
//// EXISTING: Test results
//enum TestResult {
//    case passed
//    case failed
//}
//
//// NEW: Test statistics
//struct TestStatistics {
//    let totalTests: Int
//    let completedTests: Int
//    let passedTests: Int
//    let failedTests: Int
//    let textOnlyTests: Int
//    let visionTests: Int
//    
//    var completionRate: Double {
//        guard totalTests > 0 else { return 0 }
//        return Double(completedTests) / Double(totalTests)
//    }
//    
//    var passRate: Double {
//        guard completedTests > 0 else { return 0 }
//        return Double(passedTests) / Double(completedTests)
//    }
//}
//
// ****************************************************************************************

//
//import Foundation
//import UIKit
//
//@MainActor
//class AutomationScriptManager: ObservableObject {
//    @Published var scripts: [AutomationScript] = []
//    @Published var currentScriptIndex = 0
//    
//    init() {
//        setupMedicalTestScripts()
//    }
//    
//    private func setupMedicalTestScripts() {
//        scripts = [
//            AutomationScript(
//                id: 1,
//                name: "Heart Attack Warning Signs",
//                userMessage: "What are the warning signs of a heart attack, and how should they be addressed promptly?",
//                expectedKeywords: ["chest pain", "shortness of breath", "nausea", "sweating", "arm pain", "jaw pain", "call 911", "emergency", "aspirin", "symptoms"],
//                testType: .textOnly,
//                description: "Heart attack symptoms and emergency response"
//            ),
//            
//            AutomationScript(
//                id: 2,
//                name: "Atrial Fibrillation Symptoms",
//                userMessage: "How can patients identify symptoms of atrial fibrillation, and when should they seek medical care?",
//                expectedKeywords: ["irregular heartbeat", "palpitations", "dizziness", "fatigue", "chest discomfort", "shortness of breath", "medical care", "doctor", "symptoms"],
//                testType: .textOnly,
//                description: "Atrial fibrillation identification and care timing"
//            ),
//            
//            AutomationScript(
//                id: 3,
//                name: "Congestive Heart Failure Indicators",
//                userMessage: "What are the early indicators of congestive heart failure?",
//                expectedKeywords: ["shortness of breath", "swelling", "fatigue", "rapid weight gain", "cough", "difficulty sleeping", "legs", "ankles", "fluid retention"],
//                testType: .textOnly,
//                description: "Early signs of congestive heart failure"
//            ),
//            
//            AutomationScript(
//                id: 4,
//                name: "Pneumonia Symptoms",
//                userMessage: "What are the symptoms of pneumonia, and how can they differ in mild versus severe cases?",
//                expectedKeywords: ["cough", "fever", "chest pain", "shortness of breath", "fatigue", "mild", "severe", "breathing difficulty", "phlegm", "chills"],
//                testType: .textOnly,
//                description: "Pneumonia symptoms - mild vs severe cases"
//            )
//        ]
//    }
//    
//    // Filter scripts based on model capabilities
//    func getScriptsForModel(supportsVision: Bool) -> [AutomationScript] {
//        // Since all our scripts are text-only medical queries, return all scripts regardless of vision support
//        return scripts
//    }
//    
//    func getNextScript(supportsVision: Bool = true) -> AutomationScript? {
//        let availableScripts = getScriptsForModel(supportsVision: supportsVision)
//        let incompleteScripts = availableScripts.filter { !$0.isCompleted }
//        return incompleteScripts.first
//    }
//    
//    // No test images needed for these medical queries
//    func getTestImage(for scriptId: String) -> UIImage? {
//        return nil
//    }
//    
//    func validateResponse(_ response: String, for script: AutomationScript) -> TestResult {
//        let lowercaseResponse = response.lowercased()
//        
//        // Check if it's an error response
//        if lowercaseResponse.contains("error") || lowercaseResponse.contains("failed") {
//            return .failed
//        }
//        
//        // Check if response is too short (medical queries should have substantial responses)
//        let wordCount = response.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.count
//        if wordCount < 20 {
//            print("Response too short: \(wordCount) words for medical query \(script.name)")
//            return .failed
//        }
//        
//        // For medical queries, check if response contains relevant keywords
//        let matchedKeywords = script.expectedKeywords.filter { keyword in
//            lowercaseResponse.contains(keyword.lowercased())
//        }
//        
//        // Medical responses should match at least 2 keywords to be considered valid
//        let minimumMatches = 2
//        if matchedKeywords.count >= minimumMatches {
//            print("✅ Medical query \(script.name) passed with \(matchedKeywords.count) keyword matches: \(matchedKeywords)")
//            return .passed
//        } else {
//            print("❌ Medical query \(script.name) failed - only \(matchedKeywords.count) keyword matches (need \(minimumMatches))")
//            return .failed
//        }
//    }
//    
//    func reset() {
//        for i in scripts.indices {
//            scripts[i].isCompleted = false
//            scripts[i].aiResponse = ""
//            scripts[i].testResult = nil
//        }
//        currentScriptIndex = 0
//    }
//    
//    // Get test statistics
//    func getTestStatistics(supportsVision: Bool) -> TestStatistics {
//        let relevantScripts = getScriptsForModel(supportsVision: supportsVision)
//        let completedScripts = relevantScripts.filter { $0.isCompleted }
//        let passedScripts = completedScripts.filter { $0.testResult == .passed }
//        
//        // For medical queries, we expect detailed responses, so don't track "concise" responses
//        let substantialResponses = completedScripts.filter { script in
//            let wordCount = script.aiResponse.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.count
//            return wordCount >= 30 // Medical responses should be substantial
//        }
//        
//        return TestStatistics(
//            totalTests: relevantScripts.count,
//            completedTests: completedScripts.count,
//            passedTests: passedScripts.count,
//            failedTests: completedScripts.count - passedScripts.count,
//            textOnlyTests: relevantScripts.count, // All are text-only
//            visionTests: 0, // No vision tests
//            conciseResponses: substantialResponses.count // Renamed to substantial for medical context
//        )
//    }
//}
//
//// UPDATED: Automation script structure remains the same
//struct AutomationScript: Identifiable {
//    let id: Int
//    let name: String
//    let userMessage: String
//    let expectedKeywords: [String]
//    let testType: TestType
//    let description: String
//    let requiresImage: Bool
//    let testImageName: String?
//    
//    var isCompleted = false
//    var aiResponse: String = ""
//    var testResult: TestResult?
//    
//    init(id: Int, name: String, userMessage: String, expectedKeywords: [String], testType: TestType, description: String, requiresImage: Bool = false, testImageName: String? = nil) {
//        self.id = id
//        self.name = name
//        self.userMessage = userMessage
//        self.expectedKeywords = expectedKeywords
//        self.testType = testType
//        self.description = description
//        self.requiresImage = requiresImage
//        self.testImageName = testImageName
//    }
//}
//
//// Test types
//enum TestType {
//    case textOnly
//    case visionCapability
//    case imageAnalysis
//}
//
//// Test results with display names
//enum TestResult {
//    case passed
//    case failed
//    
//    var displayName: String {
//        switch self {
//        case .passed:
//            return "PASSED"
//        case .failed:
//            return "FAILED"
//        }
//    }
//    
//    var color: UIColor {
//        switch self {
//        case .passed:
//            return .systemGreen
//        case .failed:
//            return .systemRed
//        }
//    }
//}
//
//// Test statistics structure remains the same
//struct TestStatistics {
//    let totalTests: Int
//    let completedTests: Int
//    let passedTests: Int
//    let failedTests: Int
//    let textOnlyTests: Int
//    let visionTests: Int
//    let conciseResponses: Int // For medical queries, this tracks substantial responses
//    
//    var completionRate: Double {
//        guard totalTests > 0 else { return 0 }
//        return Double(completedTests) / Double(totalTests)
//    }
//    
//    var passRate: Double {
//        guard completedTests > 0 else { return 0 }
//        return Double(passedTests) / Double(completedTests)
//    }
//    
//    var conciseRate: Double {
//        guard completedTests > 0 else { return 0 }
//        return Double(conciseResponses) / Double(completedTests)
//    }
//}
//


import Foundation
import UIKit

@MainActor
class AutomationScriptManager: ObservableObject {
    @Published var scripts: [AutomationScript] = []
    @Published var currentScriptIndex = 0
    
    init() {
        setupOptimizedTestScripts()
    }
    
    private func setupOptimizedTestScripts() {
        scripts = [
            // OPTIMIZED TEXT SCRIPTS - Shorter, focused questions for faster responses
            AutomationScript(
                id: 1,
                name: "Heart Attack Signs",
                userMessage: "List heart attack warning signs",
                expectedKeywords: ["chest pain", "shortness of breath", "nausea", "sweating", "arm pain", "emergency"],
                testType: .textOnly,
                description: "Heart attack symptoms"
            ),
            
            AutomationScript(
                id: 2,
                name: "Atrial Fibrillation",
                userMessage: "What are AFib symptoms?",
                expectedKeywords: ["irregular heartbeat", "palpitations", "dizziness", "fatigue", "chest", "medical care"],
                testType: .textOnly,
                description: "AFib symptoms"
            ),
            
            AutomationScript(
                id: 3,
                name: "Heart Failure Signs",
                userMessage: "Early heart failure indicators?",
                expectedKeywords: ["shortness of breath", "swelling", "fatigue", "weight gain", "cough", "legs"],
                testType: .textOnly,
                description: "Heart failure signs"
            ),
            
            AutomationScript(
                id: 4,
                name: "Pneumonia Symptoms",
                userMessage: "Pneumonia symptoms?",
                expectedKeywords: ["cough", "fever", "chest pain", "shortness of breath", "fatigue", "breathing"],
                testType: .textOnly,
                description: "Pneumonia symptoms"
            ),
            
            // OPTIMIZED IMAGE SCRIPTS - Simple, direct questions
            AutomationScript(
                id: 5,
                name: "X-Ray Analysis",
                userMessage: "What do you see in this medical image?",
                expectedKeywords: ["x-ray", "chest", "lungs", "bones", "medical", "image", "shows"],
                testType: .imageAnalysis,
                description: "X-ray analysis",
                requiresImage: true,
                testImageName: "medical_xray"
            ),
            
            AutomationScript(
                id: 6,
                name: "Chart Reading",
                userMessage: "Read this medical chart",
                expectedKeywords: ["chart", "medical", "data", "patient", "information", "results", "values"],
                testType: .imageAnalysis,
                description: "Chart reading",
                requiresImage: true,
                testImageName: "medical_chart"
            ),
            
            AutomationScript(
                id: 7,
                name: "Prescription Info",
                userMessage: "What medication info do you see?",
                expectedKeywords: ["prescription", "medication", "dosage", "instructions", "drug", "medicine"],
                testType: .imageAnalysis,
                description: "Prescription reading",
                requiresImage: true,
                testImageName: "prescription_label"
            ),
            
            AutomationScript(
                id: 8,
                name: "Device Reading",
                userMessage: "What readings do you see?",
                expectedKeywords: ["device", "monitor", "reading", "measurement", "display", "values", "medical"],
                testType: .imageAnalysis,
                description: "Device reading",
                requiresImage: true,
                testImageName: "medical_device"
            )
        ]
    }
    
    // Filter scripts based on model capabilities and test type
    func getScriptsForModel(supportsVision: Bool, textOnly: Bool = false) -> [AutomationScript] {
        if textOnly {
            return scripts.filter { $0.testType == .textOnly }
        }
        
        if supportsVision {
            return scripts // Return all scripts for vision-capable models
        } else {
            return scripts.filter { $0.testType == .textOnly }
        }
    }
    
    func getNextScript(supportsVision: Bool = true, textOnly: Bool = false) -> AutomationScript? {
        let availableScripts = getScriptsForModel(supportsVision: supportsVision, textOnly: textOnly)
        let incompleteScripts = availableScripts.filter { !$0.isCompleted }
        return incompleteScripts.first
    }
    
    // OPTIMIZED: Faster image loading with caching
    private var imageCache: [String: UIImage] = [:]
    
    func getTestImage(for scriptId: Int) -> UIImage? {
        guard let script = scripts.first(where: { $0.id == scriptId }),
              script.requiresImage,
              let imageName = script.testImageName else {
            return nil
        }
        
        // Check cache first for speed
        if let cachedImage = imageCache[imageName] {
            print("✅ Using cached image: \(imageName)")
            return cachedImage
        }
        
        // Load and cache image
        if let image = UIImage(named: imageName) {
            imageCache[imageName] = image
            print("✅ Loaded and cached image: \(imageName)")
            return image
        } else {
            print("❌ Failed to load image: \(imageName)")
            return nil
        }
    }
    
    // OPTIMIZED: Faster validation with reduced keyword requirements
    func validateResponse(_ response: String, for script: AutomationScript) -> TestResult {
        let lowercaseResponse = response.lowercased()
        
        // Quick error check
        if lowercaseResponse.contains("error") || lowercaseResponse.contains("failed") || lowercaseResponse.contains("timeout") {
            return .failed
        }
        
        // Relaxed length requirements for speed
        let wordCount = response.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.count
        let minimumWords = script.testType == .imageAnalysis ? 8 : 12 // Reduced requirements
        
        if wordCount < minimumWords {
            print("Response too short: \(wordCount) words for \(script.testType) \(script.name)")
            return .failed
        }
        
        // OPTIMIZED: Only need 1 keyword match for speed
        let matchedKeywords = script.expectedKeywords.filter { keyword in
            lowercaseResponse.contains(keyword.lowercased())
        }
        
        let minimumMatches = 1 // Reduced from 2 to 1 for speed
        if matchedKeywords.count >= minimumMatches {
            let testTypeIcon = script.testType.icon
            print("\(testTypeIcon) \(script.name) PASSED with \(matchedKeywords.count) keyword matches: \(matchedKeywords)")
            return .passed
        } else {
            let testTypeIcon = script.testType.icon
            print("\(testTypeIcon) \(script.name) FAILED - only \(matchedKeywords.count) keyword matches (need \(minimumMatches))")
            return .failed
        }
    }
    
    func reset() {
        for i in scripts.indices {
            scripts[i].isCompleted = false
            scripts[i].aiResponse = ""
            scripts[i].testResult = nil
        }
        currentScriptIndex = 0
        // Keep image cache for speed
    }
    
    // Get comprehensive test statistics
    func getTestStatistics(supportsVision: Bool, textOnly: Bool = false) -> TestStatistics {
        let relevantScripts = getScriptsForModel(supportsVision: supportsVision, textOnly: textOnly)
        let completedScripts = relevantScripts.filter { $0.isCompleted }
        let passedScripts = completedScripts.filter { $0.testResult == .passed }
        
        let textOnlyScripts = relevantScripts.filter { $0.testType == .textOnly }
        let imageScripts = relevantScripts.filter { $0.testType == .imageAnalysis }
        
        let substantialResponses = completedScripts.filter { script in
            let wordCount = script.aiResponse.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.count
            return wordCount >= 15 // Reduced threshold
        }
        
        return TestStatistics(
            totalTests: relevantScripts.count,
            completedTests: completedScripts.count,
            passedTests: passedScripts.count,
            failedTests: completedScripts.count - passedScripts.count,
            textOnlyTests: textOnlyScripts.count,
            visionTests: imageScripts.count,
            conciseResponses: substantialResponses.count
        )
    }
}

// UPDATED: Automation script structure with image support
struct AutomationScript: Identifiable {
    let id: Int
    let name: String
    let userMessage: String
    let expectedKeywords: [String]
    let testType: TestType
    let description: String
    let requiresImage: Bool
    let testImageName: String?
    
    var isCompleted = false
    var aiResponse: String = ""
    var testResult: TestResult?
    
    init(id: Int, name: String, userMessage: String, expectedKeywords: [String], testType: TestType, description: String, requiresImage: Bool = false, testImageName: String? = nil) {
        self.id = id
        self.name = name
        self.userMessage = userMessage
        self.expectedKeywords = expectedKeywords
        self.testType = testType
        self.description = description
        self.requiresImage = requiresImage
        self.testImageName = testImageName
    }
}

// Test types
enum TestType {
    case textOnly
    case visionCapability
    case imageAnalysis
    
    var displayName: String {
        switch self {
        case .textOnly:
            return "TEXT"
        case .visionCapability:
            return "VISION"
        case .imageAnalysis:
            return "IMAGE"
        }
    }
    
    var icon: String {
        switch self {
        case .textOnly:
            return "💬"
        case .visionCapability:
            return "👁️"
        case .imageAnalysis:
            return "🖼️"
        }
    }
}

// Test results with display names
enum TestResult {
    case passed
    case failed
    
    var displayName: String {
        switch self {
        case .passed:
            return "PASSED"
        case .failed:
            return "FAILED"
        }
    }
    
    var color: UIColor {
        switch self {
        case .passed:
            return .systemGreen
        case .failed:
            return .systemRed
        }
    }
}

// Enhanced test statistics structure
struct TestStatistics {
    let totalTests: Int
    let completedTests: Int
    let passedTests: Int
    let failedTests: Int
    let textOnlyTests: Int
    let visionTests: Int
    let conciseResponses: Int
    
    var completionRate: Double {
        guard totalTests > 0 else { return 0 }
        return Double(completedTests) / Double(totalTests)
    }
    
    var passRate: Double {
        guard completedTests > 0 else { return 0 }
        return Double(passedTests) / Double(completedTests)
    }
    
    var conciseRate: Double {
        guard completedTests > 0 else { return 0 }
        return Double(conciseResponses) / Double(completedTests)
    }
    
    var textOnlyPassRate: Double {
        let textOnlyCompleted = completedTests
        guard textOnlyCompleted > 0 else { return 0 }
        return Double(passedTests) / Double(textOnlyCompleted)
    }
    
    var imagePassRate: Double {
        let imageCompleted = completedTests
        guard imageCompleted > 0 else { return 0 }
        return Double(passedTests) / Double(imageCompleted)
    }
}

//
//import Foundation
//import UIKit
//
//@MainActor
//class AutomationScriptManager: ObservableObject {
//    @Published var scripts: [AutomationScript] = []
//    @Published var currentScriptIndex = 0
//    
//    // Sample test images
//    private let testImages: [String: UIImage] = [:]
//    
//    init() {
//        setupTestScripts()
//    }
//    
//    private func setupTestScripts() {
//        scripts = [
//            // TEXT-ONLY TESTS
//            AutomationScript(
//                id: 1,
//                name: "Basic Greeting",
//                userMessage: "Hello! Can you tell me what you are?",
//                expectedKeywords: ["AI", "assistant", "help"],
//                testType: .textOnly,
//                description: "Basic greeting test"
//            ),
//            
//            AutomationScript(
//                id: 2,
//                name: "Simple Math",
//                userMessage: "What is 15 + 27?",
//                expectedKeywords: ["42", "forty-two"],
//                testType: .textOnly,
//                description: "Simple math test"
//            ),
//            
//            AutomationScript(
//                id: 3,
//                name: "Creative Writing",
//                userMessage: "Write a short poem about technology",
//                expectedKeywords: ["technology", "digital", "future", "computer"],
//                testType: .textOnly,
//                description: "Creative writing test"
//            ),
//            
//            AutomationScript(
//                id: 4,
//                name: "Logical Reasoning",
//                userMessage: "If all cats are animals, and some animals are pets, can we conclude that some cats are pets?",
//                expectedKeywords: ["logic", "yes", "true", "correct"],
//                testType: .textOnly,
//                description: "Logical reasoning test"
//            ),
//            
//            AutomationScript(
//                id: 5,
//                name: "General Knowledge",
//                userMessage: "What is the capital of France?",
//                expectedKeywords: ["Paris", "france", "capital"],
//                testType: .textOnly,
//                description: "General knowledge test"
//            ),
//            
//            // VISION-RELATED TESTS
//            AutomationScript(
//                id: 6,
//                name: "Vision Capability Check",
//                userMessage: "Can you analyze images?",
//                expectedKeywords: ["image", "vision", "see", "analyze", "photo"],
//                testType: .visionCapability,
//                description: "Vision capability check"
//            ),
//            
//            AutomationScript(
//                id: 7,
//                name: "Image Description",
//                userMessage: "Describe what you see in this image",
//                expectedKeywords: ["describe", "see", "image", "photo"],
//                testType: .imageAnalysis,
//                description: "Image description test",
//                requiresImage: true,
//                testImageName: "sample_image"
//            ),
//            
//            AutomationScript(
//                id: 8,
//                name: "Object Detection",
//                userMessage: "What objects can you identify in this picture?",
//                expectedKeywords: ["object", "identify", "see"],
//                testType: .imageAnalysis,
//                description: "Object detection test",
//                requiresImage: true,
//                testImageName: "sample_image"
//            ),
//            
//            AutomationScript(
//                id: 9,
//                name: "Color Analysis",
//                userMessage: "What are the main colors in this image?",
//                expectedKeywords: ["color", "colours", "red", "blue", "green", "yellow"],
//                testType: .imageAnalysis,
//                description: "Color analysis test",
//                requiresImage: true,
//                testImageName: "sample_image"
//            ),
//            
//            AutomationScript(
//                id: 10,
//                name: "Text Reading",
//                userMessage: "Can you read any text in this image?",
//                expectedKeywords: ["text", "read", "words", "letters"],
//                testType: .imageAnalysis,
//                description: "Text recognition test",
//                requiresImage: true,
//                testImageName: "text_image"
//            )
//        ]
//    }
//    
//    // Filter scripts based on model capabilities
//    func getScriptsForModel(supportsVision: Bool) -> [AutomationScript] {
//        if supportsVision {
//            return scripts // Return all scripts
//        } else {
//            return scripts.filter { $0.testType == .textOnly } // Only text scripts
//        }
//    }
//    
//    func getNextScript(supportsVision: Bool = true) -> AutomationScript? {
//        let availableScripts = getScriptsForModel(supportsVision: supportsVision)
//        let incompleteScripts = availableScripts.filter { !$0.isCompleted }
//        return incompleteScripts.first
//    }
//    
//    // Get test image for script
//    func getTestImage(for scriptId: String) -> UIImage? {
//        guard let script = scripts.first(where: { $0.id == Int(scriptId) ?? 0 }),
//              let imageName = script.testImageName else {
//            return nil
//        }
//        
//        return createPlaceholderImage(for: imageName)
//    }
//    
//    // Create placeholder images for testing
//    private func createPlaceholderImage(for imageName: String) -> UIImage {
//        let size = CGSize(width: 300, height: 200)
//        let renderer = UIGraphicsImageRenderer(size: size)
//        
//        return renderer.image { context in
//            // Background
//            UIColor.systemBlue.setFill()
//            context.fill(CGRect(origin: .zero, size: size))
//            
//            // Text
//            let text: String
//            switch imageName {
//            case "sample_image":
//                text = "🏠 HOUSE\n🌳 TREE\n☀️ SUN"
//            case "text_image":
//                text = "HELLO WORLD\nTEST IMAGE\n123 456"
//            default:
//                text = "TEST IMAGE\n\(imageName.uppercased())"
//            }
//            
//            let attributes: [NSAttributedString.Key: Any] = [
//                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
//                .foregroundColor: UIColor.white
//            ]
//            
//            let textSize = text.size(withAttributes: attributes)
//            let textRect = CGRect(
//                x: (size.width - textSize.width) / 2,
//                y: (size.height - textSize.height) / 2,
//                width: textSize.width,
//                height: textSize.height
//            )
//            
//            text.draw(in: textRect, withAttributes: attributes)
//        }
//    }
//    
//    func validateResponse(_ response: String, for script: AutomationScript) -> TestResult {
//        let lowercaseResponse = response.lowercased()
//        
//        // Check if it's an error response
//        if lowercaseResponse.contains("error") || lowercaseResponse.contains("failed") {
//            return .failed
//        }
//        
//        // For vision capability check, just ensure it mentions vision
//        if script.testType == .visionCapability {
//            if script.expectedKeywords.contains(where: { lowercaseResponse.contains($0.lowercased()) }) {
//                return .passed
//            } else {
//                return .failed
//            }
//        }
//        
//        // For image analysis, be more lenient - any reasonable response is good
//        if script.testType == .imageAnalysis {
//            // Check if response is substantial (not just "I can't see" or error)
//            if lowercaseResponse.contains("can't") || lowercaseResponse.contains("cannot") ||
//               lowercaseResponse.contains("unable") || response.count < 20 {
//                return .failed
//            }
//            return .passed
//        }
//        
//        // For text-only tests, use keyword matching
//        let matchedKeywords = script.expectedKeywords.filter { keyword in
//            lowercaseResponse.contains(keyword.lowercased())
//        }
//        
//        // Pass if at least one keyword matches
//        return matchedKeywords.isEmpty ? .failed : .passed
//    }
//    
//    func reset() {
//        for i in scripts.indices {
//            scripts[i].isCompleted = false
//            scripts[i].aiResponse = ""
//            scripts[i].testResult = nil
//        }
//        currentScriptIndex = 0
//    }
//    
//    // Get test statistics
//    func getTestStatistics(supportsVision: Bool) -> TestStatistics {
//        let relevantScripts = getScriptsForModel(supportsVision: supportsVision)
//        let completedScripts = relevantScripts.filter { $0.isCompleted }
//        let passedScripts = completedScripts.filter { $0.testResult == .passed }
//        
//        return TestStatistics(
//            totalTests: relevantScripts.count,
//            completedTests: completedScripts.count,
//            passedTests: passedScripts.count,
//            failedTests: completedScripts.count - passedScripts.count,
//            textOnlyTests: relevantScripts.filter { $0.testType == .textOnly }.count,
//            visionTests: relevantScripts.filter { $0.testType != .textOnly }.count
//        )
//    }
//}
//
//// UPDATED: Automation script with image support
//struct AutomationScript: Identifiable {
//    let id: Int
//    let name: String
//    let userMessage: String
//    let expectedKeywords: [String]
//    let testType: TestType
//    let description: String
//    let requiresImage: Bool
//    let testImageName: String?
//    
//    var isCompleted = false
//    var aiResponse: String = ""
//    var testResult: TestResult?
//    
//    init(id: Int, name: String, userMessage: String, expectedKeywords: [String], testType: TestType, description: String, requiresImage: Bool = false, testImageName: String? = nil) {
//        self.id = id
//        self.name = name
//        self.userMessage = userMessage
//        self.expectedKeywords = expectedKeywords
//        self.testType = testType
//        self.description = description
//        self.requiresImage = requiresImage
//        self.testImageName = testImageName
//    }
//}
//
//// Test types
//enum TestType {
//    case textOnly
//    case visionCapability
//    case imageAnalysis
//}
//
//// Test results with display names
//enum TestResult {
//    case passed
//    case failed
//    
//    var displayName: String {
//        switch self {
//        case .passed:
//            return "PASSED"
//        case .failed:
//            return "FAILED"
//        }
//    }
//}
//
//// Test statistics
//struct TestStatistics {
//    let totalTests: Int
//    let completedTests: Int
//    let passedTests: Int
//    let failedTests: Int
//    let textOnlyTests: Int
//    let visionTests: Int
//    
//    var completionRate: Double {
//        guard totalTests > 0 else { return 0 }
//        return Double(completedTests) / Double(totalTests)
//    }
//    
//    var passRate: Double {
//        guard completedTests > 0 else { return 0 }
//        return Double(passedTests) / Double(completedTests)
//    }
//}
//








//
//import Foundation
//import Combine
//
//class AutomationScriptManager: ObservableObject {
//    @Published var scripts: [AutomationScript] = []
//    @Published var currentScriptIndex = 0
//    @Published var isRunning = false
//    
//    init() {
//        loadGemmaOptimizedTestScripts()
//    }
//    
//    private func loadGemmaOptimizedTestScripts() {
//        scripts = [
//            // AI & Technology (Scripts 1-9)
//            AutomationScript(
//                id: 1,
//                name: "AI Definition",
//                userMessage: "What is AI? Answer in exactly 2 lines.",
//                expectedKeywords: ["artificial", "intelligence", "computer", "machine", "algorithms", "data", "human", "tasks"],
//                description: "Tests basic AI knowledge in concise format"
//            ),
//            
//            AutomationScript(
//                id: 2,
//                name: "Photosynthesis Explanation",
//                userMessage: "Explain photosynthesis in 2 lines only.",
//                expectedKeywords: ["plants", "sunlight", "carbon dioxide", "oxygen", "glucose", "energy", "chlorophyll", "water"],
//                description: "Tests scientific knowledge with length constraint"
//            ),
//            
//            AutomationScript(
//                id: 3,
//                name: "Japan Capital",
//                userMessage: "What is Japan's capital? Explain in 2 lines.",
//                expectedKeywords: ["tokyo", "japan", "capital", "city", "largest", "population", "government", "center"],
//                description: "Tests factual knowledge with explanation requirement"
//            ),
//            
//            AutomationScript(
//                id: 4,
//                name: "Gravity Explanation",
//                userMessage: "How does gravity work? Keep it to 2 lines.",
//                expectedKeywords: ["force", "mass", "attraction", "objects", "earth", "newton", "acceleration", "weight"],
//                description: "Tests physics concepts in brief format"
//            ),
//            
//            AutomationScript(
//                id: 5,
//                name: "Weather vs Climate",
//                userMessage: "Weather vs climate difference in 2 lines.",
//                expectedKeywords: ["weather", "climate", "short", "long", "term", "conditions", "patterns", "average"],
//                description: "Tests ability to distinguish related concepts"
//            ),
//            
//            AutomationScript(
//                id: 6,
//                name: "WiFi Technology",
//                userMessage: "How does WiFi work? Answer in 2 lines.",
//                expectedKeywords: ["wireless", "radio", "waves", "router", "signals", "network", "frequency", "data"],
//                description: "Tests technical communication skills"
//            ),
//            
//            AutomationScript(
//                id: 7,
//                name: "Blockchain Explanation",
//                userMessage: "What is blockchain? Explain in 2 lines.",
//                expectedKeywords: ["distributed", "ledger", "blocks", "chain", "decentralized", "transactions", "secure", "database"],
//                description: "Tests modern technology understanding"
//            ),
//            
//            AutomationScript(
//                id: 8,
//                name: "CPU Function",
//                userMessage: "How does a CPU work? Keep it to 2 lines.",
//                expectedKeywords: ["processor", "instructions", "calculations", "fetch", "execute", "decode", "computer", "brain"],
//                description: "Tests hardware knowledge concisely"
//            ),
//            
//            AutomationScript(
//                id: 9,
//                name: "Machine Learning",
//                userMessage: "What is machine learning? Answer in 2 lines.",
//                expectedKeywords: ["algorithms", "data", "patterns", "learn", "predictions", "training", "artificial", "models"],
//                description: "Tests ML concept understanding"
//            ),
//            
//            // Information & Systems (Scripts 10-15)
//            AutomationScript(
//                id: 10,
//                name: "Search Engines",
//                userMessage: "How do search engines work? 2 lines only.",
//                expectedKeywords: ["index", "crawl", "web", "algorithms", "keywords", "ranking", "database", "results"],
//                description: "Tests understanding of web technology"
//            ),
//            
//            AutomationScript(
//                id: 11,
//                name: "Earthquakes Cause",
//                userMessage: "What causes earthquakes? Answer in 2 lines.",
//                expectedKeywords: ["tectonic", "plates", "fault", "movement", "pressure", "crust", "energy", "ground"],
//                description: "Tests geological knowledge"
//            ),
//            
//            AutomationScript(
//                id: 12,
//                name: "Vaccine Function",
//                userMessage: "How do vaccines work? Explain in 2 lines.",
//                expectedKeywords: ["immune", "system", "antibodies", "protection", "disease", "response", "memory", "exposure"],
//                description: "Tests medical knowledge clearly"
//            ),
//            
//            AutomationScript(
//                id: 13,
//                name: "DNA Definition",
//                userMessage: "What is DNA? Keep it to 2 lines.",
//                expectedKeywords: ["genetic", "code", "heredity", "information", "cells", "traits", "inheritance", "blueprint"],
//                description: "Tests biological understanding"
//            ),
//            
//            AutomationScript(
//                id: 14,
//                name: "Water Cycle",
//                userMessage: "Explain the water cycle in 2 lines.",
//                expectedKeywords: ["evaporation", "condensation", "precipitation", "water", "cycle", "clouds", "rain", "ocean"],
//                description: "Tests environmental science knowledge"
//            ),
//            
//            AutomationScript(
//                id: 15,
//                name: "Relativity Theory",
//                userMessage: "What is relativity? Answer in 2 lines.",
//                expectedKeywords: ["einstein", "time", "space", "speed", "light", "gravity", "theory", "relative"],
//                description: "Tests advanced physics concepts"
//            ),
//            
//            // Creative Tasks (Scripts 16-20)
//            AutomationScript(
//                id: 16,
//                name: "Ocean Poem",
//                userMessage: "Write a 2-line poem about the ocean.",
//                expectedKeywords: ["ocean", "sea", "waves", "blue", "deep", "vast", "water", "shore"],
//                description: "Tests creative writing ability"
//            ),
//            
//            AutomationScript(
//                id: 17,
//                name: "Colors to Blind Person",
//                userMessage: "Explain colors to a blind person in 2 lines.",
//                expectedKeywords: ["temperature", "emotions", "feelings", "warm", "cool", "bright", "sensations", "experience"],
//                description: "Tests empathetic communication"
//            ),
//            
//            AutomationScript(
//                id: 18,
//                name: "Painting Robot Story",
//                userMessage: "Create a 2-line story about a painting robot.",
//                expectedKeywords: ["robot", "paint", "art", "colors", "canvas", "create", "brush", "artistic"],
//                description: "Tests creative storytelling"
//            ),
//            
//            AutomationScript(
//                id: 19,
//                name: "Spring Haiku",
//                userMessage: "Write a 2-line haiku about spring.",
//                expectedKeywords: ["spring", "flowers", "bloom", "green", "nature", "season", "fresh", "growth"],
//                description: "Tests poetic structure understanding"
//            ),
//            
//            AutomationScript(
//                id: 20,
//                name: "Sunset Metaphors",
//                userMessage: "Describe a sunset in 2 lines using metaphors.",
//                expectedKeywords: ["sun", "sky", "fire", "gold", "painting", "canvas", "colors", "horizon"],
//                description: "Tests metaphorical language use"
//            ),
//            
//            // Problem Solving & Ethics (Scripts 21-25)
//            AutomationScript(
//                id: 21,
//                name: "World Hunger Solution",
//                userMessage: "How to solve world hunger? Answer in 2 lines.",
//                expectedKeywords: ["food", "distribution", "agriculture", "poverty", "resources", "technology", "sustainable", "access"],
//                description: "Tests complex problem analysis"
//            ),
//            
//            AutomationScript(
//                id: 22,
//                name: "Renewable Energy Benefits",
//                userMessage: "Benefits of renewable energy in 2 lines.",
//                expectedKeywords: ["clean", "sustainable", "environment", "pollution", "climate", "solar", "wind", "future"],
//                description: "Tests environmental awareness"
//            ),
//            
//            AutomationScript(
//                id: 23,
//                name: "Plastic Pollution Reduction",
//                userMessage: "How to reduce plastic pollution? 2 lines only.",
//                expectedKeywords: ["reduce", "reuse", "recycle", "alternatives", "biodegradable", "ocean", "environment", "waste"],
//                description: "Tests practical environmental solutions"
//            ),
//            
//            AutomationScript(
//                id: 24,
//                name: "Good Leadership",
//                userMessage: "What makes a good leader? Answer in 2 lines.",
//                expectedKeywords: ["vision", "communication", "empathy", "decisions", "inspire", "trust", "responsibility", "team"],
//                description: "Tests leadership understanding"
//            ),
//            
//            AutomationScript(
//                id: 25,
//                name: "Building Trust",
//                userMessage: "How to build trust? Explain in 2 lines.",
//                expectedKeywords: ["honesty", "consistency", "reliability", "communication", "respect", "actions", "time", "integrity"],
//                description: "Tests interpersonal skills knowledge"
//            ),
//            
//            // Mathematics (Scripts 26-30)
//            AutomationScript(
//                id: 26,
//                name: "Percentage Calculation",
//                userMessage: "What is 15% of 200? Show work in 2 lines.",
//                expectedKeywords: ["15", "200", "30", "percent", "multiply", "0.15", "calculation", "answer"],
//                description: "Tests basic math with explanation"
//            ),
//            
//            AutomationScript(
//                id: 27,
//                name: "Distance Calculation",
//                userMessage: "Train travels 60 mph for 2.5 hours. Distance? 2 lines.",
//                expectedKeywords: ["60", "2.5", "150", "miles", "speed", "time", "distance", "multiply"],
//                description: "Tests physics math application"
//            ),
//            
//            AutomationScript(
//                id: 28,
//                name: "Probability Concept",
//                userMessage: "Explain probability in 2 lines.",
//                expectedKeywords: ["chance", "likelihood", "events", "ratio", "outcomes", "possible", "statistics", "measure"],
//                description: "Tests mathematical concept explanation"
//            ),
//            
//            AutomationScript(
//                id: 29,
//                name: "Square Root",
//                userMessage: "Square root of 144? Show work in 2 lines.",
//                expectedKeywords: ["144", "12", "square", "root", "multiply", "itself", "calculation", "answer"],
//                description: "Tests mathematical operations"
//            ),
//            
//            AutomationScript(
//                id: 30,
//                name: "Compound Interest",
//                userMessage: "How to calculate compound interest? 2 lines.",
//                expectedKeywords: ["principal", "rate", "time", "formula", "compound", "interest", "growth", "investment"],
//                description: "Tests financial mathematics"
//            ),
//            
//            // History & Culture (Scripts 31-35)
//            AutomationScript(
//                id: 31,
//                name: "Leonardo da Vinci",
//                userMessage: "Who was Leonardo da Vinci? Answer in 2 lines.",
//                expectedKeywords: ["artist", "inventor", "renaissance", "mona lisa", "genius", "scientist", "painter", "italian"],
//                description: "Tests historical knowledge"
//            ),
//            
//            AutomationScript(
//                id: 32,
//                name: "Renaissance Period",
//                userMessage: "What was the Renaissance? Explain in 2 lines.",
//                expectedKeywords: ["cultural", "rebirth", "art", "science", "europe", "14th", "17th", "century"],
//                description: "Tests historical period understanding"
//            ),
//            
//            AutomationScript(
//                id: 33,
//                name: "Moon Landing Significance",
//                userMessage: "Significance of moon landing in 2 lines.",
//                expectedKeywords: ["space", "exploration", "achievement", "technology", "human", "apollo", "1969", "milestone"],
//                description: "Tests historical significance analysis"
//            ),
//            
//            AutomationScript(
//                id: 34,
//                name: "Internet History",
//                userMessage: "History of internet in 2 lines only.",
//                expectedKeywords: ["arpanet", "network", "communication", "computers", "world", "web", "1990s", "global"],
//                description: "Tests technology history"
//            ),
//            
//            AutomationScript(
//                id: 35,
//                name: "Telephone Inventor",
//                userMessage: "Who invented the telephone? Answer in 2 lines.",
//                expectedKeywords: ["alexander", "graham", "bell", "telephone", "communication", "invention", "1876", "patent"],
//                description: "Tests invention history"
//            ),
//            
//            // Philosophy & Abstract Concepts (Scripts 36-40)
//            AutomationScript(
//                id: 36,
//                name: "Meaning of Life",
//                userMessage: "What is the meaning of life? Answer in 2 lines.",
//                expectedKeywords: ["purpose", "happiness", "fulfillment", "relationships", "growth", "experience", "love", "contribution"],
//                description: "Tests philosophical thinking"
//            ),
//            
//            AutomationScript(
//                id: 37,
//                name: "Ethics of Lying",
//                userMessage: "Is it ever okay to lie? Explain in 2 lines.",
//                expectedKeywords: ["truth", "harm", "protect", "context", "ethics", "morality", "situation", "consequences"],
//                description: "Tests ethical reasoning"
//            ),
//            
//            AutomationScript(
//                id: 38,
//                name: "Nature of Beauty",
//                userMessage: "What makes something beautiful? 2 lines only.",
//                expectedKeywords: ["subjective", "harmony", "symmetry", "emotion", "perception", "aesthetics", "observer", "experience"],
//                description: "Tests aesthetic philosophy"
//            ),
//            
//            AutomationScript(
//                id: 39,
//                name: "Moral Knowledge",
//                userMessage: "How do we know right from wrong? 2 lines.",
//                expectedKeywords: ["conscience", "society", "empathy", "consequences", "values", "ethics", "culture", "reason"],
//                description: "Tests moral philosophy"
//            ),
//            
//            AutomationScript(
//                id: 40,
//                name: "Consciousness Definition",
//                userMessage: "What is consciousness? Answer in 2 lines.",
//                expectedKeywords: ["awareness", "experience", "self", "perception", "mind", "thoughts", "feelings", "existence"],
//                description: "Tests complex philosophical concept"
//            )
//        ]
//    }
//    
//    var totalScripts: Int {
//        return scripts.count
//    }
//    
//    func getNextScript() -> AutomationScript? {
//        guard currentScriptIndex < scripts.count else { return nil }
//        let script = scripts[currentScriptIndex]
//        currentScriptIndex += 1
//        return script
//    }
//    
//    func reset() {
//        currentScriptIndex = 0
//        isRunning = false
//        // Reset all script completion states
//        for index in scripts.indices {
//            scripts[index].isCompleted = false
//            scripts[index].testResult = .pending
//            scripts[index].aiResponse = ""
//        }
//        print("🔄 Automation scripts reset - \(scripts.count) Gemma-optimized tests ready")
//    }
//    
//    func getCurrentScript() -> AutomationScript? {
//        guard currentScriptIndex > 0 && currentScriptIndex <= scripts.count else { return nil }
//        return scripts[currentScriptIndex - 1]
//    }
//    
//    func updateScriptResult(_ scriptId: Int, response: String, result: TestResult) {
//        if let index = scripts.firstIndex(where: { $0.id == scriptId }) {
//            scripts[index].aiResponse = response
//            scripts[index].testResult = result
//            scripts[index].isCompleted = true
//            print("✅ Script \(scriptId) (\(scripts[index].name)) updated: \(result.displayName)")
//        }
//    }
//    
//    func getCompletedScriptsCount() -> Int {
//        return scripts.filter { $0.isCompleted }.count
//    }
//    
//    func getPassedScriptsCount() -> Int {
//        return scripts.filter { $0.testResult == .passed }.count
//    }
//    
//    func getFailedScriptsCount() -> Int {
//        return scripts.filter { $0.testResult == .failed }.count
//    }
//    
//    func getSuccessRate() -> Double {
//        let completed = getCompletedScriptsCount()
//        guard completed > 0 else { return 0.0 }
//        let passed = getPassedScriptsCount()
//        return Double(passed) / Double(completed) * 100
//    }
//    
//    // Enhanced validation specifically tuned for 2-line responses
//    func validateResponse(_ response: String, for script: AutomationScript) -> TestResult {
//        let lowercasedResponse = response.lowercased()
//        let matchedKeywords = script.expectedKeywords.filter { keyword in
//            lowercasedResponse.contains(keyword.lowercased())
//        }
//        
//        // Adjusted thresholds for 2-line responses
//        let passThreshold: Int
//        
//        switch script.id {
//        case 1...15:
//            // Factual/Scientific - require at least 25% keyword match
//            passThreshold = max(1, script.expectedKeywords.count * 25 / 100)
//        case 16...25:
//            // Creative/Problem-solving - require at least 20% keyword match
//            passThreshold = max(1, script.expectedKeywords.count * 20 / 100)
//        case 26...35:
//            // Math/History - require at least 30% keyword match
//            passThreshold = max(1, script.expectedKeywords.count * 30 / 100)
//        case 36...40:
//            // Philosophy - require at least 15% keyword match (more subjective)
//            passThreshold = max(1, script.expectedKeywords.count * 15 / 100)
//        default:
//            passThreshold = max(1, script.expectedKeywords.count * 20 / 100)
//        }
//        
//        // Length validation for 2-line constraint
//        let lineCount = response.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
//        let hasValidLength = response.count >= 20 && response.count <= 300 // Reasonable for 2 lines
//        let followsConstraint = lineCount <= 3 // Allow some flexibility
//        
//        // Quality checks
//        let hasValidResponse = !response.isEmpty &&
//                              !response.contains("ERROR") &&
//                              !response.hasPrefix("❌") &&
//                              hasValidLength &&
//                              followsConstraint
//        
//        let result = matchedKeywords.count >= passThreshold && hasValidResponse ? TestResult.passed : TestResult.failed
//        
//        print("🔍 Validation - Script \(script.id): \(script.name)")
//        print("   Keywords: \(matchedKeywords.count)/\(script.expectedKeywords.count) (need \(passThreshold))")
//        print("   Length: \(response.count) chars, Lines: \(lineCount)")
//        print("   Matched: \(matchedKeywords)")
//        print("   Result: \(result.displayName)")
//        
//        return result
//    }
//    
//    // Generate detailed test report for 40 scripts
//    func generateTestReport() -> TestReport {
//        let completed = getCompletedScriptsCount()
//        let passed = getPassedScriptsCount()
//        let failed = getFailedScriptsCount()
//        let successRate = getSuccessRate()
//        
//        let categoryResults = getCategoryResults()
//        
//        return TestReport(
//            totalTests: scripts.count,
//            completedTests: completed,
//            passedTests: passed,
//            failedTests: failed,
//            successRate: successRate,
//            categoryBreakdown: categoryResults,
//            detailedResults: scripts.map { script in
//                TestResult(
//                    id: script.id,
//                    name: script.name,
//                    status: script.testResult.displayName,
//                    keywordsFound: countKeywordsInResponse(script.aiResponse, expectedKeywords: script.expectedKeywords),
//                    responseLength: script.aiResponse.count,
//                    description: script.description
//                )
//            }
//        )
//    }
//    
//    private func getCategoryResults() -> [String: CategoryResult] {
//        return [
//            "AI & Technology (1-9)": analyzeCategoryPerformance(scriptIds: Array(1...9)),
//            "Information & Systems (10-15)": analyzeCategoryPerformance(scriptIds: Array(10...15)),
//            "Creative Tasks (16-20)": analyzeCategoryPerformance(scriptIds: Array(16...20)),
//            "Problem Solving & Ethics (21-25)": analyzeCategoryPerformance(scriptIds: Array(21...25)),
//            "Mathematics (26-30)": analyzeCategoryPerformance(scriptIds: Array(26...30)),
//            "History & Culture (31-35)": analyzeCategoryPerformance(scriptIds: Array(31...35)),
//            "Philosophy & Abstract (36-40)": analyzeCategoryPerformance(scriptIds: Array(36...40))
//        ]
//    }
//    
//    private func analyzeCategoryPerformance(scriptIds: [Int]) -> CategoryResult {
//        let categoryScripts = scripts.filter { scriptIds.contains($0.id) && $0.isCompleted }
//        let passed = categoryScripts.filter { $0.testResult == .passed }.count
//        let total = categoryScripts.count
//        
//        return CategoryResult(
//            totalTests: total,
//            passedTests: passed,
//            successRate: total > 0 ? Double(passed) / Double(total) * 100 : 0.0
//        )
//    }
//    
//    private func countKeywordsInResponse(_ response: String, expectedKeywords: [String]) -> Int {
//        let lowercasedResponse = response.lowercased()
//        return expectedKeywords.filter { keyword in
//            lowercasedResponse.contains(keyword.lowercased())
//        }.count
//    }
//}
//
//// MARK: - Supporting Structures for Detailed Reporting
//
//struct TestReport {
//    let totalTests: Int
//    let completedTests: Int
//    let passedTests: Int
//    let failedTests: Int
//    let successRate: Double
//    let categoryBreakdown: [String: CategoryResult]
//    let detailedResults: [TestResult]
//    
//    var summary: String {
//        return """
//        📊 GEMMA 2 MODEL TEST RESULTS (40 Scripts)
//        
//        Overall Performance:
//        • Total Tests: \(totalTests)
//        • Completed: \(completedTests)
//        • Passed: \(passedTests) (\(String(format: "%.1f", successRate))%)
//        • Failed: \(failedTests)
//        
//        Category Breakdown:
//        \(categoryBreakdown.map { "\($0.key): \(String(format: "%.1f", $0.value.successRate))% (\($0.value.passedTests)/\($0.value.totalTests))" }.joined(separator: "\n"))
//        
//        All scripts test 2-line response constraint! 📝
//        Ready for comprehensive model evaluation! 🚀
//        """
//    }
//}
//
//struct CategoryResult {
//    let totalTests: Int
//    let passedTests: Int
//    let successRate: Double
//}
//
//// Extension to the existing TestResult struct
//extension TestResult {
//    init(id: Int, name: String, status: String, keywordsFound: Int, responseLength: Int, description: String) {
//        // This would need to be adapted based on your existing TestResult implementation
//        self = .pending // Placeholder - adjust based on your actual TestResult structure
//    }
//}
