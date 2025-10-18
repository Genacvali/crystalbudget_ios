import Foundation
import AppIntents
import SwiftUI

// MARK: - Add Expense Intent
@available(iOS 16.0, *)
struct AddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Добавить расход"
    static var description = IntentDescription("Добавляет новый расход в CrystalBudget")
    
    @Parameter(title: "Сумма")
    var amount: Double
    
    @Parameter(title: "Категория")
    var category: String
    
    @Parameter(title: "Описание")
    var description: String?
    
    @Parameter(title: "Кошелёк")
    var wallet: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Добавить расход \(\.$amount)₽ в категорию \(\.$category)")
    }
    
    func perform() async throws -> some IntentResult {
        // Add expense to Core Data
        let context = PersistenceController.shared.container.viewContext
        
        let transaction = Transaction(context: context, 
                                   amount: amount, 
                                   category: category, 
                                   wallet: wallet, 
                                   note: description, 
                                   type: "expense")
        
        try context.save()
        
        return .result()
    }
}

// MARK: - Show Balance Intent
@available(iOS 16.0, *)
struct ShowBalanceIntent: AppIntent {
    static var title: LocalizedStringResource = "Показать баланс"
    static var description = IntentDescription("Показывает текущий баланс в CrystalBudget")
    
    @Parameter(title: "Кошелёк")
    var wallet: String?
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let context = PersistenceController.shared.container.viewContext
        
        // Calculate balance
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let transactions = try context.fetch(request)
        
        let income = transactions.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
        let expenses = transactions.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
        let balance = income - expenses
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        formatter.locale = Locale(identifier: "ru_RU")
        
        let balanceString = formatter.string(from: NSNumber(value: balance)) ?? "₽0"
        
        return .result(value: "Ваш баланс: \(balanceString)")
    }
}

// MARK: - Add Income Intent
@available(iOS 16.0, *)
struct AddIncomeIntent: AppIntent {
    static var title: LocalizedStringResource = "Добавить доход"
    static var description = IntentDescription("Добавляет новый доход в CrystalBudget")
    
    @Parameter(title: "Сумма")
    var amount: Double
    
    @Parameter(title: "Источник")
    var source: String
    
    @Parameter(title: "Описание")
    var description: String?
    
    @Parameter(title: "Кошелёк")
    var wallet: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Добавить доход \(\.$amount)₽ от \(\.$source)")
    }
    
    func perform() async throws -> some IntentResult {
        let context = PersistenceController.shared.container.viewContext
        
        let transaction = Transaction(context: context, 
                                   amount: amount, 
                                   category: source, 
                                   wallet: wallet, 
                                   note: description, 
                                   type: "income")
        
        try context.save()
        
        return .result()
    }
}

// MARK: - Check Budget Intent
@available(iOS 16.0, *)
struct CheckBudgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Проверить бюджет"
    static var description = IntentDescription("Проверяет состояние бюджета по категории")
    
    @Parameter(title: "Категория")
    var category: String
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let context = PersistenceController.shared.container.viewContext
        
        // Get budget for category
        let budgetRequest: NSFetchRequest<Budget> = Budget.fetchRequest()
        budgetRequest.predicate = NSPredicate(format: "category == %@", category)
        let budgets = try context.fetch(budgetRequest)
        
        guard let budget = budgets.first else {
            return .result(value: "Бюджет для категории '\(category)' не найден")
        }
        
        // Get expenses for category
        let transactionRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        transactionRequest.predicate = NSPredicate(format: "category == %@ AND type == %@", category, "expense")
        let transactions = try context.fetch(transactionRequest)
        
        let spentAmount = transactions.reduce(0) { $0 + $1.amount }
        let remainingAmount = budget.limit - spentAmount
        let percentage = budget.limit > 0 ? (spentAmount / budget.limit) * 100 : 0
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        formatter.locale = Locale(identifier: "ru_RU")
        
        let spentString = formatter.string(from: NSNumber(value: spentAmount)) ?? "₽0"
        let remainingString = formatter.string(from: NSNumber(value: remainingAmount)) ?? "₽0"
        
        var status = ""
        if percentage >= 100 {
            status = "Превышен"
        } else if percentage >= 80 {
            status = "Почти исчерпан"
        } else {
            status = "В норме"
        }
        
        return .result(value: "Бюджет '\(category)': потрачено \(spentString), осталось \(remainingString) (\(Int(percentage))%). Статус: \(status)")
    }
}

