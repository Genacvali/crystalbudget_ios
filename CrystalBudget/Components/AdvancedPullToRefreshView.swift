import SwiftUI

// MARK: - Advanced Pull to Refresh Component
struct AdvancedPullToRefreshView<Content: View>: View {
    let content: Content
    let onRefresh: () async -> Void
    
    @State private var isRefreshing = false
    @State private var pullOffset: CGFloat = 0
    @State private var refreshTriggered = false
    @State private var showCompletionMessage = false
    @State private var lastRefreshTime: Date?
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    
    private let refreshThreshold: CGFloat = 70
    private let maxPullDistance: CGFloat = 120
    private let animationDuration: Double = 0.18
    private let completionDuration: Double = 0.8
    
    init(@ViewBuilder content: () -> Content, onRefresh: @escaping () async -> Void) {
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Pull to refresh header
                    pullToRefreshHeader
                        .frame(height: max(0, pullOffset))
                        .opacity(pullOffset > 0 ? 1 : 0)
                        .clipped()
                    
                    content
                }
                .background(
                    GeometryReader { scrollGeometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, 
                                      value: scrollGeometry.frame(in: .named("scroll")).minY)
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                handleScrollOffset(value)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Pull to refresh")
            .accessibilityValue(refreshStatusText)
            .accessibilityHint("Pull down to refresh content")
            .accessibilityAddTraits(.updatesFrequently)
        }
        .animation(.spring(response: animationDuration, dampingFraction: 0.8), value: pullOffset)
        .animation(.easeInOut(duration: animationDuration), value: isRefreshing)
        .animation(.easeInOut(duration: animationDuration), value: showCompletionMessage)
    }
    
    // MARK: - Pull to Refresh Header
    
    private var pullToRefreshHeader: some View {
        VStack(spacing: 12) {
            Spacer()
            
            // Main refresh indicator
            refreshIndicatorContainer
            
            // Status text with animation
            statusTextContainer
            
            // Last refresh time (if available)
            if let lastRefresh = lastRefreshTime {
                lastRefreshText(lastRefresh)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(headerBackground)
        .overlay(
            // Subtle gradient overlay
            LinearGradient(
                colors: [
                    Color(.systemBackground).opacity(0.8),
                    Color(.systemBackground).opacity(0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Refresh Indicator Container
    
    private var refreshIndicatorContainer: some View {
        ZStack {
            // Background circle (appears when pulling)
            Circle()
                .fill(Color.primaryBlue.opacity(0.1))
                .frame(width: 50, height: 50)
                .scaleEffect(pullOffset > 20 ? min(1.0, pullOffset / 100) : 0)
                .opacity(pullOffset > 20 ? 1 : 0)
            
            // Main indicator
            Group {
                if isRefreshing {
                    // Spinning progress indicator
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primaryBlue))
                        .scaleEffect(1.3)
                        .accessibilityLabel("Refreshing content")
                } else {
                    // Pull indicator with smooth rotation
                    Image(systemName: "arrow.down")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryBlue)
                        .rotationEffect(.degrees(pullOffset > refreshThreshold ? 180 : 0))
                        .scaleEffect(pullOffset > refreshThreshold ? 1.2 : 1.0)
                        .opacity(pullOffset > 20 ? 1 : 0)
                        .accessibilityLabel(pullOffset > refreshThreshold ? "Release to refresh" : "Pull to refresh")
                }
            }
            .animation(.spring(response: animationDuration, dampingFraction: 0.7), value: isRefreshing)
            .animation(.spring(response: animationDuration, dampingFraction: 0.8), value: pullOffset > refreshThreshold)
        }
    }
    
    // MARK: - Status Text Container
    
    private var statusTextContainer: some View {
        Text(refreshStatusText)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .frame(height: 20)
            .opacity(refreshStatusText.isEmpty ? 0 : 1)
            .accessibilityLabel(refreshStatusText)
            .accessibilityAddTraits(.updatesFrequently)
    }
    
    // MARK: - Last Refresh Text
    
    private func lastRefreshText(_ date: Date) -> some View {
        Text("Обновлено \(formatLastRefreshTime(date))")
            .font(.caption)
            .foregroundColor(.tertiary)
            .opacity(pullOffset > 0 ? 0 : 1)
            .animation(.easeInOut(duration: animationDuration), value: pullOffset)
    }
    
    // MARK: - Header Background
    
    private var headerBackground: some View {
        Color(.systemBackground)
            .overlay(
                // Subtle border
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 0.5),
                alignment: .bottom
            )
    }
    
    // MARK: - Status Text
    
    private var refreshStatusText: String {
        if showCompletionMessage {
            return "Готово"
        } else if isRefreshing {
            return "Обновляю..."
        } else if pullOffset > refreshThreshold {
            return "Отпустите для обновления"
        } else if pullOffset > 20 {
            return "Потяни, чтобы обновить"
        } else {
            return ""
        }
    }
    
    // MARK: - Scroll Handling
    
    private func handleScrollOffset(_ offset: CGFloat) {
        let adjustedOffset = max(0, -offset)
        
        // Only handle pull-to-refresh when at the top
        if offset <= 0 {
            let resistance = calculateElasticResistance(for: adjustedOffset)
            pullOffset = min(adjustedOffset * resistance, maxPullDistance)
            
            // Trigger refresh when threshold is reached and released
            if adjustedOffset > refreshThreshold && !refreshTriggered {
                refreshTriggered = true
                triggerRefresh()
            }
        } else {
            // Reset when scrolling down
            pullOffset = 0
            refreshTriggered = false
        }
    }
    
    // MARK: - Elastic Resistance Calculation
    
    private func calculateElasticResistance(for offset: CGFloat) -> CGFloat {
        // More sophisticated elastic resistance
        let baseResistance: CGFloat = 0.65
        let maxResistance: CGFloat = 0.25
        
        if offset < refreshThreshold {
            // Linear resistance before threshold
            return baseResistance
        } else {
            // Exponential resistance after threshold
            let excess = offset - refreshThreshold
            let resistanceReduction = min(excess * 0.008, baseResistance - maxResistance)
            return baseResistance - resistanceReduction
        }
    }
    
    // MARK: - Refresh Action
    
    private func triggerRefresh() {
        guard !isRefreshing else { return }
        
        // Haptic feedback with different intensities
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Start refresh
        isRefreshing = true
        
        Task {
            await onRefresh()
            
            await MainActor.run {
                // Update last refresh time
                lastRefreshTime = Date()
                
                // Show completion message
                showCompletionMessage = true
                
                // Success haptic
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
                
                // Reset after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + completionDuration) {
                    withAnimation(.spring(response: animationDuration, dampingFraction: 0.8)) {
                        isRefreshing = false
                        showCompletionMessage = false
                        pullOffset = 0
                        refreshTriggered = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func formatLastRefreshTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Reduced Motion Support

struct AccessiblePullToRefreshView<Content: View>: View {
    let content: Content
    let onRefresh: () async -> Void
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        if reduceMotion {
            // Simplified version for reduced motion
            ScrollView {
                content
                    .refreshable {
                        await onRefresh()
                    }
            }
            .accessibilityLabel("Content with refresh capability")
        } else {
            // Full pull-to-refresh experience
            AdvancedPullToRefreshView(content: { content }, onRefresh: onRefresh)
        }
    }
}

// MARK: - Custom Refresh Modifier

struct PullToRefreshModifier: ViewModifier {
    let onRefresh: () async -> Void
    
    func body(content: Content) -> some View {
        AccessiblePullToRefreshView(content: { content }, onRefresh: onRefresh)
    }
}

extension View {
    func pullToRefresh(onRefresh: @escaping () async -> Void) -> some View {
        modifier(PullToRefreshModifier(onRefresh: onRefresh))
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(0..<20, id: \.self) { index in
                    TransactionCard(
                        transaction: Transaction(
                            context: PersistenceController.shared.container.viewContext,
                            amount: Double(index * 100 + 500),
                            category: ["Еда", "Транспорт", "Покупки", "Развлечения"].randomElement() ?? "Другое",
                            wallet: "Основной",
                            note: "Тестовая операция \(index + 1)",
                            type: index % 3 == 0 ? "income" : "expense"
                        )
                    )
                }
            }
            .padding()
        }
        .pullToRefresh {
            // Simulate refresh
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
        .navigationTitle("Pull to Refresh Demo")
    }
}
