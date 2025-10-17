# 🚀 Запуск в Xcode

## Способ 1: Через терминал

```bash
# Открыть проект в Xcode
open ios/App/App.xcworkspace
```

## Способ 2: Через Finder

1. Откройте Finder
2. Перейдите в папку проекта: `/Users/genacvali/Documents/crystalbudget_ios`
3. Откройте папку `ios/App/`
4. Дважды кликните на `App.xcworkspace`

## Способ 3: Через Xcode

1. Откройте Xcode
2. File → Open
3. Выберите файл: `ios/App/App.xcworkspace`

---

## В Xcode

### 1. Выберите устройство
- **iPhone Simulator** (для тестирования)
- **Ваш iPhone** (для установки на устройство)

### 2. Настройте подпись (для реального устройства)
- Выберите проект `App` в навигаторе
- Перейдите на вкладку **Signing & Capabilities**
- Выберите **Team** (ваш Apple ID)
- Убедитесь, что **Bundle Identifier** уникален

### 3. Запустите приложение
- Нажмите **Play** (▶️) или `Cmd + R`
- Дождитесь сборки
- Приложение откроется на выбранном устройстве

---

## Возможные проблемы

### Ошибка подписи
```
Signing for "App" requires a development team
```
**Решение**: Выберите Team в Signing & Capabilities

### Ошибка сборки
```
Build failed
```
**Решение**: 
1. Clean Build Folder (`Cmd + Shift + K`)
2. Попробуйте снова

### Приложение не запускается
**Решение**:
1. Убедитесь, что выбран правильный target
2. Проверьте, что устройство подключено
3. Перезапустите Xcode

---

## Готово!

После успешного запуска вы увидите:
- ✅ Splash screen с логотипом CrystalBudget
- ✅ Нативный iOS интерфейс
- ✅ Offline-first функциональность
- ✅ Haptic feedback
- ✅ Push notifications

**Приложение готово к использованию!** 🎉📱
