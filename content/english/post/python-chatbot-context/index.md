+++
title = "How to Get the Context of Your Chatbot in Python"
date = 2021-07-14T16:13:36+08:00
categories = []
tags = ["Python"]
draft = true
showToc = true

+++

When you develop a chatbot, sometimes for user experience, you cannot ask your user send messages like  commands. For example, we want to build a guess number bot. We want the bot works like this:

> **user:** /guess  
> **bot:** From what number?
> **user:**: 25
> **bot:** To what number?
> **user:** 100
> **bot:** Guess a number between 25 to 100.
> **user:** 64  
> **bot:** Too small  
> **user:** 91  
> **bot:** Too big  
> ......  
> **user:** 83  
> **bot:** Correct! You spent 6 times to guess this number.

However, the common way we dealing with requests in backend is one-request-one-response. That would be a disaster to seperate the conversation to a lot of handlers. Why? Think about how to store the states? In global variables? Or database? Or Redis? Once you ask users one more question, you need to change the schema of your state, and the code become more complex. 

In the following, I will show you how to deal with conversations and write the handler in a nice way. I will write a LINE bot for example, but it doesn't really matter what platform you develop to. I will use Django and it's totally okay if you use other framework.

## Pre-Requirement

It's for setting up the bot, you can skip this if you know it.

Go to [LINE Developers](https://developers.line.biz) to create a bot. Issue the token and your secret

Create a django project and install the requirements

```
django-admin startproject pythonchatbotcontext
cd pythonchatbotcontext
pipenv install django line-bot-sdk
pipenv shell
```

Create the guess number app

```
python manage.py startapp guess
```