// MARK: - Quick Add Intent
@available(iOS 16.0, *)
struct QuickAddIntent: AppIntent {
    static var title: LocalizedStringResource = "Быстро добавить расход"
    static var description = IntentDescription("Быстро добавляет расход с автоматической категоризацией")
    
    @Parameter(title: "Сумма")
    var amount: Double
    
    @Parameter(title: "Описание")
    var description: String?
    
    func perform() async throws -> some IntentResult {
        let context = PersistenceController.shared.container.viewContext
        
        // Simple category detection based on description
        let category = detectCategory(from: description ?? "")
        
        // Get default wallet
        let walletRequest: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        walletRequest.predicate = NSPredicate(format: "isDefault == YES")
        let wallets = try context.fetch(walletRequest)
        let wallet = wallets.first?.name ?? "Основной"
        
        let transaction = Transaction(context: context, 
                                   amount: amount, 
                                   category: category, 
                                   wallet: wallet, 
                                   note: description, 
                                   type: "expense")
        
        try context.save()
        
        return .result()
    }
    
    private func detectCategory(from description: String) -> String {
        let lowercased = description.lowercased()
        
        if lowercased.contains("еда") || lowercased.contains("кафе") || lowercased.contains("ресторан") || lowercased.contains("продукт") {
            return "Еда"
        } else if lowercased.contains("транспорт") || lowercased.contains("такси") || lowercased.contains("автобус") || lowercased.contains("метро") {
            return "Транспорт"
        } else if lowercased.contains("магазин") || lowercased.contains("покупк") || lowercased.contains("одежд") {
            return "Покупки"
        } else if lowercased.contains("аптек") || lowercased.contains("лекарств") || lowercased.contains("здоровье") {
            return "Здоровье"
        } else {
            return "Другое"
        }
    }
}

// MARK: - Intent Configuration
@available(iOS 16.0, *)
struct CrystalBudgetAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddExpenseIntent(),
            phrases: [
                "Добавить расход в \(.applicationName)",
                "Записать трату в \(.applicationName)",
                "Потратил \(.amount) в \(.applicationName)"
            ],
            shortTitle: "Добавить расход",
            systemImageName: "minus.circle.fill"
        )
        
        AppShortcut(
            intent: ShowBalanceIntent(),
            phrases: [
                "Показать баланс в \(.applicationName)",
                "Сколько денег в \(.applicationName)",
                "Мой баланс в \(.applicationName)"
            ],
            shortTitle: "Показать баланс",
            systemImageName: "wallet.pass.fill"
        )
        
        AppShortcut(
            intent: AddIncomeIntent(),
            phrases: [
                "Добавить доход в \(.applicationName)",
                "Получил \(.amount) в \(.applicationName)",
                "Записать доход в \(.applicationName)"
            ],
            shortTitle: "Добавить доход",
            systemImageName: "plus.circle.fill"
        )
        
        AppShortcut(
            intent: CheckBudgetIntent(),
            phrases: [
                "Проверить бюджет в \(.applicationName)",
                "Сколько осталось в \(.category) в \(.applicationName)",
                "Статус бюджета в \(.applicationName)"
            ],
            shortTitle: "Проверить бюджет",
            systemImageName: "chart.pie.fill"
        )
        
        AppShortcut(
            intent: QuickAddIntent(),
            phrases: [
                "Быстро добавить \(.amount) в \(.applicationName)",
                "Потратил \(.amount) на \(.description) в \(.applicationName)"
            ],
            shortTitle: "Быстро добавить",
            systemImageName: "bolt.fill"
        )
    }
}

// MARK: - Intent Donations
class IntentDonationManager {
    static let shared = IntentDonationManager()
    
    private init() {}
    
    @available(iOS 16.0, *)
    func donateAddExpenseIntent(amount: Double, category: String, wallet: String) {
        let intent = AddExpenseIntent()
        intent.amount = amount
        intent.category = category
        intent.wallet = wallet
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                print("Error donating intent: \(error)")
            }
        }
    }
    
    @available(iOS 16.0, *)
    func donateShowBalanceIntent() {
        let intent = ShowBalanceIntent()
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                print("Error donating intent: \(error)")
            }
        }
    }
    
    @available(iOS 16.0, *)
    func donateCheckBudgetIntent(category: String) {
        let intent = CheckBudgetIntent()
        intent.category = category
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                print("Error donating intent: \(error)")
            }
        }
    }
}
