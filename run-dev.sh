#!/bin/bash

# Скрипт для запуска бота в режиме разработки
# Устанавливает необходимые переменные окружения и запускает бот

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔄 Настройка переменных окружения...${NC}"

# Настройка переменных окружения
export PORT=2999 # Используем порт 2999 как в .env
export TEST_BOT_NAME=ai_koshey_bot # Бот для тестирования
export ORIGIN=http://localhost:2999 # Локальный сервер с правильным портом
export NODE_ENV=development

echo -e "${GREEN}✅ Переменные окружения установлены:${NC}"
echo -e "📌 PORT=${BLUE}$PORT${NC}"
echo -e "📌 TEST_BOT_NAME=${BLUE}$TEST_BOT_NAME${NC}"
echo -e "📌 ORIGIN=${BLUE}$ORIGIN${NC}"
echo -e "📌 NODE_ENV=${BLUE}$NODE_ENV${NC}"

echo -e "${YELLOW}🚀 Запуск бота...${NC}"

# Запуск через pnpm или npm в зависимости от того, что доступно
if command -v pnpm &> /dev/null; then
    pnpm dev
elif command -v npm &> /dev/null; then
    npm run dev
else
    echo -e "${RED}❌ Не найдены pnpm или npm. Установите их для запуска бота.${NC}"
    exit 1
fi 