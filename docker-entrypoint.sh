#!/bin/sh
set -e

echo "🔍 Проверка рабочей директории и файловой структуры..."
pwd
ls -la /app
ls -la /app/dist || echo "Директория dist не существует!"

# Создаем необходимые директории
echo "📁 Создание необходимых директорий..."
mkdir -p /app/logs
mkdir -p /app/dist/utils
mkdir -p /app/dist/helpers/error
mkdir -p /app/dist/interfaces
mkdir -p /app/dist/core/bot
mkdir -p /app/dist/core/supabase

# Проверяем наличие необходимых модулей
echo "📦 Проверка наличия модуля winston..."
if [ ! -d "/app/node_modules/winston" ]; then
  echo "⚠️ Модуль winston не найден. Устанавливаем..."
  cd /app && npm install winston --save
else
  echo "✅ Модуль winston найден."
fi

# Проверяем существование файла bot.js
if [ ! -f "/app/dist/bot.js" ]; then
  echo "❌ Файл /app/dist/bot.js не найден. Выполняем сборку..."
  cd /app && npm run build
  
  # Проверяем снова
  if [ ! -f "/app/dist/bot.js" ]; then
    echo "❌ Критическая ошибка: Не удалось создать файл bot.js. Проверяем содержимое директории dist:"
    ls -la /app/dist/
    echo "Содержимое src директории:"
    ls -la /app/src/
  fi
else
  echo "✅ Файл /app/dist/bot.js найден."
fi

# Запускаем node приложение
echo "🚀 Запуск приложения..."
cd /app
ls -la /app/dist
exec "$@" 