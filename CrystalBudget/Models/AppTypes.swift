import Foundation
import SwiftUI

// MARK: - Transaction Types
enum TransactionType: String, CaseIterable, Codable {
    case income = "income"
    case expense = "expense"
    
    var displayName: String {
        switch self {
        case .income:
            return "Доход"
        case .expense:
            return "Расход"
        }
    }
    
    var icon: String {
        switch self {
        case .income:
            return "arrow.up.circle.fill"
        case .expense:
            return "arrow.down.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .income:
            return .successGreen
        case .expense:
            return .dangerRed
        }
    }
}

// MARK: - Date Range
enum DateRange: String, CaseIterable, Codable {
    case currentMonth = "current_month"
    case lastMonth = "last_month"
    case currentYear = "current_year"
    case lastYear = "last_year"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .currentMonth:
            return "Этот месяц"
        case .lastMonth:
            return "Прошлый месяц"
        case .currentYear:
            return "Этот год"
        case .lastYear:
            return "Прошлый год"
        case .custom:
            return "Выбрать период"
        }
    }
    
    var dateInterval: DateInterval {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .currentMonth:
            return calendar.dateInterval(of: .month, for: now) ?? DateInterval(start: now, end: now)
        case .lastMonth:
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return calendar.dateInterval(of: .month, for: lastMonth) ?? DateInterval(start: lastMonth, end: lastMonth)
        case .currentYear:
            return calendar.dateInterval(of: .year, for: now) ?? DateInterval(start: now, end: now)
        case .lastYear:
            let lastYear = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return calendar.dateInterval(of: .year, for: lastYear) ?? DateInterval(start: lastYear, end: lastYear)
        case .custom:
            return DateInterval(start: now, end: now)
        }
    }
}

// MARK: - Chart Types
enum ChartType: String, CaseIterable, Codable {
    case expensesByCategory = "expenses_by_category"
    case incomeByCategory = "income_by_category"
    case monthlyTrend = "monthly_trend"
    case budgetProgress = "budget_progress"
    case dailySpending = "daily_spending"
    
    var displayName: String {
        switch self {
        case .expensesByCategory:
            return "Расходы по категориям"
        case .incomeByCategory:
            return "Доходы по категориям"
        case .monthlyTrend:
            return "Месячная динамика"
        case .budgetProgress:
            return "Прогресс бюджетов"
        case .dailySpending:
            return "Ежедневные траты"
        }
    }
    
    var icon: String {
        switch self {
        case .expensesByCategory:
            return "chart.pie.fill"
        case .incomeByCategory:
            return "chart.bar.fill"
        case .monthlyTrend:
            return "chart.line.uptrend.xyaxis"
        case .budgetProgress:
            return "chart.bar.xaxis"
        case .dailySpending:
            return "calendar"
        }
    }
}

// MARK: - Transaction Filter
enum TransactionFilter: String, CaseIterable, Codable {
    case all = "all"
    case expenses = "expenses"
    case income = "income"
    
    var displayName: String {
        switch self {
        case .all:
            return "Все"
        case .expenses:
            return "Расходы"
        case .income:
            return "Доходы"
        }
    }
    
    var icon: String {
        switch self {
        case .all:
            return "list.bullet"
        case .expenses:
            return "arrow.down.circle"
        case .income:
            return "arrow.up.circle"
        }
    }
}

// MARK: - Budget Period
enum BudgetPeriod: String, CaseIterable, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .daily:
            return "Ежедневно"
        case .weekly:
            return "Еженедельно"
        case .monthly:
            return "Ежемесячно"
        case .yearly:
            return "Ежегодно"
        }
    }
    
    var icon: String {
        switch self {
        case .daily:
            return "calendar"
        case .weekly:
            return "calendar.badge.clock"
        case .monthly:
            return "calendar.badge.plus"
        case .yearly:
            return "calendar.badge.exclamationmark"
        }
    }
}

// MARK: - Widget Transaction
struct WidgetTransaction: Identifiable, Codable {
    let id = UUID()
    let category: String
    let amount: Double
    let type: String
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case category, amount, type, date
    }
}

// MARK: - Widget Budget
struct WidgetBudget: Identifiable, Codable {
    let id = UUID()
    let category: String
    let limit: Double
    let spent: Double
    let remaining: Double
    
    enum CodingKeys: String, CodingKey {
        case category, limit, spent, remaining
    }
}

// MARK: - Category
struct Category: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String
    let type: TransactionType
    
    enum CodingKeys: String, CodingKey {
        case name, icon, color, type
    }
    
    static let defaultCategories: [Category] = [
        // Income categories
        Category(name: "Зарплата", icon: "briefcase.fill", color: "successGreen", type: .income),
        Category(name: "Фриланс", icon: "laptopcomputer", color: "successGreen", type: .income),
        Category(name: "Инвестиции", icon: "chart.line.uptrend.xyaxis", color: "successGreen", type: .income),
        Category(name: "Подарки", icon: "gift.fill", color: "successGreen", type: .income),
        Category(name: "Прочее", icon: "plus.circle.fill", color: "successGreen", type: .income),
        
        // Expense categories
        Category(name: "Еда", icon: "fork.knife", color: "dangerRed", type: .expense),
        Category(name: "Транспорт", icon: "car.fill", color: "dangerRed", type: .expense),
        Category(name: "Жилье", icon: "house.fill", color: "dangerRed", type: .expense),
        Category(name: "Развлечения", icon: "gamecontroller.fill", color: "dangerRed", type: .expense),
        Category(name: "Здоровье", icon: "cross.fill", color: "dangerRed", type: .expense),
        Category(name: "Образование", icon: "book.fill", color: "dangerRed", type: .expense),
        Category(name: "Покупки", icon: "bag.fill", color: "dangerRed", type: .expense),
        Category(name: "Прочее", icon: "ellipsis.circle.fill", color: "dangerRed", type: .expense)
    ]
}

