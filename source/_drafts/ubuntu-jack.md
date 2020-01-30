---
title: 在 Ubuntu 上安裝 Jack
date: 2019-11-17 22:11:34
tags:
- Music
- Linux
- Jack
---

本篇是如何在 Ubuntu 上安裝 Jack，並與原先的音頻系統 PulseAudio 共存的教學。

示範環境：Linux Mint 19.10

# 安裝 KxStudio Repository

首先我們安裝 [KxStudio](https://kx.studio/) 這個專門為 Linux 音樂軟體庫，先前往 [KxStudio Repositories](https://kx.studio/Repositories)，然後安裝他的 PPA。

{% asset_img kxstudio.png %}

先下載 kxstudio-repos.deb，然後按照官網的指示進行操作：

``` sh
# Install required dependencies if needed
sudo apt-get install apt-transport-https gpgv

# Remove legacy repos
sudo dpkg --purge kxstudio-repos-gcc5

# Download package file
wget https://launchpad.net/~kxstudio-debian/+archive/kxstudio/+files/kxstudio-repos_10.0.3_all.deb

# Install it
sudo dpkg -i kxstudio-repos_10.0.3_all.deb
```

這樣就安裝好了 KxStudio 的 PPA，我們就可以在 apt 指令安裝 KxStudio 的軟體了。

# 安裝 Cadence

Cadence 是一個 Jack 的管理器，同時也附帶很多工具。安裝 Cadence 的同時也會自動安裝 Jack2

``` sh
sudo apt install cadence
```

那由於 Jack 執行時，無法讓 PulseAudio 同時運行，所以我們同時要安裝 pulseaudio-module-jack 這個套件讓 PulseAudio 可以當作 Jack 上的 plugin 執行。

```sh
sudo apt install pulseaudio-module-jack
```

接下來我們還要將使用者加入 `sound` 群組

``` sh
sudo usermod -aG sound $USER
```

接下來我們啟動 Cadence

{% asset_img slug cadence.png %}

點開 Jack Bridge 的地方，然後設定 Bridge Type 為 `ALSA -> PulseAudio -> JACK(Plugin)`。

重開機，打開 Cadence -> Tools -> Catia，Catia 是操作 Jack 接線的地方，應該就可以看到以下畫面：

{% asset_img catia.png %}

有部份不同沒關係，重點是有沒有看到 PulseAudio JACK Source 這個區塊，如果沒有就代表前面有設定沒成功。

接著試著播放音樂，如果瀏覽器和一般音樂播放器都沒問題的話，就成功了。