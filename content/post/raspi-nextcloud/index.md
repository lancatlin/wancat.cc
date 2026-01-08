+++
title = "從零開始的 Nextcloud 完整安裝教學"
date = 2021-08-07T13:12:54+08:00
categories = ["self-hosted"]
tags = ["Raspberry Pi", "Nextcloud", "Linux"]
showtoc = true
tocopen = true
summary = "用兩顆外接硬碟組 RAID 1，設定 DDNS、Nginx，並安裝 Nextcloud，以及後續的 PHP 調校與 Redis 快取。"
updated = "2023-01-08T03:16:00+08:00"
+++

我以前寫過一篇 Nextcloud 安裝教學，最近設定了一台新的 Pi，記錄下從無到有的完整設定過程，包含基本設定、路由器、防火牆等。安裝過程若遇問題，可搭配各段落 References 服用。本文使用 Raspberry Pi 作為硬體，其中大部分設定用在 Debian / Ubuntu 也沒有問題。

本文會用兩顆外接硬碟組磁碟陣列，設定 DDNS、Nginx，並安裝 Nextcloud，以及後續的 PHP 調校與 Redis 快取。

## 準備工作

* Raspberry Pi，我使用 4B
* 記憶卡
* 外接硬碟或硬碟外接盒，如果要組磁碟陣列需要兩顆。
* 路由器
* 能取得公網 IP 之網路
* 一個域名

首先讓路由器接上網路，下載 [Raspberry Pi Imager](https://www.raspberrypi.org/software/)，將記憶卡寫入 Raspberry Pi OS **LITE**。

接著將記憶卡插上 Pi，接上螢幕後開機，帳號是 pi，密碼是 raspberry。

### 靜態 IP 設定

路由器預設是 DHCP 自動分配 IP，可能會浮動，對穩定性不太好，所以我們會幫 Pi 設定一個 static LAN IP，如 192.168.0.2。

Ref: [Raspberry Doc](https://www.raspberrypi.org/documentation/configuration/tcpip/)

編輯 `/etc/dhcpcd.conf`

```sh
sudo cp /etc/dhcpcd.conf /etc/dhcpcd.backup     # 備份
sudo vim /etc/dhcpcd.conf                       # Feel free to use Nano or something else :)
```

找到以下幾行，拿掉註解

```sh
interface eth0
static ip_address=192.168.0.2/24                # Pi 的 IP 位址， /24 為 netmask，要記得加
static ip6_address=fd51:42f8:caae:d92e::ff/64   # IPv6，随意
static routers=192.168.0.1                      # 路由器位址
static domain_name_servers=1.1.1.1 8.8.8.8 fd51:42f8:caae:d92e::1       # DNS Server IP
```

若不確定 router ip，可使用 `ip a` 指今查詢。

完成後重開機，用 `ip a` 檢查有無更新。

### 基本設定

我們做一些 Pi 的設定

```sh
sudo raspi-config
```

首先改密碼：  
System Options -> Password

啟用 SSH：  
Interface Options -> SSH -> Yes

然後跑下更新

```sh
sudo apt update
sudo apt upgrade
```

### SSH 換 Port

為了安全性考量，我們將 SSH 換一個 Port。編輯 SSH 設定檔：

```sh
sudo vim /etc/ssh/sshd_config
```

找到以下行，將預設的 22 換成你要的 port，以 22222 為例：

```
Port 22222
```

接著重啟 SSH

```
sudo systemctl restart sshd
```

接下來可以從你的電腦連上 Pi

```
ssh -p 22222 pi@192.168.0.2
```

## 設定 RAID 磁碟陣列

為了避免因硬碟壞掉導致資料遺失，我們設定 RAID 1 來鏡像兩顆硬碟：

Refs:
* https://www.ricmedia.com/build-raspberry-pi3-raid-nas-server/
* https://jlamoure.net/blog/raspberry-pi-raid-1/

安裝 mdadm

```
sudo apt install mdadm -y
```

RAID 需要重開機才能讓核心載入需要的檔案：

```
sudo reboot
```

接著插入兩顆硬碟，待會需要格式化，裡面不要存放資料。檢查硬碟編號：

```
lsblk
```

假設兩顆分別是 `/dev/sda` 和 `/dev/sdb`，先建立 GPT 和分割區：

```
sudo fdisk /dev/sda
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help):
g           # 建立 GPT 分割表
n           # 建立分割區，ENTER 到底
w           # 寫入變更，無法復原資料
q
```

重復 `/dev/sdb`。

再跑一次 `lsblk`，應該能看到出現 `/dev/sda1` 和 `/dev/sdb1`，接著建立 RAID 1：

```
# mint 可以換你喜歡的名字
sudo mdadm --create --verbose /dev/md/mint --level=1 --raid-devices=2 /dev/sda1 /dev/sdb1
```

`lsblk` 就會看到 sda1 和 sdb1 下面出現了 /dev/md/mint

```
NAME        MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda           8:0    0  3.7T  0 disk  
`-sda1        8:1    0  3.7T  0 part  
  `-md127     9:127  0  3.7T  0 raid1
sdb           8:16   0  3.7T  0 disk  
`-sdb1        8:17   0  3.7T  0 part  
  `-md127     9:127  0  3.7T  0 raid1
```

檢視 RAID 資訊：

```
sudo mdadm --detail /dev/md/mint
```

接著寫入變更：

```
sudo -i
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
```

格式化 RAID 分割區：

```
sudo mkfs.ext4 -v -m .1 -b 4096 -E stride=32,stripe-width=64 /dev/md/mint
```

掛載分割區：

```
sudo mkdir /mnt/data

blkid                   # copy the uuid of /dev/md127 or /dev/md/mint
sudo vim /etc/fstab
# Add this line
UUID=your-uuid /mnt/data ext4 defaults,nofail 0 2       # 把 your-uuid 換成你的 UUID
```

接著重開機，如果開不起來可以再試一次。

## Cloudflare DDNS

由於我使用的是浮動 IP，需要設定 DDNS，我使用 Cloudflare 做 DNS 託管，之前寫過一篇 [Cloudflare 設定 DDNS 教學](/post/cloudflare-ddns/)，但我使用的程式已經停止維護，這次找到一個更好用的 [NewFuture/DDNS](https://github.com/NewFuture/DDNS)。

首先安裝 git

```
sudo apt install git
```

Clone 程式下來：

```
sudo git clone https://github.com/NewFuture/DDNS.git /usr/share/
```

建立設定檔：

```
sudo mkdir /etc/DDNS
sudo python /usr/share/DDNS/run.py -c /etc/DDNS/config.json
sudo vim /etc/DDNS/config.json
```

到 Cloudflare 申請一支 token，設定其有編輯區域 DNS 的權限：https://dash.cloudflare.com/profile/api-tokens

編輯設定檔：

```
{
  "$schema": "https://ddns.newfuture.cc/schema/v2.8.json",
  "debug": false,
  "dns": "cloudflare",
  "id": "",                 # 使用 Token 故留空
  "index4": "public",
  "index6": "default",
  "ipv4": [
    "cloud.example.com"     # 你的 domain
  ],
  "ipv6": [
  ],
  "proxy": null,
  "token": "the-token",     # 填入你的 token
  "ttl": null
}
```

測試執行：

```
sudo python /usr/share/DDNS/run.py -c /etc/DDNS/config.json
```

檢查是否能成功更新 Cloudflare 上的 IP

安裝 systemd service：

```
sudo /usr/share/DDNS/systemd.sh install
```

檢查有無執行：

```
sudo systemctl status ddns.timer
```

重開 router，故意換 IP，看會不會五分鐘自動更新。

```
journalctl -u ddns.service
```

## 防火牆設定

防火牆我使用最簡單好用的 ufw，首先是安裝：

```
sudo apt install ufw
sudo ufw allow 22222        # 你前面設定的 SSH port
sudo ufw allow http
sudo ufw allow https
sudo ufw default deny       # 預設擋掉
sudo ufw enable             # 開啟防火牆
```

開啟前要確定有開到 SSH 用的 port。

## Nginx Setup

接下來設定 Web Server，有別於[以往都用 Caddy](/post/caddy/)，我這次改用傳統的 Nginx，後續裝 Nextcloud 比較輕鬆。

Ref: [LandChad Nginx](https://landchad.net/nginx)

```
sudo apt install nginx
```

瀏覽口打開 192.168.0.2，看看有沒有 Nginx 安裝成功的頁面。

接下來要在路由器設定 DMZ，允許外網連線到 Pi。方法有分 Port Forwarding 和 DMZ 兩種，Port Forwarding 只導向指定的幾個 Port，DMZ 則是將所有外網連線交給一個 IP。Port Forwarding 會由路由器做防火牆，DMZ 則是由 Pi 自己做，由於路由器的硬體一般都比較差，用 DMZ 應該會有比較好的效能（但要確定有設定好 ufw），當服務需要用大量的 port 時，DMZ 設定起來也比較輕鬆。本文以 DMZ 做示範。

登入你的路由器 http://192.168.0.1 ，找到 DMZ 設定，將其設為 Pi 的 IP（192.168.0.2），然後重開路由器。完成後，打開你的網址 http://cloud.example.com ，看看有沒有出現 Nginx 預設頁面。

### 安裝 Certbot

Certbot 可以免費取得 HTTPS 所需的憑證，且自動安裝至系統中並配置 Nginx。

Ref: [LandChad Certbot](https://landchad.net/certbot)

安裝 Certbot：

```
sudo apt install python3-certbot-nginx
```

執行：

```
sudo certbot --nginx
```

輸入你用來接收 renew 通知的 email、輸入域名（cloud.example.com）、視需求選擇 Redirect（沒特別原因就選吧！）

再打開一次網頁，看看有沒有換成 https 了。

## Nextcloud

Ref: 
* [Nextcloud Doc](https://docs.nextcloud.com/server/latest/admin_manual/installation/example_ubuntu.html)
* [LandChad Nextcloud](https://landchad.net/nextcloud) 註：此文章是安裝在子路徑（example.com/cloud）而非子網域（cloud.example.com），故其 Nginx 設定檔不適用。


接著要來安裝 Nextcloud 了，先安裝依賴，我使用的是相容於 MySQL 的 MariaDB：

```
sudo apt install mariadb-server  php php-mysql php-gd php-mbstring php-curl php-zip php-xml php-fpm php-intl php-gmp php-bcmath php-exif php-imagick php-bz2
```

### MySQL

```
sudo mysql

CREATE DATABASE nextcloud;
GRANT ALL ON nextcloud.* TO 'ncadmin'@'localhost' IDENTIFIED BY 'supersecretpassword';
FLUSH PRIVILEGES;
EXIT;
```

### Download Nextcloud

到 https://nextcloud.com/install/#instructions-server 去，複製 .tar.bz2 檔案連結（Details and download options 中），接著用 wget 下載：

```
wget https://download.nextcloud.com/server/releases/nextcloud-22.1.0.tar.bz2
```

解壓縮到 /var/www

```
sudo tar -jxvf nextcloud-22.1.0.tar.bz2 -C /var/www
```

改變權限：

```
sudo chown -R www-data:www-data /var/www/nextcloud
sudo chmod -R 755 /var/www/nextcloud
```

建立我們存放檔案的資料來：

```
sudo mkdir /mnt/data/nextcloud
sudo chown www-data:www-data /mnt/data/nextcloud
```

啟動 PHP 和 MariaDB：

```
systemctl enable php-fpm
systemctl start php-fpm
systemctl enable mariadb
systemctl start mariadb
```

### Nginx

接下來設定 Nginx，先確認 Nginx 使用者是以 www-data 執行。檢查 /etc/nginx/nginx.conf 應該出現

```
user www-data;
```

再來我們在新增 /etc/nginx/site-available/nextcloud 這個檔案，填入以下內容：

請將 ssl_certificate 的地方換成 /etc/nginx/site-available/default 裡面的路徑，cloud.example.com 也記得換成自己的域名。若你的 PHP 版本為 7.4，修改第二行的路徑成 7.4。

```
upstream php-handler {
    server unix:/run/php/php-fpm.sock;
    server 127.0.0.1:9000;
}

server {
    listen 80;
    listen [::]:80;
    server_name cloud.example.com;

    return 301 https://$server_name$request_uri;
}

server {
    listen 443      ssl http2;
    listen [::]:443 ssl http2;
    server_name cloud.example.com;

    ssl_certificate     /etc/letsencrypt/live/cloud.example.com/fullchain.pem ;     # 重點區塊！
    ssl_certificate_key /etc/letsencrypt/live/cloud.example.com/privkey.pem ;
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    # set max upload size
    client_max_body_size 512M;
    fastcgi_buffers 64 4K;

    # Enable gzip but do not remove ETag headers
    gzip on;
    gzip_vary on;
    gzip_comp_level 4;
    gzip_min_length 256;
    gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
    gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

    # Pagespeed is not supported by Nextcloud, so if your server is built
    # with the `ngx_pagespeed` module, uncomment this line to disable it.
    #pagespeed off;

    # HTTP response headers borrowed from Nextcloud `.htaccess`
    add_header Referrer-Policy                      "no-referrer"   always;
    add_header X-Content-Type-Options               "nosniff"       always;
    add_header X-Download-Options                   "noopen"        always;
    add_header X-Frame-Options                      "SAMEORIGIN"    always;
    add_header X-Permitted-Cross-Domain-Policies    "none"          always;
    add_header X-Robots-Tag                         "none"          always;
    add_header X-XSS-Protection                     "1; mode=block" always;

    # Remove X-Powered-By, which is an information leak
    fastcgi_hide_header X-Powered-By;

    # Path to the root of your installation
    root /var/www/nextcloud;

    # Specify how to handle directories -- specifying `/index.php$request_uri`
    # here as the fallback means that Nginx always exhibits the desired behaviour
    # when a client requests a path that corresponds to a directory that exists
    # on the server. In particular, if that directory contains an index.php file,
    # that file is correctly served; if it doesn't, then the request is passed to
    # the front-end controller. This consistent behaviour means that we don't need
    # to specify custom rules for certain paths (e.g. images and other assets,
    # `/updater`, `/ocm-provider`, `/ocs-provider`), and thus
    # `try_files $uri $uri/ /index.php$request_uri`
    # always provides the desired behaviour.
    index index.php index.html /index.php$request_uri;

    # Rule borrowed from `.htaccess` to handle Microsoft DAV clients
    location = / {
        if ( $http_user_agent ~ ^DavClnt ) {
            return 302 /remote.php/webdav/$is_args$args;
        }
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    # Make a regex exception for `/.well-known` so that clients can still
    # access it despite the existence of the regex rule
    # `location ~ /(\.|autotest|...)` which would otherwise handle requests
    # for `/.well-known`.
    location ^~ /.well-known {
        # The rules in this block are an adaptation of the rules
        # in `.htaccess` that concern `/.well-known`.

        location = /.well-known/carddav { return 301 /remote.php/dav/; }
        location = /.well-known/caldav  { return 301 /remote.php/dav/; }

        location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }
        location /.well-known/pki-validation    { try_files $uri $uri/ =404; }

        # Let Nextcloud's API for `/.well-known` URIs handle all other
        # requests by passing them to the front-end controller.
        return 301 /index.php$request_uri;
    }

    # Rules borrowed from `.htaccess` to hide certain paths from clients
    location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)  { return 404; }
    location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console)                { return 404; }

    # Ensure this block, which passes PHP files to the PHP process, is above the blocks
    # which handle static assets (as seen below). If this block is not declared first,
    # then Nginx will encounter an infinite rewriting loop when it prepends `/index.php`
    # to the URI, resulting in a HTTP 500 error response.
    location ~ \.php(?:$|/) {
        fastcgi_split_path_info ^(.+?\.php)(/.*)$;
        set $path_info $fastcgi_path_info;

        try_files $fastcgi_script_name =404;

        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $path_info;
        fastcgi_param HTTPS on;

        fastcgi_param modHeadersAvailable true;         # Avoid sending the security headers twice
        fastcgi_param front_controller_active true;     # Enable pretty urls
        fastcgi_pass php-handler;

        fastcgi_intercept_errors on;
        fastcgi_request_buffering off;
    }

    location ~ \.(?:css|js|svg|gif|png|jpg|ico)$ {
        try_files $uri /index.php$request_uri;
        expires 6M;         # Cache-Control policy borrowed from `.htaccess`
        access_log off;     # Optional: Don't log access to assets
    }

    location ~ \.woff2?$ {
        try_files $uri /index.php$request_uri;
        expires 7d;         # Cache-Control policy borrowed from `.htaccess`
        access_log off;     # Optional: Don't log access to assets
    }

    # Rule borrowed from `.htaccess`
    location /remote {
        return 301 /remote.php$request_uri;
    }

    location / {
        try_files $uri $uri/ /index.php$request_uri;
    }
}
```

儲存後重啟 Nginx：

```
sudo systemctl reload nginx
```

打開 https://cloud.example.com ，就可以填入剛設定的資料庫密碼，以及選擇 /mnt/data/nextcloud 做為目標資料夾，完成安裝程式。

### Redis

Nextcloud 可以透過安裝 Redis 做快取來優化效能：

Ref: [Nextcloud Manual: Memory Caching](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/caching_configuration.html#id2)

```
sudo apt install redis-server php8.0-redis
sudo vim /var/www/nextcloud/config/config.php
```

加入以下內容：

```
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'memcache.distributed' => '\\OC\\Memcache\\Redis',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' => [
    'host' => 'localhost',
    'port' => 6379,
  ],
```

重啟 PHP：

```
sudo systemctl restart php8.0-fpm.service
```

### PHP 設定

Ref: [Nextcloud Manual: php-fpm configuration notes](https://docs.nextcloud.com/server/latest/admin_manual/installation/source_installation.html#php-fpm-configuration-notes)

找到以下設定並修改：

```
sudo vim /etc/php/7.4/fpm/php.ini

memory_limit = 512M             # PHP 記憶體上限
upload_max_filesize = 2000M     # 最大上傳大小

opcache.enable = 1
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = 10000
opcache.memory_consumption = 128
opcache.save_comments = 1
opcache.revalidate_freq = 1
```

```
sudo vim /etc/php/7.4/cli/php.ini


# 加入這行
apc.enable_cli = 1
```

```
sudo systemctl restart php7.4-fpm.service
```

### 設定 Cron

Ref: [Nextcloud Manual: Background jobs](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/background_jobs_configuration.html#cron)
Nextcloud 需要定時跑一些程序來更新快取，我們使用效能最好的 cron：

```
sudo crontab -u www-data -e

# 加入以下這行
*/5  *  *  *  * php -f /var/www/nextcloud/cron.php
```

---

到這邊 Nextcloud 的基本設定就告一段落了，Nextcloud 有非常多的 App 可以安裝，讓你的 Nextcloud 成為一個強大的辦公平台。希望你有愉快的使用體驗！

{{< service_homelab >}}
