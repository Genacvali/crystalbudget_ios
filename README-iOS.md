# 📱 CrystalBudget - iOS версия

## 🎯 Статус проекта

Проект **полностью готов** к разработке iOS приложения!

### ✅ Что сделано:

1. ✅ Установлены все необходимые зависимости Capacitor
2. ✅ Создан конфигурационный файл `capacitor.config.ts`
3. ✅ Добавлены утилиты для работы с iOS (`src/utils/capacitor.ts`)
4. ✅ Создан компонент SafeArea для iPhone с notch
5. ✅ Обновлены стили для iOS (Safe Area, убран bouncing)
6. ✅ Добавлена инициализация в `main.tsx`
7. ✅ Добавлены npm скрипты для iOS
8. ✅ Создана документация по установке
9. ✅ Созданы скрипты автоматизации

### ⚠️ Что нужно сделать:

**Обновить Node.js до версии 20+**

Текущая версия: **v16.15.0**  
Требуется: **>= v20.0.0**

---

## 🚀 Быстрый старт

### Шаг 1: Обновить Node.js

См. инструкцию в файле: **`ВАЖНО-ОБНОВИТЬ-NODE.md`**

Быстрый способ через nvm:
```bash
# Установить nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Перезапустить терминал, затем:
nvm install 20
nvm use 20
nvm alias default 20

# Проверить
node --version  # Должно быть v20.x.x
```

### Шаг 2: Переустановить зависимости

```bash
cd /Users/genacvali/Documents/crystalbudget

# Очистить старые зависимости
rm -rf node_modules
rm package-lock.json

# Установить заново
npm install
```

### Шаг 3: Запустить автоматическую настройку iOS

```bash
# Автоматический скрипт (рекомендуется!)
./ios-scripts/setup-ios.sh
```

Или вручную:
```bash
# Собрать проект
npm run build

# Добавить iOS платформу
npm run ios:add

# Открыть в Xcode
npm run ios:open
```

### Шаг 4: Настроить в Xcode и запустить

См. подробную инструкцию в файле: **`iOS-SETUP.md`**

---

## 📁 Структура iOS файлов

```
crystalbudget/
├── capacitor.config.ts           # Конфигурация Capacitor
├── iOS-SETUP.md                  # 📖 Полная инструкция по установке
├── ВАЖНО-ОБНОВИТЬ-NODE.md        # ⚠️ Инструкция по обновлению Node.js
├── README-iOS.md                 # 📄 Этот файл
│
├── ios-scripts/                  # 🛠️ Скрипты автоматизации
│   ├── setup-ios.sh             # Первоначальная настройка
│   └── reinstall-ios.sh         # Переустановка каждые 7 дней
│
├── ios/                          # 📱 iOS проект (создается после setup)
│   ├── App/
│   │   ├── App.xcworkspace      # ← Открывать этот файл в Xcode!
│   │   ├── Podfile              # CocoaPods зависимости
│   │   └── App/
│   │       ├── Info.plist       # Разрешения iOS
│   │       └── Assets.xcassets/ # Иконки и splash screens
│   └── README.md
│
└── src/
    ├── utils/
    │   └── capacitor.ts          # 🔧 Утилиты для iOS/Android
    ├── components/
    │   └── SafeArea.tsx          # 📱 Компонент для Safe Area
    └── main.tsx                  # ✅ Обновлен с инициализацией
```

---

## 🛠️ Доступные команды

### iOS разработка:

```bash
# Добавить iOS платформу (один раз)
npm run ios:add

# Синхронизировать изменения после правки кода
npm run ios:sync

# Открыть проект в Xcode
npm run ios:open

# Запустить на подключенном iPhone
npm run ios:run

# Полная сборка: build + sync + open
npm run ios:build
```

### Утилиты:

```bash
# Автоматическая настройка iOS
./ios-scripts/setup-ios.sh

# Переустановка на iPhone (каждые 7 дней)
./ios-scripts/reinstall-ios.sh

# Очистка iOS проекта
npm run mobile:clean
```

---

## 🎨 iOS-специфичные функции

### 1. Инициализация приложения

```typescript
// src/utils/capacitor.ts
import { initializeApp } from '@/utils/capacitor';

// Автоматически вызывается в main.tsx
initializeApp(); // Настраивает status bar, splash screen, обработчики
```

### 2. Работа с камерой (сканирование чеков)

