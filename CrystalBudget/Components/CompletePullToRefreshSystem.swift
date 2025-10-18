import SwiftUI

// MARK: - Complete Pull to Refresh System
struct CompletePullToRefreshSystem<Content: View>: View {
    let content: Content
    let onRefresh: () async -> Void
    let refreshThreshold: CGFloat
    let maxPullDistance: CGFloat
    let animationDuration: Double
    
    @State private var isRefreshing = false
    @State private var pullOffset: CGFloat = 0
    @State private var refreshTriggered = false
    @State private var showCompletionMessage = false
    @State private var lastRefreshTime: Date?
    @State private var refreshProgress: Double = 0
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        refreshThreshold: CGFloat = 70,
        maxPullDistance: CGFloat = 120,
        animationDuration: Double = 0.18,
        @ViewBuilder content: () -> Content,
        onRefresh: @escaping () async -> Void
    ) {
        self.refreshThreshold = refreshThreshold
        self.maxPullDistance = maxPullDistance
        self.animationDuration = animationDuration
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Enhanced pull to refresh header
                    enhancedPullToRefreshHeader
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
        .animation(.easeInOut(duration: animationDuration), value: refreshProgress)
    }
    
    // MARK: - Enhanced Pull to Refresh Header
    
    private var enhancedPullToRefreshHeader: some View {
        VStack(spacing: 16) {
            Spacer()
            
            // Main refresh indicator with progress
            enhancedRefreshIndicator
            
            // Status text with smooth transitions
            enhancedStatusText
            
            // Last refresh time with animation
            if let lastRefresh = lastRefreshTime, !isRefreshing {
                lastRefreshTimeView(lastRefresh)
            }
            
            // Progress bar during refresh
            if isRefreshing {
                progressBarView
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(enhancedHeaderBackground)
        .overlay(
            // Subtle gradient overlay
            LinearGradient(
                colors: [
                    Color(.systemBackground).opacity(0.9),
                    Color(.systemBackground).opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Enhanced Refresh Indicator
    
    private var enhancedRefreshIndicator: some View {
        ZStack {
            // Background circle with pulsing animation
            Circle()
                .fill(Color.primaryBlue.opacity(0.15))
                .frame(width: 60, height: 60)
                .scaleEffect(pullOffset > 20 ? min(1.2, pullOffset / 80) : 0)
                .opacity(pullOffset > 20 ? 1 : 0)
                .animation(.easeInOut(duration: animationDuration), value: pullOffset)
            
            // Progress ring during refresh
            if isRefreshing {
                Circle()
                    .stroke(Color.primaryBlue.opacity(0.3), lineWidth: 3)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: refreshProgress)
                    .stroke(Color.primaryBlue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.1), value: refreshProgress)
            }
            
            // Main indicator
            Group {
                if isRefreshing {
                    // Spinning progress indicator
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primaryBlue))
                        .scaleEffect(1.4)
                        .accessibilityLabel("Refreshing content")
                } else {
                    // Pull indicator with smooth rotation and scaling
                    Image(systemName: "arrow.down")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryBlue)
                        .rotationEffect(.degrees(pullOffset > refreshThreshold ? 180 : 0))
                        .scaleEffect(pullOffset > refreshThreshold ? 1.3 : 1.0)
                        .opacity(pullOffset > 20 ? 1 : 0)
                        .accessibilityLabel(pullOffset > refreshThreshold ? "Release to refresh" : "Pull to refresh")
                }
            }
            .animation(.spring(response: animationDuration, dampingFraction: 0.7), value: isRefreshing)
            .animation(.spring(response: animationDuration, dampingFraction: 0.8), value: pullOffset > refreshThreshold)
        }
    }
    
    // MARK: - Enhanced Status Text
    
    private var enhancedStatusText: some View {
        Text(refreshStatusText)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .frame(height: 24)
            .opacity(refreshStatusText.isEmpty ? 0 : 1)
            .accessibilityLabel(refreshStatusText)
            .accessibilityAddTraits(.updatesFrequently)
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
    
    // MARK: - Last Refresh Time View
    
    private func lastRefreshTimeView(_ date: Date) -> some View {
        Text("Обновлено \(formatLastRefreshTime(date))")
            .font(.caption)
            .foregroundColor(.tertiary)
            .opacity(pullOffset > 0 ? 0 : 1)
            .animation(.easeInOut(duration: animationDuration), value: pullOffset)
            .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    // MARK: - Progress Bar View
    
    private var progressBarView: some View {
        VStack(spacing: 8) {
            ProgressView(value: refreshProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .primaryBlue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .cornerRadius(4)
                .frame(maxWidth: 200)
            
            Text("\(Int(refreshProgress * 100))%")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
    
    // MARK: - Enhanced Header Background
    
    private var enhancedHeaderBackground: some View {
        Color(.systemBackground)
            .overlay(
                // Subtle border with animation
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 0.5)
                    .opacity(pullOffset > 0 ? 1 : 0),
                alignment: .bottom
            )
            .overlay(
                // Subtle shadow
                Rectangle()
                    .fill(Color.black.opacity(0.05))
                    .frame(height: 1)
                    .blur(radius: 1),
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
    
    // MARK: - Enhanced Elastic Resistance
    
    private func calculateElasticResistance(for offset: CGFloat) -> CGFloat {
        // More sophisticated elastic resistance with smooth curves
        let baseResistance: CGFloat = 0.65
        let maxResistance: CGFloat = 0.25
        
        if offset < refreshThreshold {
            // Linear resistance before threshold
            return baseResistance
        } else {
            // Exponential resistance after threshold for better feel
            let excess = offset - refreshThreshold
            let resistanceReduction = min(excess * 0.008, baseResistance - maxResistance)
            return baseResistance - resistanceReduction
        }
    }
    
    // MARK: - Enhanced Refresh Action
    
    private func triggerRefresh() {
        guard !isRefreshing else { return }
        
        // Enhanced haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Start refresh with progress tracking
        isRefreshing = true
        refreshProgress = 0
        
        Task {
            // Simulate progress updates
            await simulateProgressUpdates()
            
            // Perform actual refresh
            await onRefresh()
            
            await MainActor.run {
                // Update last refresh time
                lastRefreshTime = Date()
                
                // Complete progress
                refreshProgress = 1.0
                
                // Show completion message
                showCompletionMessage = true
                
                // Success haptic feedback
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
                
                // Reset after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: animationDuration, dampingFraction: 0.8)) {
                        isRefreshing = false
                        showCompletionMessage = false
                        pullOffset = 0
                        refreshTriggered = false
                        refreshProgress = 0
                    }
                }
            }
        }
    }
    
    // MARK: - Progress Simulation
    
    private func simulateProgressUpdates() async {
        let totalSteps = 20
        let stepDuration = 0.05 // 50ms per step
        
        for step in 1...totalSteps {
            await MainActor.run {
                refreshProgress = Double(step) / Double(totalSteps)
            }
            
            try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
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

// MARK: - Accessibility Support

extension CompletePullToRefreshSystem {
    private var accessibilityStatus: String {
        if isRefreshing {
            return "Refreshing content, \(Int(refreshProgress * 100))% complete"
        } else if pullOffset > refreshThreshold {
            return "Release to refresh"
        } else if pullOffset > 20 {
            return "Pull to refresh"
        } else {
            return "Content loaded"
        }
    }
}

// MARK: - Reduced Motion Support

struct AccessibleCompletePullToRefreshView<Content: View>: View {
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
            CompletePullToRefreshSystem(content: { content }, onRefresh: onRefresh)
        }
    }
}

// MARK: - Custom Refresh Modifier

struct CompletePullToRefreshModifier: ViewModifier {
    let onRefresh: () async -> Void
    
    func body(content: Content) -> some View {
        AccessibleCompletePullToRefreshView(content: { content }, onRefresh: onRefresh)
    }
}

extension View {
    func completePullToRefresh(onRefresh: @escaping () async -> Void) -> some View {
        modifier(CompletePullToRefreshModifier(onRefresh: onRefresh))
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(0..<20, id: \.self) { index in
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        
                        Text("Item \(index + 1)")
                            .font(.body)
                        
                        Spacer()
                        
                        Text("₽\(index * 100)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .completePullToRefresh {
            // Simulate refresh with progress
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
        .navigationTitle("Complete Pull to Refresh Demo")
    }
}
