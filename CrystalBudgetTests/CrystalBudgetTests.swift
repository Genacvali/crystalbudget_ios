import XCTest
@testable import CrystalBudget

final class CrystalBudgetTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    var context: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        // Create in-memory Core Data stack for testing
        coreDataManager = CoreDataManager()
        context = coreDataManager.context
    }
    
    override func tearDownWithError() throws {
        coreDataManager = nil
        context = nil
    }
    
    // MARK: - Transaction Tests
    
    func testAddTransaction() throws {
        // Given
        let amount = 1500.0
        let category = "Еда"
        let wallet = "Основной"
        let note = "Обед в кафе"
        let type = "expense"
        
        // When
        coreDataManager.addTransaction(
            amount: amount,
            category: category,
            wallet: wallet,
            note: note,
            type: type
        )
        
        // Then
        let transactions = coreDataManager.fetchTransactions()
        XCTAssertEqual(transactions.count, 1)
        
        let transaction = transactions.first!
        XCTAssertEqual(transaction.amount, amount)
        XCTAssertEqual(transaction.category, category)
        XCTAssertEqual(transaction.wallet, wallet)
        XCTAssertEqual(transaction.note, note)
        XCTAssertEqual(transaction.type, type)
    }
    
    func testAddIncomeTransaction() throws {
        // Given
        let amount = 80000.0
        let category = "Зарплата"
        let wallet = "Основной"
        let type = "income"
        
        // When
        coreDataManager.addTransaction(
            amount: amount,
            category: category,
            wallet: wallet,
            type: type
        )
        
        // Then
        let transactions = coreDataManager.fetchTransactions()
        XCTAssertEqual(transactions.count, 1)
        
        let transaction = transactions.first!
        XCTAssertEqual(transaction.type, "income")
        XCTAssertEqual(transaction.amount, amount)
    }
    
    // MARK: - Budget Tests
    
    func testAddBudget() throws {
        // Given
        let category = "Еда"
        let limit = 20000.0
        let period = "monthly"
        let wallet = "Основной"
        
        // When
        coreDataManager.addBudget(
            category: category,
            limit: limit,
            period: period,
            wallet: wallet
        )
        
        // Then
        let budgets = coreDataManager.fetchBudgets()
        XCTAssertEqual(budgets.count, 1)
        
        let budget = budgets.first!
        XCTAssertEqual(budget.category, category)
        XCTAssertEqual(budget.limit, limit)
        XCTAssertEqual(budget.period, period)
        XCTAssertEqual(budget.wallet, wallet)
        XCTAssertTrue(budget.isActive)
    }
    
    func testBudgetProgressCalculation() throws {
        // Given
        let category = "Еда"
        let limit = 20000.0
        
        // Add budget
        coreDataManager.addBudget(
            category: category,
            limit: limit,
            period: "monthly",
            wallet: "Основной"
        )
        
        // Add expenses
        coreDataManager.addTransaction(
            amount: 5000.0,
            category: category,
            wallet: "Основной",
            type: "expense"
        )
        
        coreDataManager.addTransaction(
            amount: 3000.0,
            category: category,
            wallet: "Основной",
            type: "expense"
        )
        
        // When
        let budgets = coreDataManager.fetchBudgets()
        let transactions = coreDataManager.fetchTransactions()
        
        let budget = budgets.first!
        let spentAmount = transactions
            .filter { $0.category == budget.category && $0.type == "expense" }
            .reduce(0) { $0 + $1.amount }
        
        // Then
        XCTAssertEqual(spentAmount, 8000.0)
        XCTAssertEqual(budget.limit - spentAmount, 12000.0)
    }
    
    // MARK: - Wallet Tests
    
    func testAddWallet() throws {
        // Given
        let name = "Основной"
        let balance = 50000.0
        let currency = "RUB"
        
        // When
        coreDataManager.addWallet(
            name: name,
            balance: balance,
            currency: currency
        )
        
        // Then
        let wallets = coreDataManager.fetchWallets()
        XCTAssertEqual(wallets.count, 1)
        
        let wallet = wallets.first!
        XCTAssertEqual(wallet.name, name)
        XCTAssertEqual(wallet.balance, balance)
        XCTAssertEqual(wallet.currency, currency)
        XCTAssertFalse(wallet.isDefault)
    }
    
    func testAddDefaultWallet() throws {
        // Given
        let name = "Основной"
        
        // When
        coreDataManager.addWallet(name: name)
        
        // Then
        let wallets = coreDataManager.fetchWallets()
        XCTAssertEqual(wallets.count, 1)
        
        let wallet = wallets.first!
        XCTAssertEqual(wallet.name, name)
        XCTAssertEqual(wallet.balance, 0)
        XCTAssertEqual(wallet.currency, "RUB")
    }
    
    // MARK: - Category Tests
    
    func testAddCategory() throws {
        // Given
        let name = "Еда"
        let icon = "fork.knife"
        let color = "#FF6B6B"
        
        // When
        coreDataManager.addCategory(
            name: name,
            icon: icon,
            color: color
        )
        
        // Then
        let categories = coreDataManager.fetchCategories()
        XCTAssertEqual(categories.count, 1)
        
        let category = categories.first!
        XCTAssertEqual(category.name, name)
        XCTAssertEqual(category.icon, icon)
        XCTAssertEqual(category.color, color)
        XCTAssertFalse(category.isDefault)
    }
    
    // MARK: - Date Range Tests
    
    func testCurrentMonthDateRange() throws {
        // Given
        let dateRange = DateRange.currentMonth
        let calendar = Calendar.current
        
        // When
        let start = dateRange.start
        let end = dateRange.end
        
        // Then
        let now = Date()
        let expectedStart = calendar.dateInterval(of: .month, for: now)?.start
        let expectedEnd = calendar.dateInterval(of: .month, for: now)?.end
        
        XCTAssertEqual(start, expectedStart)
        XCTAssertEqual(end, expectedEnd)
    }
    
    func testLastMonthDateRange() throws {
        // Given
        let dateRange = DateRange.lastMonth
        let calendar = Calendar.current
        
        // When
        let start = dateRange.start
        let end = dateRange.end
        
        // Then
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let expectedStart = calendar.dateInterval(of: .month, for: lastMonth)?.start
        let expectedEnd = calendar.dateInterval(of: .month, for: lastMonth)?.end
        
        XCTAssertEqual(start, expectedStart)
        XCTAssertEqual(end, expectedEnd)
    }
    
    // MARK: - Demo Data Tests
    
    func testCreateDemoData() throws {
        // When
        coreDataManager.createDemoData()
        
        // Then
        let wallets = coreDataManager.fetchWallets()
        let categories = coreDataManager.fetchCategories()
        let transactions = coreDataManager.fetchTransactions()
        let budgets = coreDataManager.fetchBudgets()
        
        XCTAssertGreaterThan(wallets.count, 0)
        XCTAssertGreaterThan(categories.count, 0)
        XCTAssertGreaterThan(transactions.count, 0)
        XCTAssertGreaterThan(budgets.count, 0)
        
        // Check if default wallet exists
        let defaultWallet = wallets.first { $0.isDefault }
        XCTAssertNotNil(defaultWallet)
        
        // Check if default categories exist
        let defaultCategories = categories.filter { $0.isDefault }
        XCTAssertGreaterThan(defaultCategories.count, 0)
    }
    
    // MARK: - Performance Tests
    
    func testTransactionFetchPerformance() throws {
        // Given
        coreDataManager.createDemoData()
        
        // When
        measure {
            _ = coreDataManager.fetchTransactions()
        }
    }
    
    func testBudgetCalculationPerformance() throws {
        // Given
        coreDataManager.createDemoData()
        let transactions = coreDataManager.fetchTransactions()
        let budgets = coreDataManager.fetchBudgets()
        
        // When
        measure {
            for budget in budgets {
                let spentAmount = transactions
                    .filter { $0.category == budget.category && $0.type == "expense" }
                    .reduce(0) { $0 + $1.amount }
                _ = budget.limit - spentAmount
            }
        }
    }
}
