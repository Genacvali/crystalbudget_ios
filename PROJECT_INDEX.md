# CrystalBudget - Индексная документация проекта

## 📋 Обзор проекта

**CrystalBudget** - современное Progressive Web App для управления личными и семейными финансами с уникальной системой многоисточникового распределения бюджета.

### 🎯 Ключевые особенности
- **Многоисточниковое распределение бюджета** - уникальная фича, позволяющая распределять категории расходов между несколькими источниками дохода
- **AI помощник** на базе ChatGPT для управления финансами
- **Telegram Bot** с голосовыми сообщениями и сканированием чеков
- **Семейный доступ** с синхронизацией в реальном времени
- **PWA** - работает как нативное приложение
- **Мультивалютность** - поддержка 9 валют

---

## 🏗️ Архитектура проекта

### Frontend Stack
- **React 18** + **TypeScript**
- **Vite** для быстрой разработки
- **Tailwind CSS** + **shadcn/ui** для UI компонентов
- **TanStack Query** для state management
- **React Router** для навигации
- **Recharts** для графиков и диаграмм

### Backend Stack
- **Supabase** (PostgreSQL) - база данных и аутентификация
- **Supabase Edge Functions** (Deno) - серверная логика
- **OpenAI API** - AI помощник и распознавание
- **Telegram Bot API** - интеграция с Telegram

### Инфраструктура
- **Nginx** reverse proxy
- **Let's Encrypt** SSL
- **Linux** (systemd)
- **Cloud-ready** архитектура

---

## 📁 Структура проекта

```
crystalbudget/
├── src/                          # Исходный код приложения
│   ├── components/               # React компоненты
│   │   ├── ui/                  # Базовые UI компоненты (shadcn/ui)
│   │   ├── Layout.tsx           # Основной макет приложения
│   │   ├── Dashboard.tsx        # Главная страница
│   │   ├── AIChatDialog.tsx     # AI помощник
│   │   ├── CategoryCard.tsx    # Карточка категории
│   │   ├── IncomeSourceCard.tsx # Карточка источника дохода
│   │   └── ...                  # Другие компоненты
│   ├── pages/                   # Страницы приложения
│   │   ├── Dashboard.tsx        # Главная страница
│   │   ├── Categories.tsx       # Управление категориями
│   │   ├── Incomes.tsx          # Управление доходами
│   │   ├── Transactions.tsx     # История транзакций
│   │   ├── Reports.tsx          # Отчеты и аналитика
│   │   ├── Settings.tsx         # Настройки
│   │   └── Auth.tsx             # Аутентификация
│   ├── hooks/                   # Пользовательские хуки
│   │   ├── useAuth.tsx          # Аутентификация
│   │   ├── useCurrency.tsx      # Работа с валютами
│   │   └── use-mobile.tsx       # Определение мобильных устройств
│   ├── types/                   # TypeScript типы
│   │   └── budget.ts            # Типы для бюджета
│   ├── integrations/            # Интеграции
│   │   └── supabase/           # Supabase клиент и типы
│   ├── lib/                     # Утилиты
│   │   ├── utils.ts            # Общие утилиты
│   │   └── numberInput.ts      # Работа с числами
│   └── assets/                  # Статические ресурсы
├── supabase/                    # Backend (Supabase)
│   ├── functions/               # Edge Functions
│   │   ├── ai-chat/            # AI помощник
│   │   ├── telegram-bot/       # Telegram бот
│   │   ├── scan-receipt/       # Сканирование чеков
│   │   ├── transcribe-voice/   # Распознавание голоса
│   │   └── ...                 # Другие функции
│   ├── migrations/             # Миграции базы данных
│   └── config.toml             # Конфигурация Supabase
├── public/                      # Публичные файлы
│   ├── manifest.json           # PWA манифест
│   ├── sw.js                   # Service Worker
│   └── ...                     # Иконки и другие ресурсы
└── ...                         # Конфигурационные файлы
```

---

## 🗄️ База данных

### Основные таблицы

#### `profiles`
- Профили пользователей
- Связь с `auth.users`
- Поля: `id`, `user_id`, `full_name`, `avatar_url`

#### `income_sources`
- Источники дохода
- Поля: `id`, `user_id`, `name`, `color`, `amount`, `frequency`, `received_date`

#### `categories`
- Категории расходов
- Поля: `id`, `user_id`, `name`, `icon`, `allocation_amount`, `allocation_percent`, `linked_source_id`

