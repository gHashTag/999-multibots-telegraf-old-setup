#!/bin/bash

# ===== 🌈 Скрипт SSH-обновления NeuroBlogger 🌈 =====
# Автор: НейроКодер
# Дата создания: 18.04.2025
# Версия: 1.0
# Описание: Скрипт для автоматического обновления проекта на сервере через SSH

# Радужные цвета для красивого вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SERVER="root@999-multibots-u14194.vm.elestio.app"
SSH_KEY="~/.ssh/id_rsa"
PROJECT_DIR="/opt/app/999-multibots-telegraf"

# Функция для красивого вывода сообщений
print_message() {
  local color=$1
  local message=$2
  echo -e "${color}[НейроБлоггер SSH Обновление] ${message}${NC}"
}

# Проверка наличия SSH ключа
if [ ! -f $(eval echo $SSH_KEY) ]; then
  print_message "$RED" "❌ SSH ключ не найден: $SSH_KEY"
  exit 1
fi

print_message "$CYAN" "🌈 Начинаю процесс обновления НейроБлоггера на удаленном сервере..."
print_message "$BLUE" "🔄 Подключаюсь к серверу: $SERVER"

# Функция для выполнения SSH команд с проверкой ошибок
ssh_exec() {
  local command=$1
  print_message "$YELLOW" "🔄 Выполняю: $command"
  
  ssh -i $(eval echo $SSH_KEY) $SERVER "$command"
  local status=$?
  
  if [ $status -ne 0 ]; then
    print_message "$RED" "❌ Ошибка при выполнении команды: $command"
    return $status
  fi
  
  return 0
}

# Проверка доступности сервера
print_message "$BLUE" "🔍 Проверяю доступность сервера..."
if ! ssh -i $(eval echo $SSH_KEY) -o ConnectTimeout=5 $SERVER "echo 'Соединение установлено'" &> /dev/null; then
  print_message "$RED" "❌ Не удалось подключиться к серверу: $SERVER"
  exit 1
fi

print_message "$GREEN" "✅ Соединение с сервером установлено"

# Выполнение обновления на сервере
print_message "$BLUE" "📂 Переходим в директорию проекта и обновляем код..."

# Проверка существования директории проекта
if ! ssh_exec "[ -d $PROJECT_DIR ]"; then
  print_message "$RED" "❌ Директория проекта не найдена: $PROJECT_DIR"
  exit 1
fi

# Проверка наличия Git репозитория
if ! ssh_exec "[ -d $PROJECT_DIR/.git ]"; then
  print_message "$RED" "❌ Git репозиторий не найден в директории проекта"
  exit 1
fi

# Обновление кода из репозитория
print_message "$CYAN" "🔄 Получаю последние изменения из репозитория..."
if ! ssh_exec "cd $PROJECT_DIR && git fetch --prune"; then
  print_message "$RED" "❌ Не удалось получить изменения из репозитория"
  exit 1
fi

# Сохранение локальных изменений, если они есть
print_message "$YELLOW" "💾 Проверяю наличие локальных изменений..."
if ssh_exec "cd $PROJECT_DIR && git diff --quiet"; then
  print_message "$GREEN" "✅ Локальных изменений нет"
else
  print_message "$YELLOW" "⚠️ Обнаружены локальные изменения, сохраняю их..."
  if ! ssh_exec "cd $PROJECT_DIR && git stash"; then
    print_message "$RED" "❌ Не удалось сохранить локальные изменения"
    exit 1
  fi
fi

# Обновление до последней версии
print_message "$CYAN" "🔄 Обновляю код до последней версии..."
if ! ssh_exec "cd $PROJECT_DIR && git pull"; then
  print_message "$RED" "❌ Не удалось обновить код до последней версии"
  exit 1
fi

# Проверка и обновление прав на скрипты
print_message "$BLUE" "🔐 Обновляю права на исполнение скриптов..."
if ! ssh_exec "cd $PROJECT_DIR && chmod +x scripts/*.sh"; then
  print_message "$YELLOW" "⚠️ Предупреждение: не удалось обновить права на скрипты"
fi

# Запуск скрипта обновления Docker
print_message "$PURPLE" "🐳 Запускаю скрипт обновления Docker..."
if ! ssh_exec "cd $PROJECT_DIR && ./scripts/update-docker.sh"; then
  print_message "$RED" "❌ Ошибка при выполнении скрипта обновления Docker"
  exit 1
fi

# Проверка статуса контейнеров
print_message "$BLUE" "🔍 Проверяю статус Docker контейнеров..."
ssh_exec "docker ps"

# Проверка логов контейнеров
print_message "$CYAN" "📜 Вывожу последние логи контейнеров..."
ssh_exec "docker logs --tail 20 999-multibots"

print_message "$GREEN" "✅ Обновление НейроБлоггера на удаленном сервере успешно завершено!"
print_message "$CYAN" "🌈 Радужный мост между локальной и удаленной системой установлен"

exit 0 