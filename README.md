# 🍰 French Dessert Collector (Flutter)

> 🇰🇿 Қазақша төменде | 🇷🇺 Русская версия ниже

---

## 🇰🇿 Қазақша

### 📋 Сипаттамасы

**French Dessert Collector** — Flutter негізінде жасалған аркадалық ойын. Экранның үстінен түсіп жатқан француз десерттерін (багет, макарон, пуф) ұстап, ұпай жинау керек, ал сүйектерден (bone, fishbone) аулақ болу керек. Ойын нәтижелері құрылғыда сақталып, рейтинг кестесінде көрсетіледі.

### ✨ Ойын механикасы

- ⏱️ **Уақыт**: 30 секундтан басталады
- ❤️ **Өмір (lives)**: 3-тен басталады
- 🏆 **Ұпай жүйесі**:

  | Зат | Ұпай |
  |---|---|
  | 🥖 Baguette | +10 |
  | 🍪 Macaron | +20 |
  | 🥐 Puff | +30 |
  | 🦴 Bone | −10 |
  | 🐟 Fishbone | −20 |

- Заттар кездейсоқ түседі: **70% десерт, 30% қоқыс**
- Әр **100 ұпай сайын** заттардың түсу жылдамдығы артады (қиындық деңгейі өседі)
- Уақыт таусылғанда немесе өмір саны 0-ге жеткенде ойын аяқталады

### 📱 Экрандар

| Экран | Файл | Қызметі |
|---|---|---|
| Басты бет | `home_screen.dart` | "Game Start" батырмасы |
| Атты енгізу | `username_screen.dart` | Ойыншы атын енгізу (валидациямен) |
| Ойын экраны | `game_screen.dart` | Негізгі ойын логикасы — таймер, ұпай, өмір, кідірту |
| Кідірту | `pause_screen.dart` | Ойынды уақытша тоқтату мәзірі |
| Ойын соңы | `game_over_screen.dart` | Нәтиже, жиналған заттар статистикасы |
| Рейтинг | `rankings_screen.dart` | Барлық ойыншылардың нәтижелері, ұпай бойынша сұрыпталған |

### 🛠️ Технологиялар

- **Flutter / Dart**
- `shared_preferences` — нәтижелерді (`ScoreModel`) құрылғыда JSON түрінде сақтау
- `cupertino_icons`
- Меншікті сервис-класстар: `FoodService` (кездейсоқ заттар генерациясы), `StorageService` (нәтижелерді сақтау/оқу)

### 📂 Жоба құрылымы

```
lib/
├── main.dart                    # Кіру нүктесі (MyApp)
├── home_screen.dart             # Басты бет
├── username_screen.dart         # Ойыншы атын енгізу
├── game_screen.dart             # Негізгі ойын логикасы
├── pause_screen.dart            # Кідірту мәзірі
├── game_over_screen.dart        # Ойын соңы, нәтиже
├── rankings_screen.dart         # Рейтинг кестесі
├── models/
│   ├── food_item.dart           # FoodItem, CollectedFood, FallingItem
│   └── score_model.dart         # ScoreModel (username, score, date)
└── services/
    ├── food_service.dart        # Кездейсоқ заттар генерациясы
    └── storage_service.dart     # Нәтижелерді сақтау/жүктеу

assets/
├── images/    # Ойын графикасы (десерттер, фон, ойыншы, батырмалар)
└── icons/     # Интерфейс иконкалары
```

### 🚀 Орнату және іске қосу

```bash
git clone <repository-url>
cd dessert_collector_flutter
flutter pub get
flutter run
```

### 📌 Ескертпе

Бұл жобаның **Java (Android native)** нұсқасы да бар — сол нұсқада логика ұқсас, бірақ Android SDK негізінде жазылған. Осы репозиторийдегі нұсқа сол логиканы **Flutter/Dart-қа қайта жазылған** нұсқасы болып табылады.

---

## 🇷🇺 Русская версия

### 📋 Описание

**French Dessert Collector** — аркадная игра на Flutter. Нужно ловить падающие сверху французские десерты (багет, макарон, пуф) и набирать очки, избегая костей (bone, fishbone). Результаты сохраняются на устройстве и отображаются в таблице рейтинга.

### ✨ Игровая механика

- ⏱️ **Время**: старт с 30 секунд
- ❤️ **Жизни**: старт с 3
- 🏆 **Система очков**:

  | Предмет | Очки |
  |---|---|
  | 🥖 Baguette | +10 |
  | 🍪 Macaron | +20 |
  | 🥐 Puff | +30 |
  | 🦴 Bone | −10 |
  | 🐟 Fishbone | −20 |

- Предметы падают случайно: **70% десерт, 30% мусор**
- Каждые **100 очков** увеличивается скорость падения предметов (растёт сложность)
- Игра заканчивается, когда время истекло или жизни закончились

### 📱 Экраны

| Экран | Файл | Назначение |
|---|---|---|
| Главный экран | `home_screen.dart` | Кнопка "Game Start" |
| Ввод имени | `username_screen.dart` | Ввод имени игрока (с валидацией) |
| Игровой экран | `game_screen.dart` | Основная логика игры — таймер, очки, жизни, пауза |
| Пауза | `pause_screen.dart` | Меню временной остановки игры |
| Конец игры | `game_over_screen.dart` | Результат, статистика собранных предметов |
| Рейтинг | `rankings_screen.dart` | Результаты всех игроков, отсортированные по очкам |

### 🛠️ Технологии

- **Flutter / Dart**
- `shared_preferences` — хранение результатов (`ScoreModel`) на устройстве в формате JSON
- `cupertino_icons`
- Собственные сервис-классы: `FoodService` (генерация случайных предметов), `StorageService` (сохранение/чтение результатов)

### 📂 Структура проекта

```
lib/
├── main.dart                    # Точка входа (MyApp)
├── home_screen.dart             # Главный экран
├── username_screen.dart         # Ввод имени игрока
├── game_screen.dart             # Основная логика игры
├── pause_screen.dart            # Меню паузы
├── game_over_screen.dart        # Конец игры, результат
├── rankings_screen.dart         # Таблица рейтинга
├── models/
│   ├── food_item.dart           # FoodItem, CollectedFood, FallingItem
│   └── score_model.dart         # ScoreModel (username, score, date)
└── services/
    ├── food_service.dart        # Генерация случайных предметов
    └── storage_service.dart     # Сохранение/загрузка результатов

assets/
├── images/    # Игровая графика (десерты, фон, игрок, кнопки)
└── icons/     # Иконки интерфейса
```

### 🚀 Установка и запуск
mm
```bash
git clone <repository-url><img width="1250" height="455" alt="dessert_collector_" src="https://github.com/user-attachments/assets/c21e2b45-b1f3-4282-b862-82b16c0f898a" />

cd dessert_collector_flutter
flutter pub get
flutter run
```<img width="1250" height="455" alt="dessert_collector_" src="https://github.com/user-attachments/assets/92b2f0ae-e7c3-45a2-b0c4-0b7d5b3b47d2" />
