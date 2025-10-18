# 🚀 Инструкция по запуску CrystalBudget в Xcode

## ✅ **Исправленные проблемы:**

### 1. **Ошибки подписи (Signing)**
- ✅ **Bundle Identifier**: `com.crystalbudget.app`
- ✅ **Code Signing**: Automatic
- ✅ **Development Team**: Personal Team (для тестирования)

### 2. **Пути к файлам и ресурсам**
- ✅ **DEVELOPMENT_ASSET_PATHS**: `"CrystalBudget/Preview Content"`
- ✅ **Assets.xcassets**: создан с AppIcon и AccentColor
- ✅ **Preview Assets**: создан для SwiftUI Preview

### 3. **Настройки проекта**
- ✅ **iOS Deployment Target**: 17.0
- ✅ **Swift Version**: 5.0
- ✅ **Base Internationalization**: включена
- ✅ **Recommended Settings**: обновлены

### 4. **Структура файлов**
- ✅ **Все Swift файлы**: добавлены в проект
- ✅ **CoreData модель**: подключена
- ✅ **WidgetKit**: настроен
- ✅ **App Intents**: подключены

## 🎯 **Пошаговая инструкция:**

### **Шаг 1: Открытие проекта**
```bash
cd /Users/genacvali/Documents/crystalbudget_ios
open CrystalBudget.xcodeproj
```

### **Шаг 2: Настройка подписи**
1. Выберите проект **CrystalBudget** в навигаторе
2. Перейдите в **"Signing & Capabilities"**
3. Выберите **"Personal Team"** (ваше имя)
4. Bundle Identifier: `com.crystalbudget.app` (или измените на уникальный)

### **Шаг 3: Выбор схемы сборки**
1. В верхней панели выберите **CrystalBudget** схему
2. Выберите **симулятор** (например, iPhone 15 Pro)
3. Убедитесь что выбрана схема **Debug**

### **Шаг 4: Запуск приложения**
```bash
# Горячие клавиши
Cmd + R

# Или нажмите кнопку ▶️ в Xcode
```

### **Шаг 5: Проверка работоспособности**
- ✅ **Приложение запускается** без крашей
- ✅ **Онбординг** отображается корректно
- ✅ **Табы** переключаются
- ✅ **Pull-to-refresh** работает
- ✅ **Биометрическая аутентификация** доступна

## 🔧 **Возможные проблемы и решения:**

### **Проблема: "Signing Error"**
```bash
# Решение:
# 1. Выберите Personal Team
# 2. Измените Bundle Identifier на уникальный
# 3. Очистите проект: Product → Clean Build Folder
```

### **Проблема: "Build Failed"**
```bash
# Решение:
# 1. Product → Clean Build Folder (Cmd + Shift + K)
# 2. Product → Build (Cmd + B)
# 3. Проверьте консоль на ошибки
```

### **Проблема: "No such module 'Charts'"**
```bash
# Решение:
# 1. File → Add Package Dependencies
# 2. URL: https://github.com/apple/swift-charts
# 3. Add Package
```

### **Проблема: "Missing Info.plist"**
```bash
# Решение:
# Info.plist уже создан в CrystalBudget/Info.plist
# Проверьте что файл существует
```

## 📱 **Тестирование функций:**

### **Основные функции:**
- ✅ **Онбординг** - пройдите все шаги
- ✅ **Аутентификация** - попробуйте Face ID/Touch ID
- ✅ **Добавление транзакций** - через Quick Add
- ✅ **Pull-to-refresh** - потяните вниз на любом экране
- ✅ **Навигация** - переключитесь между табами

### **Дополнительные функции:**
- ✅ **Сканирование чеков** - через ReceiptScannerView
- ✅ **Виджеты** - добавьте на главный экран
- ✅ **Siri Shortcuts** - попробуйте голосовые команды
- ✅ **Уведомления** - проверьте настройки

## 🎨 **Настройки для разработки:**

### **Build Settings:**
```bash
# Debug Configuration:
# - Optimization Level: None [-O0]
# - Debug Information Format: DWARF with dSYM File
# - Enable Bitcode: No
```

### **Scheme Settings:**
```bash
# Edit Scheme → Run → Info:
# - Build Configuration: Debug
# - Launch: Wait for executable to be launched
```

## 🚀 **Готово к запуску!**

После выполнения всех шагов приложение должно:
- ✅ **Компилироваться** без ошибок
- ✅ **Запускаться** на симуляторе
- ✅ **Работать** со всеми функциями
- ✅ **Отображать** корректный UI

## 📞 **Поддержка:**

Если возникнут проблемы:
1. **Проверьте консоль** Xcode на ошибки
2. **Очистите проект** (Product → Clean Build Folder)
3. **Перезапустите** Xcode
4. **Проверьте** что все файлы на месте

**Удачной разработки!** 🎉