// MARK: - Wallet
struct Wallet: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let type: WalletType
    let balance: Double
    let isDefault: Bool
    
    enum WalletType: String, CaseIterable, Codable {
        case cash = "cash"
        case card = "card"
        case bank = "bank"
        case crypto = "crypto"
        
        var displayName: String {
            switch self {
            case .cash:
                return "Наличные"
            case .card:
                return "Карта"
            case .bank:
                return "Банк"
            case .crypto:
                return "Криптовалюта"
            }
        }
        
        var icon: String {
            switch self {
            case .cash:
                return "banknote.fill"
            case .card:
                return "creditcard.fill"
            case .bank:
                return "building.columns.fill"
            case .crypto:
                return "bitcoinsign.circle.fill"
            }
        }
    }
    
    static let defaultWallets: [Wallet] = [
        Wallet(name: "Основной", type: .card, balance: 0, isDefault: true),
        Wallet(name: "Наличные", type: .cash, balance: 0, isDefault: false),
        Wallet(name: "Сбережения", type: .bank, balance: 0, isDefault: false)
    ]
}

// MARK: - Budget Status
enum BudgetStatus: String, CaseIterable, Codable {
    case normal = "normal"
    case warning = "warning"
    case danger = "danger"
    case exceeded = "exceeded"
    
    var displayName: String {
        switch self {
        case .normal:
            return "Норма"
        case .warning:
            return "Предупреждение"
        case .danger:
            return "Опасность"
        case .exceeded:
            return "Превышен"
        }
    }
    
    var color: Color {
        switch self {
        case .normal:
            return .successGreen
        case .warning:
            return .warningOrange
        case .danger:
            return .dangerRed
        case .exceeded:
            return .dangerRed
        }
    }
    
    var threshold: Double {
        switch self {
        case .normal:
            return 0.0
        case .warning:
            return 0.7
        case .danger:
            return 0.9
        case .exceeded:
            return 1.0
        }
    }
}

// MARK: - Sync Status
enum SyncStatus: String, CaseIterable, Codable {
    case idle = "idle"
    case syncing = "syncing"
    case success = "success"
    case error = "error"
    
    var displayName: String {
        switch self {
        case .idle:
            return "Готов"
        case .syncing:
            return "Синхронизация"
        case .success:
            return "Успешно"
        case .error:
            return "Ошибка"
        }
    }
    
    var icon: String {
        switch self {
        case .idle:
            return "checkmark.circle"
        case .syncing:
            return "arrow.clockwise"
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .idle:
            return .secondaryText
        case .syncing:
            return .primaryBlue
        case .success:
            return .successGreen
        case .error:
            return .dangerRed
        }
    }
}

// MARK: - App State
enum AppState: String, CaseIterable, Codable {
    case onboarding = "onboarding"
    case authenticated = "authenticated"
    case locked = "locked"
    case error = "error"
    
    var displayName: String {
        switch self {
        case .onboarding:
            return "Онбординг"
        case .authenticated:
            return "Аутентифицирован"
        case .locked:
            return "Заблокирован"
        case .error:
            return "Ошибка"
        }
    }
}

// MARK: - Notification Types
enum NotificationType: String, CaseIterable, Codable {
    case budgetWarning = "budget_warning"
    case budgetExceeded = "budget_exceeded"
    case dailyReminder = "daily_reminder"
    case weeklyReport = "weekly_report"
    case monthlyReport = "monthly_report"
    
    var displayName: String {
        switch self {
        case .budgetWarning:
            return "Предупреждение о бюджете"
        case .budgetExceeded:
            return "Превышение бюджета"
        case .dailyReminder:
            return "Ежедневное напоминание"
        case .weeklyReport:
            return "Еженедельный отчет"
        case .monthlyReport:
            return "Ежемесячный отчет"
        }
    }
    
    var icon: String {
        switch self {
        case .budgetWarning:
            return "exclamationmark.triangle.fill"
        case .budgetExceeded:
            return "exclamationmark.octagon.fill"
        case .dailyReminder:
            return "bell.fill"
        case .weeklyReport:
            return "chart.bar.fill"
        case .monthlyReport:
            return "calendar.badge.clock"
        }
    }
}

// MARK: - Export Format
enum ExportFormat: String, CaseIterable, Codable {
    case csv = "csv"
    case json = "json"
    case pdf = "pdf"
    
    var displayName: String {
        switch self {
        case .csv:
            return "CSV"
        case .json:
            return "JSON"
        case .pdf:
            return "PDF"
        }
    }
    
    var fileExtension: String {
        return rawValue
    }
    
    var mimeType: String {
        switch self {
        case .csv:
            return "text/csv"
        case .json:
            return "application/json"
        case .pdf:
            return "application/pdf"
        }
    }
}

// MARK: - App Constants
struct AppConstants {
    static let maxTransactionAmount: Double = 1_000_000
    static let minTransactionAmount: Double = 0.01
    static let maxBudgetAmount: Double = 10_000_000
    static let minBudgetAmount: Double = 1.0
    
    static let maxCategoryNameLength: Int = 50
    static let maxWalletNameLength: Int = 50
    static let maxNoteLength: Int = 500
    
    static let defaultCurrency = "RUB"
    static let supportedCurrencies = ["RUB", "USD", "EUR", "GBP"]
    
    static let syncInterval: TimeInterval = 300 // 5 minutes
    static let backgroundSyncInterval: TimeInterval = 900 // 15 minutes
    
    static let maxRetryAttempts = 3
    static let retryDelay: TimeInterval = 1.0
}
