# 🚀 iOS Features Quick Start

## Что добавлено

### ✅ Иконка приложения
- Красивая иконка с кристаллом установлена
- Автоматически применяется в iOS

### 🔄 Swipe Gestures
**Компонент готов к использованию:**
```tsx
import { SwipeableCard } from '@/components/SwipeableCard';

<SwipeableCard
  onDelete={() => deleteItem()}
  onEdit={() => editItem()}
>
  <YourCard />
</SwipeableCard>
```

### 🔃 Pull-to-Refresh
**Компонент готов:**
```tsx
import { PullToRefresh } from '@/components/PullToRefresh';

<PullToRefresh onRefresh={async () => await refresh()}>
  <Content />
</PullToRefresh>
```

### 🔔 Push Notifications
- Автоматически инициализируются
- Запрос разрешений при первом запуске
- Haptic feedback при получении

### 🎨 iOS Native Styles
**CSS классы:**
```html
<div class="ios-card">iOS Card</div>
<button class="ios-button">iOS Button</button>
<input class="ios-input" />
<div class="ios-blur">Blur Effect</div>
```

### 📳 Haptic Feedback
```tsx
import { vibrate, notificationHaptic, selectionHaptic } from '@/utils/capacitor';

await vibrate('light');        // Легкая
await vibrate('medium');       // Средняя
await vibrate('heavy');        // Сильная
await notificationHaptic();    // Уведомление
await selectionHaptic();       // Выбор
```

## Запуск в Xcode

```bash
# Пересобрать и синхронизировать
npm run ios:sync

# Открыть Xcode
npx cap open ios

# В Xcode нажать Play (▶️)
```

## Тестирование

### На симуляторе:
1. В Xcode выберите iPhone 17 Pro (или любой)
2. Нажмите Play (▶️)
3. Все работает кроме Push Notifications

### На реальном iPhone:
1. Подключите iPhone кабелем
2. В Xcode выберите ваш iPhone
3. Нажмите Play (▶️)
4. На iPhone доверьте разработчику
5. Все фичи работают!

## Что попробовать

### 1. Свайп на карточках транзакций
- Открыть транзакции
- Свайпнуть карточку влево
- Появятся кнопки Удалить/Редактировать

### 2. Pull-to-Refresh на Dashboard
- Открыть Dashboard
- Потянуть экран вниз
- Данные обновятся

### 3. Push Notifications (на iPhone)
- При первом запуске разрешить уведомления
- Токен будет в логах Xcode
- Можно отправить тестовое уведомление

### 4. Haptic Feedback
- Нажимать на кнопки
- Добавлять транзакции
- Открывать меню
- Свайпать карточки

### 5. iOS Native UI
- Все карточки с blur эффектом
- SF Pro Display шрифт
- Плавные анимации
- Dark Mode поддержка

## Настройка Push Notifications в Xcode

### Добавить Capability:
1. Открыть проект в Xcode
2. Выбрать target "App"
3. Вкладка "Signing & Capabilities"
4. Нажать "+ Capability"
5. Добавить "Push Notifications"

### Background Modes (опционально):
1. Нажать "+ Capability"
2. Добавить "Background Modes"
3. Включить "Remote notifications"

## Полезные команды

```bash
# Пересобрать проект
npm run build

# Синхронизировать iOS
npx cap sync ios

# Открыть Xcode
npx cap open ios

# Всё сразу
npm run ios:sync && npx cap open ios

# Переустановить иконки
./scripts/generate-ios-icons.sh
```

## Документация

- **Полная документация**: `iOS-FEATURES.md`
- **План развития**: `ios-native-features.md`
- **Установка**: `iOS-SETUP.md`

## Что дальше?

Теперь можно интегрировать эти компоненты в существующие страницы:

1. **Transactions** - добавить SwipeableCard
2. **Dashboard** - добавить PullToRefresh
3. **Все кнопки** - добавить haptic feedback
4. **Модальные окна** - применить .ios-modal класс
5. **Карточки** - применить .ios-card класс

---

**Готово к использованию! 🎉**

Запустите в Xcode и попробуйте все фишки!

