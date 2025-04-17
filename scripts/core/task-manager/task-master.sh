#!/bin/bash

# =========================================
# task-master.sh - Мастер задач НейроКодера
# Скрипт для планирования задач и анализа прогресса
# =========================================

# Загружаем цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Путь к проекту
PROJECT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
ROADMAP_FILE="${PROJECT_PATH}/src/core/mcp/agent/memory-bank/NeuroBlogger/ROADMAP.md"
TASK_GUARDIAN="${PROJECT_PATH}/scripts/core/task-manager/task-guardian.sh"
TASK_LOG="${PROJECT_PATH}/logs/task-manager/tasks.log"

# Создаем директорию для логов, если не существует
mkdir -p "$(dirname "$TASK_LOG")"

# Функция для эмоционального статуса НейроКодера
function emotional_state() {
    local status=$1
    local message=$2
    local emoji=""
    
    case $status in
        "happy") emoji="😊" ;;
        "proud") emoji="😎" ;;
        "concerned") emoji="😟" ;;
        "excited") emoji="🤩" ;;
        "neutral") emoji="😐" ;;
        "sad") emoji="😢" ;;
        "love") emoji="💖" ;;
    esac
    
    echo -e "${PURPLE}НейроКодер ${emoji}: ${message}${NC}"
    
    # Также записываем в лог
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ЭМОЦИЯ:$status] $message" >> "$TASK_LOG"
}

# Функция для вывода заголовков
function print_header() {
    echo -e "${CYAN}======================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}======================================${NC}"
}

# Функция для вывода красивого разделителя
function print_divider() {
    echo -e "${BLUE}--------------------------------------${NC}"
}

# Проверка существования и прав на исполнение Хранителя Задач
function check_task_guardian() {
    if [ ! -f "$TASK_GUARDIAN" ]; then
        echo -e "${RED}❌ Файл task-guardian.sh не найден!${NC}"
        emotional_state "concerned" "Не могу найти моего помощника - Хранителя Задач!"
        return 1
    fi
    
    if [ ! -x "$TASK_GUARDIAN" ]; then
        echo -e "${YELLOW}⚠️ Файл task-guardian.sh не имеет прав на исполнение. Устанавливаю права...${NC}"
        chmod +x "$TASK_GUARDIAN"
        echo -e "${GREEN}✅ Права на исполнение установлены${NC}"
    fi
    
    echo -e "${GREEN}✅ Хранитель Задач найден и готов к работе${NC}"
    return 0
}

