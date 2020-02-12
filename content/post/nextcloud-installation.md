---
title: "在 Raspberry Pi 安裝 Nextcloud"
date: 2020-02-11T14:40:06+08:00
draft: false
tags:
- Nextcloud
- Raspberry Pi
- Caddy
- Linux
Categories:
- 教學

---

Nextcloud 是一套自由的雲端硬碟系統，可以讓你自己架設像 Google Drive、One Drive 一般的雲端硬碟，將資料掌握在自己手中，本篇紀錄如何在樹梅派安裝 Nextcloud。

## 安裝
到[官方網站](https://nextcloud.com/install/#instructions-server)下載壓縮檔

	sudo unzip -d /var/www nextcloud-18.0.0.zip
	sudo chown www-data:www-data /var/www/nextcloud

### PHP
安裝 PHP 依賴模組

	sudo apt install php-gd php-json php-mysql php-curl php-mbstring php-intl php-imagick php-xml php-zip

參閱 [官方文件](https://docs.nextcloud.com/server/18/admin_manual/installation/source_installation.html#prerequisites-for-manual-installation) 檢查依賴的 PHP 模組，或是擴充功能像是 smb、ldap 等等。

### MySQL
建立 Nextcloud 的資料庫和使用者

	$ sudo mysql
	> create database nextcloud;
	> create user 'nextcloud'@'localhost' identified by 'password';
	> grant all privileges on nextcloud . * to 'nextcloud'@'localhost';
	> flush privileges;


### Caddy
複製 Caddy 提供的 [Nextcloud Caddyfile](https://github.com/caddyserver/examples/blob/master/nextcloud/Caddyfile) 到 `/etc/caddy/Caddyfile`，接著修改成你自己的域名、PHP 路徑。我的設定檔如下：

```
cloud.wancat.cc {

	root   /var/www/nextcloud
	log    /var/log/nextcloud_access.log
	errors /var/log/nextcloud_errors.log

	fastcgi / /var/run/php/php7.3-fpm.sock php {
		env PATH /bin
		env modHeadersAvailable true
		env front_controller_active true
		connect_timeout 60s
		read_timeout 3600s
		send_timeout 300s
	}

	header / {
		Strict-Transport-Security		"max-age=15768000;"
		X-Content-Type-Options			"nosniff"
		X-XSS-Protection			"1; mode=block"
		X-Robots-Tag				"none"
		X-Download-Options			"noopen"
		X-Permitted-Cross-Domain-Policies	"none"
		Referrer-Policy				"no-referrer"
	}

	header /core/fonts {
		Cache-Control				"max-age=604800"
	}

	# checks for images
	rewrite {
		ext .png .html .ttf .ico .jpg .jpeg .css .js .woff .woff2 .svg .gif .map
		r ^/index.php/.*$
		to /{1} /index.php?{query}
	}
	
	rewrite {
                r ^/\.well-known/host-meta$
                to /public.php?service=host-meta&{query}
        }
	rewrite {
                r ^/\.well-known/host-meta\.json$
                to /public.php?service=host-meta-json&{query}
        }
	rewrite {
                r ^/\.well-known/webfinger$
                to /public.php?service=webfinger&{query}
        }

	rewrite {
		r ^/index.php/.*$
		to /index.php?{query}
	}

	rewrite / {
		if {path} not_starts_with /remote.php
		if {path} not_starts_with /public.php
		ext .png .html .ttf .ico .jpg .jpeg .css .js .woff .woff2 .svg .gif .map .html .ttf 
		r ^/(.*)$
		to /{1} /index.php{uri}
	}

	rewrite / {
		if {path} not /core/img/favicon.ico
		if {path} not /core/img/manifest.json
		if {path} not_starts_with /remote.php
		if {path} not_starts_with /public.php
		if {path} not_starts_with /cron.php
		if {path} not_starts_with /core/ajax/update.php
		if {path} not_starts_with /status.php
		if {path} not_starts_with /ocs/v1.php
		if {path} not_starts_with /ocs/v2.php
		if {path} not /robots.txt
		if {path} not_starts_with /updater/
		if {path} not_starts_with /ocs-provider/
		if {path} not_starts_with /ocm-provider/ 
		if {path} not_starts_with /.well-known/
		to /index.php{uri}
	}

	# client support (e.g. os x calendar / contacts)
	redir /.well-known/carddav /remote.php/carddav 301
	redir /.well-known/caldav /remote.php/caldav 301

	# remove trailing / as it causes errors with php-fpm
	rewrite {
		r ^/remote.php/(webdav|caldav|carddav|dav)(\/?)(\/?)$
		to /remote.php/{1}
	}

	rewrite {
		r ^/remote.php/(webdav|caldav|carddav|dav)/(.+?)(\/?)(\/?)$
		to /remote.php/{1}/{2}
	}

	rewrite {
		r ^/public.php/(dav|webdav|caldav|carddav)(\/?)(\/?)$
		to /public.php/{1}
	}

	rewrite {
		r ^/public.php/(dav|webdav|caldav|carddav)/(.+)(\/?)(\/?)$
		to /public.php/{1}/{2}
	}

	# .htaccess / data / config / ... shouldn't be accessible from outside
	status 404 {
		/.htaccess
		/data
		/config
		/db_structure
		/.xml
		/README
		/3rdparty
		/lib
		/templates
		/occ
		/console.php
	}

}
```

由於 Caddyfile 中定義了兩個 log 檔位置，所以我們要先將其建立，並設定所有者為 www-data，否則 Caddy 會噴錯

	sudo touch /var/log/nextcloud-access.log /var/log/nextcloud-errors.log
	sudo chown www-data:www-data /var/log/nextcloud-access.log /var/log/nextcloud-errors.log

重新啟動 Caddy，可能需要 debug 一下

	sudo service caddy restart

接下來打開你的 Nextcloud，就可以進行初始化設定。建立管理員帳號，輸入資料庫的帳號密碼，就可以開始使用了。

## 配置 Redis 緩存
沒有開 caching，效率有點差，安裝 Redis 增加效率

	sudo apt install php-apcu php-redis redis-server

安裝後，修改 Redis 設定檔

	sudo vim /etc/redis/redis.conf

修改下列欄位
```
port 0
```

將下面欄位 uncomment

```
unixsocket /var/run/redis/redis-server.sock
unixsocketperm 770
```

**注意：你的 redis socket 路徑可能跟我不太一樣，請使用原本的路徑**

重新啟動 Redis

	sudo service redis restart

編輯 Nextcloud 設定檔

	sudo vim /var/www/nextcloud/config/config.php

加入以下設定：

```
'memcache.local' => '\\OC\\Memcache\\Redis',
'memcache.locking' => '\\OC\\Memcache\\Redis',
'filelocking.enabled' => 'true',
'redis' => 
array (
	'host' => '/var/run/redis/redis-server.sock',
	'port' => 0,
	'timeout' => 0.0,
),
```

請注意：在這裡要使用你的 redis socket 路徑
設定系統開機啟動 Redis

	sudo systemctl enable redis-server

打開 Nextcloud 應該就啟用了。

## Troubleshooting
### 502 Bad Gateway
打開網頁後發現 502 Bad Gateway，這代表 PHP 連不上。

檢查 php socket 路徑，重開 php

	sudo serivce php7.3-fpm restart

## References
[How to install Nextcloud on your Raspberry Pi? (2 ways)](https://raspberrytips.com/install-nextcloud-raspberry-pi/)

[Enable caching](https://bayton.org/docs/nextcloud/installing-nextcloud-on-ubuntu-16-04-lts-with-redis-apcu-ssl-apache/#6-2-enable-caching)
