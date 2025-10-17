# 📱 iOS Native Features

## Что добавлено

### 1. ✅ App Icon & Splash Screen
- Создан красивый App Icon с кристаллом в стиле бренда
- Все размеры для iPhone и iPad
- Автоматическая генерация через скрипт `scripts/generate-ios-icons.sh`

### 2. 🔄 Swipe Gestures
**Компонент `SwipeableCard`** - свайпы для карточек:
- Swipe влево → показать кнопки Удалить/Редактировать
- Haptic feedback при свайпе
- Плавные анимации

**Использование:**
```tsx
import { SwipeableCard } from '@/components/SwipeableCard';

<SwipeableCard
  onDelete={() => handleDelete()}
  onEdit={() => handleEdit()}
>
  <YourCardContent />
</SwipeableCard>
```

### 3. 🔃 Pull-to-Refresh
**Компонент `PullToRefresh`** - обновление данных жестом:
- Потяните вниз для обновления
- Визуальный индикатор и вибрация
- Работает только когда скролл в верху

**Использование:**
```tsx
import { PullToRefresh } from '@/components/PullToRefresh';

<PullToRefresh onRefresh={async () => await refreshData()}>
  <YourContent />
</PullToRefresh>
```

### 4. 🔔 Push Notifications
**Автоматическая инициализация:**
- Запрос разрешений при первом запуске
- Обработка уведомлений
- Haptic feedback при получении
- Badge на иконке приложения

**API:**
```tsx
import { 
  initPushNotifications,
  getPushToken,
  setBadgeCount,
  clearAllNotifications 
} from '@/utils/capacitor';

// Инициализация (автоматически вызывается)
await initPushNotifications();

// Установить badge
await setBadgeCount(5);

// Очистить все уведомления
await clearAllNotifications();
```

### 5. 🎨 iOS Native UI Styles
**Автоматически применяются:**
- SF Pro Display шрифт (системный iOS шрифт)
- Blur эффекты (backdrop-filter)
- iOS-стиль кнопок, карточек, инпутов
- Нативные shadows и transitions
- Поддержка Dark Mode

**CSS классы:**
```css
.ios-button        /* iOS-стиль кнопка */
.ios-card          /* iOS-стиль карточка с blur */
.ios-input         /* iOS-стиль input */
.ios-list          /* iOS-стиль список */
.ios-list-item     /* iOS-стиль элемент списка */
.ios-navbar        /* iOS-стиль навигация */
.ios-sheet         /* iOS-стиль bottom sheet */
.ios-blur          /* Blur эффект */
.ios-shadow        /* iOS-стиль тень */
```

### 6. 📳 Enhanced Haptic Feedback
**Расширенные типы вибрации:**
```tsx
import { 
  vibrate, 
  notificationHaptic, 
  selectionHaptic 
} from '@/utils/capacitor';

// Стандартная вибрация
await vibrate('light');    // Легкая
await vibrate('medium');   // Средняя
await vibrate('heavy');    // Сильная

// Notification haptic
await notificationHaptic(); // Для уведомлений

// Selection haptic
await selectionHaptic();    // Для выбора элементов
```

## Как использовать

### В существующих компонентах

#### Добавить свайпы к транзакциям:
```tsx
// В Transactions.tsx
import { SwipeableCard } from '@/components/SwipeableCard';

{transactions.map(tx => (
  <SwipeableCard
    key={tx.id}
    onDelete={() => deleteTransaction(tx.id)}
    onEdit={() => editTransaction(tx)}
  >
    <TransactionCard transaction={tx} />
  </SwipeableCard>
))}
```

#### Добавить Pull-to-Refresh на Dashboard:
```tsx
// В Dashboard.tsx
import { PullToRefresh } from '@/components/PullToRefresh';

return (
  <PullToRefresh onRefresh={async () => await refreshDashboard()}>
    <div>
      {/* Dashboard content */}
    </div>
  </PullToRefresh>
);
```

#### Добавить haptic feedback к кнопкам:
```tsx
import { vibrate } from '@/utils/capacitor';

<Button 
  onClick={async () => {
    await vibrate('light');
    handleClick();
  }}
>
  Click me
</Button>
```

#### Применить iOS стили:
```tsx
<div className="ios-card p-4">
  <h2 className="ios-text-primary">Заголовок</h2>
  <p className="ios-text-secondary">Описание</p>
</div>

<Button className="ios-button">
  iOS Button
</Button>

<Input className="ios-input" />
```

## Настройка в Xcode

### Push Notifications Capability
1. Откройте проект в Xcode
2. Выберите target "App"
3. Вкладка "Signing & Capabilities"
4. Нажмите "+ Capability"
5. Добавьте "Push Notifications"

### Info.plist разрешения
Уже настроены:
- Camera Usage
- Photo Library Usage
- Notifications

## Тестирование

### На симуляторе:
- Все работает кроме Push Notifications (требуется реальное устройство)
- Haptic feedback не ощущается (симулятор)

### На реальном iPhone:
1. Подключите iPhone
2. В Xcode выберите устройство
3. Нажмите Play (▶️)
4. Тестируйте все фишки!

## Генерация иконок

Если изменили `public/pwa-512x512.png`:
```bash
./scripts/generate-ios-icons.sh
```

## Пересборка после изменений

```bash
npm run build
npx cap sync ios
# В Xcode нажать Play (▶️)
```

Или быстро:
```bash
npm run ios:sync
# В Xcode нажать Play (▶️)
```

## Что дальше?

### Можно добавить:
- [ ] Context Menu (long press меню)
- [ ] Quick Actions (3D Touch на иконке)
- [ ] Share Extension
- [ ] Today Widget
- [ ] App Clips
- [ ] Siri Shortcuts
- [ ] Face ID / Touch ID аутентификация
- [ ] iCloud синхронизация

## Известные проблемы

1. **Push Notifications на симуляторе**: Не работают, нужно реальное устройство
2. **Haptic Feedback на симуляторе**: Не ощущается
3. **Badge count**: Требует настройку backend для отправки payload

## Полезные ссылки

- [Capacitor Push Notifications](https://capacitorjs.com/docs/apis/push-notifications)
- [Capacitor Haptics](https://capacitorjs.com/docs/apis/haptics)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios)

