---
title: "我從開發 Fever Pass 學習到的技巧"
date: 2020-03-02T20:41:15+08:00
draft: true
tags:
- Golang
- 網站開發

---

- Use Handler method to handle request
	+ Store config, db
	+ rather than global variable
- Template Layouts
	+ Use Handler's method to render
- Session
	+ Secure Cookie
	+ Middleware
	+ Auth function
	+ Pass account by context
- Testing
	+ SQLite from memory
	+ Use ResponseRecord to test API
	+ 隨著網站功能快速改變，測試失去維護而遭廢棄
- Database
	+ Return *gorm.DB to increase usage cases
	+ Multiple filter
	+ Return different db in order by different role
- Configure
	+ Use TOML to store configure
	+ -init to execute initialized function
	+ ask question to generate configure
	+ automatic create database		
- Markdown Documents
	
由於許多學校都因為疫情的影響，需要進行量體溫等防疫措施，我得到機會來開發一套體溫紀錄系統——[Fever Pass](https://github.com/Linchpins/fever-pass)，用來協助學校讓學生自主紀錄體溫，方便學校老師們做管理與追蹤。

這個專案使用網站的方式呈現，學生們登入自己的帳號後，登記自己的體溫；老師即可從統計頁面查看尚未登記與發燒的學生，也能幫學生做登記。

此專案使用 Golang 開發，本文紀錄我在開發過程中摸索出來的一些小技巧，未必正確，希望能透過本文與其他人交流學習，因此如果你知道更好的作法，希望你能夠告訴我喔！

## 使用 Handler method 來 handle request

在處理 Request 的時候，通常會需要用到 database 或 config，但一個 http.HandleFunc 長這樣：

	func (w http.ResponseWriter, r *http.Request)

以前我使用全域變數來儲存 db，但覺得這樣~~有點母湯~~不夠乾淨，所以改成自己定義一個 Handler type，裡面包含 db, config 等需要傳遞給 function 的資料。

	type Handler struct {
		db *gorm.DB
		config Config
	}

函數就會長的像

```
func (h Handler) newSelfRecord(w http.ResponseWriter, r *http.Request) {
	acct := r.Context().Value(KeyAccount).(Account)

	record := Record{
		Account:    acct,
		RecordedBy: acct,
	}

	var err error
	record.Temperature, err = strconv.ParseFloat(r.FormValue("temperature"), 64)
	if err != nil || record.Temperature > 41 || record.Temperature < 34 {
		r = addMessage(r, "無效體溫資料")
		h.index(w, r)
		return
	}

	record.Type, err = parseType(r.FormValue("type"))
	if err != nil {
		r = addMessage(r, "無效體溫類別")
		h.index(w, r)
		return
	}

	err = h.db.Create(&record).Error // 從 Handler 中使用 db
	if err != nil {
		panic(err)
	}
	h.index(w, r)
}
```

這樣就可以在各個 HandlerFunc 中使用我們需要的資源了。

同時這個技法也讓我們在執行測試時，只要將 handler.db 替換成我們的測試用 db，就可以改變使用的資料庫了。

## Session

我這次的 session 處理使用 [gorilla/securecookie](http://www.gorillatoolkit.org/pkg/securecookie)，在登入後，將 account id 跟 expire time 存入 securecookie 中。

securecookie 是使用 HMAC 對 cookie 進行簽章，已證明內容是由伺服器所簽發，那同時也支援 AES 加密功能。

我的實踐如下：啟動程式時，會去讀取 .env 找尋是否有加密金鑰，如果無則創建，並寫入 .env 檔案。金鑰是 []byte 的形式，因此我會先用 base64 編碼後再存入檔案。

```
import (
	"github.com/joho/godotenv"
	"github.com/gorilla/securecookie"
)

func init() {
	godotenv.Load() // 載入 .env
	file, err := os.OpenFile(".env", os.O_WRONLY|os.O_CREATE, 0644)
	if err != nil {
		panic(err)
	}
	defer file.Close()
	hashKey = loadKey("HASH_KEY", file)
	blockKey = loadKey("BLOCK_KEY", file)
}

func loadKey(name string, w io.Writer) (key []byte) {
	if k := os.Getenv(name); k != "" {
		key = decodeKey(k)
	} else {
		key = securecookie.GenerateRandomKey(32)
		fmt.Fprintln(w, name+"="+encodeKey(key))
	}
	return
}

func encodeKey(key []byte) string {
	return base64.StdEncoding.EncodeToString(key)
}

func decodeKey(key string) []byte {
	if dst, err := base64.StdEncoding.DecodeString(key); err == nil {
		return dst
	} else {
		panic(err)
	}
}
```

接下來是創建 session 的部份，我將 account id 與 expire time 包在一起放入 securecookie 中，之所以要用 expire time，是因為如果只有 account id，每次的輸出都會是一樣的，安全性會有疑慮。

```
func newSession(id string) *http.Cookie {
	s := securecookie.New(hashKey, blockKey)
	var encoded string
	var err error
	session := Session{
		ID:       id,
		ExpireAt: expire(),
	}
	if encoded, err = s.Encode("session", session); err != nil {
		panic(err)
	}
	return &http.Cookie{
		Name:    "session",
		Value:   encoded,
		Path:    "/",
		Expires: session.ExpireAt,
	}
}

func expire() time.Time {
	return time.Now().AddDate(0, 0, 7)
}
```

再來是解析 session，我將解析 session 函數當作 middleware，所有請求進來都會先經過它做解析，它本身不會做權限控管，只會看有沒有 cookie，有就解析，並把 Account 放入 request 的 context value 中。

```
type ContextKey uint32

const (
	KeyAccount ContextKey = iota
)

func (h Handler) identify(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		s := securecookie.New(hashKey, blockKey)
		cookie, err := r.Cookie("session")
		if err != nil {
			next.ServeHTTP(w, r)
			return
		}
		var session Session
		if err = s.Decode("session", cookie.Value, &session); err != nil {
			logout(w, r)
			next.ServeHTTP(w, r)
			return
		}
		if time.Now().After(session.ExpireAt) {
			// session expire
			logout(w, r)
			next.ServeHTTP(w, r)
			return
		}
		var acct Account
		if err = h.db.Set("gorm:auto_preload", true).First(&acct, "id = ?", session.ID).Error; err != nil {
			logout(w, r)
			next.ServeHTTP(w, r)
			return
		}
		ctx := r.Context()
		ctx = context.WithValue(ctx, KeyAccount, acct)
		r = r.WithContext(ctx)
		next.ServeHTTP(w, r)
	})
}
```

使用 middleware

	router.Use(h.identify)

經過這個 middleware 後，如果使用者有登入，Context 中就會有 Account。

再來是權限控制，我將權限控制寫成一個函數，傳入 handler 跟最低要求權限，假如符合就會通過，否則就會 permission denied。

```
func (h Handler) auth(next http.HandlerFunc, role Role) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if role == Unknown {
			next.ServeHTTP(w, r)
		} else if acct, ok := r.Context().Value(KeyAccount).(Account); ok && acct.Role <= role {
			next.ServeHTTP(w, r)
		} else {
			h.errorPage(w, r, 401, "權限不足", "您的權限不足，需要"+role.String()+"權限")
		}
	}
}
```

使用範例：

	// 列表頁面只要登入後（最低權限為學生）即可存取
	router.Handle("/list", h.auth(h.listRecordsPage, Student))
	
	// 統計頁面則需要老師或管理員權限才可查看
	router.Handle("/stats", h.auth(h.stats, Teacher))

