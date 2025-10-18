import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedPeriod: DateRange = .currentMonth
    @State private var showingQuickAdd = false
    @State private var refreshID = UUID()
    
    private var transactions: [Transaction] {
        coreDataManager.fetchTransactions(for: selectedPeriod)
    }
    
    private var budgets: [Budget] {
        coreDataManager.fetchBudgets()
    }
    
    private var totalExpenses: Double {
        transactions.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalIncome: Double {
        transactions.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
    }
    
    private var balance: Double {
        totalIncome - totalExpenses
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header with period selector
                    headerView
                    
                    // Summary cards
                    summaryCardsView
                    
                    // Budget progress
                    if !budgets.isEmpty {
                        budgetProgressView
                    }
                    
                    // Recent transactions
                    recentTransactionsView
                    
                    // Charts
                    chartsView
                }
                .padding()
            }
            .navigationTitle("CrystalBudget")
            .navigationBarTitleDisplayMode(.large)
            .completePullToRefresh {
                await refreshData()
            }
            .sheet(isPresented: $showingQuickAdd) {
                QuickAddView()
            }
        }
        .id(refreshID)
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Добро пожаловать!")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(periodTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingQuickAdd = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.primaryBlue)
                }
            }
            
            // Period selector
            Picker("Период", selection: $selectedPeriod) {
                Text("Этот месяц").tag(DateRange.currentMonth)
                Text("Прошлый месяц").tag(DateRange.lastMonth)
                Text("Этот год").tag(DateRange.currentYear)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private var periodTitle: String {
        switch selectedPeriod {
        case .currentMonth:
            return "Текущий месяц"
        case .lastMonth:
            return "Прошлый месяц"
        case .currentYear:
            return "Текущий год"
        case .custom(let start, let end):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
    }
    
    // MARK: - Summary Cards
    
    private var summaryCardsView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            SummaryCard(
                title: "Баланс",
                amount: balance,
                icon: "wallet.pass.fill",
                color: balance >= 0 ? .successGreen : .dangerRed
            )
            
            SummaryCard(
                title: "Доходы",
                amount: totalIncome,
                icon: "arrow.up.circle.fill",
                color: .successGreen
            )
            
            SummaryCard(
                title: "Расходы",
                amount: totalExpenses,
                icon: "arrow.down.circle.fill",
                color: .dangerRed
            )
            
            SummaryCard(
                title: "Операций",
                amount: Double(transactions.count),
                icon: "list.bullet",
                color: .primaryBlue,
                isCount: true
            )
        }
    }
    
    // MARK: - Budget Progress
    
    private var budgetProgressView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Бюджеты")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink(destination: BudgetsView()) {
                    Text("Все")
                        .font(.subheadline)
                        .foregroundColor(.primaryBlue)
                }
            }
            
            ForEach(budgets.prefix(3), id: \.id) { budget in
                BudgetProgressView(budget: budget, transactions: transactions)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Recent Transactions
    
    private var recentTransactionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Последние операции")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink(destination: TransactionsView()) {
                    Text("Все")
                        .font(.subheadline)
                        .foregroundColor(.primaryBlue)
                }
            }
            
            ForEach(transactions.prefix(5), id: \.id) { transaction in
                TransactionCard(transaction: transaction)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Charts
    
    private var chartsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статистика")
                .font(.headline)
                .fontWeight(.semibold)
            
            ChartsView(transactions: transactions, period: selectedPeriod)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Actions
    
    private func refreshData() async {
        // Simulate network refresh
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            refreshID = UUID()
        }
    }
}

// MARK: - Summary Card
struct SummaryCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    var isCount: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(isCount ? "\(Int(amount))" : formatAmount(amount))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color.secondaryBackground)
        .cornerRadius(8)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: NSNumber(value: amount)) ?? "₽0"
    }
}

// MARK: - Preview
#Preview {
    DashboardView()
        .environmentObject(CoreDataManager.shared)
        .environmentObject(AuthenticationManager())
}
