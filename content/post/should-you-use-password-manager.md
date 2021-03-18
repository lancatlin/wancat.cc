+++
categories = ["評論"]
date = "2019-02-21 20:07:35"
tags = ["Bitwarden", "資訊安全"]
title = "妳該使用密碼管理工具嗎？"

+++

![](/photo/hacker-2300772_1920.jpg)

## 現代人的密碼危機

如果妳是一位**有正常使用網路**的現代人，基本上在網路上會有許多的帳號。我算是用量比較高的用戶，我稍微統計了一下：**光是記得的我就有 72 個帳號**，還有很多早就忘掉的黑數呢！  

過去，帳號被盜或許是件小事，當然如果 LOL 或玩遊戲的帳號被盜會很心痛，但不至於會影響生活。隨著現代我們將生活越來越多部份放入網路，網路身份的重要性已經足以影響生活，因此我們勢必要用一些方法好好管理自己的網路身份。  

### 重複密碼

密碼的大原則就是**不要重複**，但哪有辦法呢？我們有那麼多的帳號，如果每個都要背一個密碼哪辦得到？每次在「Sign up」頁面停了很久，最後還是用了以前的密碼。  

重複密碼的危險性在於：只要妳其中一個帳戶被破解，其他帳戶都會遭殃，尤其是一些安全性不高的小網站，或是居心不良的惡意網站，如果跟重要的帳號設了相同的密碼，那就危險了。  

### 使用不安全工具紀錄
第二個危險的情形就是**使用不安全的工具紀錄密碼**，像是我以前也會用 Evernote 紀錄密碼，相信不只我，很多人都會用一些筆記本軟體來紀錄密碼，**這非常危險！** 以下用 Evernote 舉例：一方面我們無法確定 Evernote 公司會不會讀妳的筆記，而且內容沒有經過加密，要是 Evernote 的伺服器被攻擊，資料外洩，妳的密碼就等於是明文獻給了駭客。何況妳怎麼知道 Evernote 不會授權某些極權政府讀妳的資料？（這裡就不點名了）  

有些人認為將檔案存在本機，不要上傳到網路就安全了，但其實不然：在妳的手機上有非常多的應用程式都有權限存取妳的檔案，若是其中有惡意程式發現妳的密碼文件，大可直接上傳到它的網路資料庫。  

因此紀錄密碼的工具以及儲存的資料必須要被加密，也就是要有所謂的**主控密碼**。  

---

## 密碼管理工具，安全嗎？
許多人，包括我，一開始聽到「密碼管理工具」時，都會覺得不可思議：這種東西真的能信任嗎？但其實一個做得好的密碼管理工具，是很安全的，以下我將回應常見的疑慮。  

### 我主密碼被破解了不就完了？
有些人覺得，使用密碼管理工具，就是將所有密碼的命運寄放在一組密碼上，這樣風險太大了！  

其實沒錯，如果妳今天能夠記得自己每個帳號的每個密碼，妳壓根不需要密碼管理工具，但問題是**我們辦不到**。  

就是因為我們記不得密碼，我們才會用相同的密碼，才會有上述所說的安全問題。而事實上也沒錯，使用密碼管理工具**就是將所有密碼寄放在一組密碼上**。但我們可以透過**兩步驟驗證**來避免主密碼被破解就被盜用。  

兩步驟驗證，顧名思義，就是在妳輸入密碼後還要經過另一道手續才可以登入。例如 簡訊驗證碼、Email 確認信都是常見的形式，這樣可以避免密碼被破解就導致帳號被盜，駭客必須同時掌握妳的密碼和手機才有辦法登入，這個難度實在蠻高的，所以現在幾乎所有研究都指出**兩步驟驗證能確實提高安全性**。  

### 它會偷我的密碼嗎？
另一個考量就是**這個程式是否值得信任？**，畢竟我在上面舉 Evernote 例子時也提到：**我們很難確定程式有沒有在背後搞鬼！** 而這就見仁見智了，有些人可能是信任大公司的軟體，而我是信任**良好的加密演算法和開源軟體**。  

> 一個安全的加密演算法，就是妳就算知道它的原理還是無法破解它
>

舉我所使用的 [Bitwarden](https://bitwarden.com) 為例，在官網 FAQ 就寫了 [為什麼妳要信任 Bitwarden](https://help.bitwarden.com/article/why-should-i-trust-bitwarden/)。
> 1. Bitwarden is **100% open source** software. All of our source code is hosted on GitHub and is free for anyone to review. Thousands of software developers follow Bitwarden’s source code projects (and you can too!).  
>
> 2. Bitwarden is audited by reputable third-party security auditing firms as well as independent security researchers.
> 3. Bitwarden **does not store your passwords**. Bitwarden stores encrypted versions of your passwords that **only you can unlock**. Your sensitive information is encrypted locally on your personal device before ever being sent to our cloud servers.
> 4. Bitwarden has a reputation. Bitwarden is used by hundreds of thousands of individuals and businesses. If we did anything questionable or risky we would be out of business.
>

Bitwarden 在同步時，會將妳的資料先用主控密碼加密，再上傳到伺服器，如此一來，就算駭客取得妳伺服器中的檔案，仍無法破解妳的資料。相同的，就算 Bitwarden 居心不軌，想要偷看妳的密碼，它也做不到，因為唯一能解開的，就只有知道主控密碼的 ——**妳**。  

怎麼知道它沒有偷偷上傳原始的資料？別擔心，Bitwarden 是開源軟體，開源軟體或許不一定安全，但**它不能騙妳**，因為所有的程式碼都放在 GitHub 上，等著妳去檢查。就算它騙的了妳，也騙不過成千上萬個工程師。  

如果還是不放心，Bitwarden 也提供「自架選項」，妳可以將 Bitwarden 放在自己的伺服器上，所有的資料都在自己手裡。  

## 妳不該完全信賴它
事實上，妳也不該完全信賴它。雖然我剛才提出了許多證據說明它可以信任，但它終究只是個「工具」，仍然有著風險，而且**它不能為妳負責**。**我們確實不該完全信賴任何事物**，也許我們信賴 Google、Apple、Facebook（現在不了），但**它們真的值得信賴嗎？** 值得妳將足以影響生活的權力交給它們嗎？  

因此，**我們也不該完全信賴密碼管理工具**，折衷的辦法是：**將不重要的帳號使用隨機密碼，透過密碼管理工具儲存；重要的帳號密碼自己記得**。一方面減少記憶的負擔、不會因不重要帳號被破解影響到重要的帳號、再來也**對自己的生活有主控權**。  

將工具視為輔助自己的方法，而不是完全依賴工具，才是對自己負責的作法。