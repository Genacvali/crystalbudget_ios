import WidgetKit
import SwiftUI

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
