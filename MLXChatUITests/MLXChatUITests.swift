import XCTest

final class MLXChatUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Basic Test (Start with this one)
    
    func testAppLaunches() throws {
        // Test 1: Just check if app launches successfully
        XCTAssertTrue(app.exists, "App should launch successfully")
        print("✅ App launched successfully!")
    }
    
    func testModelLoadingUI() throws {
        // Test 2: Check if model loading UI appears
        let modelStatus = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Model'")).firstMatch
        XCTAssertTrue(modelStatus.waitForExistence(timeout: 10), "Model status should be visible")
        print("✅ Model status UI found!")
    }
    
    func testAutomationButtonExists() throws {
        // Test 3: Check if automation button exists (after model loads)
        
        // Wait for model to load first
        print("⏳ Waiting for model to load...")
        let modelLoadedIndicator = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Qwen' OR label CONTAINS '✓'")).firstMatch
        
        if !modelLoadedIndicator.waitForExistence(timeout: 60) {
            // If model doesn't auto-load, try to load it manually
            let loadButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Load'")).firstMatch
            if loadButton.exists {
                print("📥 Manually loading model...")
                loadButton.tap()
                XCTAssertTrue(modelLoadedIndicator.waitForExistence(timeout: 120), "Model should load within 2 minutes")
            }
        }
        
        print("✅ Model loaded! Looking for automation button...")
        
        // Now check for automation button
        let automationButton = app.buttons["automationRunButton"]
        XCTAssertTrue(automationButton.waitForExistence(timeout: 10), "Automation button should exist after model loads")
        
        print("✅ Automation button found!")
    }
    
    func testScriptCounterExists() throws {
        // Test 4: Check if script counter exists
        
        // Wait for model to load
        let modelLoadedIndicator = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Qwen' OR label CONTAINS '✓'")).firstMatch
        XCTAssertTrue(modelLoadedIndicator.waitForExistence(timeout: 60), "Model should load")
        
        // Check script counter
        let scriptCounter = app.staticTexts["scriptCounter"]
        XCTAssertTrue(scriptCounter.waitForExistence(timeout: 5), "Script counter should exist")
        XCTAssertTrue(scriptCounter.label.contains("0/40"), "Script counter should show 0/5 initially")
        
        print("✅ Script counter found: \(scriptCounter.label)")
    }
    
    // MARK: - Simple Automation Test
    
    func testRunOneScript() throws {
        // Test 5: Try to run automation and see if it starts
        
        // Wait for model to load
        print("⏳ Waiting for model to load...")
        let modelLoadedIndicator = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Qwen' OR label CONTAINS '✓'")).firstMatch
        XCTAssertTrue(modelLoadedIndicator.waitForExistence(timeout: 60), "Model should load")
        
        print("✅ Model loaded! Starting automation test...")
        
        // Find and tap automation button
        let runButton = app.buttons["automationRunButton"]
        XCTAssertTrue(runButton.waitForExistence(timeout: 5), "Run button should exist")
        XCTAssertTrue(runButton.isEnabled, "Run button should be enabled")
        
        // Tap the button
        runButton.tap()
        print("🚀 Automation started!")
        
        // Check if button changes to "Stop"
        let stopButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Stop'")).firstMatch
        XCTAssertTrue(stopButton.waitForExistence(timeout: 5), "Button should change to Stop")
        
        print("✅ Button changed to Stop - automation is running!")
        
        // Wait a bit to see progress
        sleep(10)
        
        // Check if script counter updated
        let scriptCounter = app.staticTexts["scriptCounter"]
        print("📊 Current script counter: \(scriptCounter.label)")
        
        // Stop automation to clean up
        if stopButton.exists {
            stopButton.tap()
            print("⏹️ Stopped automation")
        }
        
        print("✅ Basic automation test completed!")
    }
    
    // MARK: - Full Automation Test (Run this after the basic ones work)
    
    func testRunAllFiveScripts() throws {
        // Test 6: Run complete automation sequence
        
        print("🚀 Starting full automation test...")
        
        // Wait for model to load
        let modelLoadedIndicator = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Qwen' OR label CONTAINS '✓'")).firstMatch
        XCTAssertTrue(modelLoadedIndicator.waitForExistence(timeout: 60), "Model should load")
        
        // Start automation
        let runButton = app.buttons["automationRunButton"]
        runButton.tap()
        
        // Monitor progress for up to 2 minutes
        let startTime = Date()
        let timeout: TimeInterval = 120 // 2 minutes
        
        while Date().timeIntervalSince(startTime) < timeout {
            let scriptCounter = app.staticTexts["scriptCounter"]
            let currentCount = scriptCounter.label
            
            print("📊 Progress: \(currentCount)")
            
            // Check if completed (5/5)
            if currentCount.contains("5/5") {
                print("🎉 All scripts completed!")
                break
            }
            
            sleep(5) // Check every 5 seconds
        }
        
        // Verify final state
        let finalCounter = app.staticTexts["scriptCounter"]
        XCTAssertTrue(finalCounter.label.contains("5/5"), "Should complete all 5 scripts")
        
        print("✅ Full automation test completed!")
    }
}
