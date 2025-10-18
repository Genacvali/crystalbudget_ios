import SwiftUI
import WidgetKit

// MARK: - Widget Pull to Refresh Support
struct WidgetPullToRefreshProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(
            date: Date(),
            balance: 50000,
            totalIncome: 80000,
            totalExpenses: 30000,
            recentTransactions: [
                WidgetTransaction(category: "Еда", amount: 1500, type: "expense", date: Date()),
                WidgetTransaction(category: "Транспорт", amount: 300, type: "expense", date: Date()),
                WidgetTransaction(category: "Зарплата", amount: 80000, type: "income", date: Date())
            ],
            budgets: [
                WidgetBudget(category: "Еда", limit: 20000, spent: 15000, remaining: 5000),
                WidgetBudget(category: "Транспорт", limit: 5000, spent: 3000, remaining: 2000)
            ],
            lastRefreshTime: Date()
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        let entry = WidgetEntry(
            date: Date(),
            balance: 50000,
            totalIncome: 80000,
            totalExpenses: 30000,
            recentTransactions: [
                WidgetTransaction(category: "Еда", amount: 1500, type: "expense", date: Date()),
                WidgetTransaction(category: "Транспорт", amount: 300, type: "expense", date: Date())
            ],
            budgets: [
                WidgetBudget(category: "Еда", limit: 20000, spent: 15000, remaining: 5000)
            ],
            lastRefreshTime: Date()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> ()) {
        let currentDate = Date()
        let entry = WidgetEntry(
            date: currentDate,
            balance: 50000,
            totalIncome: 80000,
            totalExpenses: 30000,
            recentTransactions: [
                WidgetTransaction(category: "Еда", amount: 1500, type: "expense", date: currentDate),
                WidgetTransaction(category: "Транспорт", amount: 300, type: "expense", date: currentDate)
            ],
            budgets: [
                WidgetBudget(category: "Еда", limit: 20000, spent: 15000, remaining: 5000),
                WidgetBudget(category: "Транспорт", limit: 5000, spent: 3000, remaining: 2000)
            ],
            lastRefreshTime: currentDate
        )
        
        // Update every 15 minutes for more frequent refresh
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Enhanced Widget Entry
struct WidgetEntry: TimelineEntry {
    let date: Date
    let balance: Double
    let totalIncome: Double
    let totalExpenses: Double
    let recentTransactions: [WidgetTransaction]
    let budgets: [WidgetBudget]
    let lastRefreshTime: Date?
}

// MARK: - Enhanced Small Widget View
struct EnhancedSmallWidgetView: View {
    var entry: WidgetTimelineProvider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            // Header with refresh indicator
            HStack {
                Image(systemName: "wallet.pass.fill")
                    .foregroundColor(.primaryBlue)
                    .font(.caption)
                
                Text("Баланс")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Refresh indicator
                if let lastRefresh = entry.lastRefreshTime {
                    refreshIndicator(lastRefresh)
                }
            }
            
            // Balance with animation
            VStack(alignment: .leading, spacing: 4) {
                Text(formatAmount(entry.balance))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(entry.balance >= 0 ? .successGreen : .dangerRed)
                
                Text("Текущий месяц")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Quick action with haptic feedback
            Button(intent: QuickAddIntent()) {
                HStack {
                    Image(systemName: "plus")
                        .font(.caption)
                    Text("Добавить")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.primaryBlue)
                .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    private func refreshIndicator(_ lastRefresh: Date) -> some View {
        Group {
            let timeSinceRefresh = Date().timeIntervalSince(lastRefresh)
            
            if timeSinceRefresh < 300 { // Less than 5 minutes
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.successGreen)
            } else if timeSinceRefresh < 900 { // Less than 15 minutes
                Image(systemName: "clock.fill")
                    .font(.caption2)
                    .foregroundColor(.warningOrange)
            } else {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.dangerRed)
            }
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

// MARK: - Enhanced Medium Widget View
struct EnhancedMediumWidgetView: View {
    var entry: WidgetTimelineProvider.Entry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with refresh status
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.primaryBlue)
                    .font(.caption)
                
                Text("Бюджет")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatAmount(entry.balance))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(entry.balance >= 0 ? .successGreen : .dangerRed)
                
                // Refresh status
                if let lastRefresh = entry.lastRefreshTime {
                    refreshStatusIndicator(lastRefresh)
                }
            }
            
            // Budget progress with animations
            VStack(spacing: 8) {
                ForEach(entry.budgets.prefix(2), id: \.category) { budget in
                    AnimatedBudgetProgressView(
                        budget: WidgetBudget(category: budget.category, limit: budget.limit, spent: budget.spent, remaining: budget.remaining),
                        spentAmount: budget.spent
                    )
                }
            }
            
            Spacer()
            
            // Quick actions with haptic feedback
            HStack(spacing: 8) {
                Button(intent: QuickAddIntent()) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.caption)
                        Text("Расход")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.dangerRed)
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(intent: ShowBalanceIntent()) {
                    HStack {
                        Image(systemName: "wallet.pass.fill")
                            .font(.caption)
                        Text("Баланс")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.successGreen)
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    private func refreshStatusIndicator(_ lastRefresh: Date) -> some View {
        Group {
            let timeSinceRefresh = Date().timeIntervalSince(lastRefresh)
            
            if timeSinceRefresh < 300 {
                Circle()
                    .fill(Color.successGreen)
                    .frame(width: 6, height: 6)
            } else if timeSinceRefresh < 900 {
                Circle()
                    .fill(Color.warningOrange)
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .fill(Color.dangerRed)
                    .frame(width: 6, height: 6)
            }
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

// MARK: - Animated Budget Progress View
struct AnimatedBudgetProgressView: View {
    let budget: WidgetBudget
    let spentAmount: Double
    
    @State private var animationProgress: Double = 0
    
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(budget.category)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                Text("\(Int(progressPercentage * 100))%")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(statusColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.secondaryBackground)
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(statusColor)
                        .frame(width: geometry.size.width * animationProgress, height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 0.8), value: animationProgress)
                }
            }
            .frame(height: 4)
            .onAppear {
                animationProgress = progressPercentage
            }
        }
    }
}

