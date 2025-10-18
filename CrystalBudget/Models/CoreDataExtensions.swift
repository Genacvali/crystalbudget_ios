import Foundation
import CoreData

// MARK: - CoreData Model Extensions
extension Transaction {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var wallet: String
    @NSManaged public var note: String?
    @NSManaged public var type: String
    @NSManaged public var date: Date
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isSynced: Bool
    @NSManaged public var syncId: String?
    
    convenience init(context: NSManagedObjectContext, amount: Double, category: String, wallet: String, note: String? = nil, type: String, date: Date = Date()) {
        self.init(context: context)
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.wallet = wallet
        self.note = note
        self.type = type
        self.date = date
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isSynced = false
        self.syncId = nil
    }
}

extension Budget {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Budget> {
        return NSFetchRequest<Budget>(entityName: "Budget")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var category: String
    @NSManaged public var limit: Double
    @NSManaged public var period: String
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isSynced: Bool
    @NSManaged public var syncId: String?
    
    convenience init(context: NSManagedObjectContext, category: String, limit: Double, period: String, isActive: Bool = true) {
        self.init(context: context)
        self.id = UUID()
        self.category = category
        self.limit = limit
        self.period = period
        self.isActive = isActive
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isSynced = false
        self.syncId = nil
    }
    
    var spentAmount: Double {
        // Calculate spent amount for current period
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch period {
        case "daily":
            startDate = calendar.startOfDay(for: now)
        case "weekly":
            startDate = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        case "monthly":
            startDate = calendar.dateInterval(of: .month, for: now)?.start ?? now
        case "yearly":
            startDate = calendar.dateInterval(of: .year, for: now)?.start ?? now
        default:
            startDate = calendar.dateInterval(of: .month, for: now)?.start ?? now
        }
        
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@ AND type == %@ AND date >= %@", category, "expense", startDate as NSDate)
        
        do {
            let transactions = try context.fetch(request)
            return transactions.reduce(0) { $0 + $1.amount }
        } catch {
            return 0
        }
    }
    
    var remainingAmount: Double {
        return max(0, limit - spentAmount)
    }
    
    var progressPercentage: Double {
        guard limit > 0 else { return 0 }
        return min(spentAmount / limit, 1.0)
    }
    
    var status: BudgetStatus {
        let progress = progressPercentage
        
        if progress >= 1.0 {
            return .exceeded
        } else if progress >= 0.9 {
            return .danger
        } else if progress >= 0.7 {
            return .warning
        } else {
            return .normal
        }
    }
}

extension Category {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var icon: String
    @NSManaged public var color: String
    @NSManaged public var type: String
    @NSManaged public var isDefault: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isSynced: Bool
    @NSManaged public var syncId: String?
    
    convenience init(context: NSManagedObjectContext, name: String, icon: String, color: String, type: String, isDefault: Bool = false) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.color = color
        self.type = type
        self.isDefault = isDefault
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isSynced = false
        self.syncId = nil
    }
}

extension Wallet {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Wallet> {
        return NSFetchRequest<Wallet>(entityName: "Wallet")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var type: String
    @NSManaged public var balance: Double
    @NSManaged public var isDefault: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isSynced: Bool
    @NSManaged public var syncId: String?
    
    convenience init(context: NSManagedObjectContext, name: String, type: String, balance: Double = 0, isDefault: Bool = false) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.type = type
        self.balance = balance
        self.isDefault = isDefault
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isSynced = false
        self.syncId = nil
    }
}

extension Profile {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Profile> {
        return NSFetchRequest<Profile>(entityName: "Profile")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var email: String?
    @NSManaged public var currency: String
    @NSManaged public var language: String
    @NSManaged public var isOnboardingCompleted: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isSynced: Bool
    @NSManaged public var syncId: String?
    
    convenience init(context: NSManagedObjectContext, name: String, email: String? = nil, currency: String = "RUB", language: String = "ru", isOnboardingCompleted: Bool = false) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.email = email
        self.currency = currency
        self.language = language
        self.isOnboardingCompleted = isOnboardingCompleted
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isSynced = false
        self.syncId = nil
    }
}

// MARK: - CoreData Manager Extensions
extension CoreDataManager {
    func fetchTransactions(for dateRange: DateRange) -> [Transaction] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let interval = dateRange.dateInterval
        
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", interval.start as NSDate, interval.end as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching transactions: \(error)")
            return []
        }
    }
    
    func fetchTransactions(for category: String, type: String? = nil) -> [Transaction] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        
        var predicates: [NSPredicate] = [NSPredicate(format: "category == %@", category)]
        
        if let type = type {
            predicates.append(NSPredicate(format: "type == %@", type))
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching transactions: \(error)")
            return []
        }
    }
    
    func fetchBudgets() -> [Budget] {
        let request: NSFetchRequest<Budget> = Budget.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Budget.category, ascending: true)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching budgets: \(error)")
            return []
        }
    }
    
    func fetchCategories() -> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    func fetchWallets() -> [Wallet] {
        let request: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Wallet.name, ascending: true)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching wallets: \(error)")
            return []
        }
    }
    
    func fetchProfile() -> Profile? {
        let request: NSFetchRequest<Profile> = Profile.fetchRequest()
        request.fetchLimit = 1
        
        do {
            return try container.viewContext.fetch(request).first
        } catch {
            print("Error fetching profile: \(error)")
            return nil
        }
    }
    
    func createDefaultData() {
        let context = container.viewContext
        
        // Create default categories
        let defaultCategories = AppTypes.Category.defaultCategories
        for categoryData in defaultCategories {
            let category = Category(context: context, name: categoryData.name, icon: categoryData.icon, color: categoryData.color, type: categoryData.type.rawValue, isDefault: true)
            context.insert(category)
        }
        
        // Create default wallets
        let defaultWallets = AppTypes.Wallet.defaultWallets
        for walletData in defaultWallets {
            let wallet = Wallet(context: context, name: walletData.name, type: walletData.type.rawValue, balance: walletData.balance, isDefault: walletData.isDefault)
            context.insert(wallet)
        }
        
        // Create default profile
        let profile = Profile(context: context, name: "Пользователь", currency: "RUB", language: "ru", isOnboardingCompleted: false)
        context.insert(profile)
        
        save()
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        container.viewContext.delete(transaction)
        save()
    }
    
    func deleteBudget(_ budget: Budget) {
        container.viewContext.delete(budget)
        save()
    }
    
    func deleteCategory(_ category: Category) {
        container.viewContext.delete(category)
        save()
    }
    
    func deleteWallet(_ wallet: Wallet) {
        container.viewContext.delete(wallet)
        save()
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}

// MARK: - CoreData Model Names
extension NSManagedObject {
    static var entityName: String {
        return String(describing: self)
    }
}

// MARK: - CoreData Error Handling
enum CoreDataError: Error, LocalizedError {
    case saveFailed
    case fetchFailed
    case deleteFailed
    case contextNotFound
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Не удалось сохранить данные"
        case .fetchFailed:
            return "Не удалось загрузить данные"
        case .deleteFailed:
            return "Не удалось удалить данные"
        case .contextNotFound:
            return "Контекст CoreData не найден"
        }
    }
}

// MARK: - CoreData Migration
class CoreDataMigrationManager {
    static func migrateIfNeeded() {
        // Add migration logic here if needed
        // For now, we'll use automatic migration
    }
}
