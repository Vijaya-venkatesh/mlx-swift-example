//*************************************************************************

//
//import SwiftUI
//import PhotosUI
//
//struct ScriptedChatView: View {
//    @StateObject private var modelManager = MLXModelManager()
//    @StateObject private var automationManager = AutomationScriptManager()
//    @State private var messages: [ChatMessage] = []
//    @State private var inputMessage = ""
//    @State private var isGenerating = false
//    @FocusState private var isInputFocused: Bool
//    
//    // IMAGE SUPPORT - New states
//    @State private var selectedImage: UIImage?
//    @State private var showingImagePicker = false
//    @State private var imagePickerItem: PhotosPickerItem?
//    @State private var showingCamera = false
//    
//    @State private var selectedImageData: Data?
//    @State private var selectedImageItem: PhotosPickerItem?
//    
//    // Automation states
//    @State private var isAutomationRunning = false
//    @State private var currentScriptIndex = 0
//    @State private var automationProgress = 0.0
//    
//    // CSV Export states
//    @State private var showingShareSheet = false
//    @State private var shareURL: URL?
//    
//    // Model selection states
//    @State private var selectedModelId = "mlx-community/gemma-2-2b-it-4bit"
//    @State private var showingModelSelector = false
//    
//    private var totalScripts: Int {
//        return automationManager.scripts.count
//    }
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                statusBarView
//                
//                if modelManager.isModelLoaded {
//                    chatView
//                    imagePreviewView  // NEW: Show selected image
//                    inputView         // UPDATED: Now includes image picker
//                    automationControlView
//                    exportStatusView
//                } else {
//                    modelLoadingView
//                }
//            }
//            .navigationTitle("MLX Chat - Vision + Text")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    HStack {
//                        Button("Models") {
//                            showingModelSelector = true
//                        }
//                        .disabled(modelManager.isLoading)
//                        
//                        // NEW: Vision model quick load
//                        if !modelManager.supportsVision {
//                            Button("📷 Vision") {
//                                Task {
//                                    await modelManager.loadBestVisionModel()
//                                }
//                            }
//                            .disabled(modelManager.isLoading)
//                        }
//                        
//                        Button("Export") {
//                            // exportToCSV()
//                        }
//                        .disabled(!hasDataToExport)
//                    }
//                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    clearButton
//                }
//            }
//        }
//        .sheet(isPresented: $showingShareSheet) {
//            if let url = shareURL {
//                // ShareSheet(activityItems: [url])
//            }
//        }
//        .sheet(isPresented: $showingModelSelector) {
//            modelSelectorView
//        }
//        .sheet(isPresented: $showingCamera) {
//            CameraView { image in
//                selectedImage = image
//                showingCamera = false
//            }
//        }
//        .task {
//            await loadModelIfNeeded()
//        }
//    }
//    
//    // MARK: - Views
//    
//    private var statusBarView: some View {
//        HStack {
//            Circle()
//                .fill(modelManager.isModelLoaded ? .green : .red)
//                .frame(width: 10, height: 10)
//            
//            VStack(alignment: .leading, spacing: 2) {
//                HStack {
//                    Text(modelManager.isModelLoaded ? "✓ \(modelManager.modelName)" : "Model Not Loaded")
//                        .font(.caption)
//                        .foregroundColor(modelManager.isModelLoaded ? .green : .red)
//                    
//                    // NEW: Vision indicator
//                    if modelManager.supportsVision {
//                        Image(systemName: "eye.fill")
//                            .foregroundColor(.blue)
//                            .font(.caption2)
//                    }
//                }
//                
//                if modelManager.isModelLoaded {
//                    let info = modelManager.getModelInfo(for: modelManager.currentModelId)
//                    Text("\(info.size) • \(info.speed) • \(modelManager.supportsVision ? "Vision" : "Text Only")")
//                        .font(.caption2)
//                        .foregroundColor(.secondary)
//                }
//            }
//            
//            Spacer()
//            
//            if modelManager.isOfflineReady {
//                VStack(spacing: 2) {
//                    Image(systemName: "wifi.slash")
//                        .foregroundColor(.green)
//                    Text("Offline")
//                        .font(.caption2)
//                        .foregroundColor(.green)
//                }
//            }
//            
//            if isGenerating {
//                HStack {
//                    ProgressView()
//                        .scaleEffect(0.7)
//                    Text(selectedImage != nil ? "Analyzing..." : "Thinking...")
//                        .font(.caption2)
//                        .foregroundColor(.orange)
//                }
//            }
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 8)
//        .background(Color.gray.opacity(0.1))
//    }
//    
//    // NEW: Image Preview View
//    private var imagePreviewView: some View {
//        Group {
//            if let imageData = selectedImageData,
//               let uiImage = UIImage(data: imageData) {
//                HStack {
//                    Image(uiImage: uiImage)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(height: 60)
//                        .cornerRadius(8)
//                    
//                    Spacer()
//                    
//                    Button("Remove") {
//                        selectedImageData = nil
//                        selectedImageItem = nil
//                    }
//                    .font(.caption)
//                    .foregroundColor(.red)
//                }
//                .padding(.horizontal)
//                .padding(.top, 8)
//            }
//        }
//    }
//    
//    private var modelSelectorView: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                // Your header content stays the same
//                Text("Choose Model Type")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//                    .padding(.top)
//                
//                Text("Select based on whether you need image understanding")
//                    .font(.body)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//                
//                // CHANGE: Wrap in ScrollView
//                ScrollView {
//                    LazyVStack(spacing: 12) {  // CHANGE: Use LazyVStack instead of VStack
//                        ForEach(modelManager.getAvailableModels(), id: \.self) { modelId in
//                            ModelSelectionCard(
//                                modelId: modelId,
//                                modelInfo: modelManager.getModelInfo(for: modelId),
//                                isSelected: selectedModelId == modelId,
//                                isRecommended: modelId.contains("llava-1.5-7b") || modelId.contains("gemma-2-2b-it-4bit")
//                            ) {
//                                selectedModelId = modelId
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                
//                Spacer()
//                
//                // Your buttons stay the same
//                VStack(spacing: 12) {
//                    Button("Load Selected Model") {
//                        Task {
//                            await modelManager.loadModel(modelId: selectedModelId)
//                            showingModelSelector = false
//                        }
//                    }
//                    // ... rest of buttons
//                }
//                .padding()
//            }
//            .navigationTitle("Model Selection")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Cancel") {
//                        showingModelSelector = false
//                    }
//                }
//            }
//        }
//    }
//    
//    private var chatView: some View {
//        ScrollView {
//            LazyVStack(spacing: 16) {
//                if messages.isEmpty {
//                    VStack(spacing: 16) {
//                        Image(systemName: modelManager.supportsVision ? "eye.circle" : "brain.head.profile")
//                            .font(.system(size: 60))
//                            .foregroundColor(modelManager.supportsVision ? .purple : .blue)
//                        
//                        Text(modelManager.supportsVision ?
//                             "Start chatting with vision AI!" :
//                             "Start chatting with text AI!")
//                            .font(.title2)
//                            .fontWeight(.medium)
//                        
//                        VStack(spacing: 8) {
//                            Text("Using \(modelManager.modelName)")
//                                .font(.headline)
//                                .foregroundColor(.primary)
//                            
//                            let info = modelManager.getModelInfo(for: modelManager.currentModelId)
//                            Text(info.description)
//                                .font(.body)
//                                .foregroundColor(.secondary)
//                                .multilineTextAlignment(.center)
//                            
//                            // NEW: Vision capabilities info
//                            if modelManager.supportsVision {
//                                Text("📷 Can understand images + text")
//                                    .font(.callout)
//                                    .foregroundColor(.purple)
//                                    .padding(.top, 4)
//                            }
//                        }
//                    }
//                    .padding(.top, 50)
//                }
//                
//                ForEach(messages) { message in
//                    ChatBubble(message: message)
//                        .id(message.id)
//                }
//                
//                if isGenerating {
//                    HStack {
//                        TypingIndicator()
//                        Spacer()
//                    }
//                    .padding(.horizontal)
//                }
//            }
//            .padding()
//        }
//    }
//    
//    // UPDATED: Input view now includes image picker buttons
//    private var inputView: some View {
//        VStack(spacing: 0) {
//            Divider()
//            
//            // ADD THIS SECTION - Photo picker buttons
//            if modelManager.supportsVision {
//                HStack(alignment: .bottom, spacing: 8) {
//                    // ADD THIS: Image Picker Button
//                    PhotosPicker(
//                        selection: $selectedImageItem,
//                        matching: .images
//                    ) {
//                        Image(systemName: "photo")
//                            .font(.title2)
//                            .foregroundColor(.blue)
//                    }
//                    .onChange(of: selectedImageItem) { newItem in
//                        Task {
//                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
//                                selectedImageData = data
//                            }
//                        }
//                    }
//                    
//                    // Your existing text input (keep as is)
//                    TextField("Ask about the image or type a message...", text: $inputMessage, axis: .vertical)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .lineLimit(1...4)
//                    
//                    // Your existing send button (keep as is)
//                    Button(action: sendMessage) {
//                        Image(systemName: "arrow.up.circle.fill")
//                            .font(.title2)
//                            .foregroundColor(canSendMessage ? .blue : .gray)
//                    }
//                    .disabled(!canSendMessage)
//                }
//
//                .padding(.horizontal)
//                .padding(.top, 8)
//                .onChange(of: imagePickerItem) { item in
//                    Task {
//                        if let item = item,
//                           let data = try? await item.loadTransferable(type: Data.self),
//                           let image = UIImage(data: data) {
//                            selectedImage = image
//                        }
//                    }
//                }
//            }
//            
//            // Your existing input field stays the same
//            HStack(spacing: 12) {
//                TextField("Chat with \(modelManager.modelName)...", text: $inputMessage, axis: .vertical)
//                    .textFieldStyle(.roundedBorder)
//                    .focused($isInputFocused)
//                    .lineLimit(1...5)
//                    .onSubmit {
//                        sendMessage()
//                    }
//                    .disabled(isAutomationRunning)
//                
//                Button(action: sendMessage) {
//                    Image(systemName: "arrow.up.circle.fill")
//                        .font(.title2)
//                        .foregroundColor(canSendMessage ? .blue : .gray)
//                }
//                .disabled(!canSendMessage || isAutomationRunning)
//            }
//            .padding()
//            .background(Color(.systemBackground))
//        }
//    }
//    
//    private var automationControlView: some View {
//        VStack(spacing: 12) {
//            Divider()
//            
//            HStack(spacing: 16) {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("\(modelManager.supportsVision ? "Vision" : "Text") Model Tests")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    Text("\(currentScriptIndex)/\(totalScripts)")
//                        .font(.title3)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.primary)
//                }
//                
//                Spacer()
//                
//                if isAutomationRunning {
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Progress")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                        
//                        ProgressView(value: automationProgress)
//                            .frame(width: 100)
//                    }
//                }
//                
//                Spacer()
//                
//                Button(action: toggleAutomation) {
//                    HStack(spacing: 8) {
//                        Image(systemName: isAutomationRunning ? "stop.fill" : "play.fill")
//                        Text(isAutomationRunning ? "Stop Tests" : "Run \(totalScripts) Tests")
//                    }
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 12)
//                    .background(isAutomationRunning ? Color.red : Color.green)
//                    .cornerRadius(25)
//                }
//                .disabled(!modelManager.isModelLoaded)
//            }
//            .padding()
//            .background(Color(.systemGray6))
//        }
//    }
//    
//    private var exportStatusView: some View {
//        VStack(spacing: 8) {
//            Divider()
//            
//            HStack {
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("CSV Export Ready")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    Text("Data: \(messages.count) messages • \(completedTestsCount) completed tests")
//                        .font(.caption2)
//                        .foregroundColor(.blue)
//                }
//                
//                Spacer()
//                
//                Text("Export data to compare with Android team results")
//                    .font(.caption2)
//                    .foregroundColor(.green)
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 6)
//            .background(Color(.systemGray6).opacity(0.3))
//        }
//    }
//    
//    private var clearButton: some View {
//        Button("Clear") {
//            clearChat()
//        }
//        .disabled(messages.isEmpty || isAutomationRunning)
//    }
//    
//    private var modelLoadingView: some View {
//        VStack(spacing: 24) {
//            if modelManager.isLoading {
//                VStack(spacing: 16) {
//                    ProgressView(value: modelManager.loadingProgress)
//                        .frame(width: 200)
//                    
//                    VStack {
//                        Text("Loading \(modelManager.modelName)...")
//                            .font(.headline)
//                        
//                        Text("\(Int(modelManager.loadingProgress * 100))%")
//                            .font(.title2)
//                            .fontWeight(.medium)
//                            .foregroundColor(.blue)
//                    }
//                }
//            } else {
//                VStack(spacing: 16) {
//                    Image(systemName: "brain.head.profile")
//                        .font(.system(size: 60))
//                        .foregroundColor(.blue)
//                    
//                    Text("AI Model Required")
//                        .font(.title2)
//                        .fontWeight(.medium)
//                    
//                    VStack(spacing: 12) {
//                        Button("Load Vision Model (Images + Text)") {
//                            Task { await modelManager.loadBestVisionModel() }
//                        }
//                        .buttonStyle(.borderedProminent)
//                        
//                        Button("Load Text-Only Model (Faster)") {
//                            Task { await modelManager.loadFastestModel() }
//                        }
//                        .buttonStyle(.bordered)
//                        
//                        Button("Choose Different Model") {
//                            showingModelSelector = true
//                        }
//                        .buttonStyle(.bordered)
//                    }
//                }
//            }
//            
//            if let error = modelManager.errorMessage {
//                Text(error)
//                    .foregroundColor(.red)
//                    .padding()
//                    .background(Color.red.opacity(0.1))
//                    .cornerRadius(8)
//            }
//        }
//        .padding()
//    }
//    
//    // MARK: - Computed Properties
//    
//    private var canSendMessage: Bool {
//        let hasText = !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//        let hasImage = selectedImageData != nil
//        return (hasText || hasImage) && !isGenerating && modelManager.isModelLoaded
//    }
//
//    private var hasDataToExport: Bool {
//        return !messages.isEmpty || completedTestsCount > 0
//    }
//    
//    private var completedTestsCount: Int {
//        return automationManager.scripts.filter { $0.isCompleted }.count
//    }
//    
//    // MARK: - Functions
//    
//    private func loadModelIfNeeded() async {
//        if !modelManager.isModelLoaded && !modelManager.isLoading {
//            await modelManager.loadFastestModel()
//        }
//    }
//    
//    // UPDATED: Send message function now supports images
//    private func sendMessage() {
//        let message = inputMessage.trimmingCharacters(in: .whitespacesAndNewlines)
//        let imageData = selectedImageData
//        
//        guard !isGenerating && modelManager.isModelLoaded else { return }
//        guard !message.isEmpty || imageData != nil else { return }
//        
//        // Create user message
//        let userImage = imageData.flatMap { UIImage(data: $0) }
//        let userMessage = ChatMessage(
//            content: message.isEmpty ? "What do you see in this image?" : message,
//            isUser: true,
//            timestamp: Date(),
//            image: userImage
//        )
//        
//        messages.append(userMessage)
//        
//        // Clear input
//        inputMessage = ""
//        selectedImageData = nil
//        selectedImageItem = nil
//        
//        // Generate response
//        isGenerating = true
//        
//        Task {
//            do {
//                let response = try await modelManager.generateResponse(
//                    for: userMessage.content,
//                    image: userImage
//                )
//                
//                let aiMessage = ChatMessage(
//                    content: response,
//                    isUser: false,
//                    timestamp: Date()
//                )
//                
//                await MainActor.run {
//                    messages.append(aiMessage)
//                    isGenerating = false
//                }
//                
//            } catch {
//                let errorMessage = ChatMessage(
//                    content: "Error: \(error.localizedDescription)",
//                    isUser: false,
//                    timestamp: Date()
//                )
//                
//                await MainActor.run {
//                    messages.append(errorMessage)
//                    isGenerating = false
//                }
//            }
//        }
//    }
//
//    
//    private func clearChat() {
//        messages.removeAll()
//        selectedImage = nil
//        modelManager.resetSession()
//        automationManager.reset()
//        currentScriptIndex = 0
//        automationProgress = 0.0
//    }
//    
//    private func toggleAutomation() {
//        if isAutomationRunning {
//            stopAutomation()
//        } else {
//            startAutomation()
//        }
//    }
//    
//    private func startAutomation() {
//        guard !isAutomationRunning && modelManager.isModelLoaded else { return }
//        
//        isAutomationRunning = true
//        automationManager.reset()
//        currentScriptIndex = 0
//        automationProgress = 0.0
//        
//        Task {
//            await runAutomationSequence()
//        }
//    }
//    
//    private func stopAutomation() {
//        isAutomationRunning = false
//        currentScriptIndex = 0
//        automationProgress = 0.0
//    }
//    
//    private func runAutomationSequence() async {
//        for index in 0..<totalScripts {
//            guard isAutomationRunning else { break }
//            
//            if let script = automationManager.getNextScript() {
//                await MainActor.run {
//                    currentScriptIndex = index + 1
//                    automationProgress = Double(index) / Double(totalScripts)
//                }
//                
//                await executeScript(script)
//                try? await Task.sleep(nanoseconds: 2_000_000_000)
//            }
//        }
//        
//        await MainActor.run {
//            isAutomationRunning = false
//            automationProgress = 1.0
//        }
//    }
//    
//    private func executeScript(_ script: AutomationScript) async {
//        let userMessage = ChatMessage(
//            content: script.userMessage,
//            isUser: true,
//            timestamp: Date()
//        )
//        
//        await MainActor.run {
//            messages.append(userMessage)
//            isGenerating = true
//        }
//        
//        do {
//            let response = try await modelManager.generateResponse(for: script.userMessage)
//            
//            await MainActor.run {
//                if let index = automationManager.scripts.firstIndex(where: { $0.id == script.id }) {
//                    automationManager.scripts[index].aiResponse = response
//                    automationManager.scripts[index].isCompleted = true
//                    automationManager.scripts[index].testResult = automationManager.validateResponse(response, for: script)
//                }
//            }
//            
//            let aiMessage = ChatMessage(
//                content: response,
//                isUser: false,
//                timestamp: Date()
//            )
//            
//            await MainActor.run {
//                messages.append(aiMessage)
//                isGenerating = false
//            }
//            
//        } catch {
//            await MainActor.run {
//                if let index = automationManager.scripts.firstIndex(where: { $0.id == script.id }) {
//                    automationManager.scripts[index].aiResponse = "ERROR: \(error.localizedDescription)"
//                    automationManager.scripts[index].testResult = .failed
//                    automationManager.scripts[index].isCompleted = true
//                }
//                
//                let errorMessage = ChatMessage(
//                    content: "Test error: \(error.localizedDescription)",
//                    isUser: false,
//                    timestamp: Date()
//                )
//                
//                messages.append(errorMessage)
//                isGenerating = false
//            }
//        }
//    }
//}

