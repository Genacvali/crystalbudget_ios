# CrystalBudget iOS App

Продакшен-готовое iOS приложение для управления личными финансами с современной архитектурой и всеми необходимыми функциями.

## 🚀 Особенности

### Основной функционал
- ✅ **Быстрый учёт расходов** - добавление операций за секунды
- ✅ **Контроль лимитов** - бюджеты с визуальными индикаторами
- ✅ **Offline-first** - работает без интернета с синхронизацией
- ✅ **Биометрическая защита** - Face ID/Touch ID для безопасности
- ✅ **Сканирование чеков** - автоматическое распознавание через VisionKit
- ✅ **Голосовой ввод** - добавление расходов через Siri

### iOS-специфичные функции
- ✅ **WidgetKit** - виджеты для главного экрана (маленький/средний/большой)
- ✅ **App Intents** - Siri Shortcuts для быстрых действий
- ✅ **Swift Charts** - красивые графики и диаграммы
- ✅ **Push уведомления** - напоминания и алерты о бюджетах
- ✅ **Universal Links** - deep linking в приложение
- ✅ **Background Tasks** - фоновая синхронизация

### Безопасность и приватность
- ✅ **Шифрование данных** - AES-GCM для чувствительной информации
- ✅ **Keychain** - безопасное хранение токенов и ключей
- ✅ **App Lock** - автоматическая блокировка приложения
- ✅ **Privacy Manifest** - соответствие требованиям Apple
- ✅ **Локальное хранение** - данные остаются на устройстве

## 🏗️ Архитектура

### Технологический стек
- **SwiftUI** + **Swift Concurrency** - современный UI и асинхронность
- **CoreData** - локальная база данных с миграциями
- **MVVM** - чистая архитектура с разделением слоёв
- **Combine** - реактивное программирование
- **WidgetKit** - виджеты для главного экрана
- **App Intents** - интеграция с Siri
- **VisionKit** - сканирование документов
- **UserNotifications** - push и локальные уведомления

### Структура проекта
```
CrystalBudget/
├── CrystalBudget/                 # Основное приложение
│   ├── CrystalBudgetApp.swift     # Точка входа
│   ├── ContentView.swift          # Главное представление
│   ├── Views/                     # UI компоненты
│   │   ├── DashboardView.swift
│   │   ├── TransactionsView.swift
│   │   ├── BudgetsView.swift
│   │   ├── ReportsView.swift
│   │   ├── ProfileView.swift
│   │   ├── QuickAddView.swift
│   │   ├── OnboardingView.swift
│   │   └── ReceiptScannerView.swift
│   ├── Managers/                  # Бизнес-логика
│   │   ├── CoreDataManager.swift
│   │   ├── AuthenticationManager.swift
│   │   ├── SyncManager.swift
│   │   ├── NotificationManager.swift
│   │   └── CryptoManager.swift
│   ├── Models/                    # CoreData модель
│   │   └── CrystalBudget.xcdatamodeld
│   └── Utils/                     # App Intents
│       ├── AddExpenseIntent.swift
│       └── ShowBalanceIntent.swift
├── CrystalBudgetWidget/           # Виджеты
│   ├── CrystalBudgetWidgetBundle.swift
│   ├── CrystalBudgetWidget.swift
│   └── WidgetTimelineProvider.swift
├── CrystalBudgetTests/           # Unit тесты
│   └── CrystalBudgetTests.swift
└── CrystalBudgetUITests/         # UI тесты
    └── CrystalBudgetUITests.swift
```

## 📱 Требования

- **iOS 17.0+** - минимальная версия
- **Xcode 15.0+** - для разработки
- **Swift 5.10+** - язык программирования
- **iPhone/iPad** - поддерживаемые устройства

## 🛠️ Установка и сборка

### 1. Клонирование проекта
```bash
git clone https://github.com/yourusername/crystalbudget-ios.git
cd crystalbudget-ios
```

### 2. Открытие в Xcode
```bash
open CrystalBudget.xcodeproj
```

### 3. Настройка подписи
1. Выберите проект в навигаторе
2. Перейдите в "Signing & Capabilities"
3. Выберите вашу команду разработчика
4. Убедитесь, что Bundle Identifier уникален

### 4. Сборка и запуск
- **Debug**: `Cmd + R` или Product → Run
- **Release**: Product → Archive

## 🧪 Тестирование

### Unit тесты
```bash
# Запуск всех unit тестов
Cmd + U

# Запуск конкретного теста
# Выберите тест в навигаторе и нажмите Cmd + U
```

