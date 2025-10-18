import SwiftUI

struct PullToRefreshView<Content: View>: View {
    let content: Content
    let onRefresh: () async -> Void
    
    @State private var isRefreshing = false
    @State private var pullOffset: CGFloat = 0
    @State private var refreshTriggered = false
    @State private var showCompletionMessage = false
    
    private let refreshThreshold: CGFloat = 70
    private let maxPullDistance: CGFloat = 120
    private let animationDuration: Double = 0.2
    
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
                        .frame(height: pullOffset > 0 ? pullOffset : 0)
                        .opacity(pullOffset > 0 ? 1 : 0)
                    
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
        }
        .animation(.easeInOut(duration: animationDuration), value: pullOffset)
        .animation(.easeInOut(duration: animationDuration), value: isRefreshing)
        .animation(.easeInOut(duration: animationDuration), value: showCompletionMessage)
    }
    
    // MARK: - Pull to Refresh Header
    
    private var pullToRefreshHeader: some View {
        VStack(spacing: 8) {
            Spacer()
            
            // Refresh indicator
            refreshIndicator
            
            // Status text
            Text(refreshStatusText)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityLabel(refreshStatusText)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Refresh Indicator
    
    private var refreshIndicator: some View {
        Group {
            if isRefreshing {
                // Spinning indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryBlue))
                    .scaleEffect(1.2)
                    .accessibilityLabel("Refreshing")
            } else {
                // Pull indicator
                Image(systemName: "arrow.down")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryBlue)
                    .rotationEffect(.degrees(pullOffset > refreshThreshold ? 180 : 0))
                    .scaleEffect(pullOffset > refreshThreshold ? 1.1 : 1.0)
                    .accessibilityLabel(pullOffset > refreshThreshold ? "Release to refresh" : "Pull to refresh")
            }
        }
        .animation(.easeInOut(duration: animationDuration), value: isRefreshing)
        .animation(.easeInOut(duration: animationDuration), value: pullOffset > refreshThreshold)
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
            let resistance = calculateResistance(for: adjustedOffset)
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
    
    // MARK: - Resistance Calculation
    
    private func calculateResistance(for offset: CGFloat) -> CGFloat {
        // Elastic resistance that increases as you pull further
        let resistanceFactor: CGFloat = 0.6
        let maxResistance: CGFloat = 0.3
        
        if offset < refreshThreshold {
            return resistanceFactor
        } else {
            let excess = offset - refreshThreshold
            let additionalResistance = min(excess * 0.01, maxResistance - resistanceFactor)
            return resistanceFactor + additionalResistance
        }
    }
    
    // MARK: - Refresh Action
    
    private func triggerRefresh() {
        guard !isRefreshing else { return }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Start refresh
        isRefreshing = true
        
        Task {
            await onRefresh()
            
            await MainActor.run {
                // Show completion message
                showCompletionMessage = true
                
                // Reset after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeInOut(duration: animationDuration)) {
                        isRefreshing = false
                        showCompletionMessage = false
                        pullOffset = 0
                        refreshTriggered = false
                    }
                }
            }
        }
    }
}

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Accessibility Support

extension PullToRefreshView {
    private var accessibilityStatus: String {
        if isRefreshing {
            return "Refreshing content"
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

struct ReducedMotionPullToRefreshView<Content: View>: View {
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
        } else {
            // Full pull-to-refresh experience
            PullToRefreshView(content: { content }, onRefresh: onRefresh)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ReducedMotionPullToRefreshView {
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
        } onRefresh: {
            // Simulate refresh
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
        .navigationTitle("Pull to Refresh Demo")
    }
}