// ****************************************************************

//import SwiftUI
//import PhotosUI
//
//struct ScriptedChatView: View {
//    @StateObject private var modelManager = MLXModelManager()
//    @StateObject private var automationManager = AutomationScriptManager()
//    @StateObject private var csvExportManager = CSVExportManager()
//    @State private var messages: [ChatMessage] = []
//    @State private var inputMessage = ""
//    @State private var isGenerating = false
//    @FocusState private var isInputFocused: Bool
//    
//    // IMAGE SUPPORT - New states
//    @State private var selectedImage: UIImage?
//    @State private var showingImagePicker = false
//    @State private var imagePickerItem: PhotosPickerItem?
//    @State private var showingCamera = false
//    
//    @State private var selectedImageData: Data?
//    @State private var selectedImageItem: PhotosPickerItem?
//    
//    // Automation states
//    @State private var isAutomationRunning = false
//    @State private var currentScriptIndex = 0
//    @State private var automationProgress = 0.0
//    
//    // CSV Export states
//    @State private var showingShareSheet = false
//    @State private var shareURL: URL?
//    @State private var exportedCSVContent = ""
//    
//    // Model selection states
//    @State private var selectedModelId = "mlx-community/gemma-2-2b-it-4bit"
//    @State private var showingModelSelector = false
//    
//    private var totalScripts: Int {
//        return automationManager.getScriptsForModel(supportsVision: modelManager.supportsVision).count
//    }
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                statusBarView
//                
//                if modelManager.isModelLoaded {
//                    chatView
//                    imagePreviewView
//                    inputView
//                    automationControlView
//                    exportStatusView
//                } else {
//                    modelLoadingView
//                }
//            }
//            .navigationTitle("MLX Chat - Vision + Text")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    HStack {
//                        Button("Models") {
//                            showingModelSelector = true
//                        }
//                        .disabled(modelManager.isLoading)
//                        
//                        if !modelManager.supportsVision {
//                            Button("📷 Vision") {
//                                Task {
//                                    await modelManager.loadBestVisionModel()
//                                }
//                            }
//                            .disabled(modelManager.isLoading)
//                        }
//                        
//                        Button("Export CSV") {
//                            exportToCSV()
//                        }
//                        .disabled(!hasDataToExport)
//                    }
//                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    clearButton
//                }
//            }
//        }
//        .sheet(isPresented: $showingShareSheet) {
//            if let url = shareURL {
//                ShareSheet(activityItems: [url])
//            }
//        }
//        .sheet(isPresented: $showingModelSelector) {
//            modelSelectorView
//        }
//        .sheet(isPresented: $showingCamera) {
//            CameraView { image in
//                selectedImage = image
//                showingCamera = false
//            }
//        }
//        .task {
//            await loadModelIfNeeded()
//        }
//    }
//    
//    // MARK: - Views
//    
//    private var statusBarView: some View {
//        HStack {
//            Circle()
//                .fill(modelManager.isModelLoaded ? .green : .red)
//                .frame(width: 10, height: 10)
//            
//            VStack(alignment: .leading, spacing: 2) {
//                HStack {
//                    Text(modelManager.isModelLoaded ? "✓ \(modelManager.modelName)" : "Model Not Loaded")
//                        .font(.caption)
//                        .foregroundColor(modelManager.isModelLoaded ? .green : .red)
//                    
//                    if modelManager.supportsVision {
//                        Image(systemName: "eye.fill")
//                            .foregroundColor(.blue)
//                            .font(.caption2)
//                    }
//                }
//                
//                if modelManager.isModelLoaded {
//                    let info = modelManager.getModelInfo(for: modelManager.currentModelId)
//                    Text("\(info.size) • \(info.speed) • \(modelManager.supportsVision ? "Vision" : "Text Only")")
//                        .font(.caption2)
//                        .foregroundColor(.secondary)
//                }
//            }
//            
//            Spacer()
//            
//            if modelManager.isOfflineReady {
//                VStack(spacing: 2) {
//                    Image(systemName: "wifi.slash")
//                        .foregroundColor(.green)
//                    Text("Offline")
//                        .font(.caption2)
//                        .foregroundColor(.green)
//                }
//            }
//            
//            if isGenerating {
//                HStack {
//                    ProgressView()
//                        .scaleEffect(0.7)
//                    Text(selectedImage != nil ? "Analyzing..." : "Thinking...")
//                        .font(.caption2)
//                        .foregroundColor(.orange)
//                }
//            }
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 8)
//        .background(Color.gray.opacity(0.1))
//    }
//    
//    private var imagePreviewView: some View {
//        Group {
//            if let imageData = selectedImageData,
//               let uiImage = UIImage(data: imageData) {
//                HStack {
//                    Image(uiImage: uiImage)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(height: 60)
//                        .cornerRadius(8)
//                    
//                    Spacer()
//                    
//                    Button("Remove") {
//                        selectedImageData = nil
//                        selectedImageItem = nil
//                    }
//                    .font(.caption)
//                    .foregroundColor(.red)
//                }
//                .padding(.horizontal)
//                .padding(.top, 8)
//            }
//        }
//    }
//    
//    private var modelSelectorView: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                Text("Choose Model Type")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//                    .padding(.top)
//                
//                Text("Select based on whether you need image understanding")
//                    .font(.body)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//                
//                ScrollView {
//                    LazyVStack(spacing: 12) {
//                        ForEach(modelManager.getAvailableModels(), id: \.self) { modelId in
//                            ModelSelectionCard(
//                                modelId: modelId,
//                                modelInfo: modelManager.getModelInfo(for: modelId),
//                                isSelected: selectedModelId == modelId,
//                                isRecommended: modelId.contains("llava-1.5-7b") || modelId.contains("gemma-2-2b-it-4bit")
//                            ) {
//                                selectedModelId = modelId
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                
//                Spacer()
//                
//                VStack(spacing: 12) {
//                    Button("Load Selected Model") {
//                        Task {
//                            await modelManager.loadModel(modelId: selectedModelId)
//                            showingModelSelector = false
//                        }
//                    }
//                    .buttonStyle(.borderedProminent)
//                }
//                .padding()
//            }
//            .navigationTitle("Model Selection")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Cancel") {
//                        showingModelSelector = false
//                    }
//                }
//            }
//        }
//    }
//    
//    private var chatView: some View {
//        ScrollView {
//            LazyVStack(spacing: 16) {
//                if messages.isEmpty {
//                    VStack(spacing: 16) {
//                        Image(systemName: modelManager.supportsVision ? "eye.circle" : "brain.head.profile")
//                            .font(.system(size: 60))
//                            .foregroundColor(modelManager.supportsVision ? .purple : .blue)
//                        
//                        Text(modelManager.supportsVision ?
//                             "Start chatting with vision AI!" :
//                             "Start chatting with text AI!")
//                            .font(.title2)
//                            .fontWeight(.medium)
//                        
//                        VStack(spacing: 8) {
//                            Text("Using \(modelManager.modelName)")
//                                .font(.headline)
//                                .foregroundColor(.primary)
//                            
//                            let info = modelManager.getModelInfo(for: modelManager.currentModelId)
//                            Text(info.description)
//                                .font(.body)
//                                .foregroundColor(.secondary)
//                                .multilineTextAlignment(.center)
//                            
//                            if modelManager.supportsVision {
//                                Text("📷 Can understand images + text")
//                                    .font(.callout)
//                                    .foregroundColor(.purple)
//                                    .padding(.top, 4)
//                            }
//                        }
//                    }
//                    .padding(.top, 50)
//                }
//                
//                ForEach(messages) { message in
//                    ChatBubble(message: message)
//                        .id(message.id)
//                }
//                
//                if isGenerating {
//                    HStack {
//                        TypingIndicator()
//                        Spacer()
//                    }
//                    .padding(.horizontal)
//                }
//            }
//            .padding()
//        }
//    }
//    
//    private var inputView: some View {
//        VStack(spacing: 0) {
//            Divider()
//            
//            if modelManager.supportsVision {
//                HStack(alignment: .bottom, spacing: 8) {
//                    PhotosPicker(
//                        selection: $selectedImageItem,
//                        matching: .images
//                    ) {
//                        Image(systemName: "photo")
//                            .font(.title2)
//                            .foregroundColor(.blue)
//                    }
//                    .onChange(of: selectedImageItem) { newItem in
//                        Task {
//                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
//                                selectedImageData = data
//                            }
//                        }
//                    }
//                    
//                    TextField("Ask about the image or type a message...", text: $inputMessage, axis: .vertical)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .lineLimit(1...4)
//                    
//                    Button(action: sendMessage) {
//                        Image(systemName: "arrow.up.circle.fill")
//                            .font(.title2)
//                            .foregroundColor(canSendMessage ? .blue : .gray)
//                    }
//                    .disabled(!canSendMessage)
//                }
//                .padding(.horizontal)
//                .padding(.top, 8)
//            }
//            
//            HStack(spacing: 12) {
//                TextField("Chat with \(modelManager.modelName)...", text: $inputMessage, axis: .vertical)
//                    .textFieldStyle(.roundedBorder)
//                    .focused($isInputFocused)
//                    .lineLimit(1...5)
//                    .onSubmit {
//                        sendMessage()
//                    }
//                    .disabled(isAutomationRunning)
//                
//                Button(action: sendMessage) {
//                    Image(systemName: "arrow.up.circle.fill")
//                        .font(.title2)
//                        .foregroundColor(canSendMessage ? .blue : .gray)
//                }
//                .disabled(!canSendMessage || isAutomationRunning)
//            }
//            .padding()
//            .background(Color(.systemBackground))
//        }
//    }
//    
//    private var automationControlView: some View {
//        VStack(spacing: 12) {
//            Divider()
//            
//            HStack(spacing: 16) {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("\(modelManager.supportsVision ? "Vision" : "Text") Model Tests")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    Text("\(currentScriptIndex)/\(totalScripts)")
//                        .font(.title3)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.primary)
//                }
//                
//                Spacer()
//                
//                if isAutomationRunning {
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Progress")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                        
//                        ProgressView(value: automationProgress)
//                            .frame(width: 100)
//                    }
//                }
//                
//                Spacer()
//                
//                Button(action: toggleAutomation) {
//                    HStack(spacing: 8) {
//                        Image(systemName: isAutomationRunning ? "stop.fill" : "play.fill")
//                        Text(isAutomationRunning ? "Stop Tests" : "Run \(totalScripts) Tests")
//                    }
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 12)
//                    .background(isAutomationRunning ? Color.red : Color.green)
//                    .cornerRadius(25)
//                }
//                .disabled(!modelManager.isModelLoaded)
//            }
//            .padding()
//            .background(Color(.systemGray6))
//        }
//    }
//    
//    private var exportStatusView: some View {
//        VStack(spacing: 8) {
//            Divider()
//            
//            HStack {
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("CSV Export Ready")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    Text("Data: \(messages.count) messages • \(completedTestsCount) completed tests")
//                        .font(.caption2)
//                        .foregroundColor(.blue)
//                }
//                
//                Spacer()
//                
//                Text("Export data to compare with Android team results")
//                    .font(.caption2)
//                    .foregroundColor(.green)
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 6)
//            .background(Color(.systemGray6).opacity(0.3))
//        }
//    }
//    
//    private var clearButton: some View {
//        Button("Clear") {
//            clearChat()
//        }
//        .disabled(messages.isEmpty || isAutomationRunning)
//    }
//    
//    private var modelLoadingView: some View {
//        VStack(spacing: 24) {
//            if modelManager.isLoading {
//                VStack(spacing: 16) {
//                    ProgressView(value: modelManager.loadingProgress)
//                        .frame(width: 200)
//                    
//                    VStack {
//                        Text("Loading \(modelManager.modelName)...")
//                            .font(.headline)
//                        
//                        Text("\(Int(modelManager.loadingProgress * 100))%")
//                            .font(.title2)
//                            .fontWeight(.medium)
//                            .foregroundColor(.blue)
//                    }
//                }
//            } else {
//                VStack(spacing: 16) {
//                    Image(systemName: "brain.head.profile")
//                        .font(.system(size: 60))
//                        .foregroundColor(.blue)
//                    
//                    Text("AI Model Required")
//                        .font(.title2)
//                        .fontWeight(.medium)
//                    
//                    VStack(spacing: 12) {
//                        Button("Load Vision Model (Images + Text)") {
//                            Task { await modelManager.loadBestVisionModel() }
//                        }
//                        .buttonStyle(.borderedProminent)
//                        
//                        Button("Load Text-Only Model (Faster)") {
//                            Task { await modelManager.loadFastestModel() }
//                        }
//                        .buttonStyle(.bordered)
//                        
//                        Button("Choose Different Model") {
//                            showingModelSelector = true
//                        }
//                        .buttonStyle(.bordered)
//                    }
//                }
//            }
//            
//            if let error = modelManager.errorMessage {
//                Text(error)
//                    .foregroundColor(.red)
//                    .padding()
//                    .background(Color.red.opacity(0.1))
//                    .cornerRadius(8)
//            }
//        }
//        .padding()
//    }
//    
//    // MARK: - Computed Properties
//    
//    private var canSendMessage: Bool {
//        let hasText = !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//        let hasImage = selectedImageData != nil
//        return (hasText || hasImage) && !isGenerating && modelManager.isModelLoaded
//    }
//
//    private var hasDataToExport: Bool {
//        return !messages.isEmpty || completedTestsCount > 0
//    }
//    
//    private var completedTestsCount: Int {
//        return automationManager.scripts.filter { $0.isCompleted }.count
//    }
//    
//    // MARK: - Functions
//    
//    private func loadModelIfNeeded() async {
//        if !modelManager.isModelLoaded && !modelManager.isLoading {
//            await modelManager.loadFastestModel()
//        }
//    }
//    
//    private func sendMessage() {
//        let message = inputMessage.trimmingCharacters(in: .whitespacesAndNewlines)
//        let imageData = selectedImageData
//        
//        guard !isGenerating && modelManager.isModelLoaded else { return }
//        guard !message.isEmpty || imageData != nil else { return }
//        
//        let userImage = imageData.flatMap { UIImage(data: $0) }
//        let userMessage = ChatMessage(
//            content: message.isEmpty ? "What do you see in this image?" : message,
//            isUser: true,
//            timestamp: Date(),
//            image: userImage
//        )
//        
//        messages.append(userMessage)
//        
//        inputMessage = ""
//        selectedImageData = nil
//        selectedImageItem = nil
//        
//        isGenerating = true
//        
//        Task {
//            do {
//                let response = try await modelManager.generateResponse(
//                    for: userMessage.content,
//                    image: userImage
//                )
//                
//                let aiMessage = ChatMessage(
//                    content: response,
//                    isUser: false,
//                    timestamp: Date()
//                )
//                
//                await MainActor.run {
//                    messages.append(aiMessage)
//                    isGenerating = false
//                }
//                
//            } catch {
//                let errorMessage = ChatMessage(
//                    content: "Error: \(error.localizedDescription)",
//                    isUser: false,
//                    timestamp: Date()
//                )
//                
//                await MainActor.run {
//                    messages.append(errorMessage)
//                    isGenerating = false
//                }
//            }
//        }
//    }
//
//    private func clearChat() {
//        messages.removeAll()
//        selectedImage = nil
//        modelManager.resetSession()
//        automationManager.reset()
//        currentScriptIndex = 0
//        automationProgress = 0.0
//    }
//    
//    private func toggleAutomation() {
//        if isAutomationRunning {
//            stopAutomation()
//        } else {
//            startAutomation()
//        }
//    }
//    
//    private func startAutomation() {
//        guard !isAutomationRunning && modelManager.isModelLoaded else { return }
//        
//        isAutomationRunning = true
//        automationManager.reset()
//        currentScriptIndex = 0
//        automationProgress = 0.0
//        
//        Task {
//            await runAutomationSequence()
//        }
//    }
//    
//    private func stopAutomation() {
//        isAutomationRunning = false
//        currentScriptIndex = 0
//        automationProgress = 0.0
//    }
//    
//    // Replace your existing runAutomationSequence method with this optimized version
//    private func runAutomationSequence() async {
//        let scriptsToRun = automationManager.getScriptsForModel(supportsVision: modelManager.supportsVision)
//        
//        print("🚀 Starting FAST medical automation with \(scriptsToRun.count) queries...")
//        let startTime = Date()
//        
//        for (index, script) in scriptsToRun.enumerated() {
//            guard isAutomationRunning else {
//                print("🛑 Automation stopped by user")
//                break
//            }
//            
//            let scriptStartTime = Date()
//            
//            await MainActor.run {
//                currentScriptIndex = index + 1
//                automationProgress = Double(index) / Double(scriptsToRun.count)
//            }
//            
//            print("📋 Executing medical query \(index + 1)/\(scriptsToRun.count): \(script.name)")
//            await executeScript(script)
//            
//            let scriptDuration = Date().timeIntervalSince(scriptStartTime)
//            print("✅ Query \(index + 1) completed in \(String(format: "%.1f", scriptDuration))s")
//            
//            // MINIMAL DELAY: Only 0.2 seconds between queries for maximum speed
//            if index < scriptsToRun.count - 1 {
//                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
//            }
//        }
//        
//        let totalDuration = Date().timeIntervalSince(startTime)
//        print("🏁 Medical automation completed in \(String(format: "%.1f", totalDuration))s")
//        
//        await MainActor.run {
//            isAutomationRunning = false
//            automationProgress = 1.0
//            
//            // Auto-export CSV when automation completes
//            exportToCSV()
//        }
//    }
//
//    private func executeScript(_ script: AutomationScript) async {
//        let startTime = Date()
//        
//        // Create user message
//        let userMessage = ChatMessage(
//            content: script.userMessage,
//            isUser: true,
//            timestamp: Date(),
//            image: nil
//        )
//        
//        // Update UI
//        await MainActor.run {
//            messages.append(userMessage)
//            isGenerating = true
//        }
//        
//        // Generate response with timeout
//        do {
//            print("🏥 Starting medical query: \(script.name)")
//            
//            // Use the faster medical response method
//            let response = try await modelManager.generateFastMedicalResponse(for: script.userMessage)
//            
//            let duration = Date().timeIntervalSince(startTime)
//            print("✅ Medical response received in \(String(format: "%.2f", duration))s")
//            
//            // Update script with results
//            await MainActor.run {
//                if let index = automationManager.scripts.firstIndex(where: { $0.id == script.id }) {
//                    automationManager.scripts[index].aiResponse = response
//                    automationManager.scripts[index].isCompleted = true
//                    automationManager.scripts[index].testResult = automationManager.validateResponse(response, for: script)
//                    
//                    let result = automationManager.scripts[index].testResult?.displayName ?? "UNKNOWN"
//                    print("📊 Result: \(result) for \(script.name)")
//                }
//            }
//            
//            // Create AI message
//            let aiMessage = ChatMessage(
//                content: response,
//                isUser: false,
//                timestamp: Date()
//            )
//            
//            // Update UI with response
//            await MainActor.run {
//                messages.append(aiMessage)
//                isGenerating = false
//            }
//            
//        } catch {
//            let errorDuration = Date().timeIntervalSince(startTime)
//            print("❌ Error in \(script.name) after \(String(format: "%.2f", errorDuration))s: \(error.localizedDescription)")
//            
//            await MainActor.run {
//                // Mark script as failed
//                if let index = automationManager.scripts.firstIndex(where: { $0.id == script.id }) {
//                    automationManager.scripts[index].aiResponse = "TIMEOUT/ERROR: \(error.localizedDescription)"
//                    automationManager.scripts[index].testResult = .failed
//                    automationManager.scripts[index].isCompleted = true
//                }
//                
//                // Show error in chat
//                let errorMessage = ChatMessage(
//                    content: "⚠️ Query timed out or failed: \(error.localizedDescription)",
//                    isUser: false,
//                    timestamp: Date()
//                )
//                
//                messages.append(errorMessage)
//                isGenerating = false
//            }
//        }
//    }
//
//
//
//    
////    private func runAutomationSequence() async {
////        let scriptsToRun = automationManager.getScriptsForModel(supportsVision: modelManager.supportsVision)
////
////        for (index, script) in scriptsToRun.enumerated() {
////            guard isAutomationRunning else { break }
////
////            await MainActor.run {
////                currentScriptIndex = index + 1
////                automationProgress = Double(index) / Double(scriptsToRun.count)
////            }
////
////            await executeScript(script)
////
////            // Wait between tests
////            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
////        }
////
////        await MainActor.run {
////            isAutomationRunning = false
////            automationProgress = 1.0
////
////            // Auto-export CSV when automation completes
////            exportToCSV()
////        }
////    }
////
////    private func executeScript(_ script: AutomationScript) async {
////        // Get test image if script requires it
////        let testImage = script.requiresImage ? automationManager.getTestImage(for: String(script.id)) : nil
////
////        let userMessage = ChatMessage(
////            content: script.userMessage,
////            isUser: true,
////            timestamp: Date(),
////            image: testImage
////        )
////
////        await MainActor.run {
////            messages.append(userMessage)
////            isGenerating = true
////        }
////
////        do {
////            let response = try await modelManager.generateResponse(
////                for: script.userMessage,
////                image: testImage
////            )
////
////            await MainActor.run {
////                // Update the script with results
////                if let index = automationManager.scripts.firstIndex(where: { $0.id == script.id }) {
////                    automationManager.scripts[index].aiResponse = response
////                    automationManager.scripts[index].isCompleted = true
////                    automationManager.scripts[index].testResult = automationManager.validateResponse(response, for: script)
////                }
////            }
////
////            let aiMessage = ChatMessage(
////                content: response,
////                isUser: false,
////                timestamp: Date()
////            )
////
////            await MainActor.run {
////                messages.append(aiMessage)
////                isGenerating = false
////            }
////
////        } catch {
////            await MainActor.run {
////                if let index = automationManager.scripts.firstIndex(where: { $0.id == script.id }) {
////                    automationManager.scripts[index].aiResponse = "ERROR: \(error.localizedDescription)"
////                    automationManager.scripts[index].testResult = .failed
////                    automationManager.scripts[index].isCompleted = true
////                }
////
////                let errorMessage = ChatMessage(
////                    content: "Test error: \(error.localizedDescription)",
////                    isUser: false,
////                    timestamp: Date()
////                )
////
////                messages.append(errorMessage)
////                isGenerating = false
////            }
////        }
////    }
//    
//    // MARK: - CSV Export Function
//    private func exportToCSV() {
//        let csvContent = csvExportManager.exportAllDataToCSV(
//            messages: messages,
//            scripts: automationManager.scripts,
//            modelName: modelManager.modelName
//        )
//        
//        exportedCSVContent = csvContent
//        
//        if let fileURL = csvExportManager.saveAndShareCSV(csvContent) {
//            shareURL = fileURL
//            showingShareSheet = true
//        }
//    }
//}


