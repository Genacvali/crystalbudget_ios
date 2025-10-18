import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView(selectedTab: $selectedTab)
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingQuickAdd = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }
                .tag(0)
            
            TransactionsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Операции")
                }
                .tag(1)
            
            BudgetsView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Бюджеты")
                }
                .tag(2)
            
            ReportsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Отчёты")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
                .tag(4)
        }
        .accentColor(.primaryBlue)
        .overlay(alignment: .bottomTrailing) {
            // FAB для быстрого добавления
            Button(action: {
                showingQuickAdd = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.primaryBlue)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 100) // Above tab bar
        }
        .sheet(isPresented: $showingQuickAdd) {
            QuickAddView()
        }
    }
}

// MARK: - Color Extensions
extension Color {
    static let primaryBlue = Color(red: 0.05, green: 0.43, blue: 0.99) // #0d6efd
    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let dangerRed = Color(red: 0.86, green: 0.08, blue: 0.24) // #dc3545
    static let warningOrange = Color(red: 1.0, green: 0.65, blue: 0.0) // #ffa500
    static let successGreen = Color(red: 0.13, green: 0.69, blue: 0.31) // #20c997
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
        .environmentObject(NotificationManager())
        .environmentObject(SyncManager())
}
