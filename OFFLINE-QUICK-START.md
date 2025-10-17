# 📴 Offline-First: Быстрый старт

## Что изменилось?

### ❌ Было (медленно):
```
App → Supabase → App
       ⬆️ ⬇️
   (Интернет нужен)
```

### ✅ Стало (мгновенно):
```
App → Локальное хранилище → App
     (Работает офлайн!)

Supabase (опционально):
- Только аутентификация
- Резервные копии
```

---

## Использование

### 1. Транзакции

```tsx
import { useLocalTransactions } from '@/hooks/useLocalTransactions';

function MyComponent() {
  const { 
    transactions,     // Все транзакции (мгновенно)
    addTransaction,   // Добавить (мгновенно)
    updateTransaction,// Обновить (мгновенно)
    removeTransaction,// Удалить (мгновенно)
  } = useLocalTransactions(userId);

  // Добавить транзакцию
  await addTransaction({
    amount: 1000,
    category_id: 'cat_1',
    description: 'Продукты',
    date: new Date().toISOString(),
  });
  // ✅ Сохранено мгновенно, офлайн работает!
}
```

### 2. Категории

```tsx
import { useLocalCategories } from '@/hooks/useLocalCategories';

const { 
  categories,
  addCategory,
  updateCategory,
  removeCategory,
} = useLocalCategories(userId);
```

### 3. Индикатор синхронизации

```tsx
import { SyncIndicator } from '@/components/SyncIndicator';

<SyncIndicator />
// Показывает:
// - ✅ Синхронизировано
// - 🔄 Синхронизация...
// - ⚠️ 5 не синхронизировано
```

---

## Что хранится где?

### 📱 На устройстве (мгновенно):
- Все транзакции
- Все категории
- Все доходы
- История изменений

### ☁️ В Supabase (опционально):
- Учетные записи
- Настройки профиля
- Резервные копии

---

## Преимущества

### ⚡️ Скорость
- **Без офлайна**: 200-1000ms на запрос
- **С офлайном**: <1ms на запрос
- **Разница**: в 200-1000 раз быстрее!

### 📴 Работает без интернета
- Авиарежим - ОК
- Плохая сеть - ОК
- Нет интернета - ОК

### 💾 Ваши данные
- Хранятся на вашем устройстве
- Полный контроль
- Приватность

---

## Интеграция в существующий код

### Шаг 1: Заменить Supabase на Local

**Было:**
```tsx
const { data } = await supabase
  .from('transactions')
  .select('*');
```

**Стало:**
```tsx
const { transactions } = useLocalTransactions(userId);
```

### Шаг 2: Использовать хуки

**Добавление:**
```tsx
await addTransaction({ amount, category_id, description, date });
```

**Удаление:**
```tsx
await removeTransaction(id);
```

**Обновление:**
```tsx
await updateTransaction(id, { amount: 2000 });
```

---

## Миграция данных

### Для новых пользователей
Всё работает автоматически! 🎉

### Для существующих (с данными в Supabase)

```tsx
import { migrateFromSupabase } from '@/utils/migration';

// При первом запуске
await migrateFromSupabase(userId);
// Загрузит все данные из Supabase → Локально
```

---

## FAQ

### Нужен ли интернет?
**Нет!** Приложение полностью работает офлайн.

### Что с синхронизацией?
Опциональная. Можно включить в настройках.

### Что если удалю приложение?
Локальные данные потеряются. Используйте бэкапы.

### Как бэкапить?
```tsx
import { exportAllData } from '@/utils/localStorage';
const backup = await exportAllData();
// Сохранить backup в облако или отправить себе
```

### Безопасно ли?
Да! Данные зашифрованы iOS Keychain.

---

## Статистика

```tsx
import { getStorageStats } from '@/utils/localStorage';

const stats = await getStorageStats();
// {
//   transactions: 342,
//   categories: 18,
//   incomes: 67,
//   totalItems: 427,
//   pendingSync: 0
// }
```

---

## Документация

- **Полная документация**: `OFFLINE-FIRST.md`
- **API Reference**: см. в коде
- **Примеры**: см. hooks

---

**CrystalBudget теперь работает молниеносно быстро!** ⚡️

Вся магия - в локальном хранилище 📱

