---
title: 問題紀錄。使用 Docker 安裝 Gitlab
tags:
- Docker
date: 2018-07-31 01:11:11
---

## 問題摘要：
* Docker 無法使用 --volume 將資料夾掛載，顯示 read-only
    * 改成使用mount type=bind沒用
    * 改成使用資料卷容器有用，但是無法執行
* 將 /etc/gitlab/gitlab.rb 設定external_url後重啟容器，無法連上網頁。reconfigure也無效
* Docker-compose 無法啟動，問題同第一點

## 系統環境
* 硬體（年齡超過七年）:
    * 主機板：Dell 0RY206
    * CPU:  AMD Athlon(tm) 64 X2 Dual Core Processor 4400+
    * RAM: 2G
* 軟體：
    * 作業系統：Ubuntu Server 18.04
    * Docker: 17.06.2-ce
    * Gitlab Image: gitlab/gitlab-ce:latest
* 網路：
    * 浮動IP
    * 使用No-ip DDNS服務取得 domain name
    * 機器在內網中，路由器將此伺服器設定為外網IP以連上外網

## 問題詳細描述
Docker 執行 gitlab 正常，但是當開啟專案後在clone連結會出現docker本身的hostname (一大串英文數字組成的亂碼)。並且不能使用ssh push(因為port沒有打開22)。
```
docker run -d --name gitlab -p 8888:80 gitlab/gitlab-ce:latest
```
刪掉後重新run一次。這次加入了hostname參數，雖然亂碼改成了正確hostname，但由於我的port是開在8888，因此還是不正確。這時候查到要用exec 進入去修改　/etc/gitlab/gitlab.rb
```
docker exec -it gitlab /bin/bash
# vim /etc/gitlab/gitlab.rb
------以下為修改處---------
external_url 'http://[我的host]:8888/'

itlab_rails['gitlab_ssh_host'] = '[我的host]:222'
```
設定完成後restart，重啟後久久還是看不到網頁，於是又去翻logs，結果看到輸出寫需要執行：gitlab-ctl reconfigure，但執行後出現以下錯誤：
```
Running handlers:
There was an error running gitlab-ctl reconfigure:

bash[migrate gitlab-rails database] (gitlab::database_migrations line 49) had an error: Mixlib::ShellOut::ShellCommandFailed: Expected process to exit with [0], but received '1'
---- Begin output of "bash"  "/tmp/chef-script20180715-18-hk1m59" ----
STDOUT: rake aborted!
StandardError: An error has occurred, this and all later migrations canceled:

PG::DuplicateTable: ERROR:  relation "labels" already exists
: CREATE TABLE "labels" ("id" serial primary key, "title" character varying, "color" character varying, "project_id" integer, "created_at" timestamp, "updated_at" timestamp)
/opt/gitlab/embedded/service/gitlab-rails/db/migrate/20140729134820_create_labels.rb:6:in `change'
/opt/gitlab/embedded/service/gitlab-rails/lib/tasks/gitlab/db.rake:50:in `block (3 levels) in <top (required)>'
/opt/gitlab/embedded/bin/bundle:23:in `load'
/opt/gitlab/embedded/bin/bundle:23:in `<main>'

Caused by:
ActiveRecord::StatementInvalid: PG::DuplicateTable: ERROR:  relation "labels" already exists
: CREATE TABLE "labels" ("id" serial primary key, "title" character varying, "color" character varying, "project_id" integer, "created_at" timestamp, "updated_at" timestamp)
/opt/gitlab/embedded/service/gitlab-rails/db/migrate/20140729134820_create_labels.rb:6:in `change'
/opt/gitlab/embedded/service/gitlab-rails/lib/tasks/gitlab/db.rake:50:in `block (3 levels) in <top (required)>'
/opt/gitlab/embedded/bin/bundle:23:in `load'
/opt/gitlab/embedded/bin/bundle:23:in `<main>'

Caused by:
PG::DuplicateTable: ERROR:  relation "labels" already exists
/opt/gitlab/embedded/service/gitlab-rails/db/migrate/20140729134820_create_labels.rb:6:in `change'
/opt/gitlab/embedded/service/gitlab-rails/lib/tasks/gitlab/db.rake:50:in `block (3 levels) in <top (required)>'
/opt/gitlab/embedded/bin/bundle:23:in `load'
/opt/gitlab/embedded/bin/bundle:23:in `<main>'
Tasks: TOP => db:migrate
(See full trace by running task with --trace)
== 20140729134820 CreateLabels: migrating =====================================
-- create_table(:labels)
STDERR:
---- End output of "bash"  "/tmp/chef-script20180715-18-hk1m59" ----
Ran "bash"  "/tmp/chef-script20180715-18-hk1m59" returned 1

Running handlers complete
Chef Client failed. 98 resources updated in 02 minutes 01 seconds
```
我實在看不懂，也查不到原因，於是我就將此容器刪除了。

