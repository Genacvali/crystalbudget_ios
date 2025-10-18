import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var currentPage = 0
    @State private var showingMainApp = false
    
    private let pages = [
        OnboardingPage(
            title: "Добро пожаловать в CrystalBudget",
            subtitle: "Управляйте финансами с умом",
            image: "wallet.pass.fill",
            description: "Отслеживайте доходы и расходы, контролируйте бюджеты и достигайте финансовых целей."
        ),
        OnboardingPage(
            title: "Быстрый учёт операций",
            subtitle: "Добавляйте траты за секунды",
            image: "plus.circle.fill",
            description: "Простой интерфейс для быстрого добавления операций. Сканируйте чеки и добавляйте расходы голосом."
        ),
        OnboardingPage(
            title: "Умные бюджеты",
            subtitle: "Контролируйте лимиты",
            image: "chart.pie.fill",
            description: "Настройте бюджеты по категориям и получайте уведомления о превышении лимитов."
        ),
        OnboardingPage(
            title: "Безопасность данных",
            subtitle: "Ваши финансы под защитой",
            image: "lock.shield.fill",
            description: "Биометрическая защита, шифрование данных и локальное хранение для максимальной безопасности."
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.primaryBlue.opacity(0.1), Color.secondaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Bottom section
                VStack(spacing: 24) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.primaryBlue : Color.secondary)
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut, value: currentPage)
                        }
                    }
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        if currentPage < pages.count - 1 {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage += 1
                                }
                            }) {
                                Text("Далее")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.primaryBlue)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                skipOnboarding()
                            }) {
                                Text("Пропустить")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Button(action: {
                                completeOnboarding()
                            }) {
                                Text("Начать использовать")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.primaryBlue)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            setupDemoData()
        }
    }
    
    private func completeOnboarding() {
        authManager.completeOnboarding()
        coreDataManager.createDemoData()
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.5)) {
            showingMainApp = true
        }
    }
    
    private func skipOnboarding() {
        completeOnboarding()
    }
    
    private func setupDemoData() {
        // Create demo data if needed
        if coreDataManager.fetchCategories().isEmpty {
            coreDataManager.createDemoData()
        }
    }
}

// MARK: - Onboarding Page
struct OnboardingPage {
    let title: String
    let subtitle: String
    let image: String
    let description: String
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Image
            ZStack {
                Circle()
                    .fill(Color.primaryBlue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.image)
                    .font(.system(size: 48))
                    .foregroundColor(.primaryBlue)
            }
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(page.subtitle)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primaryBlue)
                
                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Quick Start Guide
struct QuickStartGuide: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    
    private let steps = [
        QuickStartStep(
            title: "Добавьте кошелёк",
            description: "Создайте основной кошелёк для учёта средств",
            action: "Создать кошелёк",
            icon: "wallet.pass.fill"
        ),
        QuickStartStep(
            title: "Настройте категории",
            description: "Выберите категории для ваших расходов",
            action: "Настроить категории",
            icon: "folder.fill"
        ),
        QuickStartStep(
            title: "Создайте бюджет",
            description: "Установите лимиты для контроля расходов",
            action: "Создать бюджет",
            icon: "chart.pie.fill"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Progress indicator
                ProgressView(value: Double(currentStep + 1), total: Double(steps.count))
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal)
                
                // Step content
                VStack(spacing: 24) {
                    Image(systemName: steps[currentStep].icon)
                        .font(.system(size: 64))
                        .foregroundColor(.primaryBlue)
                    
                    VStack(spacing: 12) {
                        Text(steps[currentStep].title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(steps[currentStep].description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Action button
                Button(action: {
                    if currentStep < steps.count - 1 {
                        currentStep += 1
                    } else {
                        dismiss()
                    }
                }) {
                    Text(currentStep < steps.count - 1 ? "Далее" : "Завершить")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryBlue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Быстрый старт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Пропустить") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Quick Start Step
struct QuickStartStep {
    let title: String
    let description: String
    let action: String
    let icon: String
}

// MARK: - Preview
#Preview {
    OnboardingView()
        .environmentObject(AuthenticationManager())
        .environmentObject(CoreDataManager.shared)
}
