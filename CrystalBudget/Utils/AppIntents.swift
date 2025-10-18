import AppIntents
import SwiftUI

// MARK: - Quick Add Intent
struct QuickAddIntent: AppIntent {
    static var title: LocalizedStringResource = "Добавить расход"
    static var description = IntentDescription("Быстро добавляет новый расход в CrystalBudget.")
    
    @Parameter(title: "Сумма", description: "Сумма расхода")
    var amount: Double
    
    @Parameter(title: "Категория", description: "Категория расхода", requestValueDialog: "В какую категорию добавить расход?")
    var category: AppCategory?
    
    @Parameter(title: "Заметка", description: "Краткое описание расхода", requestValueDialog: "Что это был за расход?")
    var note: String?
    
    static var parameterDialog: some ParameterDialog {
        IntentDialog("Добавить расход на \(amount) в категорию \(category ?? "Без категории")")
    }
    
    func perform() async throws -> some IntentResult {
        // Here you would integrate with your CoreData/backend to save the expense
        print("Adding expense: \(amount) to category \(category?.name ?? "N/A") with note: \(note ?? "N/A")")
        
        // Example: Save to CoreData
        // let newExpense = Expense(context: CoreDataManager.shared.container.viewContext)
        // newExpense.amount = amount
        // newExpense.category = category?.name
        // newExpense.note = note
        // newExpense.date = Date()
        // CoreDataManager.shared.saveContext()
        
        return .result(
            dialog: "Расход на \(amount) ₽ успешно добавлен в категорию \(category?.name ?? "Без категории")."
        )
    }
}

// MARK: - Show Balance Intent
struct ShowBalanceIntent: AppIntent {
    static var title: LocalizedStringResource = "Показать остаток"
    static var description = IntentDescription("Показывает текущий остаток по категории или общий баланс в CrystalBudget.")
    
    @Parameter(title: "Категория", description: "Категория, по которой нужно показать остаток", requestValueDialog: "По какой категории показать остаток?")
    var category: AppCategory?
    
    static var parameterDialog: some ParameterDialog {
        IntentDialog("Показать остаток по категории \(category ?? "Общий баланс")")
    }
    
    func perform() async throws -> some IntentResult {
        // Here you would fetch the balance from your CoreData/backend
        let balance: Double
        let categoryName = category?.name ?? "Общий баланс"
        
        // Placeholder for fetching actual balance
        if category != nil {
            balance = Double.random(in: 1000...50000) // Simulate category balance
        } else {
            balance = Double.random(in: 50000...200000) // Simulate total balance
        }
        
        return .result(
            dialog: "Остаток по категории '\(categoryName)' составляет \(balance, specifier: "%.0f") ₽."
        )
    }
}

// MARK: - Check Budget Intent
struct CheckBudgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Проверить бюджет"
    static var description = IntentDescription("Проверяет статус бюджета по категории в CrystalBudget.")
    
    @Parameter(title: "Категория", description: "Категория для проверки бюджета", requestValueDialog: "По какой категории проверить бюджет?")
    var category: AppCategory?
    
    static var parameterDialog: some ParameterDialog {
        IntentDialog("Проверить бюджет по категории \(category ?? "Все категории")")
    }
    
    func perform() async throws -> some IntentResult {
        let categoryName = category?.name ?? "Все категории"
        let spentPercentage = Int.random(in: 0...100)
        
        let status: String
        if spentPercentage >= 100 {
            status = "превышен"
        } else if spentPercentage >= 90 {
            status = "критический"
        } else if spentPercentage >= 70 {
            status = "предупреждение"
        } else {
            status = "нормальный"
        }
        
        return .result(
            dialog: "Бюджет по категории '\(categoryName)' \(status). Потрачено \(spentPercentage)% от лимита."
        )
    }
}

// MARK: - Add Income Intent
struct AddIncomeIntent: AppIntent {
    static var title: LocalizedStringResource = "Добавить доход"
    static var description = IntentDescription("Быстро добавляет новый доход в CrystalBudget.")
    
    @Parameter(title: "Сумма", description: "Сумма дохода")
    var amount: Double
    
    @Parameter(title: "Категория", description: "Категория дохода", requestValueDialog: "В какую категорию добавить доход?")
    var category: AppIncomeCategory?
    
    @Parameter(title: "Заметка", description: "Краткое описание дохода", requestValueDialog: "Что это был за доход?")
    var note: String?
    
