---
title: "Caddy 安裝教學"
date: 2020-02-04T10:39:46+08:00
draft: false
categories:
- 教學
tags:
- Linux
- Caddy
---

Caddy 是一個由 Go 撰寫的 Web Server，其主要賣點是簡單的設定檔，適合在開發環境中快速架設，還有自動 HTTPS 的功能，相當方便。

我之前在 Linode 上就使用 Caddy，覺得體驗相當好，因此這次也選擇使用它。

## 安裝

到 [Caddy](https://caddyserver.com/) 網站的下載頁面，複製 One-step installer script 就可以一鍵安裝。

```
curl https://getcaddy.com | bash -s personal
```

如果是要拿來當開發環境中的 Web Server，這樣就足夠了，但我要讓它在背景執行，因此還需要設定好它的 systemd。

## Systemd

請參考[官方的安裝教學](https://github.com/caddyserver/caddy/tree/master/dist/init/linux-systemd)，照著做就行了，比較容易踩雷的是取得憑證的部份，首先 Let's Encrypt 會對你做 DNS challenge，所以如果是使用 CloudFlare 的，要把 Proxy 關掉（雲朵）。再來是寫設定檔，Caddy 的設定檔相當簡單，不過用 systemd 就是很難除錯（看 log 麻煩），所以建議先自己用 `sudo caddy -conf /etc/caddy/Caddy` 測試設定檔，等到沒問題再用 systemd 開。

## 設定檔範例

以下是我網站使用的設定檔

```
matomo.wancat.cc {
    root /var/www/matomo
    gzip
    fastcgi / /var/run/php/php7.3-fpm.sock php {
        index index.php
    }
}

lincalvino.me/narcissism {
        root /var/www/narcissism
}

lincalvino.me {
        redir / /narcissism 302
}

stock.wancat.cc {
        proxy / localhost:8080
}
```

裡頭包含流量分析軟體 [Matomo](/post/matomo-installation/)、[我爸的網站](https://lincalvino.me)、還有我寫的[股票爬蟲程式網站](https://stock.wancat.cc)。