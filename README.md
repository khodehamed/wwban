# wwban

بن موقت IPهایی که به پورت‌های واتروال/VPN اتصال خیلی زیاد می‌سازند. SSH و رنج تانل را دست نمی‌زند.

حد پیش‌فرض: **۳۰۰ اتصال همزمان** یا **۸۰ SYN نیمه‌کاره** از یک IP عمومی → دراپ حدود **۳ ساعت**. پورت ۲۲ بن نمی‌شود.

## نصب

```bash
sudo bash install.sh
# یا
sudo ./wwban install
```

منو:

```bash
sudo wwban
```

1. لیست IPهای بلاک‌شده  
2. آنبن (یکی / همه / ورود دستی)  
3. تغییر پورت‌ها  
4. وضعیت  
5. نصب / به‌روزرسانی  
6. آنیستال  

خط فرمان:

```bash
sudo wwban list
sudo wwban unban 1.2.3.4
sudo wwban ports 443,8443,2083,2053,2087,2096
sudo wwban uninstall
```

تنظیمات: `/etc/wwban.conf`  
لاگ: `/var/log/conn-watch.log`