#### `category_allocations`
- Распределение бюджета по категориям (новая система)
- Поля: `id`, `category_id`, `income_source_id`, `allocation_type`, `allocation_value`

#### `incomes`
- Доходы
- Поля: `id`, `user_id`, `source_id`, `amount`, `date`, `description`

#### `expenses`
- Расходы
- Поля: `id`, `user_id`, `category_id`, `amount`, `date`, `description`

#### `families`
- Семейные группы
- Поля: `id`, `name`, `owner_id`

#### `family_members`
- Участники семей
- Поля: `id`, `family_id`, `user_id`, `joined_at`

#### `family_invite_codes`
- Коды приглашения в семью
- Поля: `id`, `family_id`, `code`, `created_by`, `expires_at`, `used_by`

#### `subscriptions`
- Подписки пользователей
- Поля: `id`, `user_id`, `plan_type`, `status`, `started_at`, `expires_at`, `amount`

#### `telegram_users`
- Связь Telegram аккаунтов с пользователями
- Поля: `id`, `user_id`, `telegram_id`, `telegram_username`

#### `telegram_auth_codes`
- Коды авторизации для Telegram
- Поля: `id`, `telegram_id`, `auth_code`, `expires_at`

#### `telegram_bot_sessions`
- Сессии Telegram бота
- Поля: `id`, `telegram_id`, `session_data`, `expires_at`

#### `user_preferences`
- Настройки пользователей
- Поля: `id`, `user_id`, `currency`, `theme`

### Функции базы данных

- `has_family_access(family_id, user_id)` - проверка доступа к семье
- `is_family_member(target_user_id, user_id)` - проверка членства в семье
- `join_family_with_code(invite_code)` - присоединение к семье по коду
- `delete_expired_invite_codes()` - очистка истекших кодов
- `has_active_subscription(user_uuid)` - проверка активной подписки

---

## 🤖 Интеграции

### 1. AI Chat (OpenAI)
**Файл**: `supabase/functions/ai-chat/index.ts`

**Функциональность**:
- Интеграция с ChatGPT (gpt-4o-mini)
- Управление категориями, источниками дохода, транзакциями
- Функции: создание, обновление, удаление элементов бюджета
- Streaming ответы для лучшего UX

**Доступные инструменты**:
- `create_category` - создание категории
- `update_category` - обновление категории
- `delete_category` - удаление категории
- `update_category_allocation` - настройка распределения бюджета
- `create_income_source` - создание источника дохода
- `add_expense` - добавление расхода
- `add_income` - добавление дохода
- И другие...

### 2. Telegram Bot
**Файл**: `supabase/functions/telegram-bot/index.ts`

**Функциональность**:
- Полнофункциональный Telegram бот
- Авторизация через коды
- Голосовые сообщения с распознаванием
- Сканирование чеков
- Интерактивные клавиатуры
- Управление подписками

**Основные команды**:
- `/start` - начало работы и авторизация
- `/balance` - просмотр баланса
- `/help` - справка

**Типы сообщений**:
- Текстовые сообщения
- Голосовые сообщения
- Фотографии (чеки)
- Callback queries (кнопки)

### 3. Сканирование чеков
**Файл**: `supabase/functions/scan-receipt/index.ts`

**Функциональность**:
- Распознавание чеков через OpenAI Vision
- Извлечение суммы, магазина, даты
- Автоматическая категоризация
- Поддержка пользовательских категорий

**Требования**:
- Активная подписка пользователя
- Настроенные категории расходов

### 4. Распознавание голоса
**Файл**: `supabase/functions/transcribe-voice/index.ts`

**Функциональность**:
- Преобразование голоса в текст
- Извлечение суммы и категории из речи
- Поддержка доходов и расходов
- Интеграция с Telegram ботом

---

## 🎨 UI/UX Компоненты

### Основные компоненты

#### `Layout.tsx`
- Основной макет приложения
- Навигация и заголовок
- Селектор месяца
- Адаптивный дизайн

#### `Dashboard.tsx`
- Главная страница приложения
- Сводные карточки (баланс, расходы, общий баланс)
- Быстрые действия (добавить доход/расход)
- Вкладки: Обзор, Источники, Категории

#### `CategoryCard.tsx`
- Карточка категории расходов
- Показ потрачено/осталось
- Визуальные индикаторы
- Поддержка многоисточникового распределения

