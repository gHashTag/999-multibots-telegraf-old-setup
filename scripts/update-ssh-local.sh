#!/bin/bash

# ============================================================================
# 🌈 РАДУЖНЫЙ МОСТ - СКРИПТ ОБНОВЛЕНИЯ ЧЕРЕЗ SSH
# Скрипт для обновления проекта NeuroBlogger на удаленном сервере
# Автор: НейроКодер
# Дата: 20.04.2025
# ============================================================================

# Цвета для красивого вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Настройки
SSH_KEY="~/.ssh/id_rsa"
SERVER="root@999-multibots-u14194.vm.elestio.app"
PROJECT_DIR="/opt/app/999-multibots-telegraf"

# =========================== ФУНКЦИИ ===============================

# Функция для печати сообщений с цветом
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Функция для печати заголовков
print_header() {
    local message=$1
    echo ""
    print_message "${CYAN}==== 🌟 ${message} 🌟 ====${NC}"
}

# Функция для проверки успешности выполнения команды
check_result() {
    if [ $? -ne 0 ]; then
        print_message "${RED}❌ Ошибка: $1${NC}"
        exit 1
    else
        print_message "${GREEN}✅ Успешно: $1${NC}"
    fi
}

# Функция для выполнения команды на удаленном сервере
run_ssh_command() {
    local command=$1
    local message=$2
    
    print_message "${YELLOW}🔄 Выполняю: ${command}${NC}"
    output=$(ssh -i ${SSH_KEY} ${SERVER} "${command}" 2>&1)
    result=$?
    
    if [ $result -ne 0 ]; then
        print_message "${RED}❌ Ошибка при выполнении команды:${NC}"
        echo "$output"
        print_message "${RED}Операция прервана.${NC}"
        exit 1
    else
        if [ -n "$message" ]; then
            print_message "${GREEN}✅ $message${NC}"
        fi
        echo "$output"
    fi
    
    return $result
}

# =========================== ОСНОВНОЙ КОД ===============================

print_header "НАЧАЛО ПРОЦЕССА ОБНОВЛЕНИЯ НЕЙРОБЛОГГЕР"
print_message "${PURPLE}🔮 Дата и время: $(date)${NC}"

# Проверка наличия SSH ключа
if [ ! -f $(eval echo ${SSH_KEY}) ]; then
    print_message "${RED}❌ SSH ключ не найден по пути: ${SSH_KEY}${NC}"
    print_message "${YELLOW}ℹ️ Укажите правильный путь к SSH ключу и попробуйте снова.${NC}"
    exit 1
fi

print_message "${GREEN}✅ SSH ключ найден: ${SSH_KEY}${NC}"

# Проверка доступности сервера
print_header "ПРОВЕРКА ДОСТУПНОСТИ СЕРВЕРА"
run_ssh_command "echo 'Соединение установлено успешно!'" "Сервер доступен"

# Проверка наличия проекта на сервере
print_header "ПРОВЕРКА НАЛИЧИЯ ПРОЕКТА"
run_ssh_command "if [ -d ${PROJECT_DIR} ]; then echo 'Директория проекта найдена'; else echo 'Директория проекта не найдена'; exit 1; fi" "Директория проекта найдена"

# Проверка наличия Git репозитория
print_header "ПРОВЕРКА GIT РЕПОЗИТОРИЯ"
run_ssh_command "cd ${PROJECT_DIR} && git status" "Git репозиторий в порядке"

# Сохранение локальных изменений
print_header "СОХРАНЕНИЕ ЛОКАЛЬНЫХ ИЗМЕНЕНИЙ"
run_ssh_command "cd ${PROJECT_DIR} && git stash" "Локальные изменения сохранены (если были)"

# Получение последних изменений
print_header "ПОЛУЧЕНИЕ ПОСЛЕДНИХ ИЗМЕНЕНИЙ"
run_ssh_command "cd ${PROJECT_DIR} && git fetch --all" "Получены последние изменения"

# Применение последних изменений
print_header "ПРИМЕНЕНИЕ ПОСЛЕДНИХ ИЗМЕНЕНИЙ"
run_ssh_command "cd ${PROJECT_DIR} && git pull" "Код обновлен до последней версии"

# Обновление разрешений для скриптов
print_header "ОБНОВЛЕНИЕ РАЗРЕШЕНИЙ ДЛЯ СКРИПТОВ"
run_ssh_command "cd ${PROJECT_DIR} && chmod +x scripts/*.sh" "Разрешения обновлены"

# Запуск скрипта обновления Docker
print_header "ЗАПУСК ОБНОВЛЕНИЯ DOCKER"
run_ssh_command "cd ${PROJECT_DIR} && ./scripts/update-docker.sh" "Обновление Docker завершено"

# Проверка статуса контейнеров
print_header "ПРОВЕРКА СТАТУСА КОНТЕЙНЕРОВ"
run_ssh_command "docker ps" "Список активных контейнеров"

# Получение последних логов
print_header "ПОСЛЕДНИЕ ЛОГИ КОНТЕЙНЕРОВ"
run_ssh_command "docker logs 999-multibots --tail 10" "Последние логи приложения"
run_ssh_command "docker logs nginx-proxy --tail 10" "Последние логи Nginx"

print_header "ОБНОВЛЕНИЕ ЗАВЕРШЕНО УСПЕШНО"
print_message "${PURPLE}🌈 НейроБлоггер обновлен до последней версии!${NC}"
print_message "${BLUE}📅 Дата завершения: $(date)${NC}"
print_message "${GREEN}💖 Спасибо за использование Радужного Моста!${NC}"

exit 0 