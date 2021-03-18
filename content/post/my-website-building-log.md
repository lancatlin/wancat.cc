+++
categories = ["活動紀錄"]
date = "2019-01-20 13:15:09"
tags = ["Server", "Website"]
title = "網站建置紀錄"

+++


# 網站建置紀錄

我的網站從 2017 年六月第一次上 GitHub Page，到現在 www.wancat.cc ，也已經半年了，寫下這篇文章紀錄一下架站的方法。

## Hexo

我的部落格是用 [Hexo](https://hexo.io) 將 Markdown 轉成一個靜態網站的，所以可以部屬到 GitHub Page 或是任何伺服器，我自己現在還留著 https://wancatserver.github.io 避免哪天伺服器發生不測......。那 Hexo 可以多重部屬，我的設定檔大概長這樣。

```yaml
# _config.yml
deploy:
- type: git
  repo: git@github.com:WANcatServer/WANcatServer.github.io.git
- type: rsync
  host: 我的伺服器 ip
  user: lancat
  root: /volume2/WANcatServer/www

```

那我的佈景是使用 [Archer](https://github.com/fi3ework/hexo-theme-archer)，非常好看的一個佈景，那我有做一些小調整：把簡體中文換成繁體，然後將授權地方放上 CC 授權。

```shell
cd path/to/blog
vim /theme/archer/layout/post.ejs
```

即可修改模板內容，[EJS](https://ejs.co) 也是我之前用過的模板引擎，所以挺快就弄好了。

到 [創用 CC 官網](https://creativecommons.org/) 上找你要的授權，就可以複製 HTML 嵌入到網站裡了。可以直接加在 Archer 裡面的 _config.yml

```yaml
# theme/archer/_config.yml
# 將 license 改成以下
license: <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="創用 CC 授權條款" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />本著作係採用<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">創用 CC 姓名標示-相同方式分享 4.0 國際 授權條款</a>授權.

```

RSS feed 須安裝 `hexo-generator-feed` 包，然後在 Archer 裡配置

```yaml
# theme/archer/_config.yml
rss: /atom.xml
```

Disqus 也很簡單，只要將 Disqus ID 丟到網站的 _config （不是佈景的）裡就好

```yaml
# _config.yml
disqus_shortname: //你的 ID
```

可以裝 Google Analytics 看流量，設定 Archer _config：

```yaml
# theme/archer/_config.yml
google_analytics: //你的 ID
```

一開始流量不會進去的那麼快，我是隔天才看到流量進去的，所以不用緊張（也可能是我當初時間沒設到當天）。

### 版本控制

用 Hexo 的好處就是可以版控，所有文章都是好讀的 Markdown，我有做 Git 版控並同步到我自己架的 [Gitea](https://gitea.io/zh-tw/) 上（沒有公開）。比較麻煩的是佈景，佈景裝的時候是用 `git clone` 下來，所以在 Git 裡頭就會變成 **子模組 Submodules** ，那因為佈景基本上不用更新，而且我不太會用子模組，所以不如整個一起做版控（會把自己微調的內容紀錄進去），所以就把 Archer 底下的 .git 刪掉，整個 add 進去就好。Archer 的更新比較麻煩些，要自己把有更動過的檔案抓出來，然後下載新版本再移進去，所以我只更新過一次。

接下來有空也有打算自己寫一個佈景，不過現在我的前端很廢，慢慢來。

## 硬體

由於現在幫[山林復育協會](https://taiwan1forestrestoration.blogspot.com/)管理主機，所以我有一台 [Synology DS918+](https://www.synology.com/zh-tw/products/DS918+) 可以用。這台主機有還夠用的硬體，主打軟體，不過是面向非技術使用者，有自己的軟體商店，但內容有點缺乏，而且不能使用 apt（雖然它是 debian 系的），ssh 不能用公鑰登入（我有去設定過了！），shell 超難打，網頁界面很卡又容易跑掉，如果你有技術背景，不是特別在乎它附的軟體，還是自己裝 Ubuntu Server 輕鬆些。

但它的檔案系統的確蠻方便的，也有出手機應用程式，所以可以像 Google Drive 一樣從手機讀檔案，Web 管理界面也是讓我不需要一個一個查指令，有著還算清楚的說明。只不過用到現在還是比較喜歡自己裝 Ubuntu。

***

在 DS918+ 上架網站基本上就跟一般主機一樣，它的網頁伺服器是 Nginx，剛好也是我習慣的。

我的 Nginx 設定檔長這樣：

```nginx
server {
    listen 80;
    server_name www.wancat.cc;
    root /volume2/WANcatServer/www;
    index index.html;
    access_log /var/log/nginx/access_log combined;
}

```

不要笑

上面做一個重新導向到 www.@，那由於 DS918+ 設定 HTTPS 實在很複雜，我就把這偉大的任務交給 CloudFlare 了。

## 域名與 DNS

域名目前是在 [Porkbun](https://porkbun.com) 上註冊 wancat.cc。本來想買 wan.cat （真的有），但是 .cat 實在太貴，打算用 .cc 。 .tw 域名在台灣基本上都是 800 TWD / year ，除了第一年特價外，實在有點貴，所以不考慮。.cc 每年大約 10 鎂，還算便宜，而且也挺好看的。

註冊完後 DNS 用 CloudFlare 代管，雖然 DS918+ 可以裝 DNS Server，但我懶的用，CloudFlare 免費方案就很夠用了。

CloudFlare 我設定了 @, www 兩個 DNS，www CNAME 到 @，都有開雲朵（會經過 CloudFlare），所以可以隱藏真實 IP。我用 Page Rules 做轉址，設定舊網域以及 wancat.cc 會轉址到 www.wancat.cc，用 www 的理由是為了避免 Cookie 在不同 subdomain 被重用。詳細理由參考：[bjornjohansen.no](https://bjornjohansen.no/www-or-not?utm_source=wanqu.co&utm_campaign=Wanqu+Daily&utm_medium=email)

本來我是自己用 Nginx 轉址，但速度有點慢，今天改用 CloudFlare 就幾乎是瞬間完成了，我現在對它依賴度越來越高了。

如果要讓 ssh 連，可以直接連 ip 或是開一個 ssh.@，然後雲朵不要開（不會經過 CloudFlare，直接回應 IP），就可以連了。好像有更安全的作法，但我也懶的用了（茶）

# 筆記

自己架網站也半年了，從痞客邦到 Medium 到 Hexo，不過弄了這麼多還是不會寫網頁。買了五年的網域，希望自己的網站可以再撐五年（茶）。

