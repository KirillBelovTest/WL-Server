# Wolfram Web Server

Wolfram Web Server

## Цель

Наша цель - работающий веб-сервер, полностью написанный на Wolfram Language.
Чтобы достичь этой цели, мы должны поочередно реализовать все необхолимые уровни модели OSI,
которые не предтавлены в Wolfram.

## TCP

Первое, что мы сделаем - это создадим и сразу же запустим сервер,
который работает по протоколу TCP. Сделать это довольно просто.
Сначала устанавливаем необходимые пакеты:

```mathematica
PacletInstall["KirillBelov/Internal"]
PacletInstall["KirillBelov/Objets"]
PacletInstall["KirillBelov/TCPServer"]
```

Теперь импортируем определения из этих пакетов:

```mathematica
Get["KirillBelov`Internal`"]
Get["KirillBelov`Objects`"]
Get["KirillBelov`TCPServer`"]
```

Создаем сам сервер:

```mathematica
tcp = TCPServer[]
```

И запускаем его:

```mathematica
listener = SocketListen[8000, tcp@#&]
```

Все готово. Но что дальше? Сервер ведь абсолютно пустой и ничео не делает.
Нужно придумать для него функциональность. Допустим, первое, что мы сделаем - это 
ответ на `ping`. Т.е. если в сервер приходит строка `ping`, то обратно он высылает `pong`.
Для этого нам нужно добавить в сервер обработчик завершенности сообщений:

```mathematica
tcp["CompleteHandler", "Ping"] = pingQ -> pingLength
tcp["MessageHandler", "Ping"] = pingQ -> pong
```

Что значат строки выше? Всякий раз, когда сервер будет получать входящее сообщение,
то он будет сначала применять функцию `pingQ`, чтобы убедиться, что запрос пришел именно за этим.
Если это дейтствительно `ping`, то далее вычисляется ожидаемая длина этого сообщения при помощи
функции `pingLength`. После того как входящее сообщение было завершено запускатся обработка
сообщения при помощи функции `pong`. Т.е. мы добавили в наш сервер 3 функции,
но пока что ни одну не определили. Давайте сделаем это! Основное внимание на аргументы -
все три функции должны принимать на вход два аргумента. Первый аргумент - это сокет, т.е.
по сути подключенный к серверу клиент, куда мы будем отправлять ответ. А второй аргмент - это
массив байт, в котором хранится пришедшее сообщение. Сначала проверка, что это `ping`:

```mathematica
pingQ[client_SocketObject, message_ByteArray] :=
(*Return:True|False*)
Echo[ByteArrayToString[message] == "ping", "pingQ"]
```

Теперь вычисление длины сообщения - функция должна возвращать целое число:

```mathematica
pingLength[client_SocketObject, message_ByteArray] :=
(*Return:_Integer*)
Echo[Length[message], "pingLength"]
```

И последнее - функция, которая обрабатывает сообщение и возвращает результат в виде
массива байт, который сервер автоматически отправит клиенту:

```mathematica
pong[cleint_SocketObject, message_ByteArray] := (
    Echo[message, "ping"];
    (*Return:ByteArray[]*)
    Echo[StringToByteArray["pong"], "pong"]
)
```

Теперь точно все готово! Подключимся к нашему серверу и отправим в него первое сообщение:

```mathematica
socket = SocketConnect[8000]
BinaryWrite[socket, StringToByteArray["ping"]]
result = SocketReadMessage[socket]
ByteArrayToString[result]
Close[socket]
```

В итоге после выполнения последнего блока кода в консоль (или в окно *Messages*)
напечатается следующее:

>```log
>>> pingQ True
>>> pingLength 4
>>> pingQ True
>>> ping ByteArray[<4>]
>>> pong ByteArray[<4>]
>```

Это будет значит, что сервер работает. Его самая минимальная функциональность готова.
Теперь не останавливая сервис мы можем продолжить наполнять его функциональность.
Чтобы это сделать на уровне TCP нам достаточно добавить новые обработчики
по аналогии с обработчиками сообщения `ping`.

## HTTP

Теперь давайте добавим серверу возможность работать по протоколу HTTP.
Для этого необходимо установить еще один пакет:

```mathematica
PacletInstall["KirillBelov/HTTPHandler"]
```

И импортируем:

```mathematica
Get["KirillBelov`HTTPHandler`"]
Get["KirillBelov`HTTPHandler`Extensions`"]
```

