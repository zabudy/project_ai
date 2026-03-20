---
name: telegram-bot
description: >
  Create and scaffold Telegram bots using python-telegram-bot (v20+) with support for
  commands, FSM (Conversation handlers), inline keyboards, and SQLite/PostgreSQL database
  integration. Use when the user wants to: (1) generate a ready-to-run bot project,
  (2) add new handlers or FSM flows to an existing bot, (3) connect a database to a bot,
  (4) understand architecture patterns for medium-complexity bots, or (5) debug or extend
  existing python-telegram-bot code.
---

# Telegram Bot Skill

Build Telegram bots with `python-telegram-bot` v20+ (async API).

## Project Structure

```
my_bot/
├── bot.py              # Entry point, Application setup
├── config.py           # Settings (token, DB URL via env vars)
├── handlers/
│   ├── __init__.py
│   ├── common.py       # /start, /help, cancel
│   └── <feature>.py    # One file per FSM flow or feature
├── db/
│   ├── __init__.py
│   └── models.py       # DB init + CRUD helpers
└── requirements.txt
```

## Quick Start

### bot.py

```python
import asyncio
from telegram.ext import Application
from config import BOT_TOKEN
from handlers.common import start_handler, cancel_handler
from handlers.registration import registration_conv  # example FSM

async def main():
    app = Application.builder().token(BOT_TOKEN).build()
    app.add_handler(start_handler)
    app.add_handler(registration_conv)
    await app.run_polling()

if __name__ == "__main__":
    asyncio.run(main())
```

### config.py

```python
import os
BOT_TOKEN = os.environ["BOT_TOKEN"]
DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///bot.db")
```

### requirements.txt

```
python-telegram-bot==20.*
aiosqlite>=0.19
sqlalchemy[asyncio]>=2.0
python-dotenv
```

## FSM (ConversationHandler)

Use `ConversationHandler` for multi-step dialogs. Define states as module-level integers.

```python
from telegram import Update
from telegram.ext import (
    ConversationHandler, CommandHandler,
    MessageHandler, filters, ContextTypes
)

NAME, AGE = range(2)

async def ask_name(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("What's your name?")
    return NAME

async def ask_age(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    ctx.user_data["name"] = update.message.text
    await update.message.reply_text("How old are you?")
    return AGE

async def finish(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    ctx.user_data["age"] = update.message.text
    await update.message.reply_text(f"Got it: {ctx.user_data}")
    return ConversationHandler.END

registration_conv = ConversationHandler(
    entry_points=[CommandHandler("register", ask_name)],
    states={
        NAME: [MessageHandler(filters.TEXT & ~filters.COMMAND, ask_age)],
        AGE:  [MessageHandler(filters.TEXT & ~filters.COMMAND, finish)],
    },
    fallbacks=[CommandHandler("cancel", cancel)],
)
```

**Rules:**
- Always add a `cancel` fallback
- Store temp data in `ctx.user_data`, persist to DB only at `END`
- One `ConversationHandler` per logical flow

## Inline Keyboards

```python
from telegram import InlineKeyboardButton, InlineKeyboardMarkup

keyboard = InlineKeyboardMarkup([
    [InlineKeyboardButton("Yes ✅", callback_data="yes"),
     InlineKeyboardButton("No ❌",  callback_data="no")],
])

async def ask_confirm(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("Confirm?", reply_markup=keyboard)

async def handle_callback(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()
    if query.data == "yes":
        await query.edit_message_text("Confirmed!")
    else:
        await query.edit_message_text("Cancelled.")
```

Register with `CallbackQueryHandler(handle_callback, pattern="^(yes|no)$")`.

## Database (Async SQLAlchemy + SQLite)

```python
# db/models.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, sessionmaker
from config import DATABASE_URL

engine = create_async_engine(DATABASE_URL.replace("sqlite:///", "sqlite+aiosqlite:///"))
AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

class Base(DeclarativeBase): pass

class User(Base):
    __tablename__ = "users"
    id:         Mapped[int] = mapped_column(primary_key=True)
    telegram_id:Mapped[int] = mapped_column(unique=True)
    name:       Mapped[str]
    age:        Mapped[int]

async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

async def save_user(telegram_id: int, name: str, age: int):
    async with AsyncSessionLocal() as session:
        user = User(telegram_id=telegram_id, name=name, age=age)
        session.add(user)
        await session.commit()
```

Call `await init_db()` once in `main()` before `run_polling()`.

For PostgreSQL: set `DATABASE_URL=postgresql+asyncpg://user:pass@host/db` and add `asyncpg` to requirements.

