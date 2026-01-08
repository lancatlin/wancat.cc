+++
categories = ["教學"]
date = "2018-09-22 20:26:23"
tags = ["自由軟體"]
title = "YaCy安裝教學"

+++


> [YaCy](https://yacy.net/en/index.html)是一個開源的點對點搜尋引擎
> 本文將講解如何在 Ubuntu Server 上安裝 YaCy 搜尋引擎，並用Nginx做反向代理，將網址改成像是 yacy.example.com 的形式。

YaCy 架好的範例可以來我架設的伺服器使用看看https://yacy.wancatserver.tk

## 環境說明
本文假設有一台無圖形界面的伺服器以及有圖形界面的Desktop。Desktop必須要能夠使用瀏覽器。
**假設伺服器網域**： example.com，**請將本文所有example.com改成你的網域名稱**
假設使用者名稱：user ，請換成自己的使用者名稱
> 如果沒有網域名稱仍然可以安裝 YaCy ，只是需要用 ip:8090 的形式來連上它。
> 如果沒有真實 ip 就只能在內網使用

## 伺服器安裝 Java 8
YaCy可以使用 OpenJDK，也可以使用Oracle官方的JRE。
OpenJDK使用apt安裝
``` shell
$ sudo apt install openjdk-8-jre
```
官方的JRE比較麻煩，可參考[此文章](https://dotblogs.com.tw/jhsiao/archive/2013/09/03/116186.aspx)

## 安裝 YaCy
至[官網](https://yacy.net/en/index.html)下載程式。

{% asset_img slug download.png %}

將程式上傳至伺服器，請將/path/to/yacy.tar.gz替換成你下載的路徑
``` shell
$ scp /path/to/yacy.tar.gz user@example.com:/home/user/
```
接下來以ssh登入伺服器
``` shell
$ ssh user@example.com
```
解壓縮，將yacy.tar.gz替換成你下載的路徑
``` shell
$ tar -zxvf yacy.tar.gz
```
解壓縮完可以看到家目錄下多了一個目錄yacy，裡面有 startYACY.sh, stopYACY.sh, killYACY.sh, reconfigureYACY.sh, updateYACY.sh等執行檔，以及許多資料夾。

我們先去打開防火牆，YaCy使用的是 8090 port (HTTP)，以及8443 (HTTPS)。

``` shell
$ sudo ufw allow 8090
```
執行 startYACY.sh
``` shell
$ sudo ./startYACY.sh
```
接著等一下，瀏覽器連 example.com:8090。
> 啟動時可能需要等個一分鐘才能載入網頁，是正常的

如果看到這個畫面，就代表執行成功
{% asset_img slug page.png %}
可以試著用YaCy搜尋一些東西看看
> 跑得慢是正常的，出來結果很少也是正常的

{% asset_img slug search_page.png %}
停止 YaCy
``` shell
$ sudo ./stopYACY.sh
```
這個指令需要等一下YaCy才會停止，可以用top來確認YaCy停止了沒。
等到YaCy停止後，使用reconfigure來進行設定
``` shell
$ sudo ./reconfigureYACY.sh

*** YaCy commandline configuration tool ***

Make your choice:
[1] change memory settings
[2] change admin password
[3] change HTTP port
[4] change HTTPS port
[0] quit
```
選項分別是 設定YaCy可用記憶體大小(重要)、設定管理員密碼(重要)、設定HTTP埠口、設定HTTPS埠口，前面兩項要記得設定，後面看個人情況調整，如果沒有特殊需求，保留預設值即可。

## YaCy 設定
啟動YaCy ，打開 example.com:8090，點擊右上方的"Administration"
{% asset_img slug yacy_welcome.png %}
會進到設定畫面
{% asset_img slug yacy_status.png %}

YaCy 的進階設定會在日後別篇文章作說明。

## YaCy自啟動設定
現在已經可以使用YaCy了，但是得要手動開啟，不免覺得麻煩，所以接下來將會把YaCy加入service中，讓系統自動開啟，並且以yacy使用者執行，避免被攻擊後危害系統。
建立系統使用者 yacy
``` shell
$ sudo useradd --system yacy
```
把剛才在user底下的yacy資料夾搬移到yacy家目錄，並將擁有者改為yacy，這樣子YaCy資料夾就會在 /home/yacy/yacy 中。
``` shell
$ sudo mv ~/yacy /home/yacy/
$ sudo chown -R yacy:yacy /home/yacy/yacy
```
接下來要將YaCy加入系統服務中，新增/usr/lib/systemd/system/yacy.service，寫入以下內容。
``` shell
$ sudo vim /usr/lib/systemd/system/yacy.service

[Unit]
Description=YaCy search server
After=network.target

[Service]
Type=forking
User=yacy
ExecStart=/home/yacy/yacy/startYACY.sh
ExecStop=/home/yacy/yacy/stopYACY.sh

[Install]
WantedBy=multi-user.target
```
接著可以啟動YaCy
``` shell
$ sudo systemctl enable yacy
```
這樣子YaCy就會隨著開機啟動了
可以用top指令觀察yacy狀態

如果之後中途需要手動關閉或啟動YaCy，使用以下指令
``` shell
$ sudo systemctl start yacy.service
$ sudo systemctl stop yacy.service
```
//如果你按tab只跳出yacy，那就是了

## 設定 Nginx 反向代理
在做這一步之前，**請先確定 yacy.example.com 可以指向你的伺服器。**

Nginx 安裝，使用apt
``` shell
$ sudo apt install nginx
```
打開80埠口
``` shell
$ sudo ufw allow 80
```
瀏覽器開啟example.com，如果有以下畫面代表正確
{% asset_img slug nginx_welcome.png %}
編輯/etc/nginx/sites-available/default
``` shell
$ sudo vim /etc/nginx/sites-available/default
```
會看到裡面已經有許多設定檔，無視它們，寫一個新的server。
**注意：不要寫在原本的server內**
``` shell
server {
    listen 80;
    server_name yacy.example.com;
    location / {
        proxy_pass http://127.0.0.1:8090 ;
    }
}
```
接下來讓Nginx讀取設定檔
``` shell
$ sudo nginx -s reload
```
**這個過程可能會發生錯誤，須按照個人情況調整**
接下來瀏覽器連到yacy.example.com，如果可以看到YaCy，則代表成功了。
> Nginx可以調整的選項很多，我只會最簡單的設定，如果了解，可以自己進行優化

# 結語
YaCy是一個高度個人化的搜尋引擎，現在的節點數量仍嫌不足，沒有辦法查到如一般搜尋引擎一樣好的資料，速度也較慢，但可以讓小型網站有個「被搜尋」的機會。
日後將會在別篇文章對於「如何讓自己的網頁被搜尋」，以及「建立自己的資料查詢庫」做說明。



{{< service_homelab >}}
