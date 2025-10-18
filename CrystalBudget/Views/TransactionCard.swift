import SwiftUI

struct TransactionCard: View {
    let transaction: Transaction
    @State private var showingDeleteConfirmation = false
    @EnvironmentObject var coreDataManager: CoreDataManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
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
            
            // Amount
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
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Удалить", role: .destructive) {
                showingDeleteConfirmation = true
            }
            
            Button("Редактировать") {
                // TODO: Show edit sheet
            }
            .tint(.primaryBlue)
        }
        .confirmationDialog("Удалить операцию?", isPresented: $showingDeleteConfirmation) {
            Button("Удалить", role: .destructive) {
                deleteTransaction()
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Эта операция будет удалена навсегда.")
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
    
    private func deleteTransaction() {
        coreDataManager.context.delete(transaction)
        coreDataManager.save()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
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

// MARK: - Transaction List Item (for lists)
struct TransactionListItem: View {
    let transaction: Transaction
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    
    init(transaction: Transaction, onEdit: (() -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.transaction = transaction
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            iconView
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category)
                    .font(.body)
                    .fontWeight(.medium)
                
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    Text(formatDate(transaction.date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(transaction.wallet)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Amount
            Text(formatAmount(transaction.amount))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(transaction.type == "income" ? .successGreen : .dangerRed)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit?()
        }
    }
    
    private var iconView: some View {
        ZStack {
            Circle()
                .fill(transaction.type == "income" ? Color.successGreen.opacity(0.1) : Color.dangerRed.opacity(0.1))
                .frame(width: 36, height: 36)
            
            Image(systemName: transaction.type == "income" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .font(.callout)
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

// MARK: - Compact Transaction (for widgets)
struct CompactTransactionView: View {
    let transaction: Transaction
    
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
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: NSNumber(value: amount)) ?? "₽0"
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        TransactionCard(
            transaction: Transaction(context: PersistenceController.shared.container.viewContext, 
                                  amount: 1500, 
                                  category: "Еда", 
                                  wallet: "Основной", 
                                  note: "Обед в кафе", 
                                  type: "expense")
        )
        
        TransactionListItem(
            transaction: Transaction(context: PersistenceController.shared.container.viewContext, 
                                   amount: 80000, 
                                   category: "Зарплата", 
                                   wallet: "Основной", 
                                   note: "Зарплата за месяц", 
                                   type: "income")
        )
        
        CompactTransactionView(
            transaction: Transaction(context: PersistenceController.shared.container.viewContext, 
                                   amount: 300, 
                                   category: "Транспорт", 
                                   wallet: "Основной", 
                                   type: "expense")
        )
    }
    .padding()
    .environmentObject(CoreDataManager.shared)
}
