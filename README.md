# MonHubKey

Отдельная key-система для Roblox/Luau в виде самостоятельного модального окна. Она не импортирует Obsidian, не изменяет его файлы и может жить в отдельном репозитории.

## Возможности

- отдельный `ScreenGui` поверх игры;
- затемнение, blur и короткая анимация открытия;
- адаптивный масштаб для небольших экранов;
- управление мышью и touch, перетаскивание за заголовок;
- отправка по кнопке и Enter;
- состояния `checking`, `success`, `error` и защита от повторной отправки;
- действия Get key, Discord и Premium через URL или callback;
- синхронная или yielding-функция проверки ключа;
- методы `Show`, `Hide`, `Submit`, `SetStatus`, `SetKey`, `GetKey`, `Focus`, `Close`, `Destroy`.

## Быстрый старт

```luau
local KeySystem = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/USER/REPO/main/KeySystem.lua"
))()

local gate = KeySystem.new({
	Title = "Onyx",
	GetKeyUrl = "https://example.com/get-key",
	DiscordUrl = "https://discord.gg/example",
	PremiumUrl = "https://example.com/premium",

	Validate = function(key)
		-- Здесь вызывается ваш API проверки.
		return key == "MONHUB", "Invalid or expired key"
	end,

	OnSuccess = function(key, data)
		-- Запуск основного скрипта после успешной проверки.
	end,
})
```

Для Roblox Studio вместо `loadstring` используйте ModuleScript:

```luau
local KeySystem = require(path.to.KeySystem)
```

Полный локальный пример находится в `Example.lua`.

## Результат Validate

Поддерживаются два формата:

```luau
return true
return false, "Invalid key"
```

или:

```luau
return {
	Success = true,
	Message = "Welcome back",
	Data = { Plan = "Premium" },
}
```

`Validate` запускается в отдельной задаче, поэтому внутри можно ждать HTTP-ответ. Ошибка callback перехватывается и показывает безопасное сообщение вместо поломки интерфейса.

## Действия-ссылки

Если задан только URL, в executor-среде он копируется через `setclipboard`:

```luau
GetKeyUrl = "https://example.com/key"
```

Для полного контроля передайте callback:

```luau
OnGetKey = function(url, gate)
	setclipboard(url)
	gate:SetStatus("Link copied", "success")
end
```

Аналогично работают `OnDiscord` и `OnPremium`. Callback имеет приоритет над URL-механикой.

## Основные настройки

| Поле | По умолчанию | Назначение |
|---|---|---|
| `Title` | `MonHub` | Заголовок окна |
| `Subtitle` | `Enter your key to continue` | Подзаголовок |
| `Placeholder` | `key` | Placeholder поля |
| `Validate` | — | Функция проверки ключа |
| `CloseOnSuccess` | `true` | Скрыть окно после успеха |
| `SuccessDelay` | `0.45` | Задержка перед скрытием |
| `AllowClose` | `true` | Показывать крестик |
| `CloseBehavior` | `Hide` | `Hide` или `Destroy` |
| `Blur` | `true` | Размывать игру за окном |
| `BlurSize` | `12` | Сила blur |
| `Draggable` | `true` | Разрешить перетаскивание |
| `Parent` | auto | Явный родитель `ScreenGui` |
| `Theme` | dark | Таблица переопределений цветов |

Пример изменения акцента:

```luau
Theme = {
	Accent = Color3.fromRGB(139, 92, 246),
	AccentHover = Color3.fromRGB(155, 112, 255),
}
```

## Важно о безопасности

Любую проверку, полностью находящуюся в LocalScript, можно обойти. Для реальной защиты `Validate` должен обращаться к вашему серверу, а сервер — проверять срок жизни, устройство/сессию и подпись ответа. Не храните список настоящих ключей прямо в `Example.lua`.
