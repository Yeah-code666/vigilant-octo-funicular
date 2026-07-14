import SwiftUI

struct HealthCard: View {

    let icon: String
    let title: String
    let value: String

    var body: some View {

        VStack(spacing: 10) {

            Text(icon)
                .font(.largeTitle)

            Text(title)
                .font(.headline)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(18)

    }
}

#Preview {
    HealthCard(
        icon: "🌙",
        title: "Sleep",
        value: "8h"
    )
}
