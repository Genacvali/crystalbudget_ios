# Pull-to-Refresh System Documentation

## 🎯 Обзор

Система pull-to-refresh для CrystalBudget iOS приложения обеспечивает плавное и интуитивное обновление контента с поддержкой всех современных стандартов iOS.

## ✨ Особенности

### 🎨 **Визуальные эффекты**
- ✅ **Упругое сопротивление** - контент тянется вниз с естественным сопротивлением
- ✅ **Плавные анимации** - 150-200ms с естественными кривыми
- ✅ **Прогресс-индикатор** - показывает прогресс обновления
- ✅ **Статусные сообщения** - "Потяни, чтобы обновить" → "Отпустите для обновления" → "Обновляю..." → "Готово"
- ✅ **Время последнего обновления** - показывает когда было последнее обновление

### 🔧 **Технические возможности**
- ✅ **Haptic feedback** - тактильная обратная связь при срабатывании
- ✅ **Accessibility** - полная поддержка VoiceOver и aria-status
- ✅ **Reduced Motion** - автоматическое упрощение для пользователей с ограниченными возможностями
- ✅ **iOS совместимость** - не конфликтует с системной прокруткой
- ✅ **Прогресс-трекинг** - отслеживание прогресса обновления

## 🚀 Использование

### Базовое использование

```swift
ScrollView {
    // Ваш контент
    LazyVStack {
        ForEach(items) { item in
            ItemView(item: item)
        }
    }
}
.completePullToRefresh {
    await refreshData()
}
```

### Расширенное использование

```swift
ScrollView {
    // Ваш контент
}
.completePullToRefresh(
    refreshThreshold: 80,      // Порог срабатывания
    maxPullDistance: 140,       // Максимальное расстояние
    animationDuration: 0.2      // Длительность анимации
) {
    await refreshData()
}
```

### Интеграция с существующими экранами

```swift
struct DashboardView: View {
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationView {
            ScrollView {
                // Контент дашборда
            }
            .completePullToRefresh {
                await refreshData()
            }
        }
        .id(refreshID)
    }
    
    private func refreshData() async {
        // Логика обновления данных
        await coreDataManager.syncData()
        
        // Обновление UI
        await MainActor.run {
            refreshID = UUID()
        }
    }
}
```

## 🎛️ Компоненты системы

### 1. **CompletePullToRefreshSystem**
Основной компонент с полным функционалом:
- Упругое сопротивление
- Прогресс-трекинг
- Haptic feedback
- Accessibility поддержка

### 2. **AdvancedPullToRefreshView**
Продвинутая версия с дополнительными возможностями:
- Анимированные индикаторы
- Время последнего обновления
- Улучшенные переходы

### 3. **EnhancedTransactionListView**
Специализированный компонент для списков транзакций:
- Фильтрация и поиск
- Swipe actions
- Анимированные карточки

### 4. **Widget Pull-to-Refresh Support**
Поддержка для виджетов:
- Обновление данных виджетов
- Индикаторы статуса
- Быстрые действия

## 🎨 Кастомизация

### Настройка порогов

```swift
.completePullToRefresh(
    refreshThreshold: 70,      // Порог срабатывания (по умолчанию 70)
    maxPullDistance: 120,      // Максимальное расстояние (по умолчанию 120)
    animationDuration: 0.18    // Длительность анимации (по умолчанию 0.18)
) {
    await refreshData()
}
```

### Кастомные анимации

```swift
// В вашем View
.animation(.spring(response: 0.2, dampingFraction: 0.8), value: pullOffset)
.animation(.easeInOut(duration: 0.2), value: isRefreshing)
```

### Кастомные цвета

```swift
// В вашем View
.foregroundColor(.primaryBlue)  // Цвет индикатора
.background(Color(.systemBackground))  // Фон заголовка
```

## ♿ Accessibility

### VoiceOver поддержка

```swift
.accessibilityLabel("Pull to refresh")
.accessibilityValue(refreshStatusText)
.accessibilityHint("Pull down to refresh content")
.accessibilityAddTraits(.updatesFrequently)
```

