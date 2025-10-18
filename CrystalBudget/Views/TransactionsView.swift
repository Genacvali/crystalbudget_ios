import SwiftUI
import Charts

struct TransactionsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var searchText = ""
    @State private var selectedFilter: TransactionFilter = .all
    @State private var selectedPeriod: DateRange = .currentMonth
    @State private var showingQuickAdd = false
    @State private var refreshID = UUID()
    
    private var transactions: [Transaction] {
        let allTransactions = coreDataManager.fetchTransactions(for: selectedPeriod)
        
        let filtered = allTransactions.filter { transaction in
            // Search filter
            let matchesSearch = searchText.isEmpty || 
                transaction.category.localizedCaseInsensitiveContains(searchText) ||
                transaction.note?.localizedCaseInsensitiveContains(searchText) == true ||
                transaction.wallet.localizedCaseInsensitiveContains(searchText)
            
            // Type filter
            let matchesType = switch selectedFilter {
            case .all: true
            case .expenses: transaction.type == "expense"
            case .income: transaction.type == "income"
            }
            
            return matchesSearch && matchesType
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    private var totalExpenses: Double {
        transactions.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalIncome: Double {
        transactions.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with stats
                headerView
                
                // Filters
                filtersView
                
                // Transactions list
                if transactions.isEmpty {
                    emptyStateView
                } else {
                    transactionsListView
                }
            }
            .navigationTitle("Операции")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Поиск операций")
            .completePullToRefresh {
                await refreshData()
            }
            .sheet(isPresented: $showingQuickAdd) {
                QuickAddView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingQuickAdd = true
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
        VStack(spacing: 12) {
            // Period selector
            Picker("Период", selection: $selectedPeriod) {
                Text("Этот месяц").tag(DateRange.currentMonth)
                Text("Прошлый месяц").tag(DateRange.lastMonth)
                Text("Этот год").tag(DateRange.currentYear)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Stats
            HStack(spacing: 16) {
                StatCard(
                    title: "Доходы",
                    amount: totalIncome,
                    color: .successGreen,
                    icon: "arrow.up.circle.fill"
                )
                
                StatCard(
                    title: "Расходы",
                    amount: totalExpenses,
                    color: .dangerRed,
                    icon: "arrow.down.circle.fill"
                )
                
                StatCard(
                    title: "Баланс",
                    amount: totalIncome - totalExpenses,
                    color: (totalIncome - totalExpenses) >= 0 ? .successGreen : .dangerRed,
                    icon: "wallet.pass.fill"
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.secondaryBackground)
    }
    
    // MARK: - Filters View
    
    private var filtersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.title,
                        isSelected: selectedFilter == filter,
                        action: {
                            selectedFilter = filter
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Transactions List
    
    private var transactionsListView: some View {
        List {
            ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text(formatSectionDate(date))) {
                    ForEach(groupedTransactions[date] ?? [], id: \.id) { transaction in
                        TransactionListItem(transaction: transaction) {
                            // TODO: Show edit sheet
                        } onDelete: {
                            deleteTransaction(transaction)
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Нет операций")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Добавьте первую операцию, чтобы начать отслеживать свои финансы")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showingQuickAdd = true
            }) {
                Text("Добавить операцию")
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
    
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    // MARK: - Actions
    
    private func refreshData() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            refreshID = UUID()
        }
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        coreDataManager.context.delete(transaction)
        coreDataManager.save()
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func formatSectionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

// MARK: - Transaction Filter
enum TransactionFilter: CaseIterable {
    case all
    case expenses
    case income
    
    var title: String {
        switch self {
        case .all: return "Все"
        case .expenses: return "Расходы"
        case .income: return "Доходы"
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(formatAmount(amount))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.cardBackground)
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

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.primaryBlue : Color.secondaryBackground)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    TransactionsView()
        .environmentObject(CoreDataManager.shared)
}
