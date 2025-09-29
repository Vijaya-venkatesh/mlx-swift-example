//
//import Foundation
//import SwiftUI
//
//class CSVExportManager: ObservableObject {
//    
//    // MARK: - Single Export Function
//    
//    func exportAllDataToCSV(messages: [ChatMessage], scripts: [AutomationScript], modelName: String = "MLX-Swift") -> String {
//        var csvContent = ""
//        
//        // Add header with metadata
//        csvContent += "MLX iOS Chat Application Export\n"
//        csvContent += "Export Date: \(formatDate(Date()))\n"
//        csvContent += "Model: \(modelName)\n"
//        csvContent += "Total Messages: \(messages.count)\n"
//        csvContent += "Total Scripts: \(scripts.count)\n"
//        csvContent += "Completed Tests: \(scripts.filter { $0.isCompleted }.count)\n\n"
//        
//        // Add conversation data section
//        csvContent += "=== CONVERSATION DATA ===\n"
//        csvContent += createConversationCSVHeader()
//        
//        var serialNumber = 1
//        var userMessage: ChatMessage?
//        
//        for message in messages {
//            if message.isUser {
//                userMessage = message
//            } else {
//                if let user = userMessage {
//                    let processingTime = message.timestamp.timeIntervalSince(user.timestamp)
//                    let csvRow = createConversationCSVRow(
//                        serialNumber: serialNumber,
//                        userQuery: user.content,
//                        modelName: modelName,
//                        modelResponse: message.content,
//                        responseTime: processingTime,
//                        userTimestamp: user.timestamp,
//                        responseTimestamp: message.timestamp,
//                        success: !message.content.contains("Error"),
//                        hasImage: user.image != nil
//                    )
//                    csvContent += csvRow + "\n"
//                    serialNumber += 1
//                    userMessage = nil
//                }
//            }
//        }
//        
//        // Add separator
//        csvContent += "\n=== AUTOMATION TEST RESULTS ===\n"
//        csvContent += createAutomationCSVHeader()
//        
//        // Add automation results
//        for script in scripts where script.isCompleted {
//            let csvRow = createAutomationCSVRow(
//                script: script,
//                modelName: modelName
//            )
//            csvContent += csvRow + "\n"
//        }
//        
//        // Add summary statistics
//        csvContent += "\n=== TEST SUMMARY ===\n"
//        let completedScripts = scripts.filter { $0.isCompleted }
//        let passedScripts = completedScripts.filter { $0.testResult == .passed }
//        let failedScripts = completedScripts.filter { $0.testResult == .failed }
//        
//        csvContent += "Total Tests,\(scripts.count)\n"
//        csvContent += "Completed Tests,\(completedScripts.count)\n"
//        csvContent += "Passed Tests,\(passedScripts.count)\n"
//        csvContent += "Failed Tests,\(failedScripts.count)\n"
//        csvContent += "Success Rate,\(completedScripts.count > 0 ? String(format: "%.1f", Double(passedScripts.count) / Double(completedScripts.count) * 100) : "0")%\n"
//        csvContent += "Text-Only Tests,\(scripts.filter { $0.testType == .textOnly }.count)\n"
//        csvContent += "Vision Tests,\(scripts.filter { $0.testType != .textOnly }.count)\n"
//        
//        return csvContent
//    }
//    
//    // MARK: - CSV Headers
//    
//    private func createConversationCSVHeader() -> String {
//        return [
//            "Serial Number",
//            "User Query",
//            "Model Name",
//            "Model Response",
//            "Total Response Time (seconds)",
//            "Total Tokens (estimated)",
//            "Response Length (characters)",
//            "Query Start Time",
//            "Response Completed Time",
//            "Has Image",
//            "Accelerator",
//            "Success",
//            "Error Message"
//        ].joined(separator: ",") + "\n"
//    }
//    
//    private func createAutomationCSVHeader() -> String {
//        return [
//            "Test ID",
//            "Test Name",
//            "Test Type",
//            "User Query",
//            "Expected Keywords",
//            "Model Name",
//            "Model Response",
//            "Test Result",
//            "Processing Time (estimated)",
//            "Response Length",
//            "Keywords Found",
//            "Success Rate",
//            "Success",
//            "Description",
//            "Required Image"
//        ].joined(separator: ",") + "\n"
//    }
//    
//    // MARK: - CSV Row Creation
//    
//    private func createConversationCSVRow(
//        serialNumber: Int,
//        userQuery: String,
//        modelName: String,
//        modelResponse: String,
//        responseTime: TimeInterval,
//        userTimestamp: Date,
//        responseTimestamp: Date,
//        success: Bool,
//        hasImage: Bool
//    ) -> String {
//        
//        return [
//            "\(serialNumber)",
//            escapeCSVField(userQuery),
//            escapeCSVField(modelName),
//            escapeCSVField(modelResponse),
//            String(format: "%.3f", responseTime),
//            "\(estimateTokens(modelResponse))",
//            "\(modelResponse.count)",
//            escapeCSVField(formatDate(userTimestamp)),
//            escapeCSVField(formatDate(responseTimestamp)),
//            hasImage ? "TRUE" : "FALSE",
//            "Apple Neural Engine/GPU",
//            success ? "TRUE" : "FALSE",
//            success ? "" : "Response contains error"
//        ].joined(separator: ",")
//    }
//    
//    private func createAutomationCSVRow(script: AutomationScript, modelName: String) -> String {
//        let keywordsFound = countKeywordsFound(
//            response: script.aiResponse,
//            expectedKeywords: script.expectedKeywords
//        )
//        
//        let successRate = script.expectedKeywords.count > 0 ?
//            Double(keywordsFound) / Double(script.expectedKeywords.count) * 100 : 0
//        
//        return [
//            "\(script.id)",
//            escapeCSVField(script.name),
//            escapeCSVField(script.testType.displayName),
//            escapeCSVField(script.userMessage),
//            escapeCSVField(script.expectedKeywords.joined(separator: "; ")),
//            escapeCSVField(modelName),
//            escapeCSVField(script.aiResponse),
//            escapeCSVField(script.testResult?.displayName ?? "PENDING"),
//            "2.0", // Estimated processing time
//            "\(script.aiResponse.count)",
//            "\(keywordsFound)",
//            String(format: "%.1f%%", successRate),
//            script.testResult == .passed ? "TRUE" : "FALSE",
//            escapeCSVField(script.description),
//            script.requiresImage ? "TRUE" : "FALSE"
//        ].joined(separator: ",")
//    }
//    
//    // MARK: - Helper Functions
//    
//    private func escapeCSVField(_ field: String) -> String {
//        var escaped = field
//        escaped = escaped.replacingOccurrences(of: "\n", with: " ")
//        escaped = escaped.replacingOccurrences(of: "\r", with: " ")
//        
//        if escaped.contains(",") || escaped.contains("\"") || escaped.contains("\n") {
//            escaped = escaped.replacingOccurrences(of: "\"", with: "\"\"")
//            escaped = "\"\(escaped)\""
//        }
//        
//        return escaped
//    }
//    
//    private func estimateTokens(_ text: String) -> Int {
//        return max(1, text.count / 4)
//    }
//    
//    private func countKeywordsFound(response: String, expectedKeywords: [String]) -> Int {
//        let lowercasedResponse = response.lowercased()
//        return expectedKeywords.filter { keyword in
//            lowercasedResponse.contains(keyword.lowercased())
//        }.count
//    }
//    
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        return formatter.string(from: date)
//    }
//    
//    // MARK: - File Save Function
//    
//    func saveAndShareCSV(_ csvContent: String) -> URL? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
//        let timestamp = dateFormatter.string(from: Date())
//        let filename = "MLX_Chat_Export_\(timestamp).csv"
//        
//        let tempDirectory = FileManager.default.temporaryDirectory
//        let fileURL = tempDirectory.appendingPathComponent(filename)
//        
//        do {
//            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
//            print("✅ CSV exported successfully: \(filename)")
//            return fileURL
//        } catch {
//            print("❌ Error saving CSV: \(error)")
//            return nil
//        }
//    }
//}
//
//// MARK: - Extensions for TestType display
//extension TestType {
//    var displayName: String {
//        switch self {
//        case .textOnly:
//            return "Text Only"
//        case .visionCapability:
//            return "Vision Capability"
//        case .imageAnalysis:
//            return "Image Analysis"
//        }
//    }
//}
//
//// MARK: - Share Sheet for iOS
//struct ShareSheet: UIViewControllerRepresentable {
//    let activityItems: [Any]
//    
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
//        activityVC.excludedActivityTypes = [
//            .assignToContact,
//            .saveToCameraRoll,
//            .postToFlickr,
//            .postToVimeo,
//            .postToTencentWeibo
//        ]
//        return activityVC
//    }
//    
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
//}


