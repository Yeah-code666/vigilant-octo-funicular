import SwiftUI
import Combine

// MARK: - 数据模型
struct DimensionScore: Identifiable {
    let id = UUID()
    let name: String
    let score: Double
    let icon: String
    let color: Color
}

struct Suggestion: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
    let priority: Priority

    enum Priority: Int {
        case high = 0
        case medium = 1
        case low = 2
    }
}

struct AnalysisResult {
    let score: Int
    let yesterdayScore: Int
    let dimensions: [DimensionScore]
    let suggestions: [Suggestion]
}

// MARK: - AnalysisService
class AnalysisService: ObservableObject {
    static let shared = AnalysisService()

    private let userDefaults: UserDefaults

    @Published var sleep: Double = 7.2
    @Published var study: Double = 5.5
    @Published var water: Int = 5
    @Published var mood: String = "Good"
    @Published var steps: Int = 6800
    @Published var stress: Int = 5
    @Published private(set) var dataVersion = 0

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadFromStorage()
    }

    func loadFromStorage() {
        if userDefaults.object(forKey: "userSleep") != nil {
            sleep = userDefaults.double(forKey: "userSleep")
        }
        if userDefaults.object(forKey: "userStudy") != nil {
            study = userDefaults.double(forKey: "userStudy")
        }
        if userDefaults.object(forKey: "userWater") != nil {
            water = userDefaults.integer(forKey: "userWater")
        }
        if let savedMood = userDefaults.string(forKey: "userMood") {
            mood = savedMood
        }
        if userDefaults.object(forKey: "userSteps") != nil {
            steps = userDefaults.integer(forKey: "userSteps")
        }
        if userDefaults.object(forKey: "userStress") != nil {
            stress = userDefaults.integer(forKey: "userStress")
        }
        dataVersion += 1
    }

    func updateData(sleep: Double? = nil, study: Double? = nil, steps: Int? = nil, water: Int? = nil, mood: String? = nil, stress: Int? = nil) {
        if let sleep = sleep {
            self.sleep = sleep
            userDefaults.set(sleep, forKey: "userSleep")
        }
        if let study = study {
            self.study = study
            userDefaults.set(study, forKey: "userStudy")
        }
        if let steps = steps {
            self.steps = steps
            userDefaults.set(steps, forKey: "userSteps")
        }
        if let water = water {
            self.water = water
            userDefaults.set(water, forKey: "userWater")
        }
        if let mood = mood {
            self.mood = mood
            userDefaults.set(mood, forKey: "userMood")
        }
        if let stress = stress {
            self.stress = stress
            userDefaults.set(stress, forKey: "userStress")
        }
        dataVersion += 1
    }

    func calculateScore() -> Int {
        var score = 0

        // 睡眠 (最高30分)
        if sleep >= 8 { score += 30 }
        else if sleep >= 7 { score += 25 }
        else if sleep >= 6 { score += 18 }
        else if sleep >= 5 { score += 10 }
        else { score += 5 }

        // 学习 (最高20分)
        if study >= 4 && study <= 6 { score += 20 }
        else if study > 6 { score += 15 }
        else if study >= 3 { score += 12 }
        else { score += 5 }

        // 运动 (最高20分)
        if steps >= 10000 { score += 20 }
        else if steps >= 8000 { score += 18 }
        else if steps >= 6000 { score += 14 }
        else if steps >= 4000 { score += 8 }
        else { score += 3 }

        // 饮水 (最高15分)
        if water >= 8 { score += 15 }
        else if water >= 6 { score += 12 }
        else if water >= 4 { score += 8 }
        else { score += 3 }

        // 压力 (最高15分)
        if stress <= 3 { score += 15 }
        else if stress <= 5 { score += 12 }
        else if stress <= 7 { score += 8 }
        else { score += 4 }

        return min(score, 100)
    }

    func getDimensionScore(_ type: String) -> Double {
        switch type {
        case "sleep":
            if sleep >= 8 { return 10 }
            else if sleep >= 7 { return 8.5 }
            else if sleep >= 6 { return 7.0 }
            else if sleep >= 5 { return 5.0 }
            else { return 3.0 }
        case "study":
            if study >= 4 && study <= 6 { return 10 }
            else if study > 6 { return 8.5 }
            else if study >= 3 { return 7.0 }
            else if study >= 2 { return 5.0 }
            else { return 3.0 }
        case "exercise":
            if steps >= 10000 { return 10 }
            else if steps >= 8000 { return 8.5 }
            else if steps >= 6000 { return 7.0 }
            else if steps >= 4000 { return 5.0 }
            else { return 3.0 }
        case "diet":
            if water >= 8 { return 10 }
            else if water >= 6 { return 8.0 }
            else if water >= 4 { return 6.0 }
            else { return 3.0 }
        case "stress":
            if stress <= 3 { return 10 }
            else if stress <= 5 { return 8.0 }
            else if stress <= 7 { return 5.5 }
            else { return 3.0 }
        default:
            return 5.0
        }
    }

    func getAnalysis() -> AnalysisResult {
        let score = calculateScore()

        let dimensions = [
            DimensionScore(name: "Sleep", score: getDimensionScore("sleep"), icon: "🌙", color: .blue),
            DimensionScore(name: "Study", score: getDimensionScore("study"), icon: "📚", color: .purple),
            DimensionScore(name: "Exercise", score: getDimensionScore("exercise"), icon: "🏃", color: .green),
            DimensionScore(name: "Diet", score: getDimensionScore("diet"), icon: "🍱", color: .orange),
            DimensionScore(name: "Stress", score: getDimensionScore("stress"), icon: "🧘", color: .pink)
        ]

        let suggestions = getSuggestions()

        return AnalysisResult(
            score: score,
            yesterdayScore: max(score - Int.random(in: 1...5), 50),
            dimensions: dimensions,
            suggestions: suggestions
        )
    }

    // MARK: - 动态生成AI建议（完全根据数据）
    func getSuggestions() -> [Suggestion] {
        var suggestions: [Suggestion] = []

        // 睡眠建议
        if sleep < 6 {
            suggestions.append(Suggestion(
                icon: "🌙",
                text: "You only slept \(String(format: "%.1f", sleep)) hours. Try to sleep before 11:30 PM.",
                priority: .high
            ))
        } else if sleep >= 6 && sleep < 7 {
            suggestions.append(Suggestion(
                icon: "🌙",
                text: "Sleep \(String(format: "%.1f", sleep)) hours is OK. Aim for 7-8 hours for better recovery.",
                priority: .medium
            ))
        } else if sleep >= 8 {
            suggestions.append(Suggestion(
                icon: "🌙",
                text: "Great! \(String(format: "%.1f", sleep)) hours of sleep. Keep this habit!",
                priority: .low
            ))
        }

        // 饮水建议
        if water < 4 {
            suggestions.append(Suggestion(
                icon: "💧",
                text: "You've only had \(water) cups of water. Drink \(8 - water) more cups today.",
                priority: .high
            ))
        } else if water < 6 {
            suggestions.append(Suggestion(
                icon: "💧",
                text: "You had \(water) cups of water. Try to drink \(8 - water) more cups.",
                priority: .medium
            ))
        } else if water >= 8 {
            suggestions.append(Suggestion(
                icon: "💧",
                text: "Excellent! \(water) cups of water is perfect for today.",
                priority: .low
            ))
        }

        // 运动建议
        if steps < 4000 {
            suggestions.append(Suggestion(
                icon: "🚶",
                text: "You only walked \(steps) steps. Try to walk \(8000 - steps) more steps today.",
                priority: .high
            ))
        } else if steps < 6000 {
            suggestions.append(Suggestion(
                icon: "🚶",
                text: "You walked \(steps) steps. Aim for 8000 steps for better health.",
                priority: .medium
            ))
        } else if steps >= 8000 {
            suggestions.append(Suggestion(
                icon: "🏃",
                text: "Great! \(steps) steps today. Keep moving!",
                priority: .low
            ))
        }

        // 学习建议
        if study > 6 {
            suggestions.append(Suggestion(
                icon: "📚",
                text: "You studied \(String(format: "%.1f", study)) hours. Take a 5-min break every 45 minutes.",
                priority: .medium
            ))
        } else if study < 2 && study > 0 {
            suggestions.append(Suggestion(
                icon: "📚",
                text: "You studied \(String(format: "%.1f", study)) hours today. Try to study at least 3 hours.",
                priority: .medium
            ))
        } else if study >= 4 && study <= 6 {
            suggestions.append(Suggestion(
                icon: "📚",
                text: "Perfect! \(String(format: "%.1f", study)) hours of study. Balanced schedule!",
                priority: .low
            ))
        }

        // 压力建议
        if stress > 7 {
            suggestions.append(Suggestion(
                icon: "🧘",
                text: "Your stress level is \(stress)/10. Try 5 minutes of deep breathing.",
                priority: .high
            ))
        } else if stress > 5 {
            suggestions.append(Suggestion(
                icon: "🧘",
                text: "Stress level \(stress)/10. Take a short walk or meditate.",
                priority: .medium
            ))
        }

        // 如果没有任何建议（数据全是理想的），给出鼓励
        if suggestions.isEmpty {
            suggestions.append(Suggestion(
                icon: "🌟",
                text: "Perfect! All your health metrics are great. Keep up the amazing work!",
                priority: .low
            ))
        }

        // 按优先级排序（高优先级在前）
        return suggestions.sorted { $0.priority.rawValue < $1.priority.rawValue }
    }
}
