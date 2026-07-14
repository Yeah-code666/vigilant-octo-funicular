import SwiftUI

struct ProfileView: View {
    @State private var username = "Alex Chen"
    @State private var school = "Tsinghua University"
    @State private var major = "Computer Science"
    @State private var height = "175 cm"
    @State private var weight = "68 kg"
    @AppStorage("healthGoal") private var goal = "Improve Sleep"
    @AppStorage("notificationsEnabled") private var notifications = true
    @AppStorage("darkModeEnabled") private var darkMode = false
    
    let goals = ["Improve Sleep", "Study More", "Exercise More", "Eat Healthier", "Reduce Stress"]
    
    var body: some View {
        NavigationStack {
            List {
                // 头像
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 72))
                                .foregroundColor(.blue)
                            Text(username)
                                .font(.headline)
                            Text("Edit Profile")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                
                // 个人信息
                Section("Personal Info") {
                    HStack {
                        Text("🏫 School")
                        Spacer()
                        Text(school)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("📚 Major")
                        Spacer()
                        Text(major)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("📏 Height")
                        Spacer()
                        Text(height)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("⚖️ Weight")
                        Spacer()
                        Text(weight)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 目标
                Section("🎯 Health Goal") {
                    Picker("Goal", selection: $goal) {
                        ForEach(goals, id: \.self) { g in
                            Text(g).tag(g)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // 设置
                Section("⚙️ Settings") {
                    Toggle("🔔 Notifications", isOn: $notifications)
                    Toggle("🌙 Dark Mode", isOn: $darkMode)
                }
                
                // 关于
                Section("ℹ️ About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("App")
                        Spacer()
                        Text("CampusCare AI")
                            .foregroundColor(.secondary)
                    }
                }
                
                // 退出
                Section {
                    Button(role: .destructive) {
                        // TODO: 退出登录
                    } label: {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProfileView()
}
