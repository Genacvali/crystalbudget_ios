#!/bin/bash

# 📱 Скрипт автоматической настройки iOS для CrystalBudget
# Запуск: chmod +x ios-scripts/setup-ios.sh && ./ios-scripts/setup-ios.sh

set -e  # Остановить при ошибке

echo "🚀 CrystalBudget iOS Setup"
echo "=========================="
echo ""

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Проверка Node.js версии
echo "📦 Checking Node.js version..."
NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)

if [ "$NODE_VERSION" -lt 20 ]; then
    echo -e "${RED}❌ Node.js version $NODE_VERSION is too old${NC}"
    echo -e "${YELLOW}⚠️  Required: Node.js >= 20.0.0${NC}"
    echo ""
    echo "Please update Node.js:"
    echo "  1. Using nvm: nvm install 20 && nvm use 20"
    echo "  2. Using Homebrew: brew install node@20"
    echo "  3. Download from: https://nodejs.org/"
    echo ""
    echo "See ВАЖНО-ОБНОВИТЬ-NODE.md for details"
    exit 1
fi

echo -e "${GREEN}✅ Node.js version: $(node --version)${NC}"
echo ""

# Проверка наличия Xcode
echo "🔍 Checking Xcode..."
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode is not installed${NC}"
    echo "Please install Xcode from App Store"
    exit 1
fi

XCODE_VERSION=$(xcodebuild -version | head -n1)
echo -e "${GREEN}✅ $XCODE_VERSION${NC}"
echo ""

# Проверка CocoaPods
echo "📦 Checking CocoaPods..."
if ! command -v pod &> /dev/null; then
    echo -e "${YELLOW}⚠️  CocoaPods is not installed${NC}"
    echo "Installing CocoaPods..."
    sudo gem install cocoapods
else
    echo -e "${GREEN}✅ CocoaPods $(pod --version)${NC}"
fi
echo ""

# Проверка зависимостей
echo "📦 Checking dependencies..."
if [ ! -d "node_modules" ]; then
    echo "Installing npm dependencies..."
    npm install
else
    echo -e "${GREEN}✅ node_modules exists${NC}"
fi
echo ""

# Сборка веб-версии
echo "🔨 Building web version..."
npm run build
echo -e "${GREEN}✅ Build complete${NC}"
echo ""

# Добавление iOS платформы
echo "📱 Adding iOS platform..."
if [ -d "ios" ]; then
    echo -e "${YELLOW}⚠️  ios/ folder already exists${NC}"
    read -p "Remove and recreate? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing ios/ folder..."
        rm -rf ios
        npx cap add ios
    else
        echo "Skipping iOS platform creation"
    fi
else
    npx cap add ios
fi
echo -e "${GREEN}✅ iOS platform added${NC}"
echo ""

# Синхронизация
echo "🔄 Syncing with iOS..."
npx cap sync ios
echo -e "${GREEN}✅ Sync complete${NC}"
echo ""

# Финальные инструкции
echo "=============================="
echo -e "${GREEN}✅ iOS Setup Complete!${NC}"
echo "=============================="
echo ""
echo "Next steps:"
echo "  1. Open Xcode:        npm run ios:open"
echo "  2. In Xcode:"
echo "     - Sign in with your Apple ID"
echo "     - Select your iPhone device"
echo "     - Click Play (▶️) button"
echo ""
echo "See iOS-SETUP.md for detailed instructions"
echo ""



