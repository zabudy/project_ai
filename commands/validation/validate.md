
# Project Validation Command for Project AI

Комплексная проверка AI-проекта `project_ai`. Выполни следующие команды последовательно и предоставь отчет о результатах.

---

## 1. Backend Validation

### 1.1 Python Linting (Ruff)

```bash
cd backend && ruff check src/ tests/
```

**Ожидаемый результат:** Нет ошибок (или только предупреждения, не критичные).

### 1.2 Python Formatting Check (Black)

```bash
cd backend && black --check src/ tests/
```

**Ожидаемый результат:** Все файлы отформатированы корректно.

### 1.3 Import Sorting Check (isort)

```bash
cd backend && isort --check src/ tests/
```

**Ожидаемый результат:** Импорты отсортированы по стандарту.

### 1.4 Type Checking (mypy)

```bash
cd backend && mypy src/
```

**Ожидаемый результат:** Успешная проверка типов, нет ошибок.

### 1.5 Unit Tests

```bash
cd backend && pytest tests/unit -v
```

**Ожидаемый результат:** Все тесты проходят (✅).

### 1.6 Integration Tests

```bash
cd backend && pytest tests/integration -v
```

**Ожидаемый результат:** Все тесты проходят, AI сервисы замоканы.

### 1.7 AI Service Tests (специальные)

```bash
cd backend && pytest tests/ai -v
```

**Ожидаемый результат:** 
- Тесты промптов проходят
- Тесты обработки ошибок AI проходят
- Нет реальных вызовов API (все замокано)

---

## 2. Frontend Validation

### 2.1 ESLint

```bash
cd frontend && npm run lint
```

**Ожидаемый результат:** Нет ошибок, только предупреждения (warnings) допустимы.

### 2.2 TypeScript Compilation

```bash
cd frontend && npm run typecheck
```

**Ожидаемый результат:** Успешная компиляция без ошибок типизации.

### 2.3 Formatting Check (Prettier)

```bash
cd frontend && npm run format:check
```

**Ожидаемый результат:** Все файлы отформатированы корректно.

### 2.4 Unit Tests

```bash
cd frontend && npm test -- --ci --passWithNoTests
```

**Ожидаемый результат:** Все тесты проходят (или пропущены с флагом).

### 2.5 Frontend Build

#### Development Build

```bash
cd frontend && npm run build
```

**Ожидаемый результат:** 
- Build завершается успешно
- Создается директория `build/` или `dist/`
- Размер бандла разумный (< 2MB для чанков)

#### Production Build

```bash
cd frontend && npm run build:prod
```

**Ожидаемый результат:** 
- Build завершается успешно
- Код минифицирован и оптимизирован
- Размер бандла < 500KB для основного чанка

---

## 3. AI-Specific Validations

### 3.1 API Key Check (Безопасность)

Проверь, что API ключи не закоммичены:

```bash
# Поиск потенциальных ключей в коде
grep -r "sk-[a-zA-Z0-9]" backend/ --include="*.py" --include="*.env" --exclude=".env.example"
grep -r "sk-ant" backend/ --include="*.py" --include="*.env" --exclude=".env.example"

# Проверка .env файлов (должны быть в .gitignore)
git check-ignore backend/.env backend/.env.local
```

**Ожидаемый результат:** 
- ❌ Нет реальных API ключей в коде
- ✅ Только placeholder'ы в `.env.example`
- ✅ `.env` файлы в `.gitignore`

### 3.2 Prompt Injection Check

Проверь, что пользовательский ввод санитизируется:

```bash
# Поиск прямого использования user input в промптах
grep -r "f\".*{user.*}.*\"" backend/src/services/
grep -r "format.*user" backend/src/services/
```

**Ожидаемый результат:** 
- ❌ Нет прямого конкатенирования user input
- ✅ Используются шаблоны с валидацией

### 3.3 Prompt Management Check

Проверь, что промпты хранятся правильно:

```bash
# Проверка наличия директории с промптами
ls -la backend/src/services/prompts/

# Поиск хардкода промптов
grep -r "prompt.*=.*\"\"\"" backend/src/services/ --include="*.py"
```

**Ожидаемый результат:**
- ✅ Есть директория `prompts/` с отдельными файлами
- ❌ Минимум хардкода промптов в коде

### 3.4 Cost Tracking Check

Проверь наличие механизмов отслеживания стоимости:

```bash
# Поиск токен каунтеров
grep -r "num_tokens\|token_count" backend/src/

# Поиск cost tracking
grep -r "cost\|budget\|limit" backend/src/ --include="*.py"
```

**Ожидаемый результат:**
- ✅ Есть механизм подсчета токенов
- ✅ Есть проверка бюджетных лимитов (если реализовано)

### 3.5 Fallback Mechanisms Check

Проверь обработку ошибок AI сервисов:

```bash
# Поиск обработки исключений AI
grep -r "except.*APIError\|except.*openai" backend/src/services/
grep -r "fallback\|retry\|timeout" backend/src/services/
```

