#!/bin/bash

# ===== 🌈 Скрипт обновления NeuroBlogger 🌈 =====
# Автор: NeuroBlogger AI
# Дата создания: 18.04.2025
# Версия: 1.1

# Устанавливаем цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Функция для форматированного вывода с эмодзи
echo_emoji() {
    echo -e "${2}$1${NC}"
}

# Заголовок
echo_emoji "🚀 Запуск процесса обновления NeuroBlogger..." "${BLUE}"
echo_emoji "=====================================================" "${BLUE}"

# Проверка, запущен ли скрипт от имени root
if [ "$(id -u)" != "0" ]; then
    echo_emoji "❌ Этот скрипт должен быть запущен с правами root." "${RED}"
    exit 1
fi

# Проверяем наличие директории
echo_emoji "📂 Проверка директории проекта..." "${YELLOW}"
if [ ! -d "/opt/app/999-multibots-telegraf" ]; then
    echo_emoji "❌ Директория проекта не найдена!" "${RED}"
    exit 1
fi

# Переходим в директорию проекта
echo_emoji "🔄 Переход в директорию проекта..." "${YELLOW}"
cd /opt/app/999-multibots-telegraf || exit

# Сохраняем текущий хэш коммита
echo_emoji "📌 Сохранение текущего состояния..." "${YELLOW}"
CURRENT_COMMIT=$(git rev-parse HEAD)
echo_emoji "   Текущий коммит: ${CURRENT_COMMIT}" "${CYAN}"

# Получение последних изменений
echo_emoji "⬇️ Получение последних изменений из репозитория..." "${YELLOW}"
git fetch
if [ $? -ne 0 ]; then
    echo_emoji "❌ Ошибка при выполнении git fetch. Обновление прервано." "${RED}"
    exit 1
fi

# Проверка наличия изменений
echo_emoji "🔍 Проверка наличия новых изменений..." "${YELLOW}"
UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")

if [ "$LOCAL" = "$REMOTE" ]; then
    echo_emoji "✅ Система уже обновлена до последней версии." "${GREEN}"
    echo_emoji "   Текущая версия: $(git describe --tags --always)" "${CYAN}"
    
    # Проверка статуса контейнеров
    echo_emoji "🔄 Проверка статуса контейнеров..." "${YELLOW}"
    if [ "$(docker ps -q -f name=999-multibots)" ]; then
        echo_emoji "✅ Контейнеры уже запущены и работают." "${GREEN}"
        
        # Спрашиваем пользователя, хочет ли он перезапустить контейнеры
        echo_emoji "❓ Хотите перезапустить контейнеры? (y/n)" "${PURPLE}"
        read -r restart_anyway
        
        if [ "$restart_anyway" = "y" ] || [ "$restart_anyway" = "Y" ]; then
            echo_emoji "🔄 Перезапуск контейнеров..." "${YELLOW}"
        else
            echo_emoji "✅ Скрипт завершил работу без перезапуска контейнеров." "${GREEN}"
            exit 0
        fi
    else
        echo_emoji "⚠️ Контейнеры не запущены. Запуск контейнеров..." "${YELLOW}"
    fi