    static var parameterDialog: some ParameterDialog {
        IntentDialog("Добавить доход \(amount) в категорию \(category ?? "Без категории")")
    }
    
    func perform() async throws -> some IntentResult {
        print("Adding income: \(amount) to category \(category?.name ?? "N/A") with note: \(note ?? "N/A")")
        
        return .result(
            dialog: "Доход \(amount) ₽ успешно добавлен в категорию \(category?.name ?? "Без категории")."
        )
    }
}

// MARK: - App Category Enum
struct AppCategory: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Категория"
    
    case food
    case transport
    case entertainment
    case housing
    case health
    case education
    case shopping
    case other
    
    static var allCases: [AppCategory] = [.food, .transport, .entertainment, .housing, .health, .education, .shopping, .other]
    
    static var caseDisplayRepresentations: [AppCategory: DisplayRepresentation] = [
        .food: "Еда",
        .transport: "Транспорт",
        .entertainment: "Развлечения",
        .housing: "Жилье",
        .health: "Здоровье",
        .education: "Образование",
        .shopping: "Покупки",
        .other: "Прочее"
    ]
    
    var name: String {
        Self.caseDisplayRepresentations[self]?.title.localizedStringKey ?? "Неизвестно"
    }
}

// MARK: - App Income Category Enum
struct AppIncomeCategory: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Категория дохода"
    
    case salary
    case freelance
    case investment
    case gift
    case other
    
    static var allCases: [AppIncomeCategory] = [.salary, .freelance, .investment, .gift, .other]
    
    static var caseDisplayRepresentations: [AppIncomeCategory: DisplayRepresentation] = [
        .salary: "Зарплата",
        .freelance: "Фриланс",
        .investment: "Инвестиции",
        .gift: "Подарки",
        .other: "Прочее"
    ]
    
    var name: String {
        Self.caseDisplayRepresentations[self]?.title.localizedStringKey ?? "Неизвестно"
    }
}

// MARK: - Configuration App Intent
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")
    
    @Parameter(title: "Favorite Emoji", default: "😀")
    var favoriteEmoji: String
}

// MARK: - App Intent Extensions
extension AppIntent {
    static func registerIntents() {
        // Register all app intents
        QuickAddIntent.register()
        ShowBalanceIntent.register()
        CheckBudgetIntent.register()
        AddIncomeIntent.register()
    }
}

// MARK: - Siri Shortcuts Setup
struct SiriShortcutsManager {
    static func setupShortcuts() {
        // Setup Siri shortcuts for the app
        let shortcuts = [
            QuickAddIntent(),
            ShowBalanceIntent(),
            CheckBudgetIntent(),
            AddIncomeIntent()
        ]
        
        for shortcut in shortcuts {
            // Register shortcut with Siri
            // This would typically be done through the system
        }
    }
}

// MARK: - App Intent Error Handling
enum AppIntentError: Error, LocalizedError {
    case invalidAmount
    case categoryNotFound
    case saveFailed
    case fetchFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Неверная сумма"
        case .categoryNotFound:
            return "Категория не найдена"
        case .saveFailed:
            return "Не удалось сохранить"
        case .fetchFailed:
            return "Не удалось загрузить данные"
        }
    }
}

// MARK: - App Intent Validation
extension AppIntent {
    func validateAmount(_ amount: Double) throws {
        guard amount > 0 else {
            throw AppIntentError.invalidAmount
        }
        
        guard amount <= AppConstants.maxTransactionAmount else {
            throw AppIntentError.invalidAmount
        }
    }
    
    func validateCategory(_ category: String?) throws {
        guard let category = category, !category.isEmpty else {
            throw AppIntentError.categoryNotFound
        }
    }
}

// MARK: - App Intent Helpers
struct AppIntentHelpers {
    static func formatAmount(_ amount: Double) -> String {
        return AppFormatters.currency.string(from: NSNumber(value: amount)) ?? "₽0"
    }
    
    static func formatDate(_ date: Date) -> String {
        return AppFormatters.date.string(from: date)
    }
    
    static func getCategoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "еда", "food":
            return "fork.knife"
        case "транспорт", "transport":
            return "car.fill"
        case "развлечения", "entertainment":
            return "gamecontroller.fill"
        case "жилье", "housing":
            return "house.fill"
        case "здоровье", "health":
            return "cross.fill"
        case "образование", "education":
            return "book.fill"
        case "покупки", "shopping":
            return "bag.fill"
        default:
            return "ellipsis.circle.fill"
        }
    }
}
