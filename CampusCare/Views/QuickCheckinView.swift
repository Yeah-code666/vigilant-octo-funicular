import SwiftUI

struct QuickCheckinView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var service = AnalysisService.shared

    @State private var selectedMood: Int? = 2
    @State private var waterCount = 5
    @State private var selectedSleep = 2
    @State private var selectedStudy = 2
    @State private var showingCompletion = false

    let moods = ["😀", "😄", "😐", "😔", "😭"]
    let moodLabels = ["Great", "Good", "OK", "Tired", "Exhausted"]
    let sleepOptions = ["<6h", "6-7h", "7-8h", "8h+"]
    let studyOptions = ["2h", "4h", "6h", "8h+"]
    static let sleepValues = [5.5, 6.5, 7.5, 8.0]
    static let studyValues = [2.0, 4.0, 6.0, 8.0]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    Text("Complete in 20 seconds")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)

                    // MARK: - Mood Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("😊 How do you feel today?")
                            .font(.headline)

                        HStack(spacing: 12) {
                            ForEach(0..<moods.count, id: \.self) { index in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        selectedMood = index
                                    }
                                }) {
                                    VStack(spacing: 4) {
                                        Text(moods[index])
                                            .font(.system(size: 32))
                                        Text(moodLabels[index])
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(width: 52, height: 70)
                                    .background(
                                        selectedMood == index ?
                                        Color.blue.opacity(0.15) :
                                        Color(.systemGray6)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                selectedMood == index ?
                                                Color.blue : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                }
                                .scaleEffect(selectedMood == index ? 1.05 : 1.0)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 8)

                    // MARK: - Water Intake
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("💧 Water")
                                .font(.headline)
                            Spacer()
                            HStack(spacing: 16) {
                                Button(action: { if waterCount > 0 { waterCount -= 1 } }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                                Text("\(waterCount)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .frame(minWidth: 36)
                                Button(action: { if waterCount < 20 { waterCount += 1 } }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        Text("cups")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 8)

                    // MARK: - Sleep Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🌙 Sleep (last night)")
                            .font(.headline)

                        HStack(spacing: 6) {
                            ForEach(0..<sleepOptions.count, id: \.self) { index in
                                Button(action: { selectedSleep = index }) {
                                    Text(sleepOptions[index])
                                        .font(.subheadline)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            selectedSleep == index ?
                                            Color.blue : Color(.systemGray6)
                                        )
                                        .foregroundColor(
                                            selectedSleep == index ?
                                            .white : .primary
                                        )
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 8)

                    // MARK: - Study Time
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📚 Study (today)")
                            .font(.headline)

                        HStack(spacing: 6) {
                            ForEach(0..<studyOptions.count, id: \.self) { index in
                                Button(action: { selectedStudy = index }) {
                                    Text(studyOptions[index])
                                        .font(.subheadline)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            selectedStudy == index ?
                                            Color.blue : Color(.systemGray6)
                                        )
                                        .foregroundColor(
                                            selectedStudy == index ?
                                            .white : .primary
                                        )
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 8)

                    // MARK: - Complete Button
                    Button(action: {
                        service.updateData(
                            sleep: Self.sleepValues[selectedSleep],
                            study: Self.studyValues[selectedStudy],
                            water: waterCount,
                            mood: moodLabels[selectedMood ?? 2]
                        )

                        withAnimation {
                            showingCompletion = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            showingCompletion = false
                            dismiss()
                        }
                    }) {
                        HStack {
                            if showingCompletion {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text(showingCompletion ? "Saved!" : "✅ Complete")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(showingCompletion ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(showingCompletion)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Quick Check-in")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    QuickCheckinView()
}