import SwiftUI
import PhotosUI

struct ScriptedChatView: View {
    @StateObject private var modelManager = MLXModelManager()
    @StateObject private var automationManager = AutomationScriptManager()
    @StateObject private var csvExportManager = CSVExportManager()
    @State private var messages: [ChatMessage] = []
    @State private var inputMessage = ""
    @State private var isGenerating = false
    @FocusState private var isInputFocused: Bool
    
    // IMAGE SUPPORT - New states
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var imagePickerItem: PhotosPickerItem?
    @State private var showingCamera = false
    
    @State private var selectedImageData: Data?
    @State private var selectedImageItem: PhotosPickerItem?
    
    // Automation states
    @State private var isAutomationRunning = false
    @State private var currentScriptIndex = 0
    @State private var automationProgress = 0.0
    
    // CSV Export states
    @State private var showingShareSheet = false
    @State private var shareURL: URL?
    @State private var exportedCSVContent = ""
    
    // Model selection states
    @State private var selectedModelId = "mlx-community/gemma-2-2b-it-4bit"
    @State private var showingModelSelector = false
    
    private var totalScripts: Int {
        return automationManager.getScriptsForModel(supportsVision: modelManager.supportsVision).count
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                statusBarView
                
                if modelManager.isModelLoaded {
                    chatView
                    imagePreviewView
                    inputView
                    automationControlView
                    exportStatusView
                } else {
                    modelLoadingView
                }
            }
            .navigationTitle("MLX Chat - Vision + Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button("Models") {
                            showingModelSelector = true
                        }
                        .disabled(modelManager.isLoading)
                        