**Ожидаемый результат:**
- ✅ Есть обработка специфических AI ошибок
- ✅ Есть retry логика или fallback механизмы

---

## 4. Database Validation (PostgreSQL)

### 4.1 Подключение к БД

```bash
# Проверка подключения (если PostgreSQL запущен)
cd backend && python -c "from src.core.database import check_connection; print(check_connection())"
```

**Ожидаемый результат:** Подключение успешно (`True`).

### 4.2 Проверка миграций

```bash
cd backend && alembic current
```

**Ожидаемый результат:** Показывает текущую версию миграции, нет конфликтов.

### 4.3 Проверка таблиц

```bash
# Подключись к БД и проверь таблицы
cd backend && python -c "
from src.core.database import get_db;
with get_db() as db:
    tables = db.execute('SELECT table_name FROM information_schema.tables WHERE table_schema=\\'public\\'').fetchall()
    print('Tables:', [t[0] for t in tables])
"
```

**Ожидаемый результат:** 
- Таблицы существуют (queries, users, и т.д.)
- Нет ошибок при запросе

### 4.4 Проверка данных

```bash
cd backend && python -c "
from src.repositories.query_repository import QueryRepository;
repo = QueryRepository();
count = repo.count();
print(f'Total queries in DB: {count}')
"
```

**Ожидаемый результат:** Данные существуют (или 0 для новой БД).

---

## 5. API Endpoints Validation

### 5.1 Запуск сервера

Если сервер не запущен:

```bash
cd backend && uvicorn src.main:app --reload --port 8000 &
sleep 3  # Ждем запуска
```

### 5.2 Health Check

```bash
curl -f http://localhost:8000/health || echo "❌ Health check failed"
```

**Ожидаемый результат:** Статус 200, ответ `{"status": "ok"}`.

### 5.3 Основные endpoints

Проверка API endpoints:

```bash
# Получение информации о модели
curl -s http://localhost:8000/api/v1/info | jq .

# Отправка запроса к AI (если замокано или с тестовым ключом)
curl -s -X POST http://localhost:8000/api/v1/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Hello, world!", "max_tokens": 50}' | jq .

# Проверка истории запросов (если есть)
curl -s http://localhost:8000/api/v1/history?limit=5 | jq .
```

**Ожидаемый результат:** 
- Статус 200 для успешных запросов
- Валидный JSON ответ
- Структура ответа соответствует документации

### 5.4 Rate Limiting Check

```bash
# Быстрые последовательные запросы для проверки rate limiting
for i in {1..10}; do
  curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8000/api/v1/generate \
    -H "Content-Type: application/json" \
    -d '{"prompt": "test"}'
  sleep 0.1
done
```

**Ожидаемый результат:** После определенного количества запросов статус 429 (Too Many Requests).

---

## 6. Frontend Integration Check

### 6.1 Запуск фронтенда

```bash
cd frontend && npm start &
sleep 5  # Ждем запуска
```

### 6.2 Проверка в браузере

Открой браузер и проверь:

1. Перейди на `http://localhost:3000`
2. Открой DevTools (F12) → Network tab
3. Проверь:

- [ ] Главная страница загружается
- [ ] API запросы к бэкенду идут на `http://localhost:8000/api/v1/...`
- [ ] Статус коды 200 для успешных запросов
- [ ] Нет CORS ошибок
- [ ] Нет 404 ошибок для статических файлов

### 6.3 UI/UX проверка AI интерфейса

В браузере проверь:

- [ ] Поле ввода текста работает
- [ ] Кнопка отправки реагирует на клик
- [ ] Индикатор загрузки отображается во время запроса
- [ ] Ответ AI отображается корректно
- [ ] Ошибки показываются пользователю понятным сообщением
- [ ] История запросов отображается (если есть)

### 6.4 Консоль браузера

Открой DevTools → Console:

- [ ] Нет ошибок React
- [ ] Нет предупреждений о ключах в списках
- [ ] Нет ошибок CORS
- [ ] Нет ошибок загрузки ресурсов

---

## 7. Performance & Cost Check

### 7.1 Bundle Size (Frontend)

```bash
cd frontend && npm run build && ls -lh build/static/js/
```

**Ожидаемый результат:**
- Основной чанк: < 200 KB (gzipped)
- Vendor чанк: < 300 KB (gzipped)

### 7.2 API Response Time

```bash
# Измерение времени ответа (p95)
for i in {1..20}; do
  curl -s -o /dev/null -w "Request $i: %{time_total}s\n" \
    http://localhost:8000/api/v1/generate \
    -H "Content-Type: application/json" \
    -d '{"prompt": "test", "max_tokens": 20}'
done
```

**Ожидаемый результат:** 
- p95 < 3 секунд (с учетом AI вызова)
- p95 < 500ms (если AI замокано)

### 7.3 Cost Estimation Check

Проверь, что логируются данные для оценки стоимости:

```bash
# Поиск логов с токенами
grep -r "token" backend/logs/ --include="*.log" 2>/dev/null | tail -5
```

**Ожидаемый результат:** В логах есть информация о количестве токенов.

