
import Foundation

// This file is now optional since we're using manual chat
// You can remove this file if you don't need predefined scripts

struct ChatScript: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let conversations: [ScriptConversation]
}

struct ScriptConversation: Codable, Identifiable {
    let id = UUID()
    let userMessage: String
    let expectedResponse: String?
    let delay: Double?
    let isSystemMessage: Bool?
}

class ScriptManager: ObservableObject {
    @Published var scripts: [ChatScript] = []
    
    init() {
        // You can add predefined conversation starters here if needed
        loadConversationStarters()
    }
    
    private func loadConversationStarters() {
        scripts = [
            ChatScript(
                title: "Quick Starters",
                description: "Common conversation starters",
                conversations: [
                    ScriptConversation(
                        userMessage: "Hello! How are you?",
                        expectedResponse: nil,
                        delay: nil,
                        isSystemMessage: false
                    ),
                    ScriptConversation(
                        userMessage: "What can you help me with?",
                        expectedResponse: nil,
                        delay: nil,
                        isSystemMessage: false
                    ),
                    ScriptConversation(
                        userMessage: "Tell me a joke",
                        expectedResponse: nil,
                        delay: nil,
                        isSystemMessage: false
                    )
                ]
            )
        ]
    }
    
    func getConversationStarters() -> [String] {
        return scripts.first?.conversations.map { $0.userMessage } ?? []
    }
}
