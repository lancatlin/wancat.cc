---
title: 學習筆記 RSS Telegram Bot in Go
tags: 
- Golang
- Telegram
---

# 學習筆記 RSS Telegram Bot in Go 

最近開始想要將資訊獲取來源從臉書搬出來，目前改成用 Email 電子報以及 RSS 來訂閱自己喜歡的網站，可避免被臉書演算法控制。

我一直有個困擾，**現下我竟很難找到一個足夠方便的 RSS 閱讀器**，其實我的需求不高，只要有新文章通知我就好，甚至不用在應用內開啟，我喜歡在 Firefox 看或是存到 Pocket；還有重要的一點是**跨平台**，我一開始使用 ThunderBird 當 RSS 閱讀器，因為可以整合 Email 和 RSS，但沒有辦法在手機讀，換一台電腦也就沒有了。後來我思考發覺，**Telegram 或許是一個不錯的平台**，它可以跨平台，Bot API 也很好，反正我是在瀏覽器開啟，也不需要內嵌瀏覽器。  

這樣的想法果然很多人都有，隨便找一下就找到一大堆。但實在很想練一下 Go，所以還是手癢開始做了。

[GitHub Repo](https://github.com/wancatserver/tg-rss-bot)

## XML 解析

首先要解析 atom feed。  

使用 `encoding/xml` 庫，使用 `xml.Unmarshal()` 進行解析。

須先定義解析後的物件結構 `struct`

```go
type 
```

