import SwiftUI
import Charts

struct BudgetsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var showingAddBudget = false
    @State private var selectedPeriod: BudgetPeriod = .monthly
    @State private var refreshID = UUID()
    
    private var budgets: [Budget] {
        coreDataManager.fetchBudgets().filter { $0.period == selectedPeriod.rawValue }
    }
    
    private var transactions: [Transaction] {
        coreDataManager.fetchTransactions(for: .currentMonth)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Budgets list
                if budgets.isEmpty {
                    emptyStateView
                } else {
                    budgetsListView
                }
            }
            .navigationTitle("Бюджеты")
            .navigationBarTitleDisplayMode(.large)
            .completePullToRefresh {
                await refreshData()
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddBudget = true
                    }) {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .id(refreshID)
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Period selector
            Picker("Период", selection: $selectedPeriod) {
                Text("Ежедневно").tag(BudgetPeriod.daily)
                Text("Еженедельно").tag(BudgetPeriod.weekly)
                Text("Ежемесячно").tag(BudgetPeriod.monthly)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Summary
            HStack(spacing: 16) {
                SummaryCard(
                    title: "Всего бюджетов",
                    amount: Double(budgets.count),
                    icon: "chart.pie.fill",
                    color: .primaryBlue,
                    isCount: true
                )
                
                SummaryCard(
                    title: "Потрачено",
                    amount: totalSpent,
                    icon: "arrow.down.circle.fill",
                    color: .dangerRed
                )
                
                SummaryCard(
                    title: "Осталось",
                    amount: totalRemaining,
                    icon: "wallet.pass.fill",
                    color: totalRemaining >= 0 ? .successGreen : .dangerRed
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.secondaryBackground)
    }
    
    // MARK: - Budgets List
    
    private var budgetsListView: some View {
        List {
            ForEach(budgets, id: \.id) { budget in
                BudgetCard(
                    budget: budget,
                    transactions: transactions,
                    onEdit: {
                        // TODO: Show edit sheet
                    },
                    onDelete: {
                        deleteBudget(budget)
                    }
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Нет бюджетов")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Создайте бюджет для отслеживания расходов по категориям")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showingAddBudget = true
            }) {
                Text("Создать бюджет")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.primaryBlue)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.secondaryBackground)
    }
    
    // MARK: - Computed Properties
    
    private var totalSpent: Double {
        budgets.reduce(0) { total, budget in
            let spent = transactions
                .filter { $0.category == budget.category && $0.type == "expense" }
                .reduce(0) { $0 + $1.amount }
            return total + spent
        }
    }
    
    private var totalRemaining: Double {
        let totalLimit = budgets.reduce(0) { $0 + $1.limit }
        return totalLimit - totalSpent
    }
    
    // MARK: - Actions
    
    private func refreshData() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            refreshID = UUID()
        }
    }
    
    private func deleteBudget(_ budget: Budget) {
        coreDataManager.context.delete(budget)
        coreDataManager.save()
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Budget Period
enum BudgetPeriod: String, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
}

// MARK: - Budget Card
struct BudgetCard: View {
    let budget: Budget
    let transactions: [Transaction]
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteConfirmation = false
    
