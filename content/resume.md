---
title: "履歷"
layout: "resume"
resume:
  name: "林宏信 Justin Lin"
  email: "justin.linhs@pm.me"
  github: "https://github.com/lancatlin"
  website: "https://wancat.cc"

  education:
    - school: "國立臺北科技大學"
      department: "智慧自動化工程科"
      school_url: "https://www.ntut.edu.tw/"
      department_url: "https://iae.ntut.edu.tw/"
      period: "2019 - 2024"

  honors:
    - title: "2023 大專資訊服務應用競賽"
      url: "https://innoserve.tca.org.tw/"
      content: |
        **第二名** 在競賽中與專案 [Linux Odyssey](https://linuxodyssey.xyz)
    - title: "2023 g0v 零時小學校第四屆專案孵化競賽"
      url: "https://sch001.g0v.tw/dash/brd/sch001-2023/list"
      content: |
        **首獎** 在競賽中與專案 [Linux Odyssey](https://linuxodyssey.xyz)
    - title: "2021 全國大專校院智慧機械與人工智慧暨電動車創意競賽"
      url: "https://www.chengde.org.tw/"
      content: |
        **佳作** 在競賽中與專案 EyeDrone

  work_experiences:
    - company: "2577 Full Lucky"
      company_url: "https://2577.com.tw"
      position: "後端開發工程師"
      type: "自由接案"
      location: "台北 (遠端)"
      period: "2024 年 5 月 - 2024 年 10 月"
      tech: "TypeScript, VueJS, Koa, Zod, Prisma, Swagger, PostgreSQL, GitHub Action, Google Cloud"
      content: |
        - 開發了一個基於網頁的員工管理系統，用於排班、考勤和請假管理。([2577.com.tw](https://2577.com.tw))
        - 實現了即時員工考勤報告，供主管查看。
        - 實施了可自定義的班表、假期和年假計算方法。
        - 使用 TypeScript、Koa、Prisma、Zod 和 Swagger 建立了 RESTful API 與文件。
        - 通過 Jest 單元測試，並使用 CI/CD 部署到 Google App Engine。
    - company: "LikeCoin"
      company_url: "https://about.like.co"
      position: "全端工程師"
      location: "全球 (遠端)"
      period: "2022 年 3 月 - 2022 年 8 月"
      content: |
        - [LikeChain Indexer](https://github.com/likecoin/likecoin-chain-tx-indexer): 將鏈上數據索引到資料庫並提供基於 SQL 的 API。使用 Golang、Gin、PostgreSQL。
        - [ISCN Browser](https://github.com/likecoin/iscn-browser): 瀏覽 LikeCoin 鏈上的 ISCN 記錄。使用 NuxtJS、VueJS。
        - [LikeCoin Discord Bot](https://github.com/likecoin/likecoin-discord-bot): 在 Discord 中向訊息捐贈 LIKE，將訊息發布到區塊鏈。使用 NodeJS、NuxtJS。
        - [NFT Dashboard](https://github.com/likecoin/likecoin-nft-dashboard): LikeCoin 鏈上 NFT 統計儀表板。使用 VueJS。

    - company: "IBM"
      company_url: "https://ibm.com"
      position: "後端開發實習生"
      location: "台北，台灣"
      period: "2021 年 11 月 - 2022 年 2 月"
      content: |
        - 基於深度學習的未翻譯字串檢測工具。
        - 為 NodeJS 和 AngularJS 專案設置 Jenkins CI/CD 工作流程。
        - 通過 Git 標籤自動部署至伺服器。

  projects:
    - name: "LinuxOdyssey.xyz"
      url: "https://linuxodyssey.xyz"
      role: "團隊領導 / 全端開發工程師 / DevOps 工程師"
      period: "2023 年 7 月 - 至今"
      tech: "TypeScript / VueJS / Docker / MongoDB / WebSocket / TailwindCSS"
      description: "Linux Odyssey 是針對程式設計和 Linux 初學者設計的互動終端機教學網站，以遊戲化方式學習 Linux 指令，將 Linux 變成一個互動遊戲環境，從「學習 Linux」變成「玩 Linux」。"
      achievements:
        - "提供基於 Docker 的操作環境，讓用戶只要開啟網站即可練習 Linux 命令。使用 WebSocket 在網站上實現即時終端機資料傳輸。"
        - "使用 GitHub Actions 管理 DevOps 工作流程，進行持續集成和部署，保持高代碼質量並促進敏捷開發實踐。"
        - "由 180 名沒有程式設計或 Linux 經驗的國中生測試。60% 的學生能夠在沒有任何幫助的情況下使用終端完成任務。"

    - name: "EyeDrone"
      url: ""
      role: ""
      period: "2021 年 5 月 - 2021 年 11 月"
      tech: "Python / Django / ReactJS / Scikit-Learn"
      description: "一個使用無人機和多光譜儀的水污染分析系統。"
      achievements:
        - "使用無人機拍攝的照片建立污染模型。"
        - "開發 RESTful API 以整合圖像處理算法和數據庫。"

    - name: "FeverPass"
      url: "https://github.com/Linchpins-team/fever-pass"
      role: "共同創辦人 / 後端開發工程師"
      period: "2020 年 2 月 - 2020 年 4 月"
      tech: "Go / Vanilla JS / MySQL"
      description: "針對 COVID-19，使用 Golang 開發的體溫登記系統，供學校或組織登記成員的體溫。"
      achievements:
        - "被台中一中和中山附中使用。"
        - "服務了 1,800 名註冊學生，節省了 360,000 張紙。"

    - name: "indieveloper (indie.tw)"
      url: "https://indie.tw"
      role: ""
      period: "2023 年 1 月 - 至今"
      tech: "YouTube"
      description: "一個推廣自由軟體及伺服器架設的 YouTube 頻道。"
      achievements:
        - "賦予每個人設置自己伺服器的能力。"
        - "在第一個月內達到超過 4,000 訂閱。"

  special_experiences:
    - name: "Liker.Social"
      url: "https://liker.social"
      role: "創辦人及執行董事"
      period: "2020 年 1 月 - 2021 年 4 月"
      description: "LikeCoin 的社群平台"
      achievements:
        - "籌集了 $100K LikeCoin 來啟動一個為 LikeCoin 社群設立的 Mastodon 伺服器。"
        - "1.8K 註冊用戶。"

  publications:
    - title: "A Effective Algorithm for Skew Correction in Text Images"
      url: "https://ieeexplore.ieee.org/document/9605083"
      authors: "C. -T. Chuang and H. -S. Lin"
      conference: "2021 International Conference on Fuzzy Theory and Its Applications (iFUZZY)"
      year: "2021"
      pages: "1-5"
      doi: "10.1109/iFUZZY53132.2021.9605083"

  skills:
    languages: "TypeScript、JavaScript、Go、Python"
    frameworks: "Vue、React、Nuxt、Django、TensorFlow"
    databases: "PostgreSQL、MySQL、MongoDB"
    devops: "GitHub Actions、Linux、Docker、Jenkins、Proxmox"
--- 