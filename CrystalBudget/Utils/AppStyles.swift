import SwiftUI

// MARK: - App Colors and Styles
extension Color {
    // Primary colors
    static let primaryBlue = Color(red: 0.05, green: 0.43, blue: 0.99)
    static let primaryBlueDark = Color(red: 0.03, green: 0.35, blue: 0.85)
    
    // Status colors
    static let successGreen = Color(red: 0.13, green: 0.69, blue: 0.31)
    static let successGreenDark = Color(red: 0.10, green: 0.55, blue: 0.25)
    
    static let dangerRed = Color(red: 0.86, green: 0.08, blue: 0.24)
    static let dangerRedDark = Color(red: 0.70, green: 0.06, blue: 0.19)
    
    static let warningOrange = Color(red: 1.0, green: 0.65, blue: 0.0)
    static let warningOrangeDark = Color(red: 0.85, green: 0.55, blue: 0.0)
    
    // Background colors
    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    
    // Text colors
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let tertiaryText = Color(.tertiaryLabel)
    
    // Border colors
    static let borderColor = Color(.separator)
    static let borderColorDark = Color(.opaqueSeparator)
}

// MARK: - App Fonts
extension Font {
    static let appTitle = Font.largeTitle.weight(.bold)
    static let appHeadline = Font.headline.weight(.semibold)
    static let appSubheadline = Font.subheadline.weight(.medium)
    static let appBody = Font.body.weight(.regular)
    static let appCaption = Font.caption.weight(.medium)
    static let appCaption2 = Font.caption2.weight(.medium)
}

// MARK: - App Spacing
extension CGFloat {
    static let appPadding: CGFloat = 16
    static let appPaddingSmall: CGFloat = 8
    static let appPaddingLarge: CGFloat = 24
    
    static let appCornerRadius: CGFloat = 8
    static let appCornerRadiusSmall: CGFloat = 4
    static let appCornerRadiusLarge: CGFloat = 12
    
    static let appBorderWidth: CGFloat = 0.5
    static let appShadowRadius: CGFloat = 5
}

// MARK: - App Animations
extension Animation {
    static let appSpring = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let appEaseInOut = Animation.easeInOut(duration: 0.2)
    static let appEaseInOutSlow = Animation.easeInOut(duration: 0.4)
    static let appBounce = Animation.bouncy(duration: 0.5)
}

// MARK: - App Shadows
extension View {
    func appShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.05), radius: CGFloat.appShadowRadius, x: 0, y: 2)
    }
    
    func appShadowLarge() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: CGFloat.appShadowRadius * 2, x: 0, y: 4)
    }
}

// MARK: - App Card Style
struct AppCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(CGFloat.appPadding)
            .background(Color.cardBackground)
            .cornerRadius(CGFloat.appCornerRadius)
            .appShadow()
    }
}

extension View {
    func appCard() -> some View {
        modifier(AppCardStyle())
    }
}

// MARK: - App Button Style
struct AppButtonStyle: ButtonStyle {
    let color: Color
    let size: ButtonSize
    
    enum ButtonSize {
        case small, medium, large
        
        var padding: EdgeInsets {
            switch self {
            case .small:
                return EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            case .medium:
                return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            case .large:
                return EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
            }
        }
        
        var font: Font {
            switch self {
            case .small:
                return .appCaption
            case .medium:
                return .appSubheadline
            case .large:
                return .appHeadline
            }
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(size.padding)
            .background(color)
            .cornerRadius(CGFloat.appCornerRadiusSmall)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.appEaseInOut, value: configuration.isPressed)
    }
}

extension View {
    func appButton(color: Color = .primaryBlue, size: AppButtonStyle.ButtonSize = .medium) -> some View {
        buttonStyle(AppButtonStyle(color: color, size: size))
    }
}

// MARK: - App Text Field Style
struct AppTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(CGFloat.appPaddingSmall)
            .background(Color.secondaryBackground)
            .cornerRadius(CGFloat.appCornerRadiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: CGFloat.appCornerRadiusSmall)
                    .stroke(Color.borderColor, lineWidth: CGFloat.appBorderWidth)
            )
    }
}

extension View {
    func appTextField() -> some View {
        textFieldStyle(AppTextFieldStyle())
    }
}

// MARK: - App Loading State
struct AppLoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .primaryBlue))
                .scaleEffect(1.2)
            
            Text(message)
                .font(.appSubheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.secondaryBackground)
    }
}

// MARK: - App Error State
struct AppErrorView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.dangerRed)
            
            Text("Произошла ошибка")
                .font(.appHeadline)
                .foregroundColor(.primaryText)
            
            Text(error.localizedDescription)
                .font(.appBody)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Попробовать снова", action: onRetry)
                .appButton(color: .primaryBlue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.secondaryBackground)
    }
}

// MARK: - App Empty State
struct AppEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondaryText)
            
            Text(title)
                .font(.appHeadline)
                .foregroundColor(.primaryText)
            
            Text(message)
                .font(.appBody)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .appButton(color: .primaryBlue)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.secondaryBackground)
    }
}

// MARK: - App Haptic Feedback
struct AppHapticFeedback {
    static func light() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    static func medium() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    static func heavy() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    static func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    static func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    static func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
}

// MARK: - App Constants
struct AppConstants {
    static let refreshThreshold: CGFloat = 70
    static let maxPullDistance: CGFloat = 120
    static let animationDuration: Double = 0.18
    static let completionDuration: Double = 0.8
    
    static let currencyCode = "RUB"
    static let locale = Locale(identifier: "ru_RU")
    
    static let maxRetryAttempts = 3
    static let retryDelay: TimeInterval = 1.0
}

// MARK: - App Formatters
struct AppFormatters {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = AppConstants.currencyCode
        formatter.locale = AppConstants.locale
        return formatter
    }()
    
    static let date: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = AppConstants.locale
        return formatter
    }()
    
    static let dateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = AppConstants.locale
        return formatter
    }()
    
    static let relativeDate: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = AppConstants.locale
        return formatter
    }()
}

// MARK: - App Extensions
extension Double {
    func formattedAsCurrency() -> String {
        return AppFormatters.currency.string(from: NSNumber(value: self)) ?? "₽0"
    }
}

extension Date {
    func formattedAsDate() -> String {
        return AppFormatters.date.string(from: self)
    }
    
    func formattedAsDateTime() -> String {
        return AppFormatters.dateTime.string(from: self)
    }
    
    func formattedAsRelative() -> String {
        return AppFormatters.relativeDate.localizedString(for: self, relativeTo: Date())
    }
}

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

// MARK: - App Environment Values
struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue = AppEnvironment()
}

struct AppEnvironment {
    let isDebug: Bool
    let isPreview: Bool
    
    init() {
        #if DEBUG
        self.isDebug = true
        #else
        self.isDebug = false
        #endif
        
        #if PREVIEW
        self.isPreview = true
        #else
        self.isPreview = false
        #endif
    }
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