    private var spentAmount: Double {
        transactions
            .filter { $0.category == budget.category && $0.type == "expense" }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var remainingAmount: Double {
        budget.limit - spentAmount
    }
    
    private var progressPercentage: Double {
        guard budget.limit > 0 else { return 0 }
        return min(spentAmount / budget.limit, 1.0)
    }
    
    private var statusColor: Color {
        if progressPercentage >= 1.0 {
            return .dangerRed
        } else if progressPercentage >= 0.8 {
            return .warningOrange
        } else {
            return .successGreen
        }
    }
    
    private var statusText: String {
        if progressPercentage >= 1.0 {
            return "Превышен"
        } else if progressPercentage >= 0.8 {
            return "Почти исчерпан"
        } else {
            return "В норме"
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.category)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(periodText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(statusText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(statusColor)
                    
                    Text(formatAmount(budget.limit))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.secondaryBackground)
                        .frame(height: 12)
                        .cornerRadius(6)
                    
                    Rectangle()
                        .fill(statusColor)
                        .frame(width: geometry.size.width * progressPercentage, height: 12)
                        .cornerRadius(6)
                        .animation(.easeInOut(duration: 0.3), value: progressPercentage)
                }
            }
            .frame(height: 12)
            
            // Amount info
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Потрачено")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(formatAmount(spentAmount))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Осталось")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(formatAmount(remainingAmount))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(remainingAmount >= 0 ? .primary : .dangerRed)
                }
            }
            
            // Actions
            HStack {
                Button(action: onEdit) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Редактировать")
                    }
                    .font(.caption)
                    .foregroundColor(.primaryBlue)
                }
                
                Spacer()
                
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Удалить")
                    }
                    .font(.caption)
                    .foregroundColor(.dangerRed)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .confirmationDialog("Удалить бюджет?", isPresented: $showingDeleteConfirmation) {
            Button("Удалить", role: .destructive) {
                onDelete()
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Этот бюджет будет удален навсегда.")
        }
    }
    
    private var periodText: String {
        switch budget.period {
        case "daily": return "Ежедневно"
        case "weekly": return "Еженедельно"
        case "monthly": return "Ежемесячно"
        default: return budget.period
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: NSNumber(value: amount)) ?? "₽0"
    }
}

// MARK: - Add Budget View
struct AddBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coreDataManager: CoreDataManager
    
    @State private var selectedCategory = ""
    @State private var limit = ""
    @State private var selectedPeriod: BudgetPeriod = .monthly
    @State private var selectedWallet = ""
    @State private var showingCategoryPicker = false
    @State private var showingWalletPicker = false
    
    private var categories: [Category] {
        coreDataManager.fetchCategories()
    }
    
    private var wallets: [Wallet] {
        coreDataManager.fetchWallets()
    }
    
    private var isValid: Bool {
        !selectedCategory.isEmpty && 
        !selectedWallet.isEmpty &&
        Double(limit) != nil &&
        Double(limit)! > 0
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Категория") {
                    Button(action: {
                        showingCategoryPicker = true
                    }) {
                        HStack {
                            Text(selectedCategory.isEmpty ? "Выберите категорию" : selectedCategory)
                                .foregroundColor(selectedCategory.isEmpty ? .secondary : .primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Лимит") {
                    HStack {
                        TextField("0", text: $limit)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("₽")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Период") {
                    Picker("Период", selection: $selectedPeriod) {
                        Text("Ежедневно").tag(BudgetPeriod.daily)
                        Text("Еженедельно").tag(BudgetPeriod.weekly)
                        Text("Ежемесячно").tag(BudgetPeriod.monthly)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Кошелёк") {
                    Button(action: {
                        showingWalletPicker = true
                    }) {
                        HStack {
                            Text(selectedWallet.isEmpty ? "Выберите кошелёк" : selectedWallet)
                                .foregroundColor(selectedWallet.isEmpty ? .secondary : .primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Новый бюджет")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        saveBudget()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(selectedCategory: $selectedCategory)
            }
            .sheet(isPresented: $showingWalletPicker) {
                WalletPickerView(selectedWallet: $selectedWallet)
            }
            .onAppear {
                setupDefaults()
            }
        }
    }
    
    private func setupDefaults() {
        if selectedWallet.isEmpty && !wallets.isEmpty {
            selectedWallet = wallets.first?.name ?? ""
        }
    }
    
    private func saveBudget() {
        guard let limitValue = Double(limit), limitValue > 0 else { return }
        
        coreDataManager.addBudget(
            category: selectedCategory,
            limit: limitValue,
            period: selectedPeriod.rawValue,
            wallet: selectedWallet
        )
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    BudgetsView()
        .environmentObject(CoreDataManager.shared)
}
