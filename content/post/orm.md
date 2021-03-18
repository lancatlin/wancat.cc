+++
categories = ["教學"]
date = "2019-07-26 10:49:46"
tags = ["ORM", "程式", "Golang"]
title = "ORM 入門：如何區分 ORM 中的關聯"

+++


最近初次接觸 ORM——Object-relational mapping——這個強大的工具，但是為其中的**關聯**而苦惱不已。在仔細研究後終於了解其差異，本篇文章透過一個圖書館專案的實例，使用 Golang + GORM 來實做，並輔以 SQL 做說明，讓已經學會 SQL 而想要了解 ORM 的人真的「懂」如何設計 Relation。

## 什麼時候會用到 Relation？

ORM 中的 Relation 就是相當於 SQL 中的各種 Join，用來將不同表格中的資料串起。由於 ORM 是用物件，所以如果未來有關聯到其他表格的需求，必須在物件設計時就包含進來。

來定義需求吧！我們今天假設情境是要定義一個圖書館的資料庫，那我們會有編目資料 `Book`（書的資料）、館藏資料 `Item`（書的實體），作者資料 `Author`，出版社資料 `Publisher`。書名、ISBN 等等跟關聯沒有關係的就不放入。

我們先不要討論 gorm 要怎麼寫，先把要取得的資料擺出來。

``` go
type Book struct {
    Items []Item
    Authors []Author
    Publisher Publisher
}

type Item struct {
    Book Book
}

type Author struct {
    Works []Book
}

type Publisher struct {
    Publication []Book
}
```

我們要讓所有的 structure 都能夠參考到依賴自己的對象：作者必須參考到作品集、出版社要能參考出版品、分類要能找出其中的所有書籍。

接下來我們一個一個釐清物件之間的關聯關係，來設計 ORM 吧！

## Has One

一本書會有多個實體，一個實體一定是某一本書，也就是說 Book -> Item 是一對多，而 Item -> Book 則是一對一。

從 Book -> Item 是一對多來看，應該要使用 Has many，但是 Item -> Book 應該使用 Has one 還是 Belongs to 呢？

今天如果分別使用 Belongs to 以及 Has one 所做出來的資料結構，會有什麼差異呢？

``` go
// 如果使用 Item 'Has one' Book
type Book struct {
    ID int
    Items []Item
    // 根據 Has One 的規則，被參考的物件必須要儲存參考者的 Primary Key
    ItemID int
    // 可是 Book 有許多 Item 啊...
}

type Item struct {
    Book Book
}
```

Has One 的參考關係是**來回都為一對一**，以剛才錯誤的資料結構為例，我們可以將其 SQL 資料結構設計如下：

```
CREATE TABLE items {
	id int
}
CREATE TABLE books {
	item_id int
	FOREIGN KEY (item_id) REFERENCES TO items (id)
}
```

顯然這跟我們的需求不符，那我們來看看 Belongs to

## Belongs to

``` go
// 使用 Item "Belongs to" Book
type Book struct {
    ID int
    Items []Item
}

type Item struct {
    Book  Book
    // Belongs to 規定要儲存被參考者的 primary key
    BookID int
}
```

轉換成 SQL 表格

```
CREATE TABLE books {
	id int
}

CREATE TABLE items {
	id int
	book_id int
	FOREIGN KEY (book_id) REFERENCES TO books (id)
}

SELECT books.*
FROM items INNER JOIN books
ON items.book_id = books.id
WHERE items.id = ?;
```

這樣子我們就能讓 Item 關聯到 Book 啦！

``` go
gorm.Model(&item).Related(&book)
```

## Has many

剛才還沒細講 Book 要怎麼關聯到多個 Item 呢！但其實我們**已經做出來囉！**

``` go
// 使用 Book "Has Many" Item
type Book struct {
    ID int
    // 有著多個 item 資料
    Items []Item
}

type Item struct {
    // 這一項是 Item belongs to 所使用的，在 Has Many 中不一定需要
    Book  Book
    // Has Many 規定要儲存參考者的 primary key
    BookID int
}
```

