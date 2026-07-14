import SwiftUI

struct AnalysisView: View {
    @State private var analysisResult: AnalysisResult?
    @State private var isRefreshing = false
    @StateObject private var service = AnalysisService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                if let result = analysisResult {
                    VStack(spacing: 20) {

                        // MARK: - Health Score Ring（动态分数）
                        HealthScoreRing(score: result.score, yesterdayScore: result.yesterdayScore)

                        // MARK: - Dimension Scores（动态各维度评分）
                        DimensionListView(dimensions: result.dimensions)

                        // MARK: - AI Suggestions（动态根据数据生成）
                        SuggestionListView(suggestions: result.suggestions)
                    }
                    .padding()
                } else {
                    VStack(spacing: 20) {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Analyzing your health data...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(minHeight: 400)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("AI Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: refreshAnalysis) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                        }
                        .disabled(isRefreshing)

                        NavigationLink(destination: TrendView()) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .onAppear {
            if analysisResult == nil {
                refreshAnalysis()
            }
        }
        .onChange(of: service.dataVersion) { _ in
            refreshAnalysis(delay: 0)
        }
    }

    private func refreshAnalysis() {
        refreshAnalysis(delay: 0.5)
    }

    private func refreshAnalysis(delay: TimeInterval) {
        isRefreshing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            analysisResult = service.getAnalysis()
            isRefreshing = false
        }
    }
}

// MARK: - Subcomponents

struct HealthScoreRing: View {
    let score: Int
    let yesterdayScore: Int

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 10)
                    .frame(width: 150, height: 150)

                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(
                        score >= 80 ? Color.blue : score >= 60 ? Color.orange : Color.red,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: score)

                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: 44, weight: .bold))
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 4) {
                let change = score - yesterdayScore
                Image(systemName: change >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .foregroundColor(change >= 0 ? .green : .red)
                Text("\(change >= 0 ? "↑" : "↓") \(abs(change)) points")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(change >= 0 ? .green : .red)
                Text("vs yesterday")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
}

struct DimensionListView: View {
    let dimensions: [DimensionScore]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 Dimension Analysis")
                .font(.headline)
                .padding(.horizontal, 4)

            ForEach(dimensions) { dim in
                DimensionRow(dimension: dim)

                if dim.id != dimensions.last?.id {
                    Divider()
                        .padding(.horizontal, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
}

struct DimensionRow: View {
    let dimension: DimensionScore

    var body: some View {
        HStack {
            Text(dimension.icon)
                .font(.title3)
            Text(dimension.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 60, alignment: .leading)

            Spacer()

            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Image(systemName: starType(for: dimension.score, index: index))
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }

            Text(String(format: "%.1f", dimension.score))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
    }

    private func starType(for score: Double, index: Int) -> String {
        let fullStars = Int(score / 2)
        let remainder = score.truncatingRemainder(dividingBy: 2)

        if index < fullStars {
            return "star.fill"
        } else if index == fullStars && remainder >= 1 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

struct SuggestionListView: View {
    let suggestions: [Suggestion]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("💡 AI Suggestions")
                .font(.headline)

            if suggestions.isEmpty {
                Text("No suggestions yet. Keep up the good work!")
                    .font(.body)
                    .foregroundColor(.secondary)
            } else {
                ForEach(suggestions) { suggestion in
                    SuggestionRow(suggestion: suggestion)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
}

struct SuggestionRow: View {
    let suggestion: Suggestion

    var priorityColor: Color {
        switch suggestion.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(suggestion.icon)
                .font(.title3)
            Text(suggestion.text)
                .font(.body)
            Spacer()
            Circle()
                .fill(priorityColor)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AnalysisView()
}
