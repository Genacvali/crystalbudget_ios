import XCTest

final class CrystalBudgetUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Onboarding Tests
    
    func testOnboardingFlow() throws {
        // Check if onboarding is displayed
        XCTAssertTrue(app.staticTexts["Добро пожаловать в CrystalBudget"].exists)
        
        // Navigate through onboarding pages
        for _ in 0..<3 {
            XCTAssertTrue(app.buttons["Далее"].exists)
            app.buttons["Далее"].tap()
        }
        
        // Complete onboarding
        XCTAssertTrue(app.buttons["Начать использовать"].exists)
        app.buttons["Начать использовать"].tap()
        
        // Check if main app is displayed
        XCTAssertTrue(app.navigationBars["CrystalBudget"].exists)
    }
    
    func testSkipOnboarding() throws {
        // Skip onboarding
        XCTAssertTrue(app.buttons["Пропустить"].exists)
        app.buttons["Пропустить"].tap()
        
        // Check if main app is displayed
        XCTAssertTrue(app.navigationBars["CrystalBudget"].exists)
    }
    
    // MARK: - Main Navigation Tests
    
    func testTabNavigation() throws {
        // Complete onboarding first
        completeOnboarding()
        
        // Test each tab
        let tabs = ["Главная", "Операции", "Бюджеты", "Отчёты", "Профиль"]
        
        for tab in tabs {
            app.tabBars.buttons[tab].tap()
            XCTAssertTrue(app.navigationBars[tab].exists)
        }
    }
    
    func testFABButton() throws {
        // Complete onboarding first
        completeOnboarding()
        
        // Test FAB button
        XCTAssertTrue(app.buttons["plus"].exists)
        app.buttons["plus"].tap()
        
        // Check if quick add sheet is presented
        XCTAssertTrue(app.navigationBars["Добавить операцию"].exists)
        
        // Dismiss sheet
        app.buttons["Отмена"].tap()
    }
    
    // MARK: - Quick Add Tests
    
    func testQuickAddExpense() throws {
        // Complete onboarding first
        completeOnboarding()
        
        // Open quick add
        app.buttons["plus"].tap()
        
        // Fill form
        let amountField = app.textFields.firstMatch
        amountField.tap()
        amountField.typeText("1500")
        
        // Select category
        app.buttons["Выберите категорию"].tap()
        app.buttons["Еда"].tap()
        
        // Select wallet
        app.buttons["Выберите кошелёк"].tap()
        app.buttons["Основной"].tap()
        
        // Add note
        let noteField = app.textFields.element(boundBy: 1)
        noteField.tap()
        noteField.typeText("Обед в кафе")
        
        // Save
        app.buttons["Сохранить"].tap()
        
        // Check if transaction was added
        app.tabBars.buttons["Операции"].tap()
        XCTAssertTrue(app.staticTexts["Еда"].exists)
        XCTAssertTrue(app.staticTexts["₽1,500.00"].exists)
    }
    
    func testQuickAddIncome() throws {
        // Complete onboarding first
        completeOnboarding()
        
        // Open quick add
        app.buttons["plus"].tap()
        
        // Change to income
        app.segmentedControls.firstMatch.buttons["Доход"].tap()
        
        // Fill form
        let amountField = app.textFields.firstMatch
        amountField.tap()
        amountField.typeText("80000")
        
        // Select category
        app.buttons["Выберите категорию"].tap()
        app.buttons["Зарплата"].tap()
        
        // Select wallet
        app.buttons["Выберите кошелёк"].tap()
        app.buttons["Основной"].tap()
        
        // Save
        app.buttons["Сохранить"].tap()
        
        // Check if transaction was added
        app.tabBars.buttons["Операции"].tap()
        XCTAssertTrue(app.staticTexts["Зарплата"].exists)
        XCTAssertTrue(app.staticTexts["₽80,000.00"].exists)
    }
    
    // MARK: - Dashboard Tests
    
    func testDashboardSummaryCards() throws {
        // Complete onboarding first
        completeOnboarding()
        
        // Check if summary cards are displayed
        XCTAssertTrue(app.staticTexts["Баланс"].exists)
        XCTAssertTrue(app.staticTexts["Доходы"].exists)
        XCTAssertTrue(app.staticTexts["Расходы"].exists)
        XCTAssertTrue(app.staticTexts["Операций"].exists)
    }
    
    func testDashboardPeriodSelector() throws {
        // Complete onboarding first
        completeOnboarding()
        
        // Test period selector
        XCTAssertTrue(app.segmentedControls.firstMatch.exists)
        
        // Change period
        app.segmentedControls.firstMatch.buttons["Прошлый месяц"].tap()
        app.segmentedControls.firstMatch.buttons["Этот год"].tap()
        app.segmentedControls.firstMatch.buttons["Этот месяц"].tap()
    }
    
    // MARK: - Transactions Tests
    
    func testTransactionsList() throws {
        // Complete onboarding first
        completeOnboarding()
        
        // Navigate to transactions
        app.tabBars.buttons["Операции"].tap()
        
        // Check if transactions are displayed
        XCTAssertTrue(app.staticTexts["Операции"].exists)
        
        // Test filters
        XCTAssertTrue(app.buttons["Все"].exists)
        XCTAssertTrue(app.buttons["Расходы"].exists)
        XCTAssertTrue(app.buttons["Доходы"].exists)
    }
    
    func testTransactionSwipeActions() throws {
        // Complete onboarding first
        completeOnboarding()
        
        // Navigate to transactions
        app.tabBars.buttons["Операции"].tap()
        
        // Swipe on transaction
        let transaction = app.cells.firstMatch
        if transaction.exists {
            transaction.swipeLeft()
            
            // Check if swipe actions are displayed
            XCTAssertTrue(app.buttons["Удалить"].exists)
            XCTAssertTrue(app.buttons["Редактировать"].exists)
        }
    }
    
    // MARK: - Budgets Tests
    
    func testBudgetsList() throws {
        // Complete onboarding first
        completeOnboarding()
        
        // Navigate to budgets
        app.tabBars.buttons["Бюджеты"].tap()
        
        // Check if budgets are displayed
        XCTAssertTrue(app.staticTexts["Бюджеты"].exists)
        
        // Test period selector
        XCTAssertTrue(app.segmentedControls.firstMatch.exists)
    }
    
    func testAddBudget() throws {
        // Complete onboarding first
        completeOnboarding()
        
        // Navigate to budgets
        app.tabBars.buttons["Бюджеты"].tap()
        
        // Add new budget
        app.buttons["plus"].tap()
        
        // Fill form
        app.buttons["Выберите категорию"].tap()
        app.buttons["Еда"].tap()
        
        let limitField = app.textFields.firstMatch
        limitField.tap()
        limitField.typeText("20000")
        
        app.buttons["Выберите кошелёк"].tap()
        app.buttons["Основной"].tap()
        
        // Save
        app.buttons["Создать"].tap()
        
        // Check if budget was added
        XCTAssertTrue(app.staticTexts["Еда"].exists)
        XCTAssertTrue(app.staticTexts["₽20,000.00"].exists)
    }
    
    // MARK: - Reports Tests
    
    func testReportsCharts() throws {
        // Complete onboarding first
        completeOnboarding()
        
        // Navigate to reports
        app.tabBars.buttons["Отчёты"].tap()
        
        // Check if reports are displayed
        XCTAssertTrue(app.staticTexts["Отчёты"].exists)
        
        // Test chart selector
        XCTAssertTrue(app.scrollViews.firstMatch.exists)
    }
    
    // MARK: - Profile Tests
    
    func testProfileSettings() throws {
        // Complete onboarding first
        completeOnboarding()
        
        // Navigate to profile
        app.tabBars.buttons["Профиль"].tap()
        
        // Check if profile is displayed
        XCTAssertTrue(app.staticTexts["Профиль"].exists)
        
        // Test settings navigation
        app.buttons["Настройки"].tap()
        XCTAssertTrue(app.navigationBars["Настройки"].exists)
        
        // Go back
        app.buttons["Готово"].tap()
    }
    
    // MARK: - Search Tests
    
    func testSearchTransactions() throws {
        // Complete onboarding first
        completeOnboarding()
        
        // Navigate to transactions
        app.tabBars.buttons["Операции"].tap()
        
        // Test search
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("Еда")
        
        // Clear search
        app.buttons["Clear text"].tap()
    }
    
    // MARK: - Pull to Refresh Tests
    
    func testPullToRefresh() throws {
        // Complete onboarding first
        completeOnboarding()
        
        // Test pull to refresh on dashboard
        let scrollView = app.scrollViews.firstMatch
        scrollView.pullToRefresh()
        
        // Test pull to refresh on transactions
        app.tabBars.buttons["Операции"].tap()
        let tableView = app.tables.firstMatch
        tableView.pullToRefresh()
    }
    
    // MARK: - Helper Methods
    
    private func completeOnboarding() {
        // Skip onboarding if it's displayed
        if app.buttons["Пропустить"].exists {
            app.buttons["Пропустить"].tap()
        } else if app.buttons["Начать использовать"].exists {
            app.buttons["Начать использовать"].tap()
        }
    }
}