```typescript
import { takePhoto, pickPhoto } from '@/utils/capacitor';

// Сделать фото
const photoBase64 = await takePhoto();

// Выбрать из галереи
const photoBase64 = await pickPhoto();
```

### 3. Тактильная отдача (Haptics)

```typescript
import { vibrate } from '@/utils/capacitor';

// Легкая вибрация
await vibrate('light');

// Средняя
await vibrate('medium');

// Сильная
await vibrate('heavy');
```

### 4. Safe Area (для iPhone с notch)

```tsx
import { SafeArea } from '@/components/SafeArea';

function MyComponent() {
  return (
    <SafeArea>
      {/* Контент с автоматическими отступами для notch */}
    </SafeArea>
  );
}
```

### 5. Определение платформы

```typescript
import { isIOS, isAndroid, isNative, platform } from '@/utils/capacitor';

if (isIOS) {
  // Код только для iOS
}

if (isNative) {
  // Код для нативного приложения (iOS/Android)
} else {
  // Код для веб-версии
}
```

---

## 📖 Документация

| Файл | Описание |
|------|----------|
| **iOS-SETUP.md** | 📖 Полная инструкция по установке на iPhone |
| **ВАЖНО-ОБНОВИТЬ-NODE.md** | ⚠️ Инструкция по обновлению Node.js |
| **README-iOS.md** | 📄 Этот файл (краткий обзор) |
| **ios/README.md** | 📱 Информация о iOS проекте |

---

## 🔄 Процесс разработки

### 1. Первая установка:

```bash
# 1. Обновить Node.js >= 20
nvm install 20 && nvm use 20

# 2. Переустановить зависимости
rm -rf node_modules && npm install

# 3. Запустить автоматическую настройку
./ios-scripts/setup-ios.sh

# 4. Открыть Xcode и установить на iPhone
npm run ios:open
```

### 2. Ежедневная разработка:

```bash
# Внести изменения в код React...

# Синхронизировать с iOS
npm run ios:sync

# В Xcode нажать Play (▶️)
```

### 3. Переустановка каждые 7 дней:

```bash
# Быстрая переустановка
./ios-scripts/reinstall-ios.sh

# В Xcode нажать Play (▶️)
```

---

## 🎯 Следующие шаги

### После обновления Node.js:

1. ✅ Запустить `./ios-scripts/setup-ios.sh`
2. ✅ Открыть Xcode: `npm run ios:open`
3. ✅ Войти Apple ID в Xcode
4. ✅ Подключить iPhone
5. ✅ Нажать Play (▶️)
6. ✅ Доверить разработчику на iPhone
7. ✅ Протестировать приложение!

### Что тестировать:

- [ ] Авторизация
- [ ] Добавление доходов/расходов
- [ ] Сканирование чеков через камеру
- [ ] AI помощник G.A.I.A.
- [ ] Telegram интеграция
- [ ] Тактильная отдача при нажатиях
- [ ] Safe Area на iPhone с notch
- [ ] Переключение между вкладками

---

## 🐛 Решение проблем

### Node.js старый:
**См.** `ВАЖНО-ОБНОВИТЬ-NODE.md`

### Ошибка при `npx cap add ios`:
```bash
# Убедитесь что Node.js >= 20
node --version

# Переустановите зависимости
rm -rf node_modules && npm install
```

### Xcode не открывается:
```bash
# Проверить установку Xcode
xcodebuild -version

# Открыть вручную
open ios/App/App.xcworkspace
```

### CocoaPods ошибка:
```bash
# Переустановить CocoaPods
sudo gem install cocoapods

# Обновить Pods
cd ios/App
pod install
```

---

## 📞 Поддержка

- 📖 Полная инструкция: `iOS-SETUP.md`
- ⚠️ Обновление Node.js: `ВАЖНО-ОБНОВИТЬ-NODE.md`
- 🐛 Логи Xcode: см. внизу Xcode после запуска
- 🔍 Safari Web Inspector: для отладки на устройстве

---

## 🎉 Итого

Проект **готов к iOS разработке**!

**Осталось только:**
1. Обновить Node.js до v20+
2. Запустить `./ios-scripts/setup-ios.sh`
3. Наслаждаться нативным iOS приложением! 🚀

---

**Создано:** Октябрь 2025  
**Версия:** 1.0  
**Платформа:** iOS 13.0+  
**Технология:** React + Capacitor



