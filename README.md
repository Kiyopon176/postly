# Postly

Postly — Flutter-клиент для просмотра публикаций, авторов и комментариев. Приложение использует реальный REST API DummyJSON, поддерживает поиск и фильтрацию публикаций, локальное избранное, редактирование и удаление с оптимистичным обновлением интерфейса.

## Демонстрация
<img width="1080" height="2400" alt="Screenshot_2026-07-16-21-04-50-183_com example post_test" src="https://github.com/user-attachments/assets/b2826305-05c8-4a66-9fb8-65afc2296dea" />
<img width="1080" height="2400" alt="Screenshot_2026-07-16-21-04-53-525_com example post_test" src="https://github.com/user-attachments/assets/03f83474-2a93-4e0d-8f42-febaed26f5c9" />
<img width="1080" height="2400" alt="Screenshot_2026-07-16-21-04-57-565_com example post_test" src="https://github.com/user-attachments/assets/aa2aa841-05ff-458d-bc5e-f630824b7542" />
<img width="1080" height="2400" alt="Screenshot_2026-07-16-21-05-02-507_com example post_test" src="https://github.com/user-attachments/assets/2b3cc3e2-3490-4e2a-931b-17a07543ba34" />
<img width="1080" height="2400" alt="Screenshot_2026-07-16-21-05-00-455_com example post_test" src="https://github.com/user-attachments/assets/767df375-5eb6-4344-8724-e42720121392" />



## Возможности

- Главный экран со статистикой и подборкой публикаций.
- Список публикаций с поиском по заголовку и фильтром по автору.
- Pull-to-Refresh и ручный повтор запроса после ошибки.
- Детальный экран публикации с комментариями.
- Добавление публикаций в локальное избранное.
- Оптимистичное редактирование и удаление с откатом при ошибке API.
- Каталог авторов и детальные профили с контактами и публикациями.
- Loading, Empty и Error состояния.
- Hero-переходы, анимации появления, glassmorphism и skeleton-загрузка.
- Адаптивная навигация на основе `go_router`.

## Требования

- Flutter 3.41.6 или новее.
- Dart 3.11.4 или новее.
- Android Studio, Xcode или Visual Studio с компонентами для выбранной платформы.
- Доступ к `https://dummyjson.com`.

Проверить окружение:

```bash
flutter doctor -v
flutter --version
```

## Запуск

Клонировать или открыть проект и установить зависимости:

```bash
flutter pub get
```

Проверить доступные устройства:

```bash
flutter devices
```

Запустить приложение:

```bash
flutter run
```

Для выбора конкретной платформы:

```bash
flutter run -d android
flutter run -d windows
flutter run -d chrome
```

## Сборка

Android APK:

```bash
flutter build apk --release
```

Android App Bundle:

```bash
flutter build appbundle --release
```

Web:

```bash
flutter build web --release
```

Windows:

```bash
flutter build windows --release
```

## Проверка качества

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Тесты не выполняют сетевые запросы. Внешние репозитории заменяются локальными fake-реализациями.

## Архитектура

Проект построен по Feature-First подходу с разделением каждой функциональности на слои Clean Architecture.

```text
lib/
├── app/
│   ├── app.dart
│   └── app_shell.dart
├── core/
│   ├── di/
│   ├── error/
│   ├── network/
│   └── theme/
├── features/
│   ├── dashboard/
│   ├── posts/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── users/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/
│   └── widgets/
└── main.dart
```

### Data

Содержит DTO, преобразование JSON в доменные сущности, удалённые источники данных и реализации репозиториев. `Dio` выполняет запросы к DummyJSON. `SharedPreferences` хранит идентификаторы избранных публикаций между запусками приложения.

### Domain

Содержит независимые от Flutter сущности `Post`, `Comment`, `User`, контракты репозиториев и use case-классы. Presentation зависит от абстракций Domain и не знает деталей HTTP или локального хранилища.

### Presentation

Содержит экраны, UI-компоненты и Cubit-состояния. `PostsCubit` и `UsersCubit` управляют загрузкой и изменением данных. UI отображает состояние и отправляет пользовательские действия в Cubit.

## Основные решения

### Управление состоянием

Для предсказуемого однонаправленного потока данных используется `flutter_bloc`. Состояния являются неизменяемыми и сравниваются через `Equatable`.

### Dependency Injection

`get_it` используется как контейнер зависимостей. Классы Data-слоя помечены аннотациями `injectable`, а регистрации собраны в `core/di/injection.dart`. Репозитории легко заменяются fake-реализациями в тестах.

### Сеть и ошибки

`ApiClient` настраивает базовый URL, таймауты и логирование Dio. Все операции возвращают `Result<T>`:

- `Success<T>` содержит успешный результат.
- `Error<T>` содержит `Failure` с пользовательским сообщением и HTTP-кодом.

Отдельно обрабатываются отсутствие сети, connection timeout, некорректные данные, клиентские ошибки 4xx и серверные ошибки 5xx.

### Изменение данных

DummyJSON имитирует PATCH и DELETE, но не сохраняет изменения на сервере. Поэтому интерфейс обновляется оптимистично в `PostsCubit`. При неуспешном ответе Cubit восстанавливает предыдущее состояние.

### Локальное хранение

Избранное сохраняется через `SharedPreferences` как список идентификаторов. После повторного запуска состояние восстанавливается вместе с загрузкой публикаций.

### Навигация

`go_router` реализует Navigator 2.0. `ShellRoute` управляет основной нижней навигацией, а детальные экраны публикаций и пользователей открываются без нижней панели. Для переходов карточек используются Hero-анимации.

### Дизайн-система

Цвета и типографика определены в `core/theme/app_theme.dart`. Переиспользуемые glass-карточки, skeleton-загрузка и состояния экранов находятся в `shared/widgets/app_widgets.dart`.

## API

Базовый URL:

```text
https://dummyjson.com
```

Используемые операции:

| Метод | Эндпоинт | Назначение |
| --- | --- | --- |
| GET | `/posts?limit=0` | Публикации |
| GET | `/posts/{id}/comments` | Комментарии публикации |
| PATCH | `/posts/{id}` | Редактирование публикации |
| DELETE | `/posts/{id}` | Удаление публикации |
| GET | `/users?limit=0` | Авторы |

## Тесты

- Unit-тесты успешной и неуспешной загрузки `PostsCubit`.
- Widget-тест карточки публикации и действия «Избранное».
- Widget-тест редактора и наличия Material-контекста.
- Регрессионный тест поиска внутри `LookupBoundary` маршрутизатора.

## Исходный код

Основной код приложения расположен в каталоге [`lib`](lib), тесты — в каталоге [`test`](test). Точка входа — [`lib/main.dart`](lib/main.dart).