### UI тесты
```bash
# Запуск UI тестов
# Выберите CrystalBudgetUITests в схеме и нажмите Cmd + U
```

### Покрытие кода
1. Product → Scheme → Edit Scheme
2. Test → Options → Code Coverage → ✅
3. Запустите тесты и проверьте покрытие в Report Navigator

## 📦 Развертывание

### App Store Connect

#### 1. Подготовка к загрузке
```bash
# Archive сборка
Product → Archive

# Validate App
Distribute App → App Store Connect → Upload
```

#### 2. Необходимые ресурсы
- **Иконка приложения**: 1024x1024px (AppIcon.appiconset)
- **Скриншоты**: iPhone и iPad (светлая/тёмная тема)
- **Превью-видео**: 15-30 секунд демонстрации
- **Описание**: на русском и английском языках

#### 3. Метаданные
- **Название**: CrystalBudget
- **Подзаголовок**: Управление финансами
- **Категория**: Finance
- **Возрастной рейтинг**: 4+
- **Ключевые слова**: бюджет, финансы, расходы, доходы

### TestFlight

#### 1. Внутреннее тестирование
- Добавьте тестеров в App Store Connect
- Загрузите сборку через Xcode
- Отправьте приглашения тестерам

#### 2. Внешнее тестирование
- Создайте группу внешних тестеров
- Заполните информацию о тестировании
- Отправьте на ревью Apple

## 🔧 Конфигурация

### Переменные окружения
Создайте файл `Config.xcconfig`:
```bash
# Supabase Configuration
SUPABASE_URL = your-supabase-url
SUPABASE_ANON_KEY = your-supabase-anon-key

# OpenAI Configuration
OPENAI_API_KEY = your-openai-api-key

# Telegram Bot
TELEGRAM_BOT_TOKEN = your-telegram-bot-token
```

### Capabilities
Убедитесь, что включены необходимые capabilities:
- **Push Notifications** - для уведомлений
- **Background Modes** - для фоновой синхронизации
- **App Groups** - для виджетов
- **Keychain Sharing** - для безопасного хранения

### Entitlements
```xml
<key>com.apple.developer.usernotifications.communication</key>
<true/>
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

## 📊 Мониторинг и аналитика

### Crashlytics (опционально)
```swift
// Добавьте в CrystalBudgetApp.swift
import FirebaseCrashlytics

// В setupApp()
Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
```

### App Store Connect Analytics
- Отслеживайте метрики в App Store Connect
- Анализируйте отзывы пользователей
- Мониторьте производительность

## 🔒 Безопасность

### Шифрование
- Все чувствительные данные шифруются AES-GCM
- Ключи шифрования хранятся в Keychain
- Локальное хранение без передачи на сервер

### Биометрическая аутентификация
- Face ID/Touch ID для разблокировки
- Автоматическая блокировка при уходе в фон
- Fallback на пароль устройства

### Privacy Manifest
- Полное соответствие требованиям Apple
- Прозрачность использования данных
- Отсутствие трекинга пользователей

## 🚀 Производительность

### Оптимизации
- **Lazy loading** - ленивая загрузка данных
- **Image caching** - кеширование изображений
- **Background processing** - фоновая обработка
- **Memory management** - управление памятью

### Метрики
- **Cold start**: < 1 секунды
- **Memory usage**: < 100MB
- **Battery impact**: минимальный
- **Network usage**: только при синхронизации

## 📝 Лицензия

MIT License - см. файл [LICENSE](LICENSE)

## 🤝 Вклад в проект

1. Fork проекта
2. Создайте feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit изменения (`git commit -m 'Add some AmazingFeature'`)
4. Push в branch (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

## 📞 Поддержка

- **Email**: support@crystalbudget.net
- **Telegram**: @crystalbudget_bot
- **GitHub Issues**: [Создать issue](https://github.com/yourusername/crystalbudget-ios/issues)

## 🎯 Roadmap

### Версия 1.1
- [ ] Интеграция с банками через Open Banking
- [ ] Экспорт данных в Excel/PDF
- [ ] Расширенная аналитика и прогнозы

### Версия 1.2
- [ ] Семейный доступ и совместные бюджеты
- [ ] Интеграция с Apple Pay
- [ ] Расширенные виджеты

### Версия 2.0
- [ ] AI-ассистент для финансового планирования
- [ ] Интеграция с инвестиционными платформами
- [ ] Расширенная геолокация расходов

---

**CrystalBudget** - Ваши финансы под полным контролем! 💎