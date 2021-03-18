+++
date = "2020-02-12T19:15:22+08:00"
draft = false
tags = ["elementaryOS", "Linux"]
title = "elementary OS 啟用 System Tray"

+++

[elementary OS](https://elementary.io) 是一個好看、易用的 Linux 發行版，然而它有一個缺點：系統狀態欄（system tray）無法顯示其他應用程式的 icon，這導致像輸入法、Discord 等有使用 system tray 的程式無法使用完整功能。最討厭的莫過於 HP 印表機驅動 HPLIP，每次開機就跳出來說 no system tray deteched，非常煩人。

原因是 elementary OS 基本上不希望其他應用程式去使用 system tray，並且[停止支援 Ayatana Indicator API](https://github.com/elementary/wingpanel/issues/96#issuecomment-401407354)，做出相同決定的還有 GNOME，參考 [Status Icons and GNOME](https://blogs.gnome.org/aday/2017/08/31/status-icons-and-gnome/)。

## 安裝 Ayatana Indicator

	sudo add-apt-repository ppa:yunnxx/elementary
	sudo apt update
	sudo apt install indicator-application wingpanel-indicator-ayatana

編輯 `/etc/xdg/autostart/indicator-application.desktop` 加入 Pantheon
		
	OnlyShowIn=Unity;GNOME;Pantheon;

接下來重新啟動 X 或是重開機

	sudo service lightdm restart
	# or 
	reboot

完成後 elementary 就可以顯示各個應用程式的圖示了！

![](/img/elementary_system_tray.png)

## References

[How to display system tray icons in elementary OS Juno?](https://elementaryos.stackexchange.com/questions/17452/how-to-display-system-tray-icons-in-elementary-os-juno)

[ibus no system tray](https://elementaryos.stackexchange.com/questions/18474/no-system-tray-icon-for-ibus-in-elementary-os-juno)  

[steam no system tray](https://elementaryos.stackexchange.com/questions/8059/no-system-tray-icon-of-steam)  

[hplip system tray](https://elementaryos.stackexchange.com/questions/22081/im-using-hplip-and-every-time-i-login-to-elementary-os-i-get-a-message-that-the)  

[Elementary no longer support old API](https://elementaryos.stackexchange.com/questions/4226/how-can-i-get-applications-to-display-a-system-tray-icon)  

[Elementary system tray icon](https://www.reddit.com/r/elementaryos/comments/9p0sdi/system_tray_icons/)  

[elementary Guide: System Tray](https://elementary.io/docs/human-interface-guidelines#system-indicators)

[HPLIP Status Service, No system tray detected on this system ](https://www.linuxquestions.org/questions/slackware-14/hplip-status-service-no-system-tray-detected-on-this-system-4175617467/)