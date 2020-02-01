---
title: 如何在 Linux 使用 Caps Lock 切換輸入法
date: 2019-07-06 20:12:00
tags:
- Linux
categories:
- Linux
---

Caps Lock 是一個我們很少用的鍵，偏偏它擺在鍵盤的黃金位置，實在是大大的浪費，在 Mac 上可以使用 Caps Lock 來作為中英切換鍵，我認為是很好的設計，以下教學將介紹如何用指令列來設定 Fcitx 使用 Caps Lock 來切換輸入法。

事實上 Fcitx 可以使用任何鍵作為輸入法切換鍵，然而因為 Caps Lock 有著切換大小寫的功能，如果不將此功能關閉，輸入法會發生異常——中文切到英文後變成大寫，因此我們要利用 xmodmap 工具來將 Caps_Lock 鍵指向到不會使用到的 Multi_key，再將 Fcitx 切換鍵對應到 Multi_key。

我們先查詢一下 Caps_Lock 對應到的 keycode 是多少。

``` 
$ xmodmap -pke | grep Caps_Lock
keycode  66 = Caps_Lock NoSymbol Caps_Lock
```

可以看到鍵盤上的 Caps_Lock 對應到的是 66 這個 keycode，那我們接下來就是要將 66 改成對應到 Multi_key。

```
$ xmodmap -pke > ~/.Xmodmap		#將設定存為檔案
$ vim ~/.Xmodmap
# 將 keycode 66 處改為
keycode  66 = Multi_key NoSymbol Multi_key
# 在最底下加入
clear lock
$ xmodmap ~/.Xmodmap					#載入設定檔
```

根據 ArchLinux wiki，~/.Xmodmap 會自動被 GDM、XDM、LightDM 載入，如果是使用其他的請自行設定。

最後我們再開啟 fcitx config，將輸入法切換鍵設定為我們設定好的 Multi_key。建議保險多設定一組切換鍵，避免設定失敗卡在中文回不去。

![](/img/capslock/fcitx-config.png)

# 參考資料

[ArchLinux wiki: Xmodmap](https://wiki.archlinux.org/index.php/Xmodmap#Keymap_table)

[Changing your caps lock into Ctrl in X](http://efod.se/capslock/)

操作環境： Lubuntu 19.04