# Функция для анализа тенденций выполнения задач
function analyze_task_trends() {
    print_header "📊 АНАЛИЗ ТЕНДЕНЦИЙ ВЫПОЛНЕНИЯ ЗАДАЧ"
    
    if [ ! -f "$ROADMAP_FILE" ]; then
        echo -e "${RED}❌ Файл ROADMAP.md не найден!${NC}"
        emotional_state "concerned" "Как я могу анализировать тенденции без дорожной карты?"
        return
    fi
    
    # Общее количество задач и выполненных задач
    local total=$(grep -c "^- \[.\]" "$ROADMAP_FILE")
    local completed=$(grep -c "^- \[x\]" "$ROADMAP_FILE")
    
    if [ $total -eq 0 ]; then
        echo -e "${YELLOW}⚠️ Нет задач для анализа${NC}"
        emotional_state "concerned" "Мне нечего анализировать. Нужно добавить задачи!"
        return
    fi
    
    # Рассчитываем процент выполнения
    local progress=$((completed * 100 / total))
    
    echo -e "${YELLOW}Общая статистика:${NC}"
    print_divider
    echo -e "Всего задач: ${BLUE}$total${NC}"
    echo -e "Выполнено задач: ${GREEN}$completed${NC}"
    echo -e "Текущий прогресс: ${CYAN}$progress%${NC}"
    
    # Анализ по категориям
    echo -e "\n${YELLOW}Анализ по категориям:${NC}"
    print_divider
    
    local categories=("Выполненные задачи" "Текущая работа" "Запланированные задачи" "Технический долг")
    
    for category in "${categories[@]}"; do
        local cat_total=$(grep -A 100 "^## .*$category" "$ROADMAP_FILE" | grep -c "^- \[.\]")
        local cat_completed=$(grep -A 100 "^## .*$category" "$ROADMAP_FILE" | grep -c "^- \[x\]")
        
        if [ $cat_total -gt 0 ]; then
            local cat_progress=$((cat_completed * 100 / cat_total))
            echo -e "${CYAN}$category:${NC} ${GREEN}$cat_completed${NC}/${BLUE}$cat_total${NC} (${YELLOW}$cat_progress%${NC})"
        else
            echo -e "${CYAN}$category:${NC} ${YELLOW}Нет задач${NC}"
        fi
    done
    
    # Анализ тенденций
    echo -e "\n${YELLOW}Тенденции:${NC}"
    print_divider
    
    if [ $progress -lt 10 ]; then
        echo -e "${RED}⚠️ Прогресс очень низкий. Требуется активизация работы над задачами.${NC}"
        emotional_state "concerned" "Мы только начинаем. Нам нужно ускорить работу!"
    elif [ $progress -lt 30 ]; then
        echo -e "${YELLOW}⚠️ Прогресс низкий. Рекомендуется увеличить темп выполнения задач.${NC}"
        emotional_state "neutral" "Мы движемся вперед, но нужно ускориться."
    elif [ $progress -lt 50 ]; then
        echo -e "${BLUE}ℹ️ Прогресс умеренный. Движемся в правильном направлении.${NC}"
        emotional_state "happy" "Мы на правильном пути! Продолжаем двигаться вперед."
    elif [ $progress -lt 70 ]; then
        echo -e "${CYAN}✅ Прогресс хороший. Продолжайте в том же духе.${NC}"
        emotional_state "proud" "Отличный прогресс! Я горжусь нашей работой!"
    elif [ $progress -lt 90 ]; then
        echo -e "${GREEN}🚀 Прогресс отличный! Проект близок к завершению.${NC}"
        emotional_state "excited" "Мы почти у цели! Осталось еще немного!"
    else
        echo -e "${PURPLE}🎉 Проект практически завершен! Отличная работа!${NC}"
        emotional_state "love" "Невероятно! Мы почти завершили все задачи! Я так счастлив!"
    fi
    
    # Записываем анализ в лог
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [АНАЛИЗ] Прогресс: $progress%, Всего задач: $total, Выполнено: $completed" >> "$TASK_LOG"
}

# Функция для планирования следующих шагов
function plan_next_steps() {
    print_header "🔮 ПЛАНИРОВАНИЕ СЛЕДУЮЩИХ ШАГОВ"
    
    if [ ! -f "$ROADMAP_FILE" ]; then
        echo -e "${RED}❌ Файл ROADMAP.md не найден!${NC}"
        emotional_state "concerned" "Без дорожной карты я не могу планировать будущее!"
        return
    fi
    
    echo -e "${YELLOW}Анализ текущей работы:${NC}"
    print_divider
    
    # Список текущих задач, которые не выполнены
    local current_tasks=$(grep -A 50 "^## 🔄 Текущая работа" "$ROADMAP_FILE" | grep "^- \[ \]")
    
    if [ -z "$current_tasks" ]; then
        echo -e "${GREEN}✅ Все текущие задачи выполнены!${NC}"
        emotional_state "excited" "Невероятно! Мы выполнили все текущие задачи!"
        
        # Проверяем запланированные задачи
        local planned_tasks=$(grep -A 50 "^## 📅 Запланированные задачи" "$ROADMAP_FILE" | grep "^- \[ \]")
        
        if [ -z "$planned_tasks" ]; then
            echo -e "${GREEN}✅ Все запланированные задачи также выполнены!${NC}"
            emotional_state "love" "Великолепно! Мы выполнили все запланированные задачи! Время для новых планов!"
        else
            echo -e "${BLUE}ℹ️ Рекомендуется перенести следующие запланированные задачи в текущую работу:${NC}"
            print_divider
            echo "$planned_tasks" | head -n 3
            
            emotional_state "happy" "Давайте перенесем некоторые запланированные задачи в текущую работу!"
        fi
    else
        echo -e "${BLUE}ℹ️ Незавершенные текущие задачи:${NC}"
        print_divider
        echo "$current_tasks"
        
        # Определяем приоритеты
        echo -e "\n${YELLOW}Рекомендуемые приоритеты:${NC}"
        print_divider
        
        # Простой алгоритм приоритизации: короткие задачи имеют более высокий приоритет
        echo "$current_tasks" | awk '{print length, $0}' | sort -n | cut -d ' ' -f 2- | head -n 3 | while read -r task; do
            echo -e "${GREEN}ВЫСОКИЙ ПРИОРИТЕТ:${NC} $task"
        done
        
        emotional_state "neutral" "У нас все еще есть текущие задачи. Давайте сосредоточимся на них!"
    fi
    
    # Проверка технического долга
    echo -e "\n${YELLOW}Анализ технического долга:${NC}"
    print_divider
    
    local tech_debt=$(grep -A 50 "^## 💸 Технический долг" "$ROADMAP_FILE" | grep "^- \[ \]")
    
    if [ -z "$tech_debt" ]; then
        echo -e "${GREEN}✅ Нет накопленного технического долга!${NC}"
        emotional_state "proud" "Отлично! У нас нет технического долга!"
    else
        local debt_count=$(echo "$tech_debt" | wc -l)
        echo -e "${RED}⚠️ Обнаружено $debt_count задач технического долга:${NC}"
        print_divider
        echo "$tech_debt"
        
        emotional_state "concerned" "Нам стоит обратить внимание на технический долг!"
    fi
    
    # Записываем планы в лог
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ПЛАН] Запланировано действий по текущим задачам и техническому долгу" >> "$TASK_LOG"
}

# Функция для создания отчета о производительности
function generate_performance_report() {
    print_header "📈 ОТЧЕТ О ПРОИЗВОДИТЕЛЬНОСТИ"
    
    if [ ! -f "$ROADMAP_FILE" ]; then
        echo -e "${RED}❌ Файл ROADMAP.md не найден!${NC}"
        return
    fi
    
    # Извлекаем метрики из ROADMAP.md
    local active_bots=$(grep -A 10 "^## 📊 Метрики" "$ROADMAP_FILE" | grep "Активные боты:" | sed -E 's/.*: ([0-9]+|N\/A).*/\1/')
    local response_time=$(grep -A 10 "^## 📊 Метрики" "$ROADMAP_FILE" | grep "Среднее время ответа:" | sed -E 's/.*: ([0-9]+ms|N\/A).*/\1/')
    local server_load=$(grep -A 10 "^## 📊 Метрики" "$ROADMAP_FILE" | grep "Нагрузка сервера:" | sed -E 's/.*: ([^*]+).*/\1/')
    local code_coverage=$(grep -A 10 "^## 📊 Метрики" "$ROADMAP_FILE" | grep "Покрытие кода тестами:" | sed -E 's/.*: ([0-9]+%|N\/A).*/\1/')
    local deployment_automation=$(grep -A 10 "^## 📊 Метрики" "$ROADMAP_FILE" | grep "Автоматизация развертывания:" | sed -E 's/.*: ([0-9]+%|N\/A).*/\1/')
    
    echo -e "${YELLOW}Текущие метрики проекта:${NC}"
    print_divider
    echo -e "${BLUE}Активные боты:${NC} ${GREEN}$active_bots${NC}"
    echo -e "${BLUE}Среднее время ответа:${NC} ${GREEN}$response_time${NC}"
    echo -e "${BLUE}Нагрузка сервера:${NC} ${GREEN}$server_load${NC}"
    echo -e "${BLUE}Покрытие кода тестами:${NC} ${GREEN}$code_coverage${NC}"
    echo -e "${BLUE}Автоматизация развертывания:${NC} ${GREEN}$deployment_automation${NC}"
    
    echo -e "\n${YELLOW}Анализ производительности:${NC}"
    print_divider
    
    # Проверка значений метрик
    if [[ "$code_coverage" != "N/A" && "${code_coverage/\%/}" -lt 50 ]]; then
        echo -e "${RED}⚠️ Низкое покрытие кода тестами ($code_coverage). Рекомендуется увеличить покрытие.${NC}"
    else
        echo -e "${GREEN}✅ Хорошее покрытие кода тестами ($code_coverage).${NC}"
    fi
    
    if [[ "$deployment_automation" != "N/A" && "${deployment_automation/\%/}" -lt 70 ]]; then
        echo -e "${YELLOW}⚠️ Автоматизация развертывания ($deployment_automation) может быть улучшена.${NC}"
    else
        echo -e "${GREEN}✅ Хороший уровень автоматизации развертывания ($deployment_automation).${NC}"
    fi
    
    if [[ "$response_time" != "N/A" && "${response_time/ms/}" -gt 500 ]]; then
        echo -e "${RED}⚠️ Высокое время ответа ($response_time). Рекомендуется оптимизация.${NC}"
    else
        echo -e "${GREEN}✅ Хорошее время ответа ($response_time).${NC}"
    fi
    
    # Общая оценка
    echo -e "\n${YELLOW}Общая оценка производительности:${NC}"
    print_divider
    
    local performance_issues=0
    
    if [[ "$code_coverage" != "N/A" && "${code_coverage/\%/}" -lt 50 ]]; then
        ((performance_issues++))
    fi
    
    if [[ "$deployment_automation" != "N/A" && "${deployment_automation/\%/}" -lt 70 ]]; then
        ((performance_issues++))
    fi
    
    if [[ "$response_time" != "N/A" && "${response_time/ms/}" -gt 500 ]]; then
        ((performance_issues++))
    fi
    
    if [ $performance_issues -eq 0 ]; then
        echo -e "${GREEN}🎉 Отличная производительность! Все метрики в норме.${NC}"
        emotional_state "excited" "Наш проект работает великолепно! Все метрики в порядке!"
    elif [ $performance_issues -eq 1 ]; then
        echo -e "${BLUE}ℹ️ Хорошая производительность с небольшими возможностями для улучшения.${NC}"
        emotional_state "happy" "Производительность хорошая, но есть небольшой потенциал для улучшения!"
    elif [ $performance_issues -eq 2 ]; then
        echo -e "${YELLOW}⚠️ Средняя производительность. Требуется оптимизация по нескольким направлениям.${NC}"
        emotional_state "neutral" "Производительность средняя. Нам есть над чем поработать."
    else
        echo -e "${RED}❌ Низкая производительность. Требуется значительная оптимизация.${NC}"
        emotional_state "concerned" "Производительность требует значительных улучшений!"
    fi
    
    # Записываем отчет в лог
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ОТЧЕТ] Сгенерирован отчет о производительности. Проблем: $performance_issues" >> "$TASK_LOG"
}

