---
title: "Email Server Postfix & Dovecot 安裝教學"
date: 2020-05-19T15:35:07+08:00
draft: true

---

```
sudo apt install postfix
```

```
sudo dpkg-reconfigure postfix
```

```
sudo vim /etc/postfix/main.cf
	myhostname = wancat.cc
```

```
sudo service postfix restart
```

```
sudo apt update
sudo apt install dovecot-common dovecot-imapd
sudo apt install telnet
telnet localhost 25

Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 samhobbs.co.uk ESMTP Postfix (Debian/GNU)
ehlo foobar
250-samhobbs.co.uk
250-PIPELINING
250-SIZE 10240000
250-VRFY
250-ETRN
250-STARTTLS
250-ENHANCEDSTATUSCODES
250-8BITMIME
250 DSN
mail from: me        
250 2.1.0 Ok
rcpt to: me@outsideemail.com
250 2.1.5 Ok
data
354 End data with <CR><LF>.<CR><LF>
Subject: test
This is a test email
.
250 2.0.0 Ok: queued as A639C3EE6D
quit 
221 2.0.0 Bye
```

```
sudo apt install postfix-mysql libsasl2-modules-sql sasl2-bin libsasl2-2 libpam-mysql
sudo mysql

GRANT SELECT ON nextcloud.oc_users TO 'postfix'@'localhost' IDENTIFIED BY 's8zjU4tPeMjz';
```

```
sudo vim /etc/dovecot/dovecot.conf

```



https://peppe8o.com/mailserver-on-raspberry-pi-zero-w-with-postfix-dovecot-and-squirrelmail/

https://www.linode.com/docs/email/postfix/email-with-postfix-dovecot-and-mysql/

http://www.postfix.org/SASL_README.html#auxprop_sql

https://www.debiantutorials.com/installing-postfix-with-mysql-backend-and-sasl-for-smtp-authentication/

https://samhobbs.co.uk/2013/12/raspberry-pi-email-server-part-2-dovecot

https://samhobbs.co.uk/2013/12/raspberry-pi-email-server-part-1-postfix

https://doc.dovecot.org/configuration_manual/authentication/password_schemes/

https://doc.dovecot.org/configuration_manual/authentication/sql/

https://www.tutorialspoint.com/linux_admin/linux_admin_set_up_postfix_mta_and_imap_pop3.htm