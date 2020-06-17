---
title: "專案介紹：Fever Pass 體溫登記系統"
date: 2020-03-29T19:56:21+08:00
draft: false
showtoc: false
likerID: "linchpins"
categories:
- 專案
tags:
- Golang
---

Fever Pass 是我們團隊 Linchpins 在 2020 年初，為了因應新型冠狀病毒開發的一套體溫登記系統，用於協助各級機關、學校自主登記體溫。

[GitHub Repository](https://github.com/Linchpins-team/fever-pass)。可以在我們的 [demo](https://demo.feverpass.life) 試用本系統，用以下帳號登入：

- 導師 紀體溫 帳號 t101 密碼 10100
- 學生 梁體溫 帳號 1081201 密碼 10141
- 護理師 護理師 帳號 nurse 密碼 nurse

歡迎體驗 demo 的各種功能。demo 每日早上八點會幫所有帳號隨機登記體溫。

Fever Pass 是一個自由且開放原始碼的專案，使用 Go 語言撰寫，以網頁界面進行操作。可以讓機構中的成員自主登記體溫，也可由管理員登記他人體溫。

目前 Fever Pass 被臺中一中使用，[自主健康管理-體溫登錄全面電腦化-『Fever Pass體溫記錄系統』](http://w2.tcfsh.tc.edu.tw/zh_tw/news/announcement/%E8%87%AA%E4%B8%BB%E5%81%A5%E5%BA%B7%E7%AE%A1%E7%90%86-%E9%AB%94%E6%BA%AB%E7%99%BB%E9%8C%84%E5%85%A8%E9%9D%A2%E9%9B%BB%E8%85%A6%E5%8C%96-%E3%80%8EFever-Pass%E9%AB%94%E6%BA%AB%E8%A8%98%E9%8C%84%E7%B3%BB%E7%B5%B1%E3%80%8F-13903318)

![登記自己體溫](/img/fever-pass/index.png)

---

![新增他人體溫](/img/fever-pass/new.png)

Fever Pass 有清晰的統計頁面，可以看到每日的登記情況，快速找出發燒與未登記的人員。

![統計頁面](/img/fever-pass/stats.png)

Fever Pass 有豐富的權限設計，分為體溫管理權限和帳號管理權限，以這些為基礎組成許多預設的身份組，用來滿足各式各樣的管理需求。

| 職稱     | 身份   | 體溫記錄權限 | 帳號管理權限 | 重置密碼 |
| :------: | :------: | :------------: | :------------: | :--------: |
| admin    | 管理員 | 全校         | 全校         | 全校     |
| 護理師   | 教職員 | 全校         | 個人         | 個人     |
| 教職員   | 教職員 | 個人         | 個人         | 個人     |
| 導師     | 教職員 | 班級         | 班級         | 班級     |
| 衛生股長 | 學生   | 班級         | 班級         | 班級     |
| 學生     | 學生   | 個人         | 個人         | 個人     |

歡迎有需要的機關或學校自行安裝使用，希望這個系統能夠幫助更多人度過這次疫情，也歡迎志願者貢獻此專案。若需要代為安裝或是佈署，請來信 linchpins-team@protonmail.com 。

## 開發者介紹

Linchpins 是一個自由軟體開發團隊，本專案由林宏信與張旭誠負責開發。

林宏信：資料庫、後端與網頁模板  
張旭誠：網頁設計、功能優化

## 支持本專案

請幫我們用 LikeCoin 拍手，或是直接轉帳給 [linchpins](https://like.co/linchpins)（Liker ID: linchpins），您的支持能鼓勵我們繼續開發！
