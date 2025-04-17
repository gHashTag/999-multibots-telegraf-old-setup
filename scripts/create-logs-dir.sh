#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Создание необходимых директорий и подготовка к сборке...${NC}"

# Создаем директории для логирования и компилированных файлов
echo -e "${YELLOW}📁 Создание директорий для логов и компилированных файлов...${NC}"
mkdir -p dist/utils
mkdir -p dist/helpers/error
mkdir -p dist/interfaces
mkdir -p dist/core/bot
mkdir -p dist/core/supabase
mkdir -p logs

# Убедимся, что у нас есть пустой файл winston.js в node_modules
echo -e "${YELLOW}📦 Проверка наличия модуля winston...${NC}"
if [ ! -d "node_modules/winston" ]; then
    echo -e "${RED}❌ Модуль winston не найден. Устанавливаем...${NC}"
    npm install winston --save
else
    echo -e "${GREEN}✅ Модуль winston найден.${NC}"
fi

echo -e "${GREEN}✅ Все необходимые директории созданы!${NC}"
echo -e "${GREEN}✅ Подготовка к сборке завершена успешно!${NC}"

exit 0 