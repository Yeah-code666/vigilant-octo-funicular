import SwiftUI

struct HomeView: View {
    @StateObject private var service = AnalysisService.shared
    @State private var currentInsight = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Greeting（动态根据时间变化）
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(getGreeting())
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Alex")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)

                    // MARK: - Health Score Card（动态分数）
                    VStack(spacing: 8) {
                        Text("Health Score")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        let score = service.calculateScore()
                        Text("\(score)")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(score >= 80 ? .blue : score >= 60 ? .orange : .red)

                        HStack(spacing: 4) {
                            let stars = score / 20
                            ForEach(0..<5) { index in
                                Image(systemName: index < stars ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                        }
                        .font(.title3)

                        // 动态评语
                        Text(getScoreComment(score: score))
                            .font(.caption)
                            .foregroundColor(score >= 80 ? .green : score >= 60 ? .orange : .red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10)
                    .padding(.horizontal)

                    // MARK: - Quick Stats（动态数据）- 使用 Components/StatCard.swift
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            StatCard(icon: "🌙", label: "Sleep", value: String(format: "%.1fh", service.sleep))
                            StatCard(icon: "📚", label: "Study", value: String(format: "%.1fh", service.study))
                            StatCard(icon: "🚶", label: "Steps", value: "\(service.steps)")
                            StatCard(icon: "💧", label: "Water", value: "\(service.water) cups")
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - AI Insight Card（动态根据数据生成）
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Today's AI Insight", systemImage: "sparkles")
                                .font(.headline)
                            Spacer()
                            Button(action: { refreshInsight() }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.blue)
                            }
                        }
                        Text(currentInsight.isEmpty ? generateDynamicInsight() : currentInsight)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.green.opacity(0.08))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)

                    // MARK: - Today's Goals（动态进度）
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Goals")
                            .font(.headline)

                        GoalProgress(
                            title: "Drink 8 cups of water",
                            current: service.water,
                            total: 8,
                            emoji: "💧"
                        )

                        GoalProgress(
                            title: "Walk 8000 steps",
                            current: service.steps,
                            total: 8000,
                            emoji: "🚶"
                        )
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if currentInsight.isEmpty {
                    currentInsight = generateDynamicInsight()
                }
            }
            .onChange(of: service.dataVersion) { _ in
                currentInsight = generateDynamicInsight()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("😊 Good Day") {
                            AnalysisService.shared.updateData(
                                sleep: 8.0,
                                study: 5.0,
                                steps: 10000,
                                water: 8,
                                mood: "Good",
                                stress: 2
                            )
                            currentInsight = generateDynamicInsight()
                        }
                        Button("😴 Tired Day") {
                            AnalysisService.shared.updateData(
                                sleep: 5.5,
                                study: 7.0,
                                steps: 4000,
                                water: 3,
                                mood: "Tired",
                                stress: 8
                            )
                            currentInsight = generateDynamicInsight()
                        }
                        Button("🔄 Reset") {
                            AnalysisService.shared.updateData(
                                sleep: 7.2,
                                study: 5.5,
                                steps: 6800,
                                water: 5,
                                mood: "OK",
                                stress: 5
                            )
                            currentInsight = generateDynamicInsight()
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }

    // MARK: - 动态生成问候语
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning ☀️" }
        else if hour < 17 { return "Good Afternoon 🌤️" }
        else { return "Good Evening 🌙" }
    }

    // MARK: - 动态生成分数评语
    private func getScoreComment(score: Int) -> String {
        if score >= 85 { return "🌟 Excellent! Keep it up!" }
        else if score >= 70 { return "👍 Good job! Room for improvement" }
        else if score >= 55 { return "📈 Keep going! You're making progress" }
        else { return "💪 Let's focus on your health today" }
    }

    // MARK: - 动态生成AI洞察（根据实际数据）
    private func generateDynamicInsight() -> String {
        var insights: [String] = []

        // 睡眠洞察
        if service.sleep < 6 {
            insights.append("😴 You only slept \(String(format: "%.1f", service.sleep)) hours. Try to sleep earlier tonight.")
        } else if service.sleep >= 8 {
            insights.append("🌙 Great sleep! \(String(format: "%.1f", service.sleep)) hours is excellent.")
        } else if service.sleep >= 7 {
            insights.append("😊 Good sleep quality. Keep it up!")
        }

        // 学习洞察
        if service.study > 6 {
            insights.append("📚 You studied \(String(format: "%.1f", service.study)) hours. Remember to take breaks.")
        } else if service.study < 3 && service.study > 0 {
            insights.append("📖 Try to study a bit more today. Aim for 3-4 hours.")
        }

        // 饮水洞察
        if service.water < 4 {
            insights.append("💧 You've only had \(service.water) cups of water. Drink more!")
        } else if service.water >= 8 {
            insights.append("💧 Great hydration! \(service.water) cups is perfect.")
        }

        // 运动洞察
        if service.steps < 5000 {
            insights.append("🚶 Walk more today! You've taken \(service.steps) steps so far.")
        } else if service.steps >= 10000 {
            insights.append("🏃 Amazing! You've reached \(service.steps) steps today!")
        }

        // 如果没有数据，给出默认建议
        if insights.isEmpty {
            return "✨ You're doing great! Stay consistent with your healthy habits."
        }

        return insights.joined(separator: " ")
    }

    private func refreshInsight() {
        currentInsight = generateDynamicInsight()
    }
}

// MARK: - Goal Progress Component（只保留这一个）
struct GoalProgress: View {
    let title: String
    let current: Int
    let total: Int
    let emoji: String

    var progress: Double {
        Double(current) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(emoji) \(title)")
                    .font(.subheadline)
                Spacer()
                Text("\(current)/\(total)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    HomeView()
}
