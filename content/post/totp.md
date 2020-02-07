---
title: "用 TOTP 擺脫簡訊驗證碼：安全好用的兩步驟驗證"
date: 2020-02-07T19:22:30+08:00
draft: false
tags:
- 資訊安全
categories:
- 教學
- 評論
---

## 兩步驟驗證

隨著數位身份在生活中的影響力愈來愈大，只靠著一組密碼來保護我們的帳戶已經不夠安全，而且記密碼實在是違反人腦天性的行為，因此大部分人總是使用重複的、好記的脆弱密碼。要解決這個問題，除了[使用密碼管理工具](/post/should-you-use-password-manager/)來幫你記密碼，還可以透過設定兩步驟驗證（2FA：Two-Factor Authentication），大大提昇帳戶的安全性。

兩步驟驗證就是在密碼之外，多用一個資訊來驗證你是本人，主流的作法有像 Email、簡訊驗證信，但用過的人可能都會覺得登入時要開信箱收信很麻煩，信箱也會被這些信件給弄亂，更別提當人在國外時，簡訊收不到害你無法登入。

今天要介紹的 TOTP: **Time-based One-Time Password algorithm**，就是一種公開的標準，讓你透過手機上的 APP 產生一組 6 位數的一次性驗證碼進行登入，而且在沒有網路的情況下還能使用！

## TOTP 如何運作？

TOTP 的概念，就是網站與你事先約定好一組金鑰，並以當下的時間作為參數，運算出一個雜湊值，並取最後 6 位數作為一次性密碼。

然而如果網站和使用者的時間不同的話，就無法計算出相同的結果，因此通常會以 30 秒作為一個單位，來避免使用者與網站的時間差。網站為了良好的使用者體驗，通常也會允許前一次的一次性密碼。

## TOTP 的優點

TOTP 它是一個公開標準，你不需要依賴單一企業或組織，各種客戶端都能相容；它的安全性基於密碼學，而非第三方機構的信用；它是去中心化驗證，整個驗證流程只有要驗證身份的雙方而已。

Google 可以讀你的 Gmail，簡訊也可以被政府或通訊業者攔截，然而 TOTP 不需要依賴中介機構，甚至在離線的情況下也仍然可用。

同時對於服務提供者而言，TOTP 也很容易實做，不需要花錢去發簡訊或是寄 Email 被當成垃圾郵件，也不需要跟第三方機構申請，是個省錢又安全的好方法。

## 開始使用 TOTP

儘管目前懂得使用 TOTP 的使用者並不多，但其實已經有相當多網站支持以 TOTP 作為驗證方式，例如 Google、Facebook、Apple、Amazon、GitHub、PayPal 等，我管理伺服器需要用到的 CloudFlare、Linode、Porkbun 也都有設定 TOTP 來提高安全性。

開始使用的第一步是下載一個 TOTP 的應用程式，有非常多的選項，我自己使用的是 [Authy](https://authy.com/)，界面簡單易用，提供加密的雲端備份，此外還有 [Google Authenticator](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2)、[Microsoft Authenticator](https://support.microsoft.com/zh-tw/help/4026727/microsoft-account-how-to-use-the-microsoft-authenticator-app)，自由軟體則有 Red Hat 開發的 [FreeOTP](https://freeotp.github.io/)，先前在密碼管理工具提到的 [Bitwarden](https://bitwarden.com/) 的付費版也有提供 TOTP 的功能。

安裝好驗證器後，到你要登入的網站或 APP 的帳號設定中，啟動**兩步驟驗證**，在不同網站中，可能會以「驗證應用程式」、「谷歌驗證器」、「代碼產生器」等名稱出現，但背後都是 TOTP 這套標準，流程也很簡單，網站會將金鑰以 QR Code 的方式顯示，打開手機上的驗證器程式掃描就可以加入帳號，並輸入產生的一次性密碼供網站確認，就可以完成綁定。網站若是在手機上，則可以用「複製金鑰」的方式來手動輸入金鑰。

### 實際操作示範：Facebook

#### 安裝 Authy

首先在 Play 商店下載安裝 Authy

![](/img/totp/authy-install.jpg)

安裝完後會出現註冊頁面

![](/img/totp/authy-sign-up.jpg)

選用電話或簡訊完成認證，這裡的認證是註冊 Authy 帳號用的。

![](/img/totp/authy-authentication.jpg)

完成後要設定一組密碼來作為加密儲存的金鑰，如果不想開啟雲端同步功能可點擊右上腳的 skip 跳過。

#### 設定 Facebook TOTP

打開 Facebook APP，到最右欄的設定頁面，開啟設定

![](/img/totp/facebook-menu.jpg)

進到帳號安全中的帳號安全與登入

![](/img/totp/facebook-setting.jpg)

點擊「使用雙重驗證」

![](/img/totp/facebook-set-2fa.jpg)

選擇「驗證應用程式」

![](/img/totp/facebook-select-2fa-method.jpg)

接下來 Facebook 就會顯示包含金鑰的 QR Code

![](/img/totp/facebook-qrcode.jpg)

如果在電腦上的話，開啟手機上的 Authy 掃描；如果在手機上的話，則點擊「在相同裝置上設定」，就會自動導向到 Authy，如果沒有成功導向，則可以複製螢幕下方的金鑰，手動輸入 Authy 中。

![](/img/totp/authy-add-account.jpg)

接著就可以設定應用名稱（顯示用）和 Logo

![](/img/totp/authy-add-facebook.jpg)

接下來 Authy 就會產生驗證碼

![](/img/totp/authy-facebook.jpg)

複製驗證碼填入 Facebook，就可以完成設定

![](/img/totp/facebook-input-code.jpg)

![](/img/totp/facebook-succeed.jpg)

設定完成後，要在新裝置登入時，就要開啟 Authy 取得驗證碼，增加帳戶的安全性。

如果你想要在其他的網站設定 TOTP，可以參考 Authy 提供的[設定教學](https://authy.com/guides/)。

## 使用 TOTP 的注意事項

首先，無論使用哪種 2FA 方式，都要記得**抄寫復原碼**，假如今天你的手機遺失，無法取得 TOTP 驗證碼，這時就要靠事先紀錄下的一次性復原碼來登入。每個支援 TOTP 的網站也都會在設定完成後生成多組復原碼，建議將其紀錄在密碼管理工具或是紙本筆記本上，用一本專門的筆記本紀錄復原碼是個好主意，儘管身處 21 世紀，紙本紀錄仍然是最安全的方式。

此外，也要注意使用的驗證器是否安全，了解驗證器在儲存你的金鑰時是否有先加密，如果有雲端備份功能，也要確定在雲端是有加密的。

## 參考資料

- [維基百科：基於時間的一次性密碼演算法](https://zh.wikipedia.org/wiki/%E5%9F%BA%E4%BA%8E%E6%97%B6%E9%97%B4%E7%9A%84%E4%B8%80%E6%AC%A1%E6%80%A7%E5%AF%86%E7%A0%81%E7%AE%97%E6%B3%95)

- [IThome：透過簡訊執行二次驗證不再安全，美國國家標準技術研究所建議別再使用](https://ithome.com.tw/news/112845)

