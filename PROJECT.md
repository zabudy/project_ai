# PROJECT.md

> **Project-specific configuration for the agentic development team.**
> Заполните каждый раздел перед запуском workflows. Агенты читают этот файл, чтобы понять
> ваш технологический стек, команды, структуру директорий и соглашения.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Python 3.12 |
| Runtime | Python 3.12 |
| Framework | FastAPI (бэкенд), React 18 (фронтенд) |
| Database | PostgreSQL 15 (для хранения истории запросов) / SQLite (для разработки) |
| ORM / Query | SQLAlchemy 2.0 + Alembic (миграции) |
| AI Integration | OpenAI Python Library, LangChain (опционально) |
| Test framework | pytest |
| E2E framework | Playwright |
| Linter | Ruff |
| Type checker | mypy |
| Package manager | pip + venv (бэкенд), npm (фронтенд) |

## Commands

> Актуальные команды для project_ai.

| Task | Команда |
|------|---------|
| Установка зависимостей (бэкенд) | `cd backend && pip install -r requirements.txt` |
| Установка зависимостей (фронтенд) | `cd frontend && npm install` |
| Dev сервер (бэкенд) | `cd backend && uvicorn main:app --reload` |
| Dev сервер (фронтенд) | `cd frontend && npm start` |
| Сборка (фронтенд) | `cd frontend && npm run build` |
| Запуск всех тестов | `pytest` |
| Запуск одного теста | `pytest tests/path/to/test_file.py::test_function -v` |
| Тесты с покрытием | `pytest --cov=src --cov-report=html` |
| Линтинг | `ruff check .` |
| Линтинг с авто-фиксом | `ruff check . --fix` |
| Type check | `mypy src` |
| E2E тесты | `playwright test` |
| Миграции БД | `alembic upgrade head` |
| Создание миграции | `alembic revision --autogenerate -m "description"` |
| Сиды БД | `python scripts/seed_db.py` |
| Форматирование кода | `black .` |

### Validation Command

> Команда для валидации перед коммитом.
> Должна завершаться с ненулевым кодом при любой ошибке.

```bash
cd backend && ruff check . && black --check . && mypy src && pytest tests/ --maxfail=1 && cd ../frontend && npm run lint && npm run typecheck