### 無法使用資料卷
我發現每次啟動容器資料都會重置，因此我按照[官網](https://docs.gitlab.com/omnibus/docker/#run-the-image)的指令去打，想要用資料卷來儲存資料。
```
sudo docker run --detach \
    --hostname [我的host] \
    --publish 443:443 --publish 8888:80 --publish 222:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest

```
我更改的部份有hostname、80 port改到8888、22 port改到222。其他一致。
接著執行後剛閃出容器id，就爆出錯誤。
```
docker: Error response from daemon:
error while creating mount source path '/srv/gitlab/logs': mkdir /srv/gitlab:
read-only file system.
```
我試著自行先將資料夾mkdir，以及將權限設定成777，都沒辦法解決。接下來我去查詢[Docker官網](https://docs.docker.com/storage/volumes/#create-and-manage-volumes)Volume的使用方式。
看到的資料顯示，要使用資料卷有--volume跟--mount 兩種參數。根據官網的說法，在17.06之後的Docker建議使用--mount。
> New users should try --mount syntax which is simpler than --volume syntax.
>
由於前面使用--volume出問題，我這次就改成用mount試試看。我照官網文件下方的一個範例更改我的指令：
``` shell
# 官網範例
$ docker run -d \
  --name devtest \
  --mount source=myvol2,target=/app \
  nginx:latest
```
``` shell
# 我的指令
$ docker run --detach \
        -it \
        --hostname [我的host] \
        --publish 443:443 --publish 8888:80 --publish 222:22 \
        --name gitlab \
        --restart always \
        --mount source=config,target=/etc/gitlab \
        --mount source=logs,target=/var/log/gitlab \
        --mount source=data,target=/var/opt/gitlab \
        gitlab/gitlab-ce:latest
```
我的指令大致與前一次相同，只是將-v之處改成了mount。在執行後才發現這個指令會建立資料卷在docker的目錄，而非原本我設想的/src中，但先不管這個問題，反正都能達到目標。
啟動之後，忘記發生什麼事了。將logs搬出來看，發現還是跳出了read-only這個問題。我使用直接找資料卷的路徑改設定檔。
```
# vim /var/snap/docker/common/var-lib-docker/volumes/config/_data/gitlab.rb
------以下為修改處---------
external_url 'http://[我的host]:8888/'

itlab_rails['gitlab_ssh_host'] = '[我的host]:222'
```
設定完成後restart，重啟後久久還是看不到網頁，於是又去翻logs，結果看到輸出寫需要執行：gitlab update-permissons。執行失敗（忘記原因），將容器刪除。
這時在網路上查到我真正想要用的bind方法，照著找到[網頁](https://deepzz.com/post/the-docker-volumes-basic.html)打：
```
# 網站範例
$ docker run -d \
  -it \
  --name devtest \
  --mount type=bind,source="$(pwd)"/target,target=/app \
  nginx:latest
```
``` shell
# 我的指令
# docker run --detach \
        -it \
        --hostname [我的host] \
        --publish 443:443 --publish 8888:80 --publish 222:22 \
        --name gitlab \
        --restart always \
# 重點
        --mount type=bind,source=/srv/gitlab/config,target=/etc/gitlab \
        --mount type=bind,source=/srv/gitlab/logs,target=/var/log/gitlab \
        --mount type=bind,source=/srv/gitlab/data,target=/var/opt/gitlab \

        gitlab/gitlab-ce:latest
```
修改之處在source的連結，我使用的是系統絕對路徑，以及target的位置。
**執行後輸出source路徑錯誤。**，無法執行。
*#我尚未嘗試使用"$(pwd)"做前綴*
### docker-compose　結果同　-v

這時我在[Gitlab官網範例](https://docs.gitlab.com/omnibus/docker/#install-gitlab-using-docker-compose)中找到可以使用docker-compose來建立，於是我下載官方範例，並進行些微修改：
```
# Gitlab範例
web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'https://gitlab.example.com'
      # Add any other gitlab.rb configuration here, each on its own line
  ports:
    - '80:80'
    - '443:443'
    - '22:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'
```
```
# 我的修改檔
web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: '[我的host]'  #將host 改成自己的
  environment:
    GITLAB_OMNIBUS_CONFIG: |
            external_url 'http://[我的host]:8888'  #將port設定為8888
            gitlab_rails['gitlab_shell_ssh_port'] = 222　
            #將ssh port 設定為222
  ports:
    - '8888:80'　#修改port
    - '443:443'
    - '222:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'
```
運行後跳出錯誤：
```
Starting root_web_1 ... error

ERROR: for root_web_1  Cannot start service web: b"error while creating mount source path '/srv/gitlab/logs': mkdir /srv/gitlab: read-only file system"

ERROR: for web  Cannot start service web: b"error while creating mount source path '/srv/gitlab/logs': mkdir /srv/gitlab: read-only file system"
ERROR: Encountered errors while bringing up the project.
```
看起來跟最原先-v的結果是相似的，我也就不想試了。
## 修改/etc/gitlab/gitlab.rb後無法重啟
最終我放棄使用資料卷，打算單純先使用容器來儲存資料就好。
使用指令:
```
# docker run -d --name gitlab -p 8888:80 -p 443:443 -p 222:22 --hostname [我的host] gitlab/gitlab-ce:latest
```
這樣讓它跑大概五分鐘，就可以看到網頁了。但是建立repo後clone連結仍然沒有加上port（因為未設定），因此我再用exec進入容器去修改參數。
同樣只調整url和ssh url兩項設定，調整內容同前面所提過的。在調整完後，使用docker restart gitlab ，等待大約三分鐘仍然沒有反應，於是我進去檢查log，我不確定是否它有提示我reconfigure，總之我做了，這一次有成功執行完畢，但是執行完後仍然顯示不出網頁，重啟也一樣。
我觀察log，發現一直會有跳出GET訊息，還有某某json的訊息，抱歉我沒有將內容擷取下來。


---
我的嘗試就到此為止了，之所以使用Docker安裝是由於過去曾經直接安裝，但是發生很多錯誤（一直維持在503），想說透過Docker應該可以避免掉不少環境影響。

謝謝你看到這邊，如果你知道如何解決，懇請你告訴我！如果我的描述還有什麼需要補充的地方也歡迎跟我說。
