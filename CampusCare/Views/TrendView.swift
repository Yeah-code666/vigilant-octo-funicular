import SwiftUI
import Charts

struct TrendData: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

enum TrendType: String, CaseIterable {
    case sleep = "Sleep"
    case study = "Study"
    case water = "Water"
    case steps = "Steps"
}

struct TrendView: View {
    @State private var selectedTrend: TrendType = .sleep
    @StateObject private var service = AnalysisService.shared

    // MARK: - Data
    let sleepData = [
        TrendData(day: "Mon", value: 7.0),
        TrendData(day: "Tue", value: 6.5),
        TrendData(day: "Wed", value: 8.0),
        TrendData(day: "Thu", value: 7.2),
        TrendData(day: "Fri", value: 6.8),
        TrendData(day: "Sat", value: 8.5),
        TrendData(day: "Sun", value: 7.8)
    ]

    let studyData = [
        TrendData(day: "Mon", value: 5.0),
        TrendData(day: "Tue", value: 4.5),
        TrendData(day: "Wed", value: 6.0),
        TrendData(day: "Thu", value: 5.5),
        TrendData(day: "Fri", value: 4.0),
        TrendData(day: "Sat", value: 3.0),
        TrendData(day: "Sun", value: 2.5)
    ]

    let waterData = [
        TrendData(day: "Mon", value: 6.0),
        TrendData(day: "Tue", value: 5.0),
        TrendData(day: "Wed", value: 7.0),
        TrendData(day: "Thu", value: 8.0),
        TrendData(day: "Fri", value: 6.0),
        TrendData(day: "Sat", value: 7.0),
        TrendData(day: "Sun", value: 8.0)
    ]

    let stepsData = [
        TrendData(day: "Mon", value: 7500),
        TrendData(day: "Tue", value: 6800),
        TrendData(day: "Wed", value: 8200),
        TrendData(day: "Thu", value: 7100),
        TrendData(day: "Fri", value: 6900),
        TrendData(day: "Sat", value: 8500),
        TrendData(day: "Sun", value: 7800)
    ]

    var currentData: [TrendData] {
        switch selectedTrend {
        case .sleep: return replacingLatestValue(in: sleepData, with: service.sleep)
        case .study: return replacingLatestValue(in: studyData, with: service.study)
        case .water: return replacingLatestValue(in: waterData, with: Double(service.water))
        case .steps: return replacingLatestValue(in: stepsData, with: Double(service.steps))
        }
    }

    private func replacingLatestValue(in data: [TrendData], with value: Double) -> [TrendData] {
        guard let latest = data.last else { return data }
        return Array(data.dropLast()) + [TrendData(day: latest.day, value: value)]
    }

    var currentUnit: String {
        switch selectedTrend {
        case .sleep, .study: return "hours"
        case .water: return "cups"
        case .steps: return "steps"
        }
    }

    var currentColor: Color {
        switch selectedTrend {
        case .sleep: return .blue
        case .study: return .purple
        case .water: return .cyan
        case .steps: return .green
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Segment Control
                Picker("Trend Type", selection: $selectedTrend) {
                    ForEach(TrendType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // MARK: - Chart
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(selectedTrend.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text("Weekly Trend")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Chart(currentData) { item in
                        LineMark(
                            x: .value("Day", item.day),
                            y: .value("Value", item.value)
                        )
                        .foregroundStyle(currentColor)
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Day", item.day),
                            y: .value("Value", item.value)
                        )
                        .foregroundStyle(currentColor)
                        .symbolSize(50)
                    }
                    .frame(height: 280)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .padding(.vertical, 8)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 10)
                .padding(.horizontal)

                // MARK: - Statistics
                HStack(spacing: 16) {
                    TrendStatCard(
                        label: "Average",
                        value: String(format: "%.1f", averageValue()),
                        unit: currentUnit
                    )
                    TrendStatCard(
                        label: "Best",
                        value: String(format: "%.1f", maxValue()),
                        unit: currentUnit
                    )
                    TrendStatCard(
                        label: "Change",
                        value: trendDirection(),
                        unit: String(format: "%.1f", changeValue())
                    )
                }
                .padding(.horizontal)
                .padding(.top, 12)

                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Trend")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Helper Functions
    private func averageValue() -> Double {
        let total = currentData.reduce(0) { $0 + $1.value }
        return total / Double(currentData.count)
    }

    private func maxValue() -> Double {
        return currentData.map { $0.value }.max() ?? 0
    }

    private func changeValue() -> Double {
        guard currentData.count >= 2 else { return 0 }
        let first = currentData.first?.value ?? 0
        let last = currentData.last?.value ?? 0
        return last - first
    }

    private func trendDirection() -> String {
        let change = changeValue()
        if change > 0.5 { return "↑" }
        if change < -0.5 { return "↓" }
        return "→"
    }
}

// MARK: - Trend Stat Card (专门给TrendView用)
struct TrendStatCard: View {
    let label: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    TrendView()
}
