import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var showingSettings = false
    @State private var showingExportOptions = false
    @State private var showingDeleteAccount = false
    
    private var totalTransactions: Int {
        coreDataManager.fetchTransactions().count
    }
    
    private var totalBudgets: Int {
        coreDataManager.fetchBudgets().count
    }
    
    var body: some View {
        NavigationView {
            List {
                // Profile header
                profileHeaderSection
                
                // Statistics
                statisticsSection
                
                // Settings
                settingsSection
                
                // Data management
                dataManagementSection
                
                // About
                aboutSection
                
                // Danger zone
                dangerZoneSection
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .actionSheet(isPresented: $showingExportOptions) {
                exportActionSheet
            }
            .confirmationDialog("Удалить аккаунт?", isPresented: $showingDeleteAccount) {
                Button("Удалить аккаунт", role: .destructive) {
                    deleteAccount()
                }
                Button("Отмена", role: .cancel) { }
            } message: {
                Text("Все ваши данные будут удалены навсегда. Это действие нельзя отменить.")
            }
        }
    }
    
    // MARK: - Profile Header Section
    
    private var profileHeaderSection: some View {
        Section {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundColor(.primaryBlue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Пользователь")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("CrystalBudget")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Активен с \(formatDate(Date()))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        Section("Статистика") {
            StatisticRow(
                title: "Всего операций",
                value: "\(totalTransactions)",
                icon: "list.bullet",
                color: .primaryBlue
            )
            
            StatisticRow(
                title: "Активных бюджетов",
                value: "\(totalBudgets)",
                icon: "chart.pie.fill",
                color: .successGreen
            )
            
            StatisticRow(
                title: "Кошельков",
                value: "\(coreDataManager.fetchWallets().count)",
                icon: "wallet.pass.fill",
                color: .warningOrange
            )
            
            StatisticRow(
                title: "Категорий",
                value: "\(coreDataManager.fetchCategories().count)",
                icon: "folder.fill",
                color: .dangerRed
            )
        }
    }
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        Section("Настройки") {
            NavigationLink(destination: SettingsView()) {
                SettingsRow(
                    title: "Настройки",
                    icon: "gearshape.fill",
                    color: .primaryBlue
                )
            }
            
            SettingsRow(
                title: "Биометрическая защита",
                icon: "faceid",
                color: authManager.isBiometricAvailable ? .successGreen : .secondary,
                trailing: authManager.isBiometricAvailable ? "Включено" : "Недоступно"
            )
            
            SettingsRow(
                title: "Уведомления",
                icon: "bell.fill",
                color: .warningOrange,
                trailing: "Включено"
            )
        }
    }
    
    // MARK: - Data Management Section
    
    private var dataManagementSection: some View {
        Section("Управление данными") {
            Button(action: {
                showingExportOptions = true
            }) {
                SettingsRow(
                    title: "Экспорт данных",
                    icon: "square.and.arrow.up.fill",
                    color: .successGreen
                )
            }
            
            Button(action: {
                createBackup()
            }) {
                SettingsRow(
                    title: "Создать резервную копию",
                    icon: "icloud.and.arrow.up.fill",
                    color: .primaryBlue
                )
            }
            
            Button(action: {
                restoreFromBackup()
            }) {
                SettingsRow(
                    title: "Восстановить из резервной копии",
                    icon: "icloud.and.arrow.down.fill",
                    color: .warningOrange
                )
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        Section("О приложении") {
            SettingsRow(
                title: "Версия",
                icon: "info.circle.fill",
                color: .secondary,
                trailing: "1.0.0"
            )
            
            Link(destination: URL(string: "https://crystalbudget.net")!) {
                SettingsRow(
                    title: "Веб-сайт",
                    icon: "globe",
                    color: .primaryBlue
                )
            }
            
            Link(destination: URL(string: "mailto:support@crystalbudget.net")!) {
                SettingsRow(
                    title: "Поддержка",
                    icon: "envelope.fill",
                    color: .successGreen
                )
            }
            
            Link(destination: URL(string: "https://github.com/crystalbudget")!) {
                SettingsRow(
                    title: "GitHub",
                    icon: "link",
                    color: .secondary
                )
            }
        }
    }
    
    // MARK: - Danger Zone Section
    
    private var dangerZoneSection: some View {
        Section {
            Button(action: {
                showingDeleteAccount = true
            }) {
                SettingsRow(
                    title: "Удалить аккаунт",
                    icon: "trash.fill",
                    color: .dangerRed
                )
            }
        } header: {
            Text("Опасная зона")
        } footer: {
            Text("Удаление аккаунта приведет к безвозвратной потере всех данных.")
        }
    }
    
    // MARK: - Export Action Sheet
    
    private var exportActionSheet: ActionSheet {
        ActionSheet(
            title: Text("Экспорт данных"),
            message: Text("Выберите формат для экспорта"),
            buttons: [
                .default(Text("CSV")) {
                    exportToCSV()
                },
                .default(Text("JSON")) {
                    exportToJSON()
                },
                .cancel()
            ]
        )
    }
    
    // MARK: - Actions
    
    private func createBackup() {
        // TODO: Implement backup creation
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func restoreFromBackup() {
        // TODO: Implement backup restoration
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func exportToCSV() {
        // TODO: Implement CSV export
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func exportToJSON() {
        // TODO: Implement JSON export
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func deleteAccount() {
        // TODO: Implement account deletion
        authManager.isAuthenticated = false
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let title: String
    let icon: String
    let color: Color
    var trailing: String? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            if let trailing = trailing {
                Text(trailing)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Statistic Row
struct StatisticRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var biometricEnabled = false
    @State private var notificationsEnabled = true
    @State private var currency = "RUB"
    @State private var language = "ru"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Безопасность") {
                    Toggle("Биометрическая защита", isOn: $biometricEnabled)
                        .onChange(of: biometricEnabled) { value in
                            if value {
                                authManager.enableBiometric()
                            } else {
                                authManager.disableBiometric()
                            }
                        }
                }
                
                Section("Уведомления") {
                    Toggle("Push уведомления", isOn: $notificationsEnabled)
                    Toggle("Напоминания о тратах", isOn: $notificationsEnabled)
                    Toggle("Превышение бюджета", isOn: $notificationsEnabled)
                }
                
                Section("Общие") {
                    Picker("Валюта", selection: $currency) {
                        Text("Рубль (₽)").tag("RUB")
                        Text("Доллар ($)").tag("USD")
                        Text("Евро (€)").tag("EUR")
                    }
                    
                    Picker("Язык", selection: $language) {
                        Text("Русский").tag("ru")
                        Text("English").tag("en")
                    }
                }
                
                Section("Приватность") {
                    Toggle("Аналитика", isOn: $notificationsEnabled)
                    Toggle("Персонализация", isOn: $notificationsEnabled)
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                biometricEnabled = authManager.isBiometricAvailable
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
        .environmentObject(CoreDataManager.shared)
}
