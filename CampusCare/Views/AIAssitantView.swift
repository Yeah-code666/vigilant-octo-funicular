import SwiftUI

struct AIAssistantView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hello! I'm your CampusCare AI assistant 🤖\nI understand your health data and can give personalized advice.", isUser: false)
    ]
    @State private var inputText = ""
    @State private var isTyping = false
    
    struct ChatMessage: Identifiable {
        let id = UUID()
        let text: String
        let isUser: Bool
    }
    
    let quickQuestions = [
        "Why am I so tired today?",
        "What should I eat for dinner?",
        "How can I study more efficiently?",
        "How is my sleep quality?"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Message List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                            }
                            
                            if isTyping {
                                HStack {
                                    Spacer()
                                    TypingIndicator()
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            if let last = messages.last {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Quick Questions
                if messages.count == 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(quickQuestions, id: \.self) { question in
                                Button(action: { sendMessage(question) }) {
                                    Text(question)
                                        .font(.caption)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                }
                
                // Input Area
                HStack(spacing: 12) {
                    TextField("Ask about your health...", text: $inputText)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    Button(action: {
                        guard !inputText.isEmpty else { return }
                        sendMessage(inputText)
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(inputText.isEmpty ? .gray : .blue)
                    }
                    .disabled(inputText.isEmpty)
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -2)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func sendMessage(_ text: String) {
        messages.append(ChatMessage(text: text, isUser: true))
        inputText = ""
        isTyping = true
        
        // Simulate AI response with smart logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isTyping = false
            let response = SmartAIService.shared.analyzeUserMessage(text)
            messages.append(ChatMessage(text: response, isUser: false))
        }
    }
}

// MARK: - Smart AI Service (Local)
class SmartAIService {
    static let shared = SmartAIService()

    private var currentData: AnalysisService {
        AnalysisService.shared
    }
    
    func analyzeUserMessage(_ message: String) -> String {
        let lowercased = message.lowercased()
        
        if lowercased.contains("tired") || lowercased.contains("fatigue") || lowercased.contains("exhausted") {
            return analyzeFatigue()
        }
        
        if lowercased.contains("dinner") || lowercased.contains("eat") || lowercased.contains("food") || lowercased.contains("diet") {
            return analyzeDiet()
        }
        
        if lowercased.contains("study") || lowercased.contains("learn") || lowercased.contains("efficient") {
            return analyzeStudy()
        }
        
        if lowercased.contains("sleep") || lowercased.contains("insomnia") || lowercased.contains("bed") {
            return analyzeSleep()
        }
        
        if lowercased.contains("exercise") || lowercased.contains("walk") || lowercased.contains("step") {
            return analyzeExercise()
        }
        
        return generateGeneralAdvice()
    }
    
    private func analyzeFatigue() -> String {
        var reasons: [String] = []
        var suggestions: [String] = []
        
        if currentData.sleep < 7 {
            reasons.append("Sleep deprivation (only \(String(format: "%.1f", currentData.sleep)) hours)")
            suggestions.append("Go to bed early tonight, aim for 7.5+ hours")
        }
        
        if currentData.study > 5 {
            reasons.append("Long study hours (\(currentData.study) hours)")
            suggestions.append("Take a 5-min break every 45 minutes")
        }
        
        if currentData.stress > 6 {
            reasons.append("High stress level")
            suggestions.append("Try 5 minutes of deep breathing meditation")
        }
        
        if reasons.isEmpty {
            return """
            😊 You're doing great today!
            
            Recommendations:
            • Maintain good sleep schedule
            • Drink more water (aim for 8 cups)
            • Stay active
            """
        }
        
        return """
        😅 You might be tired because:
        \(reasons.map { "• \($0)" }.joined(separator: "\n"))
        
        💡 Suggestions:
        \(suggestions.map { "• \($0)" }.joined(separator: "\n"))
        """
    }
    
    private func analyzeDiet() -> String {
        let waterStatus = currentData.water >= 8 ? "✅ Good" : "⚠️ Low (\(currentData.water)/8 cups)"
        
        return """
        🍱 Today's Diet Advice:
        
        Water Intake: \(waterStatus)
        
        Recommended Dinner:
        • Carbs: Brown rice or whole wheat bread
        • Protein: Chicken/Fish/Tofu
        • Vegetables: Broccoli/Spinach/Carrots
        
        ⏰ Best time: 6:00 PM - 7:00 PM
        """
    }
    
    private func analyzeStudy() -> String {
        let efficiency = currentData.study > 4 ? "High" : "Moderate"
        
        return """
        📚 Study Analysis:
        
        Today's Study: \(currentData.study) hours
        Efficiency: \(efficiency)
        
        💡 Study Tips:
        • Use Pomodoro (25 min + 5 min break)
        • Schedule hardest subjects for 9-11 AM
        • Take a 15-min walk after afternoon study
        • Maintain consistent study schedule
        """
    }
    
    private func analyzeSleep() -> String {
        let sleepQuality = currentData.sleep >= 7.5 ? "Good" : "Needs Improvement"
        
        return """
        🌙 Sleep Analysis:
        
        Last Night: \(String(format: "%.1f", currentData.sleep)) hours
        Quality: \(sleepQuality)
        
        💡 Improvement Tips:
        • Fixed sleep time (before 11:30 PM)
        • No screens 1 hour before bed
        • Keep room cool (18-20°C)
        • 5-minute meditation before sleep
        """
    }
    
    private func analyzeExercise() -> String {
        let steps = currentData.steps
        let target = 8000
        
        if steps >= target {
            return """
            🏃 Exercise Analysis:
            
            Steps: \(steps) ✅ Goal achieved!
            Keep up the great work.
            
            Bonus: Add 2 strength training sessions per week
            """
        } else {
            return """
            🏃 Exercise Analysis:
            
            Steps: \(steps) ⚠️ Below target (\(target) steps)
            
            💡 Suggestions:
            • Walk 5 min between classes
            • 15-min walk after meals
            • Choose walking over short rides
            """
        }
    }
    
    private func generateGeneralAdvice() -> String {
        return """
        🌟 Today's General Advice:
        
        • Sleep: Aim for 7.5-8 hours
        • Hydration: At least 8 cups daily
        • Exercise: 8000+ steps daily
        • Study: Take breaks every 45 min
        
        Small changes, big impact! 💪
        """
    }
}

// MARK: - UI Components
struct MessageBubble: View {
    let message: AIAssistantView.ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.text)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    message.isUser ?
                    Color.blue : Color(.systemBackground)
                )
                .foregroundColor(
                    message.isUser ? .white : .primary
                )
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

struct TypingIndicator: View {
    @State private var animation = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .scaleEffect(animation ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animation
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .onAppear { animation = true }
    }
}

#Preview {
    AIAssistantView()
}
