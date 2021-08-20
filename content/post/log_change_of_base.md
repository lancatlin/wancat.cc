---
title: "如何推導 Log 換底公式"
date: 2021-08-21T02:33:10+08:00
categories:
  - 數學
tags:
  - 對數
draft: false
summary: ""
---

假設今天我們要算一個 2 的對數，如

$$
x = \log_2 16
$$

$$
\rightarrow 2^x = 16
$$

我們定義

$$
10^y=2
$$

把第二式帶入第一式

$$
(10^y)^x = 16
$$

$$
10^{xy} = 16
$$

根據 log 定義，可以得到

$$
xy = \log_{10} 16
$$

$$
x = \frac{\log_{10} 16}{y}
$$

又

$$
y = \log_{10} 2
$$

則

$$
x = \frac{\log_{10} 16}{\log_{10} 2}
$$

我們就得到了換底公式：

$$
\log_a b = \frac{\log_c b}{\log_c a}
$$
