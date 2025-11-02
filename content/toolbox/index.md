+++
title = "我開發的小工具"
date = 2025-11-02T16:40:29+11:00
categories = []
tags = []
draft = false
showToc = true
summary = ""
+++

整理我做過的各種小工具介紹與連結

## [Battle Timer](https://lancatlin.github.io/battle-timer)

下棋、打麻將、玩桌遊，總是有人拖拖拉拉嗎？用 Battle Timer 來對決吧！

{{< figure src="./battle_timer.gif" alt="Paysplit 畫面截圖" caption="Paysplit" >}}

可設定任意人數，累計時數與用畢後的讀秒長度。

* Vanilla JS
* [Battle Timer](https://lancatlin.github.io/battle-timer)
* [GitHub](https://github.com/lancatlin/battle-timer)

## [排列組合計算機](https://lancatlin.github.io/combine_generator/)

不會算排列組合嗎？對它使出**暴力解**吧！

{{< figure src="./combine_generator.png" alt="排列組合計算機畫面截圖" caption="排列組合計算機" >}}

支援透過 JavaScript 撰寫自定義過濾條件，透過觀察實際執行結果來輔助學習。

* Vanilla JS
* [排列組合計算機](https://lancatlin.github.io/combine_generator/)
* [GitHub 原始碼與範例](https://github.com/lancatlin/combine_generator)

## [mdsh](https://github.com/lancatlin/mdsh): 在 Markdown 中執行 shell script

每次要把指令結果貼到 markdown 中很麻煩嗎？用 mdsh 來自動執行 markdown 中的指令吧！

從模板：

~~~~markdown
# 💥 System Information Report for {{ sh "hostname" }}

* **Hostname**: {{ sh "hostname" }}
* **Username**: {{ sh "whoami" }}
* **Uptime**: {{ sh "uptime -p" }}
* **System**: {{ sh "uname -a" }}
* **CPU**: {{ sh "uname -m" }} — {{ sh "nproc" }} cores
* **IP Address**: {{ sh "hostname -I || ip a | grep inet" }}
* **Default Gateway**: {{ sh "ip route | grep default || netstat -rn | grep default" }}
~~~~

執行：

    mdsh system-info.md

產生出：

~~~~markdown
# 💥 System Information Report for `fedora`

* **Hostname**: `fedora`
* **Username**: `wancat`
* **Uptime**: `up 1 hour, 13 minutes`
* **System**: `Linux fedora 6.15.6-200.fc42.x86_64 #1 SMP PREEMPT_DYNAMIC Thu Jul 10 15:22:32 UTC 2025 x86_64 GNU/Linux`
* **CPU**: `x86_64` — `16` cores
* **IP Address**: `172.26.198.115 2405:dc00:ec83:ec80:af9c:87ed:9bae:bd0d`
* **Default Gateway**: `default via 172.26.198.50 dev wlp1s0 proto dhcp src 172.26.198.115 metric 600`
~~~~

* Go
* [使用教學（英文）](/en/post/mdsh)
* [GitHub](https://github.com/lancatlin/mdsh)

## [Paysplit](https://lancatlin.github.io/paysplit/): 該付多少錢？

出來旅行聚餐幫忙付錢嗎？別擔心，全部讓你討回來！

{{< figure src="./paysplit.png" alt="Paysplit 畫面截圖" caption="Paysplit" >}}

* Vanilla JS
* [Paysplit](https://lancatlin.github.io/paysplit/)
* [GitHub](https://github.com/lancatlin/paysplit)

## [每日熱量與飲食計算機](https://lancatlin.github.io/eat-what-you-need/)

一個簡單的計算小工具，No tracking. No bullshit.

{{< figure src="./eat.png" alt="每日熱量與飲食計算機截圖" caption="每日熱量與飲食計算機" >}}

* Svelte
* [每日熱量與飲食計算機](https://lancatlin.github.io/eat-what-you-need/)
* [GitHub](https://github.com/lancatlin/eat-what-you-need)

## [隨機順序產生器](https://lancatlin.github.io/random-order-generator/)

有時候你就是需要產生亂數

{{< figure src="./random.png" alt="隨機順序產生器截圖" caption="隨機順序產生器" >}}

支援複製結果，自動產生結果 QR code。

* Vanilla JS
* [隨機順序產生器](https://lancatlin.github.io/random-order-generator/)
* [GitHub](https://github.com/lancatlin/random-order-generator)
