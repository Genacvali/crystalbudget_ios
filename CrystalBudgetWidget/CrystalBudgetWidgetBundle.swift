import WidgetKit
import SwiftUI
import CoreData

// MARK: - Widget Bundle
struct CrystalBudgetWidgetBundle: WidgetBundle {
    var body: some Widget {
        CrystalBudgetWidget()
        CrystalBudgetMediumWidget()
        CrystalBudgetLargeWidget()
    }
}

// MARK: - Small Widget
struct CrystalBudgetWidget: Widget {
    let kind: String = "CrystalBudgetWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetTimelineProvider()) { entry in
            CrystalBudgetWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Баланс")
        .description("Показывает текущий баланс")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Medium Widget
struct CrystalBudgetMediumWidget: Widget {
    let kind: String = "CrystalBudgetMediumWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetTimelineProvider()) { entry in
            CrystalBudgetMediumWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Бюджет")
        .description("Показывает баланс и прогресс бюджетов")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Large Widget
struct CrystalBudgetLargeWidget: Widget {
    let kind: String = "CrystalBudgetLargeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetTimelineProvider()) { entry in
            CrystalBudgetLargeWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Обзор")
        .description("Полный обзор финансов")
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - Widget Entry
struct WidgetEntry: TimelineEntry {
    let date: Date
    let balance: Double
    let totalIncome: Double
    let totalExpenses: Double
    let recentTransactions: [WidgetTransaction]
    let budgets: [WidgetBudget]
}

// MARK: - Widget Models
struct WidgetTransaction {
    let category: String
    let amount: Double
    let type: String
    let date: Date
}

struct WidgetBudget {
    let category: String
    let limit: Double
    let spent: Double
    let remaining: Double
}

// MARK: - Timeline Provider
struct WidgetTimelineProvider: TimelineProvider {
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
            ]
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
            ]
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
            ]
        )
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Small Widget View
struct CrystalBudgetWidgetEntryView: View {
    var entry: WidgetTimelineProvider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "wallet.pass.fill")
                    .foregroundColor(.primaryBlue)
                    .font(.caption)
                
                Text("Баланс")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // Balance
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
            
            // Quick action
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
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: NSNumber(value: amount)) ?? "₽0"
    }
}

// MARK: - Medium Widget View
struct CrystalBudgetMediumWidgetEntryView: View {
    var entry: WidgetTimelineProvider.Entry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
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
            }
            
            // Budget progress
            VStack(spacing: 8) {
                ForEach(entry.budgets.prefix(2), id: \.category) { budget in
                    CompactBudgetProgressView(
                        budget: WidgetBudget(category: budget.category, limit: budget.limit, spent: budget.spent, remaining: budget.remaining),
                        spentAmount: budget.spent
                    )
                }
            }
            
            Spacer()
            
            // Quick actions
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
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: NSNumber(value: amount)) ?? "₽0"
    }
}

// MARK: - Large Widget View
struct CrystalBudgetLargeWidgetEntryView: View {
    var entry: WidgetTimelineProvider.Entry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.primaryBlue)
                    .font(.title3)
                
                Text("Обзор финансов")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Summary cards
            HStack(spacing: 8) {
                SummaryCard(
                    title: "Доходы",
                    amount: entry.totalIncome,
                    icon: "arrow.up.circle.fill",
                    color: .successGreen
                )
                
                SummaryCard(
                    title: "Расходы",
                    amount: entry.totalExpenses,
                    icon: "arrow.down.circle.fill",
                    color: .dangerRed
                )
                
                SummaryCard(
                    title: "Баланс",
                    amount: entry.balance,
                    icon: "wallet.pass.fill",
                    color: entry.balance >= 0 ? .successGreen : .dangerRed
                )
            }
            
            // Recent transactions
            VStack(alignment: .leading, spacing: 6) {
                Text("Последние операции")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                ForEach(entry.recentTransactions.prefix(3), id: \.category) { transaction in
                    CompactTransactionView(transaction: transaction)
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
    }
}

// MARK: - Widget Summary Card
struct SummaryCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(formatAmount(amount))
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

// MARK: - Preview
#Preview(as: .systemSmall) {
    CrystalBudgetWidget()
} timeline: {
    WidgetEntry(
        date: Date(),
        balance: 50000,
        totalIncome: 80000,
        totalExpenses: 30000,
        recentTransactions: [],
        budgets: []
    )
}