else
    # Применение изменений
    echo_emoji "⬇️ Скачивание и применение изменений..." "${YELLOW}"
    git pull
    if [ $? -ne 0 ]; then
        echo_emoji "❌ Ошибка при выполнении git pull. Возвращаемся к предыдущему состоянию." "${RED}"
        git reset --hard "$CURRENT_COMMIT"
        exit 1
    fi
    
    echo_emoji "✅ Обновление успешно применено!" "${GREEN}"
    echo_emoji "   Предыдущая версия: ${CURRENT_COMMIT}" "${CYAN}"
    echo_emoji "   Новая версия: $(git rev-parse HEAD)" "${CYAN}"
    
    # Устанавливаем права на исполнение для всех скриптов
    echo_emoji "🔑 Установка прав на исполнение для скриптов..." "${YELLOW}"
    chmod +x *.sh scripts/*.sh 2>/dev/null
    echo_emoji "✅ Права установлены!" "${GREEN}"
fi

# Проверка конфигурации Docker и Nginx
echo_emoji "🔍 Проверка конфигурации Docker и Nginx..." "${YELLOW}"

# Проверяем, есть ли записи app в /etc/hosts системы и контейнера
if ! grep -q "app" /etc/hosts; then
    echo_emoji "⚠️ В /etc/hosts отсутствует запись для 'app'. Добавляем..." "${YELLOW}"
    echo "172.20.0.2 app" >> /etc/hosts
    echo_emoji "✅ Запись добавлена!" "${GREEN}"
fi

# Проверяем запись в hosts контейнера nginx-proxy
if docker ps -q -f name=nginx-proxy >/dev/null; then
    if ! docker exec nginx-proxy grep -q "app" /etc/hosts; then
        echo_emoji "⚠️ В /etc/hosts контейнера nginx-proxy отсутствует запись для 'app'. Добавляем..." "${YELLOW}"
        docker exec nginx-proxy sh -c 'echo "172.20.0.2 app" >> /etc/hosts'
        echo_emoji "✅ Запись добавлена!" "${GREEN}"
    else
        echo_emoji "✅ Запись 'app' в /etc/hosts контейнера nginx-proxy уже существует." "${GREEN}"
    fi
fi

# Проверка дублирующихся локаций в Nginx
echo_emoji "🔍 Проверка конфигурации Nginx на дубликаты..." "${YELLOW}"
DUPES=$(grep -r "location" /etc/nginx/conf.d/ | sort | uniq -d)
if [ -n "$DUPES" ]; then
    echo_emoji "⚠️ Обнаружены дублирующиеся локации:" "${RED}"
    echo "$DUPES"
    
    # Проверяем наличие конфликта с Gaia_Kamskaia_bot
    GAIA_CONFLICT=$(grep -r "Gaia_Kamskaia_bot" /etc/nginx/conf.d/)
    if [[ $(echo "$GAIA_CONFLICT" | wc -l) -gt 1 ]]; then
        echo_emoji "🔍 Обнаружен конфликт для бота Gaia_Kamskaia_bot!" "${YELLOW}"
        echo "$GAIA_CONFLICT"
        
        # Проверяем наличие bot3.locations
        if grep -q "Gaia_Kamskaia_bot" /etc/nginx/conf.d/bot3.locations; then
            echo_emoji "🔄 Исправление конфликта: переименование локации в bot3.locations..." "${YELLOW}"
            sed -i 's/Gaia_Kamskaia_bot/ZavaraBot/g' /etc/nginx/conf.d/bot3.locations
            echo_emoji "✅ Локация переименована в ZavaraBot!" "${GREEN}"
            
            # Перезагрузка конфигурации Nginx
            if docker exec nginx-proxy nginx -s reload >/dev/null 2>&1; then
                echo_emoji "✅ Конфигурация Nginx перезагружена." "${GREEN}"
            else
                echo_emoji "⚠️ Не удалось перезагрузить конфигурацию Nginx." "${RED}"
            fi
        else
            echo_emoji "⚠️ Файл bot3.locations не содержит упоминаний Gaia_Kamskaia_bot." "${YELLOW}"
        fi
    else
        echo_emoji "✅ Конфликта с Gaia_Kamskaia_bot не обнаружено." "${GREEN}"
    fi
    
    echo_emoji "🔄 Проверка на другие дублирующиеся локации..." "${YELLOW}"
else
    echo_emoji "✅ Дублирующихся локаций не обнаружено." "${GREEN}"
fi

# Тестирование конфигурации Nginx
echo_emoji "🔍 Проверка синтаксиса конфигурации Nginx..." "${YELLOW}"
if docker exec nginx-proxy nginx -t >/dev/null 2>&1; then
    echo_emoji "✅ Конфигурация Nginx корректна." "${GREEN}"
else
    echo_emoji "⚠️ Конфигурация Nginx содержит ошибки. Проверьте конфигурацию вручную." "${RED}"
fi

# Остановка контейнеров
echo_emoji "🛑 Остановка Docker контейнеров..." "${YELLOW}"
docker-compose down
if [ $? -ne 0 ]; then
    echo_emoji "❌ Ошибка при остановке контейнеров. Пробуем docker compose down..." "${RED}"
    docker compose down
    if [ $? -ne 0 ]; then
        echo_emoji "❌ Не удалось остановить контейнеры. Проверьте вручную." "${RED}"
        exit 1
    fi
fi
echo_emoji "✅ Контейнеры остановлены!" "${GREEN}"

# Очистка неиспользуемых ресурсов
echo_emoji "🧹 Очистка неиспользуемых Docker ресурсов..." "${YELLOW}"
docker system prune -f --volumes
echo_emoji "✅ Очистка завершена!" "${GREEN}"

# Сборка и запуск контейнеров
echo_emoji "🏗️ Сборка и запуск Docker контейнеров..." "${YELLOW}"
docker-compose up --build -d
if [ $? -ne 0 ]; then
    echo_emoji "❌ Ошибка при запуске контейнеров через docker-compose. Пробуем docker compose..." "${RED}"
    docker compose up --build -d
    if [ $? -ne 0 ]; then
        echo_emoji "❌ Не удалось запустить контейнеры. Проверьте логи Docker." "${RED}"
        exit 1
    fi
fi
echo_emoji "✅ Контейнеры успешно собраны и запущены!" "${GREEN}"

# Проверка работы контейнеров
echo_emoji "🔍 Проверка работы запущенных контейнеров..." "${YELLOW}"
sleep 5  # Даем контейнерам время на запуск

# Проверяем статус контейнеров
if docker ps -q -f name=999-multibots >/dev/null && docker ps -q -f name=nginx-proxy >/dev/null; then
    echo_emoji "✅ Все контейнеры успешно запущены и работают!" "${GREEN}"
else
    echo_emoji "⚠️ Не все контейнеры запущены. Проверьте статус вручную:" "${RED}"
    docker ps
fi

# Перезапуск Nginx внутри контейнера
echo_emoji "🔄 Перезапуск Nginx в контейнере..." "${YELLOW}"
docker exec nginx-proxy nginx -s reload 2>/dev/null || docker exec nginx-proxy service nginx restart
echo_emoji "✅ Nginx перезапущен!" "${GREEN}"

# Вывод логов для проверки
echo_emoji "📋 Последние логи контейнеров:" "${PURPLE}"
echo_emoji "===== 999-multibots =====" "${BLUE}"
docker logs --tail 10 999-multibots
echo_emoji "===== nginx-proxy =====" "${BLUE}"
docker logs --tail 10 nginx-proxy

# Сообщение об успешном завершении
echo_emoji "=====================================================" "${BLUE}"
echo_emoji "✨ Обновление NeuroBlogger успешно завершено!" "${GREEN}"
echo_emoji "🌐 Система обновлена до версии: $(git describe --tags --always 2>/dev/null || git rev-parse --short HEAD)" "${CYAN}"
echo_emoji "🕒 Время завершения: $(date)" "${CYAN}"
echo_emoji "=====================================================" "${BLUE}"

exit 0