# Функция для управления рисками
function manage_risks() {
    print_header "⚠️ УПРАВЛЕНИЕ РИСКАМИ"
    
    if [ ! -f "$ROADMAP_FILE" ]; then
        echo -e "${RED}❌ Файл ROADMAP.md не найден!${NC}"
        return
    fi
    
    echo -e "${YELLOW}Идентифицированные риски:${NC}"
    print_divider
    
    # Извлекаем список рисков
    local risks=$(grep -A 50 "^## ⚠️ Риски" "$ROADMAP_FILE" | grep "^- " | sed 's/^- //')
    
    if [ -z "$risks" ]; then
        echo -e "${GREEN}✅ Риски не идентифицированы в дорожной карте.${NC}"
        emotional_state "happy" "Отлично! У нас нет идентифицированных рисков!"
    else
        echo "$risks" | while read -r risk; do
            echo -e "${RED}⚠️ ${YELLOW}$risk${NC}"
        done
        
        emotional_state "neutral" "У нас есть некоторые риски, которые нужно контролировать."
        
        echo -e "\n${YELLOW}Рекомендации по управлению рисками:${NC}"
        print_divider
        
        echo "$risks" | while read -r risk; do
            local recommendation=""
            
            if [[ "$risk" == *"API Telegram"* ]]; then
                recommendation="Регулярно проверять документацию API Telegram на наличие изменений. Иметь план отката к предыдущей версии."
            elif [[ "$risk" == *"безопасности данных"* ]]; then
                recommendation="Провести аудит безопасности. Внедрить шифрование чувствительных данных. Регулярно проверять и обновлять зависимости."
            elif [[ "$risk" == *"производительност"* ]]; then
                recommendation="Внедрить мониторинг производительности. Оптимизировать критические участки кода. Рассмотреть возможность масштабирования."
            elif [[ "$risk" == *"зависимост"* ]]; then
                recommendation="Регулярно обновлять зависимости. Создать автоматизированные тесты для проверки совместимости."
            else
                recommendation="Провести детальный анализ риска. Разработать план по его минимизации."
            fi
            
            echo -e "${CYAN}$risk:${NC} ${GREEN}$recommendation${NC}"
        done
    fi
    
    # Записываем анализ рисков в лог
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [РИСКИ] Проведен анализ и управление рисками" >> "$TASK_LOG"
}

# Функция для обращения к Хранителю Задач
function call_task_guardian() {
    print_header "🛡️ ВЫЗОВ ХРАНИТЕЛЯ ЗАДАЧ"
    
    if check_task_guardian; then
        echo -e "${YELLOW}Запускаю Хранителя Задач...${NC}"
        "$TASK_GUARDIAN"
        echo -e "${GREEN}✅ Хранитель Задач завершил работу${NC}"
    else
        echo -e "${RED}❌ Не удалось запустить Хранителя Задач${NC}"
        emotional_state "sad" "Я не могу найти или запустить Хранителя Задач!"
    fi
}

# Функция для отображения меню
function show_menu() {
    print_header "🧠 МАСТЕР ЗАДАЧ"
    echo -e "${YELLOW}Выберите действие:${NC}\n"
    echo -e "${BLUE}1.${NC} ${GREEN}Анализ тенденций выполнения задач${NC}"
    echo -e "${BLUE}2.${NC} ${GREEN}Планирование следующих шагов${NC}"
    echo -e "${BLUE}3.${NC} ${GREEN}Отчет о производительности${NC}"
    echo -e "${BLUE}4.${NC} ${GREEN}Управление рисками${NC}"
    echo -e "${BLUE}5.${NC} ${GREEN}Вызов Хранителя Задач${NC}"
    echo -e "${BLUE}0.${NC} ${RED}Выход${NC}\n"
    
    read -p "Выберите опцию (0-5): " option
    
    case $option in
        1) clear && analyze_task_trends ;;
        2) clear && plan_next_steps ;;
        3) clear && generate_performance_report ;;
        4) clear && manage_risks ;;
        5) clear && call_task_guardian ;;
        0) 
            echo -e "${GREEN}👋 До свидания!${NC}"
            emotional_state "happy" "Было приятно анализировать задачи вместе с тобой!"
            exit 0
            ;;
        *)
            clear
            echo -e "${RED}❌ Неверная опция!${NC}"
            emotional_state "concerned" "Этой опции нет в меню!"
            ;;
    esac
}

# Основная функция
function main() {
    print_header "🧠 МАСТЕР ЗАДАЧ НЕЙРОКОДЕРА"
    emotional_state "excited" "Я готов анализировать и планировать задачи проекта!"
    
    # Проверяем наличие Хранителя Задач
    check_task_guardian
    
    # Основной цикл
    while true; do
        show_menu
        echo
        read -p "Нажмите Enter для продолжения..." continue
        clear
    done
}

# Запускаем основную функцию
main 