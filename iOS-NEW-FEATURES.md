# 🚀 Новые iOS-нативные функции

## ✅ Что добавлено

### 1. 🔐 Face ID / Touch ID Аутентификация
**Биометрическая аутентификация** для входа в приложение:

```tsx
import { useBiometric } from '@/hooks/useBiometric';

function YourComponent() {
  const { 
    isAvailable,       // true если биометрия доступна
    biometricType,     // 'faceId' | 'touchId' | 'none'
    authenticate,      // функция для аутентификации
    getBiometricName,  // "Face ID" или "Touch ID"
    getBiometricIcon   // 👤 или 👆
  } = useBiometric();
  
  const handleLogin = async () => {
    const result = await authenticate('Войдите в приложение');
    if (result.success) {
      // Успешная аутентификация!
    } else {
      console.error(result.error);
    }
  };
}
```

**Функции из capacitor.ts:**
```tsx
import { 
  isBiometricAvailable,
  authenticateWithBiometric 
} from '@/utils/capacitor';

// Проверить доступность
const { available, type } = await isBiometricAvailable();

// Запросить аутентификацию
const { success, error } = await authenticateWithBiometric('Причина');
```

### 2. 📤 Share & Export Функционал
**Нативное iOS Share Sheet** для экспорта данных:

```tsx
import { 
  shareContent, 
  shareDataAsCSV 
} from '@/utils/capacitor';

// Поделиться текстом/ссылкой
await shareContent({
  title: 'Мой отчет',
  text: 'Посмотри мой бюджет!',
  url: 'https://example.com',
  dialogTitle: 'Поделиться отчетом'
});

// Экспорт данных в CSV
await shareDataAsCSV(
  transactions,        // массив данных
  'transactions.csv',  // имя файла
  'Экспорт транзакций' // заголовок
);
```

**Web Share API fallback** для веб-версии.

### 3. 🔃 Pull to Refresh
**Уже активирован на Dashboard!** Потяните экран вниз для обновления данных.

Готовый компонент для других страниц:
```tsx
import { PullToRefresh } from '@/components/PullToRefresh';

<PullToRefresh onRefresh={async () => await loadData()}>
  <YourContent />
</PullToRefresh>
```

### 4. 📋 iOS Action Sheet
**Нативное iOS модальное окно** снизу экрана:

```tsx
import { ActionSheet, useActionSheet } from '@/components/ActionSheet';

function YourComponent() {
  const { show, hide, ActionSheet } = useActionSheet();
  
  const handleShowOptions = () => {
    show({
      title: 'Выберите действие',
      description: 'Что вы хотите сделать?',
      actions: [
        {
          label: 'Редактировать',
          icon: <Edit className="w-5 h-5" />,
          onClick: () => handleEdit(),
          variant: 'default'
        },
        {
          label: 'Удалить',
          icon: <Trash className="w-5 h-5" />,
          onClick: () => handleDelete(),
          variant: 'destructive'
        }
      ],
      cancelLabel: 'Отмена'
    });
  };
  
  return (
    <>
      <button onClick={handleShowOptions}>Опции</button>
      {ActionSheet}
    </>
  );
}
```

### 5. ⏱️ Long Press Context Menu
**Меню по долгому нажатию** (как в iOS):

```tsx
import { LongPressMenu } from '@/components/LongPressMenu';

<LongPressMenu
  items={[
    {
      label: 'Копировать',
      icon: <Copy className="w-4 h-4" />,
      onClick: () => handleCopy()
    },
    {
      label: 'Удалить',
      icon: <Trash className="w-4 h-4" />,
      onClick: () => handleDelete(),
      variant: 'destructive',
      separator: true
    }
  ]}
>
  <YourCard />
</LongPressMenu>
```

**Автоматическая вибрация** при активации меню!

### 6. 📳 Расширенный Haptic Feedback
**Уже встроен** во все новые компоненты:
- **Action Sheet** - вибрация при выборе
- **Long Press Menu** - вибрация при активации
- **Share** - вибрация при открытии
- **Биометрия** - вибрация при успехе/ошибке

**Доступные функции:**
```tsx
import { 
  vibrate,           // 'light' | 'medium' | 'heavy'
  notificationHaptic, // для уведомлений
  selectionHaptic    // для выбора элементов
} from '@/utils/capacitor';

await vibrate('medium');
await notificationHaptic();
await selectionHaptic();
```

### 7. 🎨 iOS Animations & Transitions
**Улучшенные анимации** во всех новых компонентах:
- Action Sheet - плавное появление снизу с handle
- Context Menu - fade-in с bounce
- Pull to Refresh - плавное растягивание
- Кнопки - `active:scale-95` для тактильного отклика

**CSS классы** уже готовы в `ios-native.css`:
```css
.ios-sheet          /* iOS-стиль bottom sheet */
.ios-button         /* iOS-стиль кнопка с анимацией */
.ios-card           /* iOS-стиль карточка */
.ios-blur           /* Blur эффект */
```

## 🚀 Готовые компоненты для использования

### SwipeableCard (уже есть!)
```tsx
import { SwipeableCard } from '@/components/SwipeableCard';

<SwipeableCard
  onDelete={() => handleDelete()}
  onEdit={() => handleEdit()}
>
  <TransactionCard />
</SwipeableCard>
```

## 📝 Использование

### В Settings - добавить биометрию:
```tsx
import { useBiometric } from '@/hooks/useBiometric';

const { isAvailable, biometricType, getBiometricName } = useBiometric();

{isAvailable && (
  <div className="flex items-center justify-between">
    <div>
      <span>{getBiometricName()}</span>
      <p className="text-sm text-muted-foreground">
        Использовать {getBiometricName()} для входа
      </p>
    </div>
    <Switch />
  </div>
)}
```

### В Reports - добавить экспорт:
```tsx
import { shareDataAsCSV } from '@/utils/capacitor';

<Button onClick={() => shareDataAsCSV(transactions, 'report.csv')}>
  <Share className="w-4 h-4 mr-2" />
  Экспортировать
</Button>
```

### В Transactions - добавить свайпы и контекст-меню:
```tsx
import { SwipeableCard } from '@/components/SwipeableCard';
import { LongPressMenu } from '@/components/LongPressMenu';

{transactions.map(tx => (
  <SwipeableCard
    key={tx.id}
    onDelete={() => deleteTransaction(tx.id)}
    onEdit={() => editTransaction(tx)}
  >
    <LongPressMenu
      items={[
        { label: 'Копировать', onClick: () => copy(tx) },
        { label: 'Поделиться', onClick: () => share(tx) },
        { label: 'Удалить', onClick: () => delete(tx), variant: 'destructive' }
      ]}
    >
      <TransactionCard transaction={tx} />
    </LongPressMenu>
  </SwipeableCard>
))}
```

## 🔧 Настройка в Xcode

### Для Face ID:
1. Откройте `ios/App/App/Info.plist`
2. Добавьте ключ:
```xml
<key>NSFaceIDUsageDescription</key>
<string>Войти в приложение с помощью Face ID</string>
```

Это **уже сделано автоматически** при установке плагина!

## 📦 Установленные плагины

- ✅ `@aparajita/capacitor-biometric-auth` - Face ID / Touch ID
- ✅ `@capacitor/share` - Share Sheet
- ✅ `@capacitor/haptics` - Вибрация
- ✅ `@capacitor/status-bar` - Status Bar
- ✅ `@capacitor/splash-screen` - Splash Screen
- ✅ Остальные Capacitor плагины

## 🎯 Следующие шаги

1. **Добавить SwipeableCard** в Transactions и Categories
2. **Добавить биометрию** в Settings как опцию
3. **Добавить экспорт** в Reports
4. **Добавить Pull to Refresh** на все страницы
5. **Заменить алерты** на Action Sheets
6. **Добавить Context Menu** на карточки

## 🔄 Пересборка

```bash
npm run ios:sync
# В Xcode нажать Play (▶️)
```

## 🐛 Тестирование

- **Биометрия** - работает только на реальном устройстве
- **Haptic Feedback** - не ощущается на симуляторе
- **Pull to Refresh** - работает везде
- **Action Sheets** - работают везде
- **Context Menu** - работает везде
- **Share** - работает везде (но лучше на устройстве)

## 💡 Советы

1. **Всегда добавляйте haptic** к интерактивным элементам
2. **Используйте Action Sheet** вместо обычных dialogs для важных действий
3. **Context Menu** отлично подходит для quick actions
4. **Pull to Refresh** - обязателен для списков данных
5. **Биометрия** - опциональна, но увеличивает UX

## 🎉 Результат

Теперь ваше приложение **выглядит и ощущается как настоящее iOS приложение**!

- ✅ Face ID / Touch ID
- ✅ Native Share
- ✅ Pull to Refresh
- ✅ Action Sheets
- ✅ Context Menus
- ✅ Haptic Feedback везде
- ✅ iOS-стиль анимации
- ✅ Swipe Gestures

**Версия обновлена до 1.0.24!** 🚀

