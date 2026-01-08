+++
categories = ["教學"]
date = "2020-02-03T18:50:39+08:00"
draft = false
tags = ["Hugo", "Linux", "LikeCoin", "Website"]
title = "Hugo 安裝 LikeCoin 教學"

+++

## 取代 Hexo

我使用 [Hexo](https://hexo.io) 作為靜態網站生成器已經一年半，然而它有些我越來越難忍受的缺點，加上認識了由 Go 寫成的 Hugo，我在使用 Hugo 建立了幾個網站作為練習後，決定將自己的部落格改到 Hugo。

Hexo 仍然是一套很棒的工具，我主要是覺得它每次執行都要等大約十秒的時間，讓我很不耐煩；另外它的 server 功能有些缺陷，有時候改變內容會讓它變成 Untitled Post，不過我也沒有很認真的想要解決就是了。

Hugo 是 Go 寫的工具，所以是編譯好的，效能很高，server 功能也很棒，content 的管理更有彈性，整個網站也有更高的配置空間，但使用難度較高，每個 theme 的差異度很大，必須依據使用的 theme 去調整。

我覺得對新手來說 Hexo 是比較好的選擇，一開始就有預設 theme，整個架構也比較固定，內建的 deploy 指令能支援大部分平台，但如果想要有更高的自訂化，我覺得 Hugo 比較合適。

## Theme

這次我選了 [CleanWhite](https://themes.gohugo.io/hugo-theme-cleanwhite) 這套主題，功能強大，設計的很好，非常感謝作者 **Huabing Zhao**。因為 Hexo 跟 Hugo 都是使用 Markdown 作為文章格式，連標頭格式都差不多，所以基本上是無痛轉移，只有圖片的部份需要重新插入，因為 Hexo 的「資產資料夾」是使用其特殊語法，所以轉移後需要自己手動改成標準的格式。

## 插入 LikeCoin

Hugo 可以使用自訂 Layout 的方式，在不改變主題的情況下改變網站設計，我透過這個方式在每個文章下放了 LikeButton。

我們先 overwrite 文章的模板，將 theme 的 layouts 資料夾複製到專案目錄下。

```
cp -r theme/YOUR_THEME/layouts/ .
```

Hugo 中的 Partial 功能，可以讓你建立小模板，嵌入在頁面中。[參考文件](https://gohugo.io/templates/partials/)。在 layouts 的 partials 資料夾建立 likecoin.html，寫入以下內容。你也可以在這裡加上想給讀者看的說明文字（HTML格式）。

```
<iframe class="LikeCoin" height="235" src="https://button.like.co/in/embed/{{ .Site.Params.likerID }}/button?referrer={{ .Permalink }}" width="100%" frameborder=0></iframe>
```

接下來在 `config.toml` 中加入

```
[[params]]
	likerID = "your liker id"
```

接著編輯文章使用的模板，通常是 _default/single.html。這就是一個 Go Template，在你想要的地方插入，建議插在 `{{ .Content }}` 後面，Like Button 就會接在文章後面。

```
{{ partial "likecoin.html" . }}
```

這樣 Hugo 就會將 likecoin 這個 partial render 到你的文章中了。記得加上 "."，沒有的話，likecoin 的模板讀不到資料。整個過程都不需要動到 theme 的原始程式。

執行 `hugo server` 預覽你的網站。

## GitHub Page 作為網站後端

我從去年暑假開始租 Linode 作為伺服器，不過自從我發現 GitHub Page 有 CNAME 功能後，就決定遷到 GitHub Page，避免伺服器出意外。

Hugo 沒有像 Hexo 提供 deploy 的程式，但官網也有[教學](https://gohugo.io/hosting-and-deployment/hosting-on-github/)。

首先建立好你的 GitHub Page Repository，格式就是 username.github.io，然後將它 clone 到專案目錄下的 public 資料夾

```
git clone YOUR_REPO public # 如果已經初始化
# OR
git init public
cd public
git remote add origin YOUR_REPO
```

接著我會建議把 public 資料夾放進 .gitignore 中，不要用 submodule 存，這樣會減少很多問題。

接著就可以使用 `hugo` 產生網站，然後進到 public 中 push 就可以了。也可以使用以下腳本。

```
#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

cd public

# 先跟遠端同步
git pull origin master

cd ..

# Build the project.
hugo # if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
cd public
# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Come Back up to the Project Root
cd ..
```

這個腳本基本上改寫自官方網站，我有自己加一段 git pull 的指令，是避免在不同台電腦上部署導致 git 發生衝突。

然後要做 CNAME 的話，建立 `static/CNAME` 檔案並寫入你的域名，然後將你的域名新增一筆 CNAME 到 `username.github.io`（把 username 換成你的名字）。

{{< service_website >}}
