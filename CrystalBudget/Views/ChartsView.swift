import SwiftUI
import Charts

struct ReportsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var selectedPeriod: DateRange = .currentMonth
    @State private var selectedChart: ChartType = .expensesByCategory
    @State private var refreshID = UUID()
    
    private var transactions: [Transaction] {
        coreDataManager.fetchTransactions(for: selectedPeriod)
    }
    
    private var budgets: [Budget] {
        coreDataManager.fetchBudgets()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Period selector
                    periodSelectorView
                    
                    // Chart selector
                    chartSelectorView
                    
                    // Selected chart
                    selectedChartView
                    
                    // Summary cards
                    summaryCardsView
                    
                    // Category breakdown
                    categoryBreakdownView
                }
                .padding()
            }
            .navigationTitle("Отчёты")
            .navigationBarTitleDisplayMode(.large)
            .completePullToRefresh {
                await refreshData()
            }
        }
        .id(refreshID)
    }
    
    // MARK: - Period Selector
    
    private var periodSelectorView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Период")
                .font(.headline)
                .fontWeight(.semibold)
            
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
    
    // MARK: - Chart Selector
    
    private var chartSelectorView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("График")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ChartType.allCases, id: \.self) { chartType in
                        ChartTypeChip(
                            title: chartType.title,
                            icon: chartType.icon,
                            isSelected: selectedChart == chartType,
                            action: {
                                selectedChart = chartType
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Selected Chart
    
    private var selectedChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: selectedChart.icon)
                    .foregroundColor(.primaryBlue)
                
                Text(selectedChart.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            ChartsView(transactions: transactions, period: selectedPeriod, chartType: selectedChart)
                .frame(height: 300)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Summary Cards
    
    private var summaryCardsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Сводка")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
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
                    title: "Баланс",
                    amount: balance,
                    icon: "wallet.pass.fill",
                    color: balance >= 0 ? .successGreen : .dangerRed
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
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Category Breakdown
    
    private var categoryBreakdownView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Расходы по категориям")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(categoryBreakdown, id: \.category) { item in
                CategoryBreakdownRow(
                    category: item.category,
                    amount: item.amount,
                    percentage: item.percentage,
                    color: item.color
                )
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Computed Properties
    
    private var totalIncome: Double {
        transactions.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpenses: Double {
        transactions.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
    }
    
    private var balance: Double {
        totalIncome - totalExpenses
    }
    
    private var categoryBreakdown: [CategoryBreakdown] {
        let expenseTransactions = transactions.filter { $0.type == "expense" }
        let grouped = Dictionary(grouping: expenseTransactions) { $0.category }
        
        return grouped.map { category, transactions in
            let amount = transactions.reduce(0) { $0 + $1.amount }
            let percentage = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0
            
            return CategoryBreakdown(
                category: category,
                amount: amount,
                percentage: percentage,
                color: Color.random
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    // MARK: - Actions
    
    private func refreshData() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            refreshID = UUID()
        }
    }
}

// MARK: - Chart Type
enum ChartType: CaseIterable {
    case expensesByCategory
    case expensesByDay
    case incomeVsExpenses
    case budgetProgress
    
    var title: String {
        switch self {
        case .expensesByCategory: return "Расходы по категориям"
        case .expensesByDay: return "Расходы по дням"
        case .incomeVsExpenses: return "Доходы vs Расходы"
        case .budgetProgress: return "Прогресс бюджетов"
        }
    }
    
    var icon: String {
        switch self {
        case .expensesByCategory: return "chart.pie.fill"
        case .expensesByDay: return "chart.line.uptrend.xyaxis"
        case .incomeVsExpenses: return "chart.bar.fill"
        case .budgetProgress: return "chart.bar.xaxis"
        }
    }
}

// MARK: - Category Breakdown
struct CategoryBreakdown {
    let category: String
    let amount: Double
    let percentage: Double
    let color: Color
}

// MARK: - Chart Type Chip
struct ChartTypeChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .primaryBlue)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.primaryBlue : Color.secondaryBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Category Breakdown Row
struct CategoryBreakdownRow: View {
    let category: String
    let amount: Double
    let percentage: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            // Category name
            Text(category)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            // Percentage
            Text("\(Int(percentage))%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .trailing)
            
            // Amount
            Text(formatAmount(amount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .frame(width: 80, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: NSNumber(value: amount)) ?? "₽0"
    }
}

// MARK: - Charts View
struct ChartsView: View {
    let transactions: [Transaction]
    let period: DateRange
    var chartType: ChartType = .expensesByCategory
    
    var body: some View {
        Group {
            switch chartType {
            case .expensesByCategory:
                ExpensesByCategoryChart(transactions: transactions)
            case .expensesByDay:
                ExpensesByDayChart(transactions: transactions, period: period)
            case .incomeVsExpenses:
                IncomeVsExpensesChart(transactions: transactions)
            case .budgetProgress:
                BudgetProgressChart(transactions: transactions)
            }
        }
    }
}

// MARK: - Individual Charts

struct ExpensesByCategoryChart: View {
    let transactions: [Transaction]
    
    private var chartData: [ChartData] {
        let expenseTransactions = transactions.filter { $0.type == "expense" }
        let grouped = Dictionary(grouping: expenseTransactions) { $0.category }
        
        return grouped.map { category, transactions in
            let amount = transactions.reduce(0) { $0 + $1.amount }
            return ChartData(name: category, value: amount)
        }.sorted { $0.value > $1.value }
    }
    
    var body: some View {
        Chart(chartData, id: \.name) { data in
            SectorMark(
                angle: .value("Amount", data.value),
                innerRadius: .ratio(0.5),
                angularInset: 2
            )
            .foregroundStyle(Color.random)
        }
        .chartLegend(position: .bottom)
    }
}

struct ExpensesByDayChart: View {
    let transactions: [Transaction]
    let period: DateRange
    
    private var chartData: [ChartData] {
        let expenseTransactions = transactions.filter { $0.type == "expense" }
        let calendar = Calendar.current
        let startDate = period.start
        let endDate = period.end
        
        var data: [ChartData] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let dayTransactions = expenseTransactions.filter { 
                calendar.isDate($0.date, inSameDayAs: currentDate)
            }
            let amount = dayTransactions.reduce(0) { $0 + $1.amount }
            
            data.append(ChartData(
                name: DateFormatter.dayFormatter.string(from: currentDate),
                value: amount
            ))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate
        }
        
        return data
    }
    
    var body: some View {
        Chart(chartData, id: \.name) { data in
            LineMark(
                x: .value("Day", data.name),
                y: .value("Amount", data.value)
            )
            .foregroundStyle(.primaryBlue)
            .interpolationMethod(.catmullRom)
            
            AreaMark(
                x: .value("Day", data.name),
                y: .value("Amount", data.value)
            )
            .foregroundStyle(.primaryBlue.opacity(0.3))
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
    }
}

struct IncomeVsExpensesChart: View {
    let transactions: [Transaction]
    
    private var chartData: [ChartData] {
        let income = transactions.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
        let expenses = transactions.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
        
        return [
            ChartData(name: "Доходы", value: income),
            ChartData(name: "Расходы", value: expenses)
        ]
    }
    
    var body: some View {
        Chart(chartData, id: \.name) { data in
            BarMark(
                x: .value("Type", data.name),
                y: .value("Amount", data.value)
            )
            .foregroundStyle(data.name == "Доходы" ? .successGreen : .dangerRed)
        }
    }
}

struct BudgetProgressChart: View {
    let transactions: [Transaction]
    
    private var chartData: [ChartData] {
        // This would need access to budgets, simplified for demo
        return [
            ChartData(name: "Еда", value: 15000),
            ChartData(name: "Транспорт", value: 3000),
            ChartData(name: "Развлечения", value: 8000)
        ]
    }
    
    var body: some View {
        Chart(chartData, id: \.name) { data in
            BarMark(
                x: .value("Category", data.name),
                y: .value("Amount", data.value)
            )
            .foregroundStyle(.primaryBlue)
        }
    }
}

// MARK: - Chart Data
struct ChartData {
    let name: String
    let value: Double
}

// MARK: - Extensions
extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter
    }()
}

extension Color {
    static var random: Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

// MARK: - Preview
#Preview {
    ReportsView()
        .environmentObject(CoreDataManager.shared)
}
