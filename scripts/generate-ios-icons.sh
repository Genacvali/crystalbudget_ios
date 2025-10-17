#!/bin/zsh

# Скрипт для генерации iOS App Icons из исходной иконки

set -e

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎨 Генерация iOS App Icons...${NC}"

# Путь к исходной иконке
SOURCE_ICON="public/pwa-512x512.png"
IOS_ASSETS_DIR="ios/App/App/Assets.xcassets/AppIcon.appiconset"

# Проверка наличия исходной иконки
if [ ! -f "$SOURCE_ICON" ]; then
    echo "❌ Файл $SOURCE_ICON не найден!"
    exit 1
fi

# Создание директории для иконок
mkdir -p "$IOS_ASSETS_DIR"

# Размеры иконок для iOS
SIZES=(20 29 40 58 60 76 80 87 120 152 167 180 1024)

# Генерация иконок с помощью sips (встроенная утилита macOS)
for size in $SIZES; do
    output_file="$IOS_ASSETS_DIR/icon-${size}.png"
    echo -e "${GREEN}Создаю иконку ${size}x${size}...${NC}"
    sips -z "$size" "$size" "$SOURCE_ICON" --out "$output_file" > /dev/null 2>&1
done

# Создание Contents.json
cat > "$IOS_ASSETS_DIR/Contents.json" << 'EOF'
{
  "images" : [
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "icon-40.png",
      "scale" : "2x"
    },
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "icon-60.png",
      "scale" : "3x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "icon-58.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "icon-87.png",
      "scale" : "3x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "icon-80.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "icon-120.png",
      "scale" : "3x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "icon-120.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "icon-180.png",
      "scale" : "3x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "icon-20.png",
      "scale" : "1x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "icon-40.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "icon-29.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "icon-58.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "icon-40.png",
      "scale" : "1x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "icon-80.png",
      "scale" : "2x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "icon-76.png",
      "scale" : "1x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "icon-152.png",
      "scale" : "2x"
    },
    {
      "size" : "83.5x83.5",
      "idiom" : "ipad",
      "filename" : "icon-167.png",
      "scale" : "2x"
    },
    {
      "size" : "1024x1024",
      "idiom" : "ios-marketing",
      "filename" : "icon-1024.png",
      "scale" : "1x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
EOF

echo -e "${GREEN}✅ iOS App Icons созданы успешно!${NC}"
echo -e "${BLUE}📁 Иконки находятся в: $IOS_ASSETS_DIR${NC}"

