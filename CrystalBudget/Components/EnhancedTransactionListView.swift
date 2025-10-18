import SwiftUI

// MARK: - Enhanced Transaction List with Pull to Refresh
struct EnhancedTransactionListView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var searchText = ""
    @State private var selectedFilter: TransactionFilter = .all
    @State private var selectedPeriod: DateRange = .currentMonth
    @State private var refreshID = UUID()
    @State private var isLoading = false
    
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
    
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with stats
            headerView
            
            // Filters
            filtersView
            
            // Transactions list with enhanced pull-to-refresh
            if transactions.isEmpty {
                emptyStateView
            } else {
                transactionsListView
            }
        }
        .pullToRefresh {
            await refreshData()
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
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFilter = filter
                            }
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
                        EnhancedTransactionCard(transaction: transaction) {
                            // TODO: Show edit sheet
                        } onDelete: {
                            deleteTransaction(transaction)
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .overlay(
            // Loading overlay
            Group {
                if isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primaryBlue))
                            .scaleEffect(1.2)
                        
                        Text("Обновляю...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground).opacity(0.8))
                }
            }
        )
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
                // TODO: Show quick add
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
    
    private var totalExpenses: Double {
        transactions.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalIncome: Double {
        transactions.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Actions
    
    private func refreshData() async {
        await MainActor.run {
            isLoading = true
        }
        
        // Simulate network refresh
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        await MainActor.run {
            isLoading = false
            refreshID = UUID()
        }
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        withAnimation(.easeInOut(duration: 0.3)) {
            coreDataManager.context.delete(transaction)
            coreDataManager.save()
        }
        
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

// MARK: - Enhanced Transaction Card

struct EnhancedTransactionCard: View {
    let transaction: Transaction
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteConfirmation = false
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon with animation
            iconView
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(formatDate(transaction.date))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount with animation
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatAmount(transaction.amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.type == "income" ? .successGreen : .dangerRed)
                
                Text(transaction.wallet)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Удалить", role: .destructive) {
                showingDeleteConfirmation = true
            }
            
            Button("Редактировать") {
                onEdit()
            }
            .tint(.primaryBlue)
        }
        .confirmationDialog("Удалить операцию?", isPresented: $showingDeleteConfirmation) {
            Button("Удалить", role: .destructive) {
                onDelete()
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Эта операция будет удалена навсегда.")
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            
            onEdit()
        }
    }
    
    private var iconView: some View {
        ZStack {
            Circle()
                .fill(transaction.type == "income" ? Color.successGreen.opacity(0.1) : Color.dangerRed.opacity(0.1))
                .frame(width: 40, height: 40)
            
            Image(systemName: transaction.type == "income" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .font(.title3)
                .foregroundColor(transaction.type == "income" ? .successGreen : .dangerRed)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: NSNumber(value: amount)) ?? "₽0"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
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
                .font(.title3)
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
    NavigationView {
        EnhancedTransactionListView()
            .environmentObject(CoreDataManager.shared)
            .navigationTitle("Операции")
            .navigationBarTitleDisplayMode(.large)
    }
}