---

## 8. Security Check

### 8.1 CORS Configuration

Проверь CORS настройки:

```bash
# Проверка CORS заголовков
curl -I -X OPTIONS http://localhost:8000/api/v1/generate \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: POST"
```

**Ожидаемый результат:** Заголовок `Access-Control-Allow-Origin` присутствует.

### 8.2 Input Validation

Проверь валидацию больших входных данных:

```bash
# Отправка слишком длинного промпта
curl -s -X POST http://localhost:8000/api/v1/generate \
  -H "Content-Type: application/json" \
  -d "{\"prompt\": \"$(python -c 'print("A" * 10000)')\"}" | jq .
```

**Ожидаемый результат:** Статус 400 (Bad Request) с сообщением о превышении лимита.

### 8.3 Environment Variables Check

Проверь, что все необходимые переменные окружения заданы:

```bash
cd backend && python -c "
from src.core.config import settings
required_vars = ['OPENAI_API_KEY', 'DATABASE_URL', 'SECRET_KEY']
missing = [v for v in required_vars if not getattr(settings, v, None)]
print(f'Missing env vars: {missing}' if missing else '✅ All env vars present')
"
```

---

## 9. Code Quality Check

### 9.1 No Hardcoded Values

Проверь, что нет хардкода:

```bash
# Поиск хардкода URL
grep -r "'http://localhost" backend/ frontend/src/ --include="*.py" --include="*.ts" --include="*.tsx"

# Поиск хардкода промптов
grep -r "prompt.*=.*[\"\"\"]" backend/src/services/ --include="*.py" | grep -v "import"
```

**Ожидаемый результат:** 
- ❌ Минимум хардкода URL (используются переменные окружения)
- ✅ Промпты в отдельных файлах

### 9.2 Type Hints Coverage

```bash
cd backend && mypy src/ --strict --warn-unused-configs
```

**Ожидаемый результат:** Нет ошибок типизации.

### 9.3 Docstrings

```bash
# Проверка наличия docstrings в публичных функциях
cd backend && pylint src/ --disable=all --enable=missing-docstring
```

**Ожидаемый результат:** Предупреждения минимальны (если есть).

---

## 10. Summary Report

После выполнения всех проверок создай итоговый отчет:

### ✅ Passed Checks

- [ ] **Backend Validation**: Линтинг, типы, тесты пройдены
- [ ] **Frontend Validation**: Линтинг, типы, сборка работает
- [ ] **AI-Specific**: Промпты в файлах, нет утечек ключей, есть fallback
- [ ] **Database**: Подключение работает, миграции применены
- [ ] **API**: Все endpoints отвечают корректно
- [ ] **UI/UX**: Интерфейс работает, ошибки обрабатываются
- [ ] **Performance**: Response time в норме, bundle size ок
- [ ] **Security**: CORS настроен, валидация работает
- [ ] **Code Quality**: Нет хардкода, типизация полная

### ❌ Failed Checks

Список проблем с описанием:

1. **[AI Security]**: API ключ OpenAI найден в логах
   - **Ожидалось**: Ключи не должны логироваться
   - **Получено**: В файле `backend/logs/app.log` строка 42 содержит ключ
   - **Решение**: Добавить фильтр логов для API ключей

2. **[Cost Tracking]**: Нет подсчета токенов
   - **Ожидалось**: Каждый запрос считает токены
   - **Получено**: В сервисе `ai_service.py` нет вызова token counter
   - **Решение**: Добавить `count_tokens()` перед отправкой запроса

### 📊 Statistics

- **Total API Endpoints**: X
- **Successful Requests**: X/X (XX%)
- **Database Tables**: X
- **Total Documents**: X
- **Bundle Size (prod)**: X KB
- **Average API Response Time**: X ms
- **Estimated Cost per 1000 requests**: $X.XX

### 🎯 Overall Health

**[PASS / FAIL / NEEDS ATTENTION]**

- **PASS**: Все критичные проверки пройдены, проект готов к деплою
- **FAIL**: Есть критичные проблемы (security, cost), требующие немедленного исправления
- **NEEDS ATTENTION**: Некритичные проблемы, можно деплоить с отсрочкой

### 📝 Recommendations

1. **Immediate** (блокирующие):
   - Исправить утечку API ключей в логах
   - Добавить rate limiting перед деплоем

2. **Short-term** (следующий спринт):
   - Реализовать полный cost tracking
   - Добавить кэширование повторяющихся запросов

3. **Long-term** (roadmap):
   - A/B тестирование разных моделей
   - Оптимизация промптов для снижения токенов

---

## Notes

- **НЕ используй автотесты** для проверки UI - всегда используй браузер
- **Всегда проверяй безопасность API ключей** - это критично для AI проектов
- **Не забывай про cost tracking** - без него можно превысить бюджет
- **Проверяй fallback механизмы** - AI может быть недоступен
- **Логируй токены** для последующего анализа стоимости
- **Не останавливайся при ошибках** - составь план исправления и выполни его
- **Выведи результаты в консоль** в структурированном виде