### Reduced Motion

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

if reduceMotion {
    // Упрощенная версия с системным refreshable
    ScrollView {
        content
            .refreshable {
                await onRefresh()
            }
    }
} else {
    // Полная версия с pull-to-refresh
    CompletePullToRefreshSystem(content: { content }, onRefresh: onRefresh)
}
```

## 🔧 Технические детали

### Упругое сопротивление

```swift
private func calculateElasticResistance(for offset: CGFloat) -> CGFloat {
    let baseResistance: CGFloat = 0.65
    let maxResistance: CGFloat = 0.25
    
    if offset < refreshThreshold {
        return baseResistance
    } else {
        let excess = offset - refreshThreshold
        let resistanceReduction = min(excess * 0.008, baseResistance - maxResistance)
        return baseResistance - resistanceReduction
    }
}
```

### Haptic Feedback

```swift
// При начале обновления
let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
impactFeedback.impactOccurred()

// При завершении
let successFeedback = UINotificationFeedbackGenerator()
successFeedback.notificationOccurred(.success)
```

### Прогресс-трекинг

```swift
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
```

## 🎯 Лучшие практики

### 1. **Производительность**
- Используйте `LazyVStack` для больших списков
- Обновляйте только необходимые данные
- Кешируйте результаты обновления

### 2. **UX**
- Показывайте прогресс обновления
- Предоставляйте обратную связь пользователю
- Используйте подходящие haptic feedback

### 3. **Accessibility**
- Всегда предоставляйте текстовые альтернативы
- Поддерживайте Reduced Motion
- Тестируйте с VoiceOver

### 4. **Обработка ошибок**
```swift
.completePullToRefresh {
    do {
        try await refreshData()
    } catch {
        // Показать ошибку пользователю
        await MainActor.run {
            showError(error)
        }
    }
}
```

## 🧪 Тестирование

### Unit тесты

```swift
func testPullToRefreshThreshold() {
    let system = CompletePullToRefreshSystem(
        refreshThreshold: 70,
        content: { Text("Test") },
        onRefresh: { }
    )
    
    // Тест порога срабатывания
    XCTAssertEqual(system.refreshThreshold, 70)
}
```

### UI тесты

```swift
func testPullToRefreshFlow() throws {
    let app = XCUIApplication()
    app.launch()
    
    // Найти элемент для pull-to-refresh
    let scrollView = app.scrollViews.firstMatch
    
    // Выполнить pull-to-refresh
    scrollView.press(forDuration: 0.1, thenDragTo: scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8)))
    
    // Проверить что обновление началось
    XCTAssertTrue(app.staticTexts["Обновляю..."].exists)
}
```

## 🐛 Устранение неполадок

### Проблема: Pull-to-refresh не срабатывает
**Решение:**
- Проверьте что контент находится в ScrollView
- Убедитесь что модификатор применен к правильному элементу
- Проверьте порог срабатывания

### Проблема: Анимации тормозят
**Решение:**
- Уменьшите длительность анимации
- Используйте более простые анимации
- Проверьте производительность основного контента

### Проблема: Конфликт с системной прокруткой
**Решение:**
- Убедитесь что используется правильный coordinateSpace
- Проверьте что ScrollView настроен корректно
- Используйте GeometryReader для отслеживания позиции

## 📱 Совместимость

- **iOS 17.0+** - минимальная версия
- **iPhone/iPad** - все размеры экранов
- **Accessibility** - полная поддержка
- **Dark Mode** - автоматическая адаптация
- **Dynamic Type** - поддержка всех размеров шрифтов

## 🎉 Заключение

Система pull-to-refresh CrystalBudget обеспечивает:
- ✅ Плавный и интуитивный UX
- ✅ Полную accessibility поддержку
- ✅ Современные iOS стандарты
- ✅ Гибкую кастомизацию
- ✅ Высокую производительность

Используйте эту систему для создания профессионального пользовательского опыта в вашем iOS приложении!