// MARK: - Enhanced Large Widget View
struct EnhancedLargeWidgetView: View {
    var entry: WidgetTimelineProvider.Entry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with refresh info
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.primaryBlue)
                    .font(.title3)
                
                Text("Обзор финансов")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Refresh timestamp
                if let lastRefresh = entry.lastRefreshTime {
                    Text(formatRefreshTime(lastRefresh))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Summary cards with animations
            HStack(spacing: 8) {
                AnimatedSummaryCard(
                    title: "Доходы",
                    amount: entry.totalIncome,
                    icon: "arrow.up.circle.fill",
                    color: .successGreen
                )
                
                AnimatedSummaryCard(
                    title: "Расходы",
                    amount: entry.totalExpenses,
                    icon: "arrow.down.circle.fill",
                    color: .dangerRed
                )
                
                AnimatedSummaryCard(
                    title: "Баланс",
                    amount: entry.balance,
                    icon: "wallet.pass.fill",
                    color: entry.balance >= 0 ? .successGreen : .dangerRed
                )
            }
            
            // Recent transactions with animations
            VStack(alignment: .leading, spacing: 6) {
                Text("Последние операции")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                ForEach(entry.recentTransactions.prefix(3), id: \.category) { transaction in
                    AnimatedTransactionView(transaction: transaction)
                }
            }
            
            Spacer()
            
            // Quick actions
            HStack(spacing: 8) {
                Button(intent: QuickAddIntent()) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.caption)
                        Text("Добавить расход")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.primaryBlue)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(intent: ShowBalanceIntent()) {
                    HStack {
                        Image(systemName: "chart.pie.fill")
                            .font(.caption)
                        Text("Бюджеты")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.successGreen)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    private func formatRefreshTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

// MARK: - Animated Summary Card
struct AnimatedSummaryCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    
    @State private var animationAmount: Double = 0
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(formatAmount(animationAmount))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(Color.secondaryBackground)
        .cornerRadius(6)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animationAmount = amount
            }
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

// MARK: - Animated Transaction View
struct AnimatedTransactionView: View {
    let transaction: WidgetTransaction
    
    @State private var animationOffset: CGFloat = 20
    @State private var animationOpacity: Double = 0
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: transaction.type == "income" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .font(.caption)
                .foregroundColor(transaction.type == "income" ? .successGreen : .dangerRed)
            
            Text(transaction.category)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Spacer()
            
            Text(formatAmount(transaction.amount))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(transaction.type == "income" ? .successGreen : .dangerRed)
        }
        .offset(x: animationOffset)
        .opacity(animationOpacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).delay(0.1)) {
                animationOffset = 0
                animationOpacity = 1
            }
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

// MARK: - Widget Colors
extension Color {
    static let primaryBlue = Color(red: 0.05, green: 0.43, blue: 0.99)
    static let successGreen = Color(red: 0.13, green: 0.69, blue: 0.31)
    static let dangerRed = Color(red: 0.86, green: 0.08, blue: 0.24)
    static let warningOrange = Color(red: 1.0, green: 0.65, blue: 0.0)
    static let secondaryBackground = Color(.systemGray6)
}
