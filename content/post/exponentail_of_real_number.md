---
title: "如何用對數算指數為實數的值"
date: 2021-08-21T02:48:17+08:00
categories:
  - 數學
tags:
  - 對數
  - 指數
draft: false
summary: ""
---

音量單位**分貝**，定義是聲音的震幅每增加 10 倍，就增加 10 分貝，公式可寫成：

$$
P = 10^{\frac{dB}{10}}P_0
$$

在我們調整音量的時候，不可能每次都調大 10 倍吧？那在中間就會出現指數是小數的情況。例如我們今天若要算

$$
x = 10^{6.3}
$$

要怎麼在紙上求得近似值呢？

首先，我們改寫一下式子

$$
x = 10^{0.3} \times 10^6
$$

$$
y = 10^{0.3}
$$

$$
x = y \times 10^6
$$

這樣我們就可以先求 y，再回去求 x 了，這麼做是因為對數表上只會有 1 到 10 的值。

根據 log 定義

$$
0.3 = \log_{10} y
$$

透過查表，找到最接近的值是

$$
\log_{10} 2.0 = 0.301
$$

$$
\rightarrow y \approx 2.0
$$

因此 x 的值就會是

$$
x \approx 2 \times 10^6 = 2000000
$$

用 Python 算出的值是 1995262，估計值跟真實值只差了 0.24%，算是足夠精準了，我們就可以利用這個方法，來求指數為實數的近似值。
