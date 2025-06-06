---
title: 圓形碰撞檢測 FireWheel火輪手槍(一)
date: 2018-08-01 20:06:07
tags:
categories: FireWheel
---
## 遊戲的根本—碰撞檢測
### 碰撞檢測為何重要？
{% asset_img slug mario.svg %}
一個好的遊戲中，有什麼是不可或缺的條件呢？除非你是開發桌遊或卡牌遊戲，否則你一定會需要 **「碰撞檢測」** 。
碰撞檢測為何重要？想一想，今天你玩Minecraft，如果你碰不到東西，整個人像幽靈一樣開旁觀者飄來飄去，會好玩嗎？嘿嘿，其實挺好玩的，亂七八糟！如果Minecraft不會碰到東西，絕對不會有人想玩！  
那你隨便想以前的2D遊戲，例如超級馬力歐，馬力歐總要踩在地面吧？馬力歐也必須要碰到怪物會死掉，還得要用腳可以踩死怪物。那達成這些需要什麼？就是碰撞檢測，我們要能夠偵測「兩個物件相撞」這件事，而這個動作就稱為「碰撞檢測」。  

碰撞檢測在scratch的實踐是非常簡單的，你只要拉出「碰到XXX？」來偵測一個狀態，就可以處理碰撞檢測。

#### 完了... Python沒有碰撞檢測
可是問題來了，Python並沒有內建碰撞檢測。咦？！！你不是說用程式語言功能比較強大？怎麼連這個基礎的功能都沒有。  
我們必須要釐清一件事，「碰撞檢測」這類事情是遊戲設計比較會遇到的，Python的主要使用是做資料運算，像是現在很夯的AI、深度學習等等。大部分會有碰撞檢測的工具是「遊戲框架」，框架這種東西就如字面上的意思，它已經幫你把整個專案架構給設計好了，你只要按照需求把剩餘的東西給填入就好。  
至於Python上有的遊戲框架...實在不多，而且學習如何使用一個框架也是非常耗費心力的過程，於是最後我就決定自己寫碰撞檢測啦！

在接下來的介紹中，我會按照各個形狀之間的碰撞檢測來做說明，之所以用形狀區分，由於我是用簡單的幾何圖形，例如：圓形、矩形，來進行碰撞檢測。是的，碰撞檢測在每種圖形的「算法」都不一樣，因為我的遊戲就只有圓形和矩形兩種形狀，因此僅實做圓形矩形之間的碰撞檢測。

---


## 當殭屍碰到了你 ---圓形對圓形
{% asset_img slug circle_to_circle.svg.png %}
**要如何去偵測一個圓形是否碰到了另一個圓形呢？**  
在我的遊戲中，例如怪物碰到了玩家，子彈射中了怪物，玩家被子彈射中等等，都是圓形與圓形的碰撞檢測。如果我們無法檢測這些，嗯...那這個遊戲大概會很無聊，因此我們要來實做圓形對圓形的碰撞檢測。

首先，我們列出我們所知道的**資訊**：
* x, y座標
* 半徑

就這樣？是的，就只要這樣。
我們利用圓的性質，由於邊長上的任何一點到圓心都等長，不管從那個角度相撞，撞擊點到圓心的距離都會是圓的半徑。
所以如果一個點距離圓心小於半徑，就代表跟它重疊了。
那由於有兩個圓，所以只要「兩個圓心的距離」小於「兩個圓的半徑之合」，就代表兩個圓重疊，也就是「碰到」了。

至於如何取得兩點之間的距離，就是使用「畢氏定理」囉！在場的一年級應該還沒上到，礙於時間有限，我就只說重點。畢氏定理可以讓我們取得一個直角三角形的斜邊長，那我們兩個相異點之間的距離，其實就是以這兩點為頂點，畫出的直角三角形的斜邊。
畢氏定理數學公式：
![](https://wikimedia.org/api/rest_v1/media/math/render/svg/7ef0a5a4b8ab98870ae5d6d7c7b4dfe3fb6612e2)
由此可得出：
![](https://wikimedia.org/api/rest_v1/media/math/render/svg/2fef66265112bc5378959992887ca76314b1681e)

{% asset_img slug circle_to_circle2.svg.png %}

以下為Python的實做：

{% codeblock lang:python %}
'''
程式碼：計算c1與c2是否有相撞的函數
輸入值：兩個「圓形物件」，分別帶有x座標(x)，y座標(y)，半徑(r)，三種屬性
回傳值：true(代表有碰到) or false(代表沒碰到)
'''

def circle_to_circle (c1, c2) :     #c1 c2分別為圓1,圓2
    #d為兩點距離
    d = ((c1.x - c2.x) ** 2 + (c1.y - c2.y) ** 2) ** 0.5
    return d < (c1.r + c2.r)

#c1.x 代表存取c1這個圓的x座標，以此類推
#Python的次方使用「**」來計算，開根號即為0.5次方
#程式語言中()與[]的意義不同，用於表示計算優先順序的一律為小括號
#撰寫者：林宏信 2018 7/21

{% endcodeblock %}

## 小結
圓形對圓形的碰撞檢測是碰撞檢測中的基礎，很實用也非常好理解。那接下來會繼續介紹矩形對矩形的碰撞檢測。