import Foundation
import UIKit
import SwiftUI

@MainActor
class CSVExportManager: ObservableObject {
    @Published var exportStatus = "Ready to export"
    @Published var isExporting = false
    
    func exportTestResults(
        messages: [ChatMessage],
        automationScripts: [AutomationScript],
        modelInfo: String,
        supportsVision: Bool
    ) -> (csvContent: String, shareURL: URL?) {
        
        isExporting = true
        exportStatus = "Generating CSV data..."
        
        let timestamp = DateFormatter.iso8601.string(from: Date())
        let deviceInfo = UIDevice.current.name
        let systemVersion = UIDevice.current.systemVersion
        
        var csvContent = """
        MLX Chat Automation Test Results
        Exported: \(timestamp)
        Device: \(deviceInfo)
        iOS Version: \(systemVersion)
        Model: \(modelInfo)
        Vision Support: \(supportsVision ? "Yes" : "No")
        
        
        """
        
        // SECTION 1: Test Summary
        let textOnlyScripts = automationScripts.filter { $0.testType == .textOnly }
        let imageScripts = automationScripts.filter { $0.testType == .imageAnalysis }
        let completedScripts = automationScripts.filter { $0.isCompleted }
        let passedScripts = completedScripts.filter { $0.testResult == .passed }
        
        csvContent += """
        TEST SUMMARY
        Total Tests,\(automationScripts.count)
        Text-Only Tests,\(textOnlyScripts.count)
        Image Tests,\(imageScripts.count)
        Completed Tests,\(completedScripts.count)
        Passed Tests,\(passedScripts.count)
        Failed Tests,\(completedScripts.count - passedScripts.count)
        Overall Pass Rate,\(completedScripts.isEmpty ? 0 : (Double(passedScripts.count) / Double(completedScripts.count) * 100))%
        
        
        """
        
        // SECTION 2: Detailed Test Results
        csvContent += """
        DETAILED TEST RESULTS
        Test ID,Test Name,Test Type,Image Used,Status,Result,Word Count,Keywords Matched,Response Time,Description
        """
        
        for script in automationScripts {
            let testTypeDisplay = script.testType.displayName
            let imageUsed = script.requiresImage ? (script.testImageName ?? "Unknown") : "N/A"
            let status = script.isCompleted ? "Completed" : "Pending"
            let result = script.testResult?.displayName ?? "N/A"
            let wordCount = script.aiResponse.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.count
            
            // Calculate matched keywords
            let matchedKeywords = script.expectedKeywords.filter { keyword in
                script.aiResponse.lowercased().contains(keyword.lowercased())
            }
            let keywordMatches = "\(matchedKeywords.count)/\(script.expectedKeywords.count)"
            
            // Estimate response time based on word count (placeholder)
            let estimatedTime = script.isCompleted ? "\(wordCount / 10 + 2)s" : "N/A"
            
            let escapedDescription = script.description.replacingOccurrences(of: ",", with: ";")
            
            csvContent += """
            
            \(script.id),"\(script.name)",\(testTypeDisplay),\(imageUsed),\(status),\(result),\(wordCount),\(keywordMatches),\(estimatedTime),"\(escapedDescription)"
            """
        }
        
        // SECTION 3: Full Responses
        csvContent += """
        
        
        FULL AI RESPONSES
        Test ID,Test Name,Test Type,User Message,AI Response,Expected Keywords
        """
        
        for script in automationScripts.filter({ $0.isCompleted }) {
            let testTypeDisplay = script.testType.displayName
            let escapedUserMessage = escapeCSVField(script.userMessage)
            let escapedAIResponse = escapeCSVField(script.aiResponse)
            let keywords = script.expectedKeywords.joined(separator: "; ")
            
            csvContent += """
            
            \(script.id),"\(script.name)",\(testTypeDisplay),"\(escapedUserMessage)","\(escapedAIResponse)","\(keywords)"
            """
        }
        
        // SECTION 4: Chat History
        csvContent += """
        
        
        CHAT HISTORY
        Timestamp,Sender,Message Type,Content,Image Included
        """
        
        for message in messages {
            let timestamp = DateFormatter.csvTimestamp.string(from: message.timestamp)
            let sender = message.isUser ? "User" : "AI"
            let messageType = message.image != nil ? "Image + Text" : "Text Only"
            let escapedContent = escapeCSVField(message.content)
            let imageIncluded = message.image != nil ? "Yes" : "No"
            
            csvContent += """
            
            \(timestamp),\(sender),\(messageType),"\(escapedContent)",\(imageIncluded)
            """
        }
        
        // SECTION 5: Performance Metrics
        csvContent += """
        
        
        PERFORMANCE METRICS
        Metric,Text-Only Tests,Image Tests,Overall
        Total Tests,\(textOnlyScripts.count),\(imageScripts.count),\(automationScripts.count)
        Completed,\(textOnlyScripts.filter { $0.isCompleted }.count),\(imageScripts.filter { $0.isCompleted }.count),\(completedScripts.count)
        Passed,\(textOnlyScripts.filter { $0.testResult == .passed }.count),\(imageScripts.filter { $0.testResult == .passed }.count),\(passedScripts.count)
        Pass Rate,\(calculatePassRate(for: textOnlyScripts))%,\(calculatePassRate(for: imageScripts))%,\(calculatePassRate(for: automationScripts))%
        Avg Word Count,\(calculateAverageWordCount(for: textOnlyScripts)),\(calculateAverageWordCount(for: imageScripts)),\(calculateAverageWordCount(for: automationScripts))
        
        
        """
        
        // SECTION 6: Image Test Details
        if !imageScripts.isEmpty {
            csvContent += """
            IMAGE TEST ANALYSIS
            Test ID,Image Name,Image Analysis Success,Text Extraction,Object Detection,Response Quality
            """
            
            for script in imageScripts {
                let imageName = script.testImageName ?? "Unknown"
                let analysisSuccess = script.isCompleted ? "Yes" : "No"
                
                // Analyze response content
                let response = script.aiResponse.lowercased()
                let hasTextExtraction = response.contains("text") || response.contains("read") || response.contains("written")
                let hasObjectDetection = response.contains("see") || response.contains("shows") || response.contains("contains")
                let responseQuality = script.testResult == .passed ? "Good" : "Needs Improvement"
                
                csvContent += """
                
                \(script.id),\(imageName),\(analysisSuccess),\(hasTextExtraction ? "Yes" : "No"),\(hasObjectDetection ? "Yes" : "No"),\(responseQuality)
                """
            }
        }
        
        exportStatus = "Creating file..."
        
        // Create temporary file
        let fileName = "MLX_Chat_Results_\(DateFormatter.filename.string(from: Date())).csv"
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            exportStatus = "Export completed"
            isExporting = false
            
            print("📊 CSV Export completed: \(fileName)")
            print("📁 File size: \(csvContent.count) characters")
            print("📋 Text tests: \(textOnlyScripts.count), Image tests: \(imageScripts.count)")
            
            return (csvContent, tempURL)
            
        } catch {
            exportStatus = "Export failed: \(error.localizedDescription)"
            isExporting = false
            print("❌ CSV Export failed: \(error)")
            return (csvContent, nil)
        }
    }
    
    // MARK: - Helper Methods
    
    private func escapeCSVField(_ field: String) -> String {
        let escaped = field
            .replacingOccurrences(of: "\"", with: "\"\"")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
        return escaped
    }
    
    private func calculatePassRate(for scripts: [AutomationScript]) -> Int {
        let completed = scripts.filter { $0.isCompleted }
        guard !completed.isEmpty else { return 0 }
        let passed = completed.filter { $0.testResult == .passed }
        return Int(Double(passed.count) / Double(completed.count) * 100)
    }
    
    private func calculateAverageWordCount(for scripts: [AutomationScript]) -> Int {
        let completed = scripts.filter { $0.isCompleted && !$0.aiResponse.isEmpty }
        guard !completed.isEmpty else { return 0 }
        
        let totalWords = completed.reduce(0) { total, script in
            total + script.aiResponse.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.count
        }
        
        return totalWords / completed.count
    }
}

// MARK: - Date Formatters
extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    static let csvTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    static let filename: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
