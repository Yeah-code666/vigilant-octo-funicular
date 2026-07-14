import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @AppStorage("darkModeEnabled") private var darkMode = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            QuickCheckinView()
                .tabItem {
                    Label("Check-in", systemImage: "square.and.pencil")
                }
                .tag(1)

            AnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar.fill")
                }
                .tag(2)

            AIAssistantView()
                .tabItem {
                    Label("AI", systemImage: "brain.head.profile")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(.blue)
        .preferredColorScheme(darkMode ? .dark : nil)
    }
}

#Preview {
    ContentView()
}
