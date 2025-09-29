import SwiftUI
import UIKit

// UPDATED: ChatMessage struct with image support
// Add these at the end of your ScriptedChatView.swift file:

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    let image: UIImage?
    
    init(content: String, isUser: Bool, timestamp: Date, image: UIImage? = nil) {
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.image = image
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
                // Show image if present
                if let image = message.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 200, maxHeight: 200)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Message text
                if !message.content.isEmpty {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                        )
                        .foregroundColor(message.isUser ? .white : .primary)
                }
                
                // Timestamp
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .opacity(0.7)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer(minLength: 50)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct TypingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

struct ModelSelectionCard: View {
    let modelId: String
    let modelInfo: ModelInfo
    let isSelected: Bool
    let isRecommended: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(modelInfo.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if isRecommended {
                        Text("RECOMMENDED")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .cornerRadius(4)
                    }
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Text(modelInfo.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                Text(modelInfo.displayText)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CameraView: View {
    let onImageCaptured: (UIImage) -> Void
    
    var body: some View {
        Text("Camera functionality would go here")
            .foregroundColor(.secondary)
    }
}











//import Foundation
//import SwiftUI
//
//struct ChatMessage: Identifiable, Hashable {
//    let id = UUID()
//    let content: String
//    let isUser: Bool
//    let timestamp: Date
//    let image: UIImage?
//    let imageDescription: String?
//    
//    // Helper computed property
//    var hasImage: Bool {
//        return image != nil
//    }
//    
//    // CORRECTED: Primary initializer that handles all cases
//    init(content: String, isUser: Bool, timestamp: Date = Date(), image: UIImage? = nil, imageDescription: String? = nil) {
//        self.content = content
//        self.isUser = isUser
//        self.timestamp = timestamp
//        self.image = image
//        self.imageDescription = imageDescription
//    }
//    
//    // Convenience initializer for text-only messages
//    static func textMessage(content: String, isUser: Bool, timestamp: Date = Date()) -> ChatMessage {
//        return ChatMessage(content: content, isUser: isUser, timestamp: timestamp, image: nil, imageDescription: nil)
//    }
//    
//    // Convenience initializer for image messages
//    static func imageMessage(content: String = "What do you see in this image?", image: UIImage, description: String = "User shared an image", isUser: Bool = true, timestamp: Date = Date()) -> ChatMessage {
//        return ChatMessage(
//            content: content,
//            isUser: isUser,
//            timestamp: timestamp,
//            image: image,
//            imageDescription: description
//        )
//    }
//}
//
//// MARK: - Hashable conformance
//extension ChatMessage {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//        hasher.combine(content)
//        hasher.combine(isUser)
//        hasher.combine(timestamp)
//        hasher.combine(imageDescription)
//        // Note: UIImage doesn't conform to Hashable, so we use imageDescription as a proxy
//    }
//    
//    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
//        return lhs.id == rhs.id &&
//               lhs.content == rhs.content &&
//               lhs.isUser == rhs.isUser &&
//               lhs.timestamp == rhs.timestamp &&
//               lhs.imageDescription == rhs.imageDescription
//    }
//}
