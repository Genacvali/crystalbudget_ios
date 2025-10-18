import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    private let center = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        center.delegate = self
        setupNotificationCategories()
    }
    
    func requestPermissions() {
        center.requestAuthorization(options: [.alert, .badge, .sound, .provisional]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
            
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleBudgetAlert(category: String, spentAmount: Double, limit: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Превышение бюджета"
        content.body = "Категория '\(category)' превысила лимит на \(Int((spentAmount - limit)))₽"
        content.sound = .default
        content.categoryIdentifier = "BUDGET_ALERT"
        
        let request = UNNotificationRequest(
            identifier: "budget_\(category)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func scheduleReminderNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Не забудьте внести траты"
        content.body = "Внесите сегодняшние расходы для точного учёта бюджета"
        content.sound = .default
        content.categoryIdentifier = "REMINDER"
        
        // Schedule for tomorrow at 8 PM
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling reminder: \(error)")
            }
        }
    }
    
    func scheduleDigestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Еженедельный отчёт"
        content.body = "Посмотрите статистику ваших расходов за неделю"
        content.sound = .default
        content.categoryIdentifier = "DIGEST"
        
        // Schedule for Sunday at 9 AM
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "weekly_digest",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling digest: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    func getPendingNotifications() {
        center.getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                self.pendingNotifications = requests
            }
        }
    }
    
    private func setupNotificationCategories() {
        let budgetAlertCategory = UNNotificationCategory(
            identifier: "BUDGET_ALERT",
            actions: [
                UNNotificationAction(identifier: "VIEW_BUDGETS", title: "Посмотреть бюджеты", options: []),
                UNNotificationAction(identifier: "ADD_EXPENSE", title: "Добавить расход", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let reminderCategory = UNNotificationCategory(
            identifier: "REMINDER",
            actions: [
                UNNotificationAction(identifier: "ADD_EXPENSE", title: "Добавить расход", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let digestCategory = UNNotificationCategory(
            identifier: "DIGEST",
            actions: [
                UNNotificationAction(identifier: "VIEW_REPORTS", title: "Посмотреть отчёты", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([budgetAlertCategory, reminderCategory, digestCategory])
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        
        switch categoryIdentifier {
        case "BUDGET_ALERT":
            // Navigate to budgets screen
            break
        case "REMINDER":
            // Navigate to quick add screen
            break
        case "DIGEST":
            // Navigate to reports screen
            break
        default:
            break
        }
        
        completionHandler()
    }
}
