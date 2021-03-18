+++
categories = ["教學"]
date = "2020-05-16T12:12:50+08:00"
draft = true
tags = ["Raspberry Pi"]
title = "Raspberry Pi 雙影片同步播放教學"

+++

我美術系的姐姐這次錄像作品嘗試雙影片同時播放，樹梅派可以作為一個便宜的播放器，由於只有兩部影片，第四代樹梅就有雙 HDMI 輸出，所以我們只使用一台第四代樹梅派播放，以下是雙影片輸出的設定記錄。

## 準備環境

請先安裝 Raspbian，建議使用官方的 [Imager](https://www.raspberrypi.org/downloads/) 安裝。

![](/img/raspi-two-videos/imager.png)

選擇系統、記憶卡，點擊 Write 就可以開始安裝了。

![](/img/raspi-two-videos/imager-raspbian.png)

等待安裝完成，大約會半小時。

接下來將記憶卡插入 Pi，接上螢幕（必須在開機前先接上）、鍵盤滑鼠，接上電源就可以開機。設定語言、使用者密碼、網路後，即可進入桌面環境。

## 雙螢幕同步播放

由於 Pi 的處理速度不高，過高解析度的影片可能會無法同步，目前測試過可以用 2 部 1024 * 768 的影片同時播，但若是兩部 1920 * 1080 就會出現影片掉拍的情形。

播放要使用支援硬體加速的樹梅派原生播放器 [OMXPlayer](https://www.raspberrypi.org/documentation/raspbian/applications/omxplayer.md)，OMXPlayer 要使用命令列操作，我幫大家整理好了播放腳本。

在桌面按右鍵，新增 `play.sh` 文件，填入以下內容：

```
#! /bin/bash
cd ~/Desktop
omxplayer --display 2 --loop 1.mp4 &    # 第一個 HDMI 輸出，放在背景播放
omxplayer --display 7 --loop 2.mp4      # 第二個 HDMI 輸出
killall omxplayer.bin                   # 當中斷後，停止背景播放
```

請將 1.mp4, 2.mp4 換成你的影片檔案名稱。

注意：**OMXPlayer 播放時會佔用整個 HDMI 輸出**，將無法操作圖形化界面，請按 Q 離開影片。若是按了沒反應或只關掉其中一部影片，那就拔掉電源重開機。

兩部影片的聲音預設都會從第一個 HDMI 輸出，如果要指定輸出來源，可以加上 -a 選項，範例：

```
omxplayer --display 7 -a hdmi1 2.mp4   # 音頻將會使用第二個 hdmi 輸出（第一個是 hdmi0）
```

完成後存檔，對 play.sh 點擊右鍵，選擇 Properties，在 Permissions 的地方，勾選 `Allow executing file as program`。或是在終端機執行：

```
chmod +x ~/Desktop/play.sh
```

接下來雙擊 play.sh，選擇在終端機執行，這樣子就會開始進行雙影片同步播放了。

## 關閉螢幕保護程式

當播放大概半小時候，可能會突然就沒有畫面，這個是螢幕保護程式的問題，請照以下操作關閉：

連上網路，點選右上角的網路圖示即可連 WiFi

打開終端機 ctrl + alt + T，更新軟體清單

```
sudo apt update
```

安裝 X Screen Saver

```
sudo apt install xscreensaver
```

接下來打開應用程式清單 - Preferences - 螢幕保護程式，Mode 選擇 Disable Screen Saver，關閉視窗，重開機後就可以了。

## 錯誤處理

如果要取消循環播放，就拿掉 play.sh 中的 --loop。

