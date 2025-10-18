import CoreData
import Foundation

// MARK: - Core Data Model
@objc(Transaction)
public class Transaction: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var wallet: String
    @NSManaged public var note: String?
    @NSManaged public var date: Date
    @NSManaged public var type: String // "expense" or "income"
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isSynced: Bool
    @NSManaged public var syncId: String?
    
    convenience init(context: NSManagedObjectContext, 
                   amount: Double, 
                   category: String, 
                   wallet: String, 
                   note: String? = nil, 
                   date: Date = Date(), 
                   type: String) {
        self.init(context: context)
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.wallet = wallet
        self.note = note
        self.date = date
        self.type = type
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isSynced = false
    }
}

@objc(Budget)
public class Budget: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var category: String
    @NSManaged public var limit: Double
    @NSManaged public var period: String // "monthly", "weekly", "daily"
    @NSManaged public var wallet: String
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isSynced: Bool
    @NSManaged public var syncId: String?
    
    convenience init(context: NSManagedObjectContext, 
                   category: String, 
                   limit: Double, 
                   period: String, 
                   wallet: String) {
        self.init(context: context)
        self.id = UUID()
        self.category = category
        self.limit = limit
        self.period = period
        self.wallet = wallet
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isSynced = false
    }
}

@objc(Wallet)
public class Wallet: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var balance: Double
    @NSManaged public var currency: String
    @NSManaged public var isDefault: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isSynced: Bool
    @NSManaged public var syncId: String?
    
    convenience init(context: NSManagedObjectContext, 
                   name: String, 
                   balance: Double = 0, 
                   currency: String = "RUB") {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.balance = balance
        self.currency = currency
        self.isDefault = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isSynced = false
    }
}

@objc(Category)
public class Category: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var icon: String
    @NSManaged public var color: String
    @NSManaged public var isDefault: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isSynced: Bool
    @NSManaged public var syncId: String?
    
    convenience init(context: NSManagedObjectContext, 
                   name: String, 
                   icon: String, 
                   color: String) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.color = color
        self.isDefault = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isSynced = false
    }
}

@objc(SyncQueue)
public class SyncQueue: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var entityType: String
    @NSManaged public var entityId: String
    @NSManaged public var action: String // "create", "update", "delete"
    @NSManaged public var data: Data?
    @NSManaged public var createdAt: Date
    @NSManaged public var retryCount: Int32
    @NSManaged public var lastRetryAt: Date?
    
    convenience init(context: NSManagedObjectContext, 
                   entityType: String, 
                   entityId: String, 
                   action: String, 
                   data: Data? = nil) {
        self.init(context: context)
        self.id = UUID()
        self.entityType = entityType
        self.entityId = entityId
        self.action = action
        self.data = data
        self.createdAt = Date()
        self.retryCount = 0
    }
}

// MARK: - Core Data Manager
class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "CrystalBudget")
        context = container.viewContext
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data error: \(error)")
            }
        }
        
        context.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - CRUD Operations
    
    func save() {
        do {
            try context.save()
        } catch {
            print("Save error: \(error)")
        }
    }
    
    func addTransaction(amount: Double, category: String, wallet: String, note: String? = nil, type: String) {
        let transaction = Transaction(context: context, 
                                    amount: amount, 
                                    category: category, 
                                    wallet: wallet, 
                                    note: note, 
                                    type: type)
        
        // Add to sync queue
        addToSyncQueue(entityType: "Transaction", entityId: transaction.id.uuidString, action: "create")
        
        save()
    }
    
    func addBudget(category: String, limit: Double, period: String, wallet: String) {
        let budget = Budget(context: context, 
                          category: category, 
                          limit: limit, 
                          period: period, 
                          wallet: wallet)
        
        addToSyncQueue(entityType: "Budget", entityId: budget.id.uuidString, action: "create")
        
        save()
    }
    
    func addWallet(name: String, balance: Double = 0, currency: String = "RUB") {
        let wallet = Wallet(context: context, 
                          name: name, 
                          balance: balance, 
                          currency: currency)
        
        addToSyncQueue(entityType: "Wallet", entityId: wallet.id.uuidString, action: "create")
        
        save()
    }
    
    func addCategory(name: String, icon: String, color: String) {
        let category = Category(context: context, 
                             name: name, 
                             icon: icon, 
                             color: color)
        
        addToSyncQueue(entityType: "Category", entityId: category.id.uuidString, action: "create")
        
        save()
    }
    
    // MARK: - Fetch Requests
    
    func fetchTransactions(for period: DateRange = .currentMonth) -> [Transaction] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", 
                                       period.start as NSDate, 
                                       period.end as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    func fetchBudgets() -> [Budget] {
        let request: NSFetchRequest<Budget> = Budget.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    func fetchWallets() -> [Wallet] {
        let request: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    func fetchCategories() -> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    func fetchSyncQueue() -> [SyncQueue] {
        let request: NSFetchRequest<SyncQueue> = SyncQueue.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SyncQueue.createdAt, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    // MARK: - Sync Queue Management
    
    private func addToSyncQueue(entityType: String, entityId: String, action: String, data: Data? = nil) {
        let syncItem = SyncQueue(context: context, 
                               entityType: entityType, 
                               entityId: entityId, 
                               action: action, 
                               data: data)
    }
    
    func removeFromSyncQueue(_ item: SyncQueue) {
        context.delete(item)
        save()
    }
    
    // MARK: - Demo Data
    
    func createDemoData() {
        // Create default wallet
        let wallet = Wallet(context: context, name: "Основной", balance: 50000, currency: "RUB")
        wallet.isDefault = true
        
        // Create default categories
        let categories = [
            ("Еда", "fork.knife", "#FF6B6B"),
            ("Транспорт", "car.fill", "#4ECDC4"),
            ("Развлечения", "gamecontroller.fill", "#45B7D1"),
            ("Покупки", "bag.fill", "#96CEB4"),
            ("Здоровье", "heart.fill", "#FFEAA7"),
            ("Образование", "book.fill", "#DDA0DD"),
            ("Дом", "house.fill", "#98D8C8"),
            ("Другое", "ellipsis.circle.fill", "#F7DC6F")
        ]
        
        for (name, icon, color) in categories {
            let category = Category(context: context, name: name, icon: icon, color: color)
            category.isDefault = true
        }
        
        // Create sample transactions
        let sampleTransactions = [
            (1500.0, "Еда", "Основной", "Обед в кафе", "expense"),
            (300.0, "Транспорт", "Основной", "Такси", "expense"),
            (2500.0, "Покупки", "Основной", "Одежда", "expense"),
            (80000.0, "Зарплата", "Основной", "Зарплата за месяц", "income")
        ]
        
        for (amount, category, wallet, note, type) in sampleTransactions {
            let transaction = Transaction(context: context, 
                                       amount: amount, 
                                       category: category, 
                                       wallet: wallet, 
                                       note: note, 
                                       type: type)
        }
        
        // Create sample budgets
        let sampleBudgets = [
            ("Еда", 20000.0, "monthly", "Основной"),
            ("Транспорт", 5000.0, "monthly", "Основной"),
            ("Развлечения", 10000.0, "monthly", "Основной")
        ]
        
        for (category, limit, period, wallet) in sampleBudgets {
            let budget = Budget(context: context, 
                              category: category, 
                              limit: limit, 
                              period: period, 
                              wallet: wallet)
        }
        
        save()
    }
}

// MARK: - Date Range Helper
enum DateRange {
    case currentMonth
    case lastMonth
    case currentYear
    case custom(start: Date, end: Date)
    
    var start: Date {
        switch self {
        case .currentMonth:
            return Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
        case .lastMonth:
            let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            return Calendar.current.dateInterval(of: .month, for: lastMonth)?.start ?? Date()
        case .currentYear:
            return Calendar.current.dateInterval(of: .year, for: Date())?.start ?? Date()
        case .custom(let start, _):
            return start
        }
    }
    
    var end: Date {
        switch self {
        case .currentMonth:
            return Calendar.current.dateInterval(of: .month, for: Date())?.end ?? Date()
        case .lastMonth:
            let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            return Calendar.current.dateInterval(of: .month, for: lastMonth)?.end ?? Date()
        case .currentYear:
            return Calendar.current.dateInterval(of: .year, for: Date())?.end ?? Date()
        case .custom(_, let end):
            return end
        }
    }
}