#### `IncomeSourceCard.tsx`
- Карточка источника дохода
- Показ остатка по источнику
- Цветовая маркировка
- Статистика по источнику

#### `AIChatDialog.tsx`
- Диалог AI помощника
- Streaming ответы
- Интеграция с функциями управления бюджетом

### UI Kit (shadcn/ui)
- Полный набор компонентов
- Темная/светлая тема
- Адаптивный дизайн
- Accessibility поддержка

---

## 🔧 Конфигурация

### Основные файлы конфигурации

#### `package.json`
- Зависимости проекта
- Скрипты сборки и разработки
- Основные библиотеки: React, TypeScript, Vite, Tailwind, Supabase

#### `vite.config.ts`
- Конфигурация Vite
- Алиасы путей
- Настройки сервера разработки
- Поддержка Lovable

#### `tailwind.config.ts`
- Конфигурация Tailwind CSS
- Кастомные цвета и темы
- Анимации и переходы

#### `tsconfig.json`
- Конфигурация TypeScript
- Строгая типизация
- Пути импортов

### Переменные окружения

#### Frontend
- `VITE_SUPABASE_URL` - URL Supabase проекта
- `VITE_SUPABASE_ANON_KEY` - Анонимный ключ Supabase

#### Backend (Supabase Functions)
- `SUPABASE_URL` - URL Supabase проекта
- `SUPABASE_SERVICE_ROLE_KEY` - Service role ключ
- `OPENAI_API_KEY` - API ключ OpenAI
- `TELEGRAM_BOT_TOKEN` - Токен Telegram бота
- `CLOUDPAYMENTS_PUBLIC_ID` - ID CloudPayments

---

## 🚀 Развертывание

### Локальная разработка
```bash
# Установка зависимостей
npm install

# Запуск dev сервера
npm run dev

# Сборка для продакшена
npm run build
```

### Supabase
```bash
# Установка Supabase CLI
npm install -g supabase

# Локальная разработка
supabase start

# Развертывание функций
supabase functions deploy
```

### PWA
- Автоматическая регистрация Service Worker
- Манифест для установки на устройство
- Офлайн поддержка
- Push уведомления

---

## 📊 Мониторинг и аналитика

### Логирование
- Консольные логи в Edge Functions
- Обработка ошибок с детальной информацией
- Таймауты для защиты от зависаний

### Метрики
- Время загрузки приложения
- PWA Score: 95/100
- Security: A+ SSL
- GDPR compliance

---

## 🔒 Безопасность

### Аутентификация
- Supabase Auth с JWT токенами
- Row Level Security (RLS) для всех таблиц
- Изоляция данных пользователей

### API Security
- CORS настройки
- Валидация токенов авторизации
- Проверка подписок для премиум функций

### Данные
- Шифрование в транзите (HTTPS)
- Безопасное хранение паролей
- Защита от SQL инъекций

---

## 🎯 Уникальные особенности

### 1. Многоисточниковое распределение бюджета
- Одна категория может получать бюджет из нескольких источников
- Гибкое распределение: фиксированная сумма или процент
- Автоматический расчет остатков по каждому источнику

### 2. Carry-Over система
- Перенос остатка между месяцами
- Отдельный учет текущего месяца и общего баланса
- История всех операций с начала использования

### 3. AI интеграция
- Умный помощник для управления финансами
- Создание категорий по голосовому запросу
- Анализ трат и советы по оптимизации

### 4. Telegram Bot
- Полная интеграция с приложением
- Голосовые сообщения и фото чеков
- Интерактивные клавиатуры
- Уведомления о важных событиях

---

## 📈 Roadmap

### В разработке
- [ ] Мобильное приложение (React Native)
- [ ] Экспорт в Excel/PDF
- [ ] Интеграция с банками (API)
- [ ] Автоматическая категоризация на основе ML

### Планируется
- [ ] Widget для главного экрана
- [ ] Apple Watch / Android Wear
- [ ] Голосовой ассистент (Alexa, Google Home)
- [ ] Геолокация расходов на карте
- [ ] Gamification (достижения, челленджи)

---

## 📞 Поддержка

- **Сайт**: https://crystalbudget.net
- **Email**: support@crystalbudget.net
- **Telegram**: @crystalbudget_bot
- **GitHub**: github.com/your-repo

---

## 📄 Лицензия

MIT License - свободное использование и модификация

---

**CrystalBudget** - Ваши финансы под полным контролем! 💎

*Документ обновлен: январь 2025*
