+++
categories = ["教學"]
date = "2020-05-17T22:17:08+08:00"
draft = false
showtoc = false
tags = ["Raspberry Pi", "WordPress", "Caddy"]
title = "Raspberry Pi 安裝 WordPress 教學"

+++

WordPress 是一套自由的網站系統，可以安裝在自己的伺服器，以下是我在 Raspberry Pi 上安裝 WordPress 的記錄。

請先安裝好 MariaDB / MySQL、PHP 7.3 以上、[Caddy](/post/caddy/)。

到[官網](https://wordpress.org/download/)複製壓縮檔連結（我偏好 tar.gz）

```
cd Downloads
wget https://wordpress.org/latest.tar.gz

sudo tar -zxvf latest.tar.gz -C /var/www
sudo chown -R www-data:www-data /var/www/wordpress
```

接著建立 MySQL 使用者：

```
sudo mysql
> create database wordpress;
> create user 'wordpress'@'localhost' identified by 'password';
> grant all privileges on wordpress . * to 'wordpress'@'localhost';
> flush privileges;
```

接下來將域名綁定到 Web Server，這邊我們使用 Caddy

```
yourhostname.com {
	root /var/www/wordpress
	gzip
	fastcgi / /var/run/php/php7.3-fpm.sock php {
		index index.php
	}
}
```

重啟 Caddy

```
sudo service caddy restart
```

接著打開網站，就會出現安裝畫面：

![wordpress-installation](/img/wordpress-installation/install.png)

接下來照著指示操作，填入剛剛設定的資料庫、使用者、及密碼即可完成安裝。


{{< service_homelab >}}
