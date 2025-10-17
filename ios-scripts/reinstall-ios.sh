#!/bin/bash

# 🔄 Скрипт для переустановки приложения на iPhone (каждые 7 дней)
# Запуск: ./ios-scripts/reinstall-ios.sh

set -e

echo "🔄 CrystalBudget iOS Reinstall"
echo "=============================="
echo ""

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Синхронизация изменений
echo "🔄 Syncing latest changes..."
npx cap sync ios
echo -e "${GREEN}✅ Sync complete${NC}"
echo ""

# Открыть Xcode
echo "📱 Opening Xcode..."
npx cap open ios
echo ""

echo "=============================="
echo -e "${GREEN}✅ Ready to reinstall${NC}"
echo "=============================="
echo ""
echo "In Xcode:"
echo "  1. Make sure your iPhone is connected"
echo "  2. Select your iPhone device"
echo "  3. Click Play (▶️) button"
echo ""
echo -e "${YELLOW}⏱️  This will extend the app validity for another 7 days${NC}"
echo ""



