import Foundation
import AppIntents
import SwiftUI

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
