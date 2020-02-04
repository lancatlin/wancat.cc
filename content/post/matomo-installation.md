---
title: "Google Analytics 替代方案 Matomo 安裝教學"
date: 2020-02-04T10:27:38+08:00
draft: true
categories:
- 教學
tags:
- Matomo
- Linux
- Caddy
- SQL
---

因為實在不想再讓 Google 拿到資料了，所以我到 [No More Google](https://nomoregoogle.com/) 網站上找 Google Analytics 的替代方案，第一名就是 [Matomo](https://matomo.org/)。

Matomo 是一個自架的流量分析程式，是自由軟體，也有提供付費的 Cloud hosting 服務。我在試用後覺得還不錯，就決定自行在 Raspberry Pi 上安裝。因為是自架的，所以資料都在自己手上，不會被 Google 拿去利用。

安裝方式參考[官方文件](https://matomo.org/docs/installation/。

環境需要 PHP、MySQL or MariaDB

PHP 安裝：
```
sudo apt-get install php7.0 php7.0-curl php7.0-gd php7.0-cli mysql-server php7.0-mysql php-xml php7.0-mbstring
```

資料庫我比較偏好社群維護的 MariaDB：

```
sudo apt install mariadb-server
sudo mysql_secure_installation
```

建議在安裝後執行 `mysql_secure_installation` 來強化安全性。

由於我使用 Caddy，所以 Caddyfile 中要加入以下程式：

```
matomo.wancat.cc {
    root /var/www/matomo # 換成你的 matomo 位置
    gzip
    fastcgi / /var/run/php/php7.3-fpm.sock php {
        index index.php
    }
}
```

然後打開網頁，就可以看到安裝程式了。接著要幫 Matomo 設定好 SQL User 和 Database，

```
$ sudo mysql
> create database matomo;
> create user 'matomo'@'localhost' identified by 'password';
> grant all privileges on matomo . * to 'matomo'@'localhost';
> flush privileges;
```

這樣 matomo 帳號就只能控制 'matomo' 這個 database。把帳號密碼填入安裝程序，就會檢查是否完成了。這裡有個要注意的是，執行 matomo 的帳號（www-data）基本上不該給它對網站的寫入權限，可以設成 555，matomo.js 這個 JavaScript 檔需要給予寫入權限。