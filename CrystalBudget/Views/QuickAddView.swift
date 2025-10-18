import SwiftUI
import Charts

struct QuickAddView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coreDataManager: CoreDataManager
    
    @State private var amount = ""
    @State private var selectedCategory = ""
    @State private var selectedWallet = ""
    @State private var note = ""
    @State private var selectedDate = Date()
    @State private var transactionType: TransactionType = .expense
    @State private var showingCategoryPicker = false
    @State private var showingWalletPicker = false
    @State private var showingReceiptScanner = false
    
    private var categories: [Category] {
        coreDataManager.fetchCategories()
    }
    
    private var wallets: [Wallet] {
        coreDataManager.fetchWallets()
    }
    
    private var isValid: Bool {
        !amount.isEmpty && 
        !selectedCategory.isEmpty && 
        !selectedWallet.isEmpty &&
        Double(amount) != nil &&
        Double(amount)! > 0
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Transaction type
                Section {
                    Picker("Тип операции", selection: $transactionType) {
                        Text("Расход").tag(TransactionType.expense)
                        Text("Доход").tag(TransactionType.income)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Amount
                Section("Сумма") {
                    HStack {
                        TextField("0", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("₽")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Category
                Section("Категория") {
                    Button(action: {
                        showingCategoryPicker = true
                    }) {
                        HStack {
                            Text(selectedCategory.isEmpty ? "Выберите категорию" : selectedCategory)
                                .foregroundColor(selectedCategory.isEmpty ? .secondary : .primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Wallet
                Section("Кошелёк") {
                    Button(action: {
                        showingWalletPicker = true
                    }) {
                        HStack {
                            Text(selectedWallet.isEmpty ? "Выберите кошелёк" : selectedWallet)
                                .foregroundColor(selectedWallet.isEmpty ? .secondary : .primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Note
                Section("Заметка") {
                    TextField("Описание операции", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Date
                Section("Дата") {
                    DatePicker("Дата операции", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }
                
                // Quick actions
                Section("Быстрые действия") {
                    Button(action: {
                        showingReceiptScanner = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.primaryBlue)
                            
                            Text("Сканировать чек")
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Добавить операцию")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveTransaction()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(selectedCategory: $selectedCategory)
            }
            .sheet(isPresented: $showingWalletPicker) {
                WalletPickerView(selectedWallet: $selectedWallet)
            }
            .sheet(isPresented: $showingReceiptScanner) {
                ReceiptScannerView { receiptData in
                    processReceiptData(receiptData)
                }
            }
            .onAppear {
                setupDefaults()
            }
        }
    }
    
    private func setupDefaults() {
        if selectedWallet.isEmpty && !wallets.isEmpty {
            selectedWallet = wallets.first?.name ?? ""
        }
        
        if selectedCategory.isEmpty && !categories.isEmpty {
            selectedCategory = categories.first?.name ?? ""
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        coreDataManager.addTransaction(
            amount: amountValue,
            category: selectedCategory,
            wallet: selectedWallet,
            note: note.isEmpty ? nil : note,
            type: transactionType.rawValue
        )
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        dismiss()
    }
    
    private func processReceiptData(_ receiptData: ReceiptData) {
        amount = String(receiptData.amount)
        selectedCategory = receiptData.category
        note = receiptData.description
        selectedDate = receiptData.date
    }
}

// MARK: - Transaction Type
enum TransactionType: String, CaseIterable {
    case expense = "expense"
    case income = "income"
}

// MARK: - Category Picker
struct CategoryPickerView: View {
    @Binding var selectedCategory: String
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coreDataManager: CoreDataManager
    
    private var categories: [Category] {
        coreDataManager.fetchCategories()
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.id) { category in
                    Button(action: {
                        selectedCategory = category.name
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(Color(hex: category.color))
                                .frame(width: 24)
                            
                            Text(category.name)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedCategory == category.name {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primaryBlue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Выберите категорию")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Wallet Picker
struct WalletPickerView: View {
    @Binding var selectedWallet: String
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coreDataManager: CoreDataManager
    
    private var wallets: [Wallet] {
        coreDataManager.fetchWallets()
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(wallets, id: \.id) { wallet in
                    Button(action: {
                        selectedWallet = wallet.name
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "wallet.pass.fill")
                                .foregroundColor(.primaryBlue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading) {
                                Text(wallet.name)
                                    .foregroundColor(.primary)
                                
                                Text(formatAmount(wallet.balance))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedWallet == wallet.name {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primaryBlue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Выберите кошелёк")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
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

// MARK: - Receipt Data Model
struct ReceiptData {
    let amount: Double
    let category: String
    let description: String
    let date: Date
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview {
    QuickAddView()
        .environmentObject(CoreDataManager.shared)
}
