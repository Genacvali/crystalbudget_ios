#!/bin/bash

# Скрипт для обновления иконки приложения и splash screen
# Использование: ./scripts/update-app-icon.sh <путь_к_иконке>

set -e

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎨 Обновление иконки приложения...${NC}"

# Проверяем аргумент
if [ -z "$1" ]; then
    echo -e "${RED}❌ Ошибка: Укажите путь к иконке${NC}"
    echo "Использование: $0 <путь_к_иконке.png>"
    exit 1
fi

SOURCE_ICON="$1"

# Проверяем существование файла
if [ ! -f "$SOURCE_ICON" ]; then
    echo -e "${RED}❌ Файл не найден: $SOURCE_ICON${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Исходная иконка: $SOURCE_ICON${NC}"

# Копируем в public для PWA
echo -e "${BLUE}📱 Обновляем PWA иконки...${NC}"
cp "$SOURCE_ICON" "public/pwa-icon.png"
cp "$SOURCE_ICON" "public/pwa-512x512.png"

# Генерируем 192x192 для PWA
sips -z 192 192 "$SOURCE_ICON" --out "public/pwa-192x192.png" > /dev/null 2>&1

echo -e "${GREEN}✓ PWA иконки обновлены${NC}"

# Проверяем наличие sips (macOS инструмент для работы с изображениями)
if ! command -v sips &> /dev/null; then
    echo -e "${RED}❌ sips не найден. Используется только на macOS${NC}"
    exit 1
fi

# Директория для iOS иконок
IOS_ICONSET="ios/App/App/Assets.xcassets/AppIcon.appiconset"

echo -e "${BLUE}🍎 Генерируем iOS иконки...${NC}"

# Размеры для iOS
# iPhone
sips -z 40 40 "$SOURCE_ICON" --out "$IOS_ICONSET/icon-40.png" > /dev/null 2>&1
sips -z 60 60 "$SOURCE_ICON" --out "$IOS_ICONSET/icon-60.png" > /dev/null 2>&1
sips -z 58 58 "$SOURCE_ICON" --out "$IOS_ICONSET/icon-58.png" > /dev/null 2>&1
sips -z 87 87 "$SOURCE_ICON" --out "$IOS_ICONSET/icon-87.png" > /dev/null 2>&1
sips -z 80 80 "$SOURCE_ICON" --out "$IOS_ICONSET/icon-80.png" > /dev/null 2>&1
sips -z 120 120 "$SOURCE_ICON" --out "$IOS_ICONSET/icon-120.png" > /dev/null 2>&1
sips -z 180 180 "$SOURCE_ICON" --out "$IOS_ICONSET/icon-180.png" > /dev/null 2>&1

# iPad
sips -z 20 20 "$SOURCE_ICON" --out "$IOS_ICONSET/icon-20.png" > /dev/null 2>&1
sips -z 29 29 "$SOURCE_ICON" --out "$IOS_ICONSET/icon-29.png" > /dev/null 2>&1
sips -z 76 76 "$SOURCE_ICON" --out "$IOS_ICONSET/icon-76.png" > /dev/null 2>&1
sips -z 152 152 "$SOURCE_ICON" --out "$IOS_ICONSET/icon-152.png" > /dev/null 2>&1
sips -z 167 167 "$SOURCE_ICON" --out "$IOS_ICONSET/icon-167.png" > /dev/null 2>&1

# App Store
sips -z 1024 1024 "$SOURCE_ICON" --out "$IOS_ICONSET/icon-1024.png" > /dev/null 2>&1

echo -e "${GREEN}✓ iOS иконки сгенерированы${NC}"

# Обновляем splash screen
echo -e "${BLUE}🌟 Обновляем Splash Screen...${NC}"

SPLASH_DIR="ios/App/App/Assets.xcassets/Splash.imageset"
mkdir -p "$SPLASH_DIR"

# Создаём splash с кристаллом в центре на тёмном фоне
# Размер для 2x (750x1334 для iPhone 8)
sips -z 1334 750 "$SOURCE_ICON" --out "$SPLASH_DIR/splash-2x.png" > /dev/null 2>&1

# Размер для 3x (1242x2208 для iPhone 8 Plus)
sips -z 2208 1242 "$SOURCE_ICON" --out "$SPLASH_DIR/splash-3x.png" > /dev/null 2>&1

# Создаём Contents.json для Splash
cat > "$SPLASH_DIR/Contents.json" << EOF
{
  "images" : [
    {
      "idiom" : "universal",
      "filename" : "splash-2x.png",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "filename" : "splash-3x.png",
      "scale" : "3x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
EOF

echo -e "${GREEN}✓ Splash Screen обновлён${NC}"

# Копируем в assets для использования в React
echo -e "${BLUE}⚛️  Обновляем React assets...${NC}"
mkdir -p "src/assets"
cp "$SOURCE_ICON" "src/assets/crystal-logo.png"
cp "$SOURCE_ICON" "src/assets/crystal-icon.png"

echo -e "${GREEN}✓ React assets обновлены${NC}"

echo ""
echo -e "${GREEN}🎉 Готово! Все иконки обновлены${NC}"
echo ""
echo -e "${BLUE}📝 Следующие шаги:${NC}"
echo "1. npm run ios:sync"
echo "2. Откройте Xcode и запустите приложение"
echo ""