## Architecture Patterns

- **One file per feature/flow** — keep handlers focused, avoid a single giant handlers.py
- **No business logic in handlers** — handlers call DB helpers, not raw SQL
- **Use `ctx.user_data` for session state** — cleared when bot restarts; persist important data to DB at flow end
- **Group related `CallbackQueryHandler`s** by pattern prefix** — e.g. `"^menu_"`, `"^order_"`

## Common Pitfalls

| Problem | Fix |
|---|---|
| Handler not triggering | Check handler registration order in `add_handler`; specific before generic |
| FSM stuck in wrong state | Ensure all states have fallback; add `allow_reentry=True` if needed |
| Callback query timeout | Always call `await query.answer()` immediately |
| DB session errors | Never share one session across handlers; use `async with AsyncSessionLocal()` per operation |

## Self-Improvement Loop

Improve this skill autonomously using binary assertions — no manual review needed for structural checks.

### How It Works

```
┌─────────────────────────────────────────┐
│  1. Run test prompts through the skill  │
│  2. Evaluate each assertion (true/false) │
│  3. If any fail → propose one edit      │
│  4. Re-run tests → keep edit or revert  │
│  5. Repeat until all assertions pass    │
└─────────────────────────────────────────┘
```

### Eval File (`evals/skill_assertions.py`)

Create this file to define binary checks on Claude's output:

```python
# evals/skill_assertions.py
# Each assertion: (description, fn(output: str) -> bool)

ASSERTIONS = [
    # --- Structure ---
    ("Contains project structure block",
     lambda o: "my_bot/" in o and "bot.py" in o),

    ("Contains requirements.txt section",
     lambda o: "requirements.txt" in o),

    ("FSM example includes ConversationHandler",
     lambda o: "ConversationHandler" in o),

    # --- Format ---
    ("No inline HTML tags",
     lambda o: "<br>" not in o and "<b>" not in o),

    ("Code blocks are fenced (```)",
     lambda o: o.count("```") >= 2),

    # --- Forbidden patterns ---
    ("No synchronous requests.get() calls",
     lambda o: "requests.get(" not in o),

    ("No bare except clauses",
     lambda o: "except:" not in o),

    ("Token not hardcoded",
     lambda o: "BOT_TOKEN" not in o.replace("os.environ", "")),

    # --- Length ---
    ("Response not too short (>200 chars)",
     lambda o: len(o) > 200),

    ("Response not too long (<8000 chars)",
     lambda o: len(o) < 8000),
]
```

### Test Prompts (`evals/prompts.txt`)

```
Create a basic Telegram bot with /start and /help commands.
Build a registration flow that asks for name and email using FSM.
Add a SQLite database to store user data.
Show me an inline keyboard with Yes/No buttons.
```

### Running the Loop

```bash
# Single eval run
python evals/run_evals.py --skill SKILL.md --prompts evals/prompts.txt

# Autonomous improvement loop (max 10 iterations)
python evals/run_evals.py --skill SKILL.md --prompts evals/prompts.txt --auto --max-iter 10
```

### `evals/run_evals.py` Template

```python
import subprocess, sys, importlib.util, argparse

def load_assertions(path):
    spec = importlib.util.spec_from_file_location("assertions", path)
    mod  = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.ASSERTIONS

def run_skill(prompt: str) -> str:
    # Replace with actual Claude Code CLI call
    result = subprocess.run(
        ["claude", "-p", prompt, "--skill", args.skill],
        capture_output=True, text=True
    )
    return result.stdout

def evaluate(output: str, assertions: list) -> list[tuple]:
    return [(desc, fn(output)) for desc, fn in assertions]

def print_results(results):
    passed = sum(1 for _, ok in results if ok)
    for desc, ok in results:
        print(f"  {'✅' if ok else '❌'} {desc}")
    print(f"\n{passed}/{len(results)} passed")
    return passed == len(results)
```

### What Binary Assertions Cover Well

| ✅ Good fit | ❌ Needs human review |
|---|---|
| Required code blocks present | Tone and clarity |
| Forbidden patterns absent | Creativity of examples |
| Correct library used (async, not sync) | Quality of DB schema design |
| Structure elements exist | Appropriateness of FSM flow |
| Response length within bounds | Use of context from references |

**Key rule:** one change per iteration — isolate what works.

## References

- For detailed DB patterns and migrations: see `references/db.md` (if present)
- For deployment (systemd, Docker, webhook): see `references/deploy.md` (if present)
- For eval loop setup: see `evals/skill_assertions.py` and `evals/run_evals.py`