眼尖的你會發現，這根本和前一個一模一樣啊！沒錯，因為 Has many 的參考方不需要儲存任何資料，而是由被參考方來儲存參考方的主鍵，這是資料庫正規化的第一條鐵則：**不能有重複群**

SQL 實做：

```
CREATE TABLE books {
	id int PRIMARY KEY
}

CREATE TABLE items {
	id int PRIMARY KEY
	book_id int
	FOREIGN KEY (book_id) REFERENCES TO books (id)
}

SELECT items.*
FROM books INNER JOIN items
ON books.id = items.book_id
WHERE books.id = ?;
```

``` go
gorm.Model(&book).Related(&items)
```

## Many To Many

接下來我們來處理書本與作者的關聯，一個書本會對應到多個作者，一個作者也會對應到多個書本，那這就是所謂的 Many To Many 關聯啦！

要理解 Many To Many，我們要先了解在 SQL 中我們通常是怎麼實做的：由於雙方都會關聯到多個值，我們必須創建第三個表格來儲存它們的對應關係

```
CREATE TABLE books {
	id int PRIMARY KEY
};

CREATE TABLE authors {
	id int PRIMARY KEY
};

CREATE TABLE book_authors {
	book_id int
	author_id int
	FOREIGN KEY (book_id) REFERENCES TO books (id)
	FOREIGN KEY (author_id) REFERENCES TO authors (id)
};

# 找尋某 book 的所有 author
SELECT authors.*
FROM book_authors INNER JOIN authors
ON book_authors.author_id = authors.id
WHERE book_authors.book_id = ?;

# 找尋某 author 的所有 book
SELECT books.*
FROM book_authors INNER JOIN books
ON book_authors.book_id = books.id
WHERE book_authors.author_id = ?;
```

那 ORM 就可以簡化這個複雜的實做過程，今天有 Many To Many 的對應關係，可以簡單的在各自的物件宣告被參考者的 slice，然後透過 struct tag 來設定「第三個表格」的名稱即可。

``` go
type Book struct {
    Authors []Author `gorm:"many2many:book_authors"` // struct tag 設定第三個表格的名稱
}

type Author struct {
    Works []Book `gorm:"many2many:book_authors"` // struct tag 設定第三個表格的名稱
}
```

這樣 ORM 就會自動幫你建立 `book_authors` 這個表格並完成他們的依賴關係囉！

``` go
// 找尋某 book 的所有作者
gorm.Model(&book).Related(&authors)

// 找尋某 author 的所有作品
gorm.Model(&author).Related(&books)
```

注意！Many To Many 指的是「彼此皆為一對多」，不是說你在查詢的時候要拿「多個」去找「多個」喔！查詢時還是拿一個找多個。

## 總結

所以我們最後來回顧一下 Belongs To、Has One、Has Many、Many To Many 的差別吧！

所謂 Has something 的，就是將「自己的主鍵」儲存在「對方的欄位」，也就是說被 Has 的那一方，就是 Belongs To，沒錯！Has something 的 back-reference 就是 Belongs To，差別在於 Has One 的對象是單數，Has Many 的對象是複數，但其實兩者的 SQL 表格實做起來會是一樣的！

反過來說，Belongs To 就是將「對方的主鍵」保存在「自己的欄位」，那根據資料庫正規化的第一條原則：不能有群集，所以 Belongs To 一定只能保存一個對方的主鍵，因此被參考方一定是單數喔！

Many To Many 則是將「雙方的主鍵」保存在「第三個表格」，所以雙方都能夠關聯到多個對方。

最後我們再來實做 Book 跟 Publisher 的對應關係，因為一本書對應到一個出版社，而一個出版社對應到多本書，因此我們採用 Publisher "Has Many" Book 的方式，那當然也就會是 Book "Belongs To" Publisher。

``` go
type Book struct {
    Publisher Publisher
    PublisherID int
}

type Publisher struct {
    ID int
    Publication []Book
}

// 從某書取得出版社
gorm.Model(&book).Related(&publisher)

// 從某出版社取得所有書籍
gorm.Model(&publisher).Related(&books)
```