                        if !modelManager.supportsVision {
                            Button("📷 Vision") {
                                Task {
                                    await modelManager.loadBestVisionModel()
                                }
                            }
                            .disabled(modelManager.isLoading)
                        }
                        
                        Button("Export CSV") {
                            exportToCSV()
                        }
                        .disabled(!hasDataToExport)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    clearButton
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = shareURL {
                ShareSheet(activityItems: [url])
            }
        }
        .sheet(isPresented: $showingModelSelector) {
            modelSelectorView
        }
        .sheet(isPresented: $showingCamera) {
            CameraView { image in
                selectedImage = image
                showingCamera = false
            }
        }
        .task {
            await loadModelIfNeeded()
            preloadAllImages() // Add this line
        }
    }
    
    // MARK: - Views
    
    private var statusBarView: some View {
        HStack {
            Circle()
                .fill(modelManager.isModelLoaded ? .green : .red)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(modelManager.isModelLoaded ? "✓ \(modelManager.modelName)" : "Model Not Loaded")
                        .font(.caption)
                        .foregroundColor(modelManager.isModelLoaded ? .green : .red)
                    
                    if modelManager.supportsVision {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.blue)
                            .font(.caption2)
                    }
                }
                
                if modelManager.isModelLoaded {
                    let info = modelManager.getModelInfo(for: modelManager.currentModelId)
                    Text("\(info.size) • \(info.speed) • \(modelManager.supportsVision ? "Vision" : "Text Only")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if modelManager.isOfflineReady {
                VStack(spacing: 2) {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.green)
                    Text("Offline")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
            
            if isGenerating {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text(selectedImage != nil ? "Analyzing..." : "Thinking...")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
    }
    
    private var imagePreviewView: some View {
        Group {
            if let imageData = selectedImageData,
               let uiImage = UIImage(data: imageData) {
                HStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Button("Remove") {
                        selectedImageData = nil
                        selectedImageItem = nil
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
    
    private var modelSelectorView: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Choose Model Type")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                Text("Select based on whether you need image understanding")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(modelManager.getAvailableModels(), id: \.self) { modelId in
                            ModelSelectionCard(
                                modelId: modelId,
                                modelInfo: modelManager.getModelInfo(for: modelId),
                                isSelected: selectedModelId == modelId,
                                isRecommended: modelId.contains("llava-1.5-7b") || modelId.contains("gemma-2-2b-it-4bit")
                            ) {
                                selectedModelId = modelId
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button("Load Selected Model") {
                        Task {
                            await modelManager.loadModel(modelId: selectedModelId)
                            showingModelSelector = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Model Selection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingModelSelector = false
                    }
                }
            }
        }
    }
    
    private var chatView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if messages.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: modelManager.supportsVision ? "eye.circle" : "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundColor(modelManager.supportsVision ? .purple : .blue)
                        
                        Text(modelManager.supportsVision ?
                             "Start chatting with vision AI!" :
                             "Start chatting with text AI!")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        VStack(spacing: 8) {
                            Text("Using \(modelManager.modelName)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            let info = modelManager.getModelInfo(for: modelManager.currentModelId)
                            Text(info.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            if modelManager.supportsVision {
                                Text("📷 Can understand images + text")
                                    .font(.callout)
                                    .foregroundColor(.purple)
                                    .padding(.top, 4)
                            }
                        }
                    }
                    .padding(.top, 50)
                }
                
                ForEach(messages) { message in
                    ChatBubble(message: message)
                        .id(message.id)
                }
                
                if isGenerating {
                    HStack {
                        TypingIndicator()
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
    }
    
    private var inputView: some View {
        VStack(spacing: 0) {
            Divider()
            
            if modelManager.supportsVision {
                HStack(alignment: .bottom, spacing: 8) {
                    PhotosPicker(
                        selection: $selectedImageItem,
                        matching: .images
                    ) {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .onChange(of: selectedImageItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                    
                    TextField("Ask about the image or type a message...", text: $inputMessage, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(1...4)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(canSendMessage ? .blue : .gray)
                    }
                    .disabled(!canSendMessage)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            HStack(spacing: 12) {
                TextField("Chat with \(modelManager.modelName)...", text: $inputMessage, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .focused($isInputFocused)
                    .lineLimit(1...5)
                    .onSubmit {
                        sendMessage()
                    }
                    .disabled(isAutomationRunning)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(canSendMessage ? .blue : .gray)
                }
                .disabled(!canSendMessage || isAutomationRunning)
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
    
    // UPDATED: Enhanced automation control with text/image options
    private var automationControlView: some View {
        VStack(spacing: 12) {
            Divider()
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(modelManager.supportsVision ? "Text + Image" : "Text Only") Tests")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Text("\(currentScriptIndex)/\(totalScripts)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if modelManager.supportsVision {
                            let textCount = automationManager.getScriptsForModel(supportsVision: true, textOnly: true).count
                            let imageCount = totalScripts - textCount
                            Text("(\(textCount) text + \(imageCount) image)")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                if isAutomationRunning {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Progress")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            ProgressView(value: automationProgress)
                                .frame(width: 100)
                            Text("\(Int(automationProgress * 100))%")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                VStack(spacing: 8) {
                    Button(action: toggleAutomation) {
                        HStack(spacing: 8) {
                            Image(systemName: isAutomationRunning ? "stop.fill" : "play.fill")
                            Text(isAutomationRunning ? "Stop Tests" : "Run All Tests")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(isAutomationRunning ? Color.red : Color.green)
                        .cornerRadius(25)
                    }
                    .disabled(!modelManager.isModelLoaded)
                    
                    if modelManager.supportsVision && !isAutomationRunning {
                        HStack(spacing: 8) {
                            Button("Text Only") {
                                startTextOnlyAutomation()
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(15)
                            
                            Button("Images Only") {
                                startImageOnlyAutomation()
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.purple.opacity(0.1))
                            .foregroundColor(.purple)
                            .cornerRadius(15)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
        }
    }
    
    private var exportStatusView: some View {
        VStack(spacing: 8) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CSV Export Ready")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Data: \(messages.count) messages • \(completedTestsCount) completed tests")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("Export data to compare with Android team results")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color(.systemGray6).opacity(0.3))
        }
    }
    
    private var clearButton: some View {
        Button("Clear") {
            clearChat()
        }
        .disabled(messages.isEmpty || isAutomationRunning)
    }
    
    private var modelLoadingView: some View {
        VStack(spacing: 24) {
            if modelManager.isLoading {
                VStack(spacing: 16) {
                    ProgressView(value: modelManager.loadingProgress)
                        .frame(width: 200)
                    
                    VStack {
                        Text("Loading \(modelManager.modelName)...")
                            .font(.headline)
                        
                        Text("\(Int(modelManager.loadingProgress * 100))%")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("AI Model Required")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    VStack(spacing: 12) {
                        Button("Load Vision Model (Images + Text)") {
                            Task { await modelManager.loadBestVisionModel() }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Load Text-Only Model (Faster)") {
                            Task { await modelManager.loadFastestModel() }
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Choose Different Model") {
                            showingModelSelector = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            
            if let error = modelManager.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    // MARK: - Computed Properties
    
    private var canSendMessage: Bool {
        let hasText = !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasImage = selectedImageData != nil
        return (hasText || hasImage) && !isGenerating && modelManager.isModelLoaded
    }

    private var hasDataToExport: Bool {
        return !messages.isEmpty || completedTestsCount > 0
    }
    
    private var completedTestsCount: Int {
        return automationManager.scripts.filter { $0.isCompleted }.count
    }
    
    // MARK: - Functions
    
    private func loadModelIfNeeded() async {
        if !modelManager.isModelLoaded && !modelManager.isLoading {
            await modelManager.loadFastestModel()
        }
    }
    
    private func sendMessage() {
        let message = inputMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        let imageData = selectedImageData
        
        guard !isGenerating && modelManager.isModelLoaded else { return }
        guard !message.isEmpty || imageData != nil else { return }
        
        let userImage = imageData.flatMap { UIImage(data: $0) }
        let userMessage = ChatMessage(
            content: message.isEmpty ? "What do you see in this image?" : message,
            isUser: true,
            timestamp: Date(),
            image: userImage
        )
        
        messages.append(userMessage)
        
        inputMessage = ""
        selectedImageData = nil
        selectedImageItem = nil
        
        isGenerating = true
        
        Task {
            do {
                let response = try await modelManager.generateResponse(
                    for: userMessage.content,
                    image: userImage
                )
                
                let aiMessage = ChatMessage(
                    content: response,
                    isUser: false,
                    timestamp: Date()
                )
                
                await MainActor.run {
                    messages.append(aiMessage)
                    isGenerating = false
                }
                
            } catch {
                let errorMessage = ChatMessage(
                    content: "Error: \(error.localizedDescription)",
                    isUser: false,
                    timestamp: Date()
                )
                
                await MainActor.run {
                    messages.append(errorMessage)
                    isGenerating = false
                }
            }
        }
    }

    private func clearChat() {
        messages.removeAll()
        selectedImage = nil
        modelManager.resetSession()
        automationManager.reset()
        currentScriptIndex = 0
        automationProgress = 0.0
    }
    
    // MARK: - UPDATED Automation Functions
    
    private func toggleAutomation() {
        if isAutomationRunning {
            stopAutomation()
        } else {
            startAutomation(textOnly: false)
        }
    }
    
    private func startTextOnlyAutomation() {
        guard !isAutomationRunning && modelManager.isModelLoaded else { return }
        startAutomation(textOnly: true)
    }
    
    private func startImageOnlyAutomation() {
        guard !isAutomationRunning && modelManager.isModelLoaded && modelManager.supportsVision else { return }
        startAutomation(imageOnly: true)
    }

    private func startAutomation(textOnly: Bool = false, imageOnly: Bool = false) {
        guard !isAutomationRunning && modelManager.isModelLoaded else { return }
        
        isAutomationRunning = true
        automationManager.reset()
        currentScriptIndex = 0
        automationProgress = 0.0
        
        Task {
            await runAutomationSequence(textOnly: textOnly, imageOnly: imageOnly)
        }
    }
    
    private func stopAutomation() {
        isAutomationRunning = false
        currentScriptIndex = 0
        automationProgress = 0.0
    }

    // UPDATED: Enhanced automation sequence with image support
    // ULTRA-OPTIMIZED: Fastest possible automation sequence
    private func runAutomationSequence(textOnly: Bool = false, imageOnly: Bool = false) async {
        var scriptsToRun: [AutomationScript]
        
        if textOnly {
            scriptsToRun = automationManager.getScriptsForModel(supportsVision: modelManager.supportsVision, textOnly: true)
            print("🚀 Starting ULTRA-FAST TEXT automation with \(scriptsToRun.count) queries...")
        } else if imageOnly {
            scriptsToRun = automationManager.getScriptsForModel(supportsVision: modelManager.supportsVision).filter { $0.testType == .imageAnalysis }
            print("🚀 Starting FAST IMAGE automation with \(scriptsToRun.count) tests...")
        } else {
            scriptsToRun = automationManager.getScriptsForModel(supportsVision: modelManager.supportsVision)
            print("🚀 Starting SPEED-OPTIMIZED automation with \(scriptsToRun.count) tests...")
        }
        
        let startTime = Date()
        
        for (index, script) in scriptsToRun.enumerated() {
                guard isAutomationRunning else {
                    print("🛑 Automation stopped")
                    break
                }
                
                await MainActor.run {
                    currentScriptIndex = index + 1
                    automationProgress = Double(index) / Double(scriptsToRun.count)
                }
                
                print("▶️ Test \(index + 1)/\(scriptsToRun.count): \(script.name)")
                
                // Execute with proper error handling
                await executeScript(script)
                
                // CRITICAL: Always add delay between scripts to let model stabilize
                if index < scriptsToRun.count - 1 {
                    try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s minimum
                }
            }
        
        let totalDuration = Date().timeIntervalSince(startTime)
        let avgTime = totalDuration / Double(scriptsToRun.count)
        print("🏁 ULTRA-FAST automation completed in \(String(format: "%.1f", totalDuration))s (avg: \(String(format: "%.1f", avgTime))s per test)")
        
        await MainActor.run {
            isAutomationRunning = false
            automationProgress = 1.0
            
            // Auto-export CSV when automation completes
            exportToCSV()
        }
    }

    // OPTIMIZATION: Batch image preloading for maximum speed
    private func preloadAllImages() {
        let imageScripts = automationManager.scripts.filter { $0.requiresImage }
        
        Task.detached(priority: .background) {
            for script in imageScripts {
                if let _ = await automationManager.getTestImage(for: script.id) {
                    print("Preloaded image for \(script.name)")
                }
            }
        }
    }
    
    private func executeScript(_ script: AutomationScript) async {
        let startTime = Date()
        
        // CHECK: Ensure automation is still running
        guard isAutomationRunning else {
            print("⏹️ Automation stopped, skipping \(script.name)")
            return
        }
        
        // OPTIMIZATION: Pre-load image synchronously for speed
        var testImage: UIImage? = nil
        if script.requiresImage {
            testImage = automationManager.getTestImage(for: script.id)
            if testImage == nil {
                print("❌ Missing image for \(script.name)")
                // FIX: Mark as failed and continue
                await markScriptAsFailed(script, reason: "Image not found")
                return
            }
        }
        
        // OPTIMIZATION: Skip UI updates during automation for speed
        let userMessage = ChatMessage(
            content: script.userMessage,
            isUser: true,
            timestamp: Date(),
            image: testImage
        )
        
        // Add to messages without animation
        await MainActor.run {
            messages.append(userMessage)
        }
        
        // Generate response with minimal overhead
        do {
            let responseStartTime = Date()
            
            if script.testType == .imageAnalysis {
                print("🖼️ Fast image analysis: \(script.name)")
            } else {
                print("💬 Fast text query: \(script.name)")
            }
            
            // FIX: Add timeout wrapper to prevent hanging
            let response = try await withTimeout(seconds: 10.0) {
                if script.testType == .imageAnalysis && testImage != nil {
                    return try await modelManager.generateResponse(for: script.userMessage, image: testImage)
                } else {
                    return try await modelManager.generateFastMedicalResponse(for: script.userMessage)
                }
            }
            
            let responseTime = Date().timeIntervalSince(responseStartTime)
            print("⚡ Response in \(String(format: "%.2f", responseTime))s")
            
            // OPTIMIZATION: Batch update script results
            await MainActor.run {
                if let index = automationManager.scripts.firstIndex(where: { $0.id == script.id }) {
                    automationManager.scripts[index].aiResponse = response
                    automationManager.scripts[index].isCompleted = true
                    automationManager.scripts[index].testResult = automationManager.validateResponse(response, for: script)
                    
                    let result = automationManager.scripts[index].testResult?.displayName ?? "UNKNOWN"
                    let testTypeIcon = script.testType.icon
                    print("\(testTypeIcon) Result: \(result)")
                }
            }
            
            // Add AI response to messages
            let aiMessage = ChatMessage(
                content: response,
                isUser: false,
                timestamp: Date()
            )
            
            await MainActor.run {
                messages.append(aiMessage)
            }
            
        } catch {
            let errorDuration = Date().timeIntervalSince(startTime)
            print("❌ ERROR in \(script.name) after \(String(format: "%.2f", errorDuration))s: \(error.localizedDescription)")
            
            // CRITICAL FIX: Reset model session after error
            await modelManager.resetSession()
            
            await MainActor.run {
                // Mark script as failed quickly
                if let index = automationManager.scripts.firstIndex(where: { $0.id == script.id }) {
                    automationManager.scripts[index].aiResponse = "TIMEOUT: \(error.localizedDescription)"
                    automationManager.scripts[index].testResult = .failed
                    automationManager.scripts[index].isCompleted = true
                }
                
                // Add minimal error message
                let errorMessage = ChatMessage(
                    content: "Error: \(script.testType.displayName) test timed out",
                    isUser: false,
                    timestamp: Date()
                )
                
                messages.append(errorMessage)
            }
            
            // CRITICAL FIX: Add recovery delay after error
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s to let model stabilize
        }
    }

    // ADD THIS HELPER FUNCTION
    private func markScriptAsFailed(_ script: AutomationScript, reason: String) async {
        await MainActor.run {
            if let index = automationManager.scripts.firstIndex(where: { $0.id == script.id }) {
                automationManager.scripts[index].aiResponse = "FAILED: \(reason)"
                automationManager.scripts[index].testResult = .failed
                automationManager.scripts[index].isCompleted = true
            }
            
            let errorMessage = ChatMessage(
                content: "❌ Test failed: \(reason)",
                isUser: false,
                timestamp: Date()
            )
            messages.append(errorMessage)
        }
    }

    // ADD THIS TIMEOUT HELPER FUNCTION
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            // Add the actual operation
            group.addTask {
                try await operation()
            }
            
            // Add timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw MLXModelManager.MLXError.generationTimeout
            }
            
            // Get first result and cancel others
            guard let result = try await group.next() else {
                throw MLXModelManager.MLXError.generationFailed
            }
            group.cancelAll()
            return result
        }
    }
//        let startTime = Date()
//        
//        // Get test image if required
//        var testImage: UIImage? = nil
//        if script.requiresImage {
//            testImage = automationManager.getTestImage(for: script.id)
//            if testImage == nil {
//                print("❌ Warning: Required test image not found for \(script.name)")
//            }
//        }
//        
//        // Create user message
//        let userMessage = ChatMessage(
//            content: script.userMessage,
//            isUser: true,
//            timestamp: Date(),
//            image: testImage
//        )
//        
//        // Update UI
//        await MainActor.run {
//            messages.append(userMessage)
//            isGenerating = true
//        }
//        
//        // Generate response with timeout
//        do {
//            if script.testType == .imageAnalysis {
//                print("🖼️ Starting image analysis: \(script.name)")
//            } else {
//                print("💬 Starting text query: \(script.name)")
//            }
//            
//            // Use appropriate response method
//            let response = if script.testType == .imageAnalysis && testImage != nil {
//                try await modelManager.generateResponse(for: script.userMessage, image: testImage)
//            } else {
//                try await modelManager.generateFastMedicalResponse(for: script.userMessage)
//            }
//            
//            let duration = Date().timeIntervalSince(startTime)
//            print("✅ Response received in \(String(format: "%.2f", duration))s")
//            
//            // Update script with results
//            await MainActor.run {
//                if let index = automationManager.scripts.firstIndex(where: { $0.id == script.id }) {
//                    automationManager.scripts[index].aiResponse = response
//                    automationManager.scripts[index].isCompleted = true
//                    automationManager.scripts[index].testResult = automationManager.validateResponse(response, for: script)
//                    
//                    let result = automationManager.scripts[index].testResult?.displayName ?? "UNKNOWN"
//                    let testTypeIcon = script.testType.icon
//                    print("\(testTypeIcon) Result: \(result) for \(script.name)")
//                }
//            }
//            
//            // Create AI message
//            let aiMessage = ChatMessage(
//                content: response,
//                isUser: false,
//                timestamp: Date()
//            )
//            
//            // Update UI with response
//            await MainActor.run {
//                messages.append(aiMessage)
//                isGenerating = false
//            }
//            
//        } catch {
//            let errorDuration = Date().timeIntervalSince(startTime)
//            print("❌ Error in \(script.name) after \(String(format: "%.2f", errorDuration))s: \(error.localizedDescription)")
//            
//            await MainActor.run {
//                // Mark script as failed
//                if let index = automationManager.scripts.firstIndex(where: { $0.id == script.id }) {
//                    automationManager.scripts[index].aiResponse = "TIMEOUT/ERROR: \(error.localizedDescription)"
//                    automationManager.scripts[index].testResult = .failed
//                    automationManager.scripts[index].isCompleted = true
//                }
//                
//                // Show error in chat
//                let errorMessage = ChatMessage(
//                    content: "⚠️ \(script.testType.displayName) test failed: \(error.localizedDescription)",
//                    isUser: false,
//                    timestamp: Date()
//                )
//                
//                messages.append(errorMessage)
//                isGenerating = false
//            }
//        }
//    }

    // MARK: - UPDATED CSV Export
    private func exportToCSV() {
        let modelInfo = "\(modelManager.modelName) (\(modelManager.currentModelId))"
        
        let result = csvExportManager.exportTestResults(
            messages: messages,
            automationScripts: automationManager.scripts,
            modelInfo: modelInfo,
            supportsVision: modelManager.supportsVision
        )
        
        exportedCSVContent = result.csvContent
        shareURL = result.shareURL
        
        if shareURL != nil {
            showingShareSheet = true
        }
    }
}
