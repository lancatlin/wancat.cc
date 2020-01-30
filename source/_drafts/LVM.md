# LVM 教學

LVM，Logical Volume Manager，是 Linux 上的一種可以動態調整硬碟分割區大小的技術。原理是將一個或多個 Physical Volume—PV，組合成一個 Volume Group—VG，然後在 VG 中分割出多個 Logical Volume—LV。

LVM 能夠動態調整分割區大小的原理是，將 VG 內的空間分成一小一小塊的 Physical Extent—PE，再個別標注這些 PE 是屬於哪一個 LV。

使用 LVM 的好處是未來擴充硬碟會很方便，因為只要將新硬碟的 PV 加入既有的 VG，就能夠讓 VG 內的各個分割區去使用新的空間，無須搬遷資料。

## 建立 PV

使用 `pvcreate` 指令，假如我今天要將 /dev/sda5 設為 PV

``` sh
# pvcreate /dev/sda5
```

完成後可以用 `pvdisplay` 來查看所有的 PV 資料

``` shell
# pvdisplay
```

## 建立 VG

## 建立 LV

## 增加 PV 到 VG 中

## 調整 LV 大小

