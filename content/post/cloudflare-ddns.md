+++
categories = ["教學"]
date = "2020-02-04T10:35:52+08:00"
draft = false
showtoc = false
tags = ["CloudFlare", "Linux", "Raspberry Pi"]
title = "CloudFlare 設定 DDNS 教學"

+++

最近剛入手一個 Raspberry Pi，用來作為一個省電的伺服器，本來困擾自己家裡的固定 IP 已經給了其他台伺服器，但找到方法用 CloudFlare 實現 DDNS。

### CloudFlare DDNS

CloudFlare 本身沒有官方的 DDNS 支援，但可以用 CloudFlare API 實做，我找了一個別人做好的 [CloudFlare-ddns](https://github.com/thatjpk/cloudflare-ddns)，折騰一會兒就設定好了。

首先安裝 cloudflare-ddns 和其依賴，然後以我要設定 pi.wancat.cc 為例，建立 site_pi.yaml 設定檔，填入以下內容：

```
%YAML 1.2
# CloudFlare DDNS updater script config.
---

# CloudFlare API key
# You can find this under Account > My account after logging into CloudFlare.
cf_key: 'your key'

# Email address for your CloudFlare account.
cf_email: 'your email'

# Domain you're using CloudFlare to manage.
# If the host name you're updating is "ddns.domain.com", make this "domain.com".
cf_domain: 'wancat.cc'

# The subdomain you're using for your DDNS A record.
# If the host name you're updating is "ddns.domain.com", make this "ddns".
# However, if you're updating the A record for the naked domain (that is, just
# "domain.com" without a subdomain), then set cf_subdomain to an empty value.
cf_subdomain: 'pi'

# CloudFlare service mode. This enables/disables CF's traffic acceleration.
# Enabled (orange cloud) is 1. Disabled (grey cloud) is 0.
cf_service_mode: 0

# If set to true, prints a message only when the record changes or when
# there's an error.  If set to 'false', prints a message every time even if
# the record didn't change.
quiet: false

# If set to true then we call the ec2metadata service for the instance
# public ip address rather than an external service.
aws_use_ec2metadata: false

# If set to true dig will be used to fetch the public IP which is better
# but not available on all systems.
use_dig: false

```

這邊的 cf_key 要到 CloudFlare 網站裡找，介紹是寫要用 Global API Key，我沒試過專門功能的 Key 行不行。執行 cloudflare-ddns.py 測試

```
python cloudflare-ddns.py site_pi.yaml
```

如果沒問題就把它加到 `crontab`，執行 `crontab -e`：

```
*/15 * * * * /home/pi/bin/cloudflare_ddns/cloudflare_ddns.py /home/pi/bin/cloudflare_ddns/site_pi.yaml >> /home/pi/bin/cloudflare_ddns/cloudflare_ddns.log
```
