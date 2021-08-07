+++
title = "Raspberry Pi 架設 Nextcloud 含 RAID 完整安裝教學"
date = 2021-08-07T13:12:54+08:00
categories = []
tags = []
draft = true
showToc = true
+++

我以前寫過一篇 Nextcloud 安裝教學，最近設定了一台新的 Pi，記錄下從無到有的完整設定過程。安裝過程若遇問題，可搭配各段落 References 服用。

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

```
sudo cp /etc/dhcpcd.conf /etc/dhcpcd.backup     # 備份
sudo vim /etc/dhcpcd.conf                       # Feel free to use Nano or something else :)
```

找到以下幾行，拿掉註解

```
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

```bash
sudo raspi-config
```

首先改密碼：  
System Options -> Password

啟用 SSH：  
Interface Options -> SSH -> Yes

然後跑下更新

```
sudo apt update
sudo apt upgrade
```

### SSH 換 Port

為了安全性考量，我們將 SSH 換一個 Port。編輯 SSH 設定檔：

```
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

## Nextcloud



```
sudo apt-get install mariadb-server php-mysql php php-gd php-mbstring php-curl php-zip php-xml php-fpm php-intl -y
```

```
sudo mysql_secure_installation
sudo mysql -u root -p
```

## Redis

https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/caching_configuration.html#id2

```
sudo apt install redis-server php-redis

sudo vim config/config.php
```

Add following lines:

```
  'memcache.local' => '\\OC\\Memcache\\Redis',
  'memcache.distributed' => '\\OC\\Memcache\\Redis',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' => [
    'host' => 'localhost',
    'port' => 6379,
  ],
```





