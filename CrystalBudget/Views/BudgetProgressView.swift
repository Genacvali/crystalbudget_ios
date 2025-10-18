import SwiftUI

struct BudgetProgressView: View {
    let budget: Budget
    let transactions: [Transaction]
    
    private var spentAmount: Double {
        transactions
            .filter { $0.category == budget.category && $0.type == "expense" }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var remainingAmount: Double {
        budget.limit - spentAmount
    }
    
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
    
    private var statusText: String {
        if progressPercentage >= 1.0 {
            return "Превышен"
        } else if progressPercentage >= 0.8 {
            return "Почти исчерпан"
        } else {
            return "В норме"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(budget.category)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(statusText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(statusColor)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.secondaryBackground)
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    // Progress
                    Rectangle()
                        .fill(statusColor)
                        .frame(width: geometry.size.width * progressPercentage, height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 0.3), value: progressPercentage)
                }
            }
            .frame(height: 8)
            
            // Amount info
            HStack {
                Text("Потрачено: \(formatAmount(spentAmount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Осталось: \(formatAmount(remainingAmount))")
                    .font(.caption)
                    .foregroundColor(remainingAmount >= 0 ? .secondary : .dangerRed)
            }
            
            // Limit info
            Text("Лимит: \(formatAmount(budget.limit))")
                .font(.caption2)
                .foregroundColor(.secondary)
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

// MARK: - Compact Budget Progress (for widgets)
struct CompactBudgetProgressView: View {
    let budget: Budget
    let spentAmount: Double
    
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
                        .frame(width: geometry.size.width * progressPercentage, height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        BudgetProgressView(
            budget: Budget(context: PersistenceController.shared.container.viewContext, 
                          category: "Еда", 
                          limit: 20000, 
                          period: "monthly", 
                          wallet: "Основной"),
            transactions: []
        )
        
        CompactBudgetProgressView(
            budget: Budget(context: PersistenceController.shared.container.viewContext, 
                          category: "Транспорт", 
                          limit: 5000, 
                          period: "monthly", 
                          wallet: "Основной"),
            spentAmount: 4000
        )
    }
    .padding()
}
