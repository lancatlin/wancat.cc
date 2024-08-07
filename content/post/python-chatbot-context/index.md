+++
title = "在 Python 中實作對話型聊天機器人"
date = 2021-07-29T16:13:36+08:00
categories = ["技術"]
tags = ["Python", "Chatbot"]
draft = false
showToc = true

+++

當你在開發一個聊天機器人，有時候為了使用者體驗，你不能要使用者用像指令的方式，將所有資訊一次傳過來。舉例來說，若我們要開發一個猜數字遊戲運作如以下：

> **user:** guess  
> **bot:** From what number?  
> **user:**: 25  
> **bot:** To what number?  
> **user:** 100  
> **bot:** Guess a number between 25 to 100  
> **user:** 64  
> **bot:** too small  
> **user:** 91  
> **bot:** too large  
> ......  
> **user:** 83  
> **bot:** Correct! You spent 6 times to guess this number.

然而，我們在後端通常是「一個請求一個回覆」，如果要將這樣的行為拆成多個 handler 將會是場災難，為什麼？想想要怎麼存狀態，全域變數？資料庫？還是 Redis？每當你多問使用者一個問題，你就得在你的 state schema 新增一個欄位，讓你的程式碼越來越複雜。

接下來，我會告訴你如何用一個非常輕鬆的方式處理對話，讓你只要寫像以下一般的程式碼就能達成。

```python
    def guess(self):
        '''Game function'''
        min_value = self.ask_number('From what number?')
        max_value = self.ask_number('To what number?')
        secret = randint(min_value, max_value)
        msg = f'Guess a number between {min_value} to {max_value}'
        counter = 0
        while True:
            counter += 1
            answer = self.ask_number(msg)
            if answer > secret:
                msg = 'Too large'
            elif answer < secret:
                msg = 'Too small'
            else:
                break
        self.reply(f'You spent {counter} times to guess the secret number.')
```

我會以 LINE Bot 作為示範，但你用什麼平台其實不重要，這個方法完全可以套用在其他的 bot 像 Telegram 或 Messenger。我在範例中使用 Django，同樣你也可以換成其他 framework。

## 設定環境

這裡是設定 bot 的環境，如果你已經知道了可以跳過此部分。

需要安裝 pipenv：

```bash
sudo pip3 install pipenv
```

下載我的程式碼：

```bash
git clone https://github.com/lancatlin/python-chatbot-context.git
cd python-chatbot-context
pipenv install
pipenv shell
```

到 [LINE Developers](https://developers.line.biz) 去建立一個 bot，產生一個 access token 和 secret，建立一個 `.env` 檔案：

```bash
LINE_TOKEN=YOUR_TOKEN
LINE_SECRET=YOUR_SECRET
```

接著就能啟動 Django 了

```bash
python manage.py migrate 	# for first execution
python manage.py runserver
```

再來用 Ngrok 或類似程式將 localhost:8000 打出一個公開的網址，接著將網址註冊到 LINE Messaging API 的設定。

## 概念解說

###### ![](./diagram.jpg)

核心概念是阻塞指令之 thread，直到下一則訊息抵達。當程式收到 'guess' 指令，就會開始遊戲，當程式需要使用者輸入訊息，它放一個 True （放什麼無所謂）到當前聊天室的 requests queue 中，接著等待。當下一則訊息進來時，會跑到另一個 thread 中，接著檢查當前聊天室的 requests queue，如果不是空的，就會將此訊息放入 responses queue 中。遊戲 thread 從 responses queue 拿到訊息後就會繼續執行。

## 實作

我們將此概念實作成 `MessageQueue` 類別：

```python
# guess/message_queue.py
import queue
from threading import RLock
from .line import get_room


class RequestTimout(Exception):
    pass


class MessageQueue:
    __lock = RLock()
    __requests = {}
    __responses = {}

    @classmethod
    def create_if_not_exists(cls, room):
        '''Create the requests and responses queues for the room if not exists'''
        with cls.__lock:
            if room not in cls.__requests:
                cls.__requests[room] = queue.Queue(maxsize=1)

            if room not in cls.__responses:
                cls.__responses[room] = queue.Queue(maxsize=1)

    @classmethod
    def handle(cls, event):
        '''Handle the message, check whether there is room request for'''
        room = get_room(event)
        cls.create_if_not_exists(room)

        try:
            if not cls.__requests[room].empty():
                cls.__responses[room].put(event, timeout=1)
                cls.__requests[room].get()
                return True
            return False
        except queue.Empty:
            '''No request, ignore the message'''
            return False

    @classmethod
    def request(cls, room, timeout=30):
        '''Request a message, block until message comes in or timeout'''
        try:
            cls.create_if_not_exists(room)

            cls.__requests[room].put_nowait(True)
            return cls.__responses[room].get(timeout=timeout)

        except queue.Empty:
            MessageQueue.clear(room)
            raise RequestTimout

    @classmethod
    def clear(cls, room):
        '''Clear the requests'''
        cls.create_if_not_exists(room)
        try:
            cls.__requests[room].get_nowait()
        except queue.Empty:
            pass

```

有了這個，我們就能非常輕鬆的實作猜數字遊戲：

```python
# guess/guess.py
from .message_queue import MessageQueue, RequestTimout
from .line import reply_text, get_room, get_msg
from random import randint


class Guess:
    '''Guess handle a guess number game'''

    def __init__(self, event):
        self.event = event
        try:
            self.guess()
        except RequestTimout:
            self.reply('Timeout')

    def guess(self):
        '''Game function'''
        min_value = self.ask_number('From what number?')
        max_value = self.ask_number('To what number?')
        secret = randint(min_value, max_value)
        msg = f'Guess a number between {min_value} to {max_value}'
        counter = 0
        while True:
            counter += 1
            answer = self.ask_number(msg)
            if answer > secret:
                msg = 'Too large'
            elif answer < secret:
                msg = 'Too small'
            else:
                break
        self.reply(f'You spent {counter} times to guess the secret number.')

    def ask(self, *msg):
        '''Ask a question to current user'''
        self.reply(*msg)
        self.event = MessageQueue.request(get_room(self.event))
        return get_msg(self.event)

    def ask_number(self, *msg):
        '''Ask a number, if not number, ask again'''
        try:
            content = self.ask(*msg)
            return int(content)
        except ValueError:
            return self.ask_number('Please input an integer.', *msg)

    def reply(self, *msg):
        '''Reply words to user'''
        reply_text(self.event, *msg)

```

你可以看到遊戲的主函式非常的直觀，只用了 17 行程式碼就完成，而且還可以同時多人使用。

![](./result.gif)

在 [GitHub](https://github.com/lancatlin/python-chatbot-context) 取得完整程式碼。

特別感謝 [YukinaMochizuki](https://github.com/YukinaMochizuki) 由[他的 Notion bot 專案](https://github.com/YukinaMochizuki/DCDos)提供我原始想法。
