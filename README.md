[![Chat on Telegram](https://img.shields.io/badge/Chat%20on-Telegram-brightgreen.svg)](https://t.me/+xeozJ_-PolZiYmQ1k)

---

Customized OpenWRT firmware, build for national level harden Internet acess. LANG=EN mostly.

Firmware includes :-
- Linux Kernel 6.x
- Latest OpenWrt
- Xray / V2Ray
- ShadowSocksR Plus+
- OpenClash
- AdGuard
- WireGuard
- ZeroTier

Supported Hardware:
- x86_64
- [D-Team Newifi D2 (Newifi3)](https://openwrt.org/toh/hwdata/d-team/d-team_newifi_d2)

---

#### How To Setup:

- [How to Install Proxmox 7.3 - The Complete Guide](https://www.youtube.com/watch?v=6NfZ1R6jrXQ)
- [Run an OpenWRT VM on Proxmox VE](https://www.youtube.com/watch?v=_fh7tnQW034)
- [Install V2Ray Client on OpenWRT and Configure Vmess](https://www.youtube.com/watch?v=o7PC57_2734)

---

#### Screenshot:

[![Login](https://github.com/xwings/xwingswrt/raw/master/screenshot/login.png)](https://github.com/xwings/xwingswrt/raw/master/screenshot/login.png)

[![Overview](https://github.com/xwings/xwingswrt/raw/master/screenshot/overview.png)](https://github.com/xwings/xwingswrt/raw/master/screenshot/overview.png)

[![Realtime](https://github.com/xwings/xwingswrt/raw/master/screenshot/realtime.png)](https://github.com/xwings/xwingswrt/raw/master/screenshot/realtime.png)

[![OpenClash](https://github.com/xwings/xwingswrt/raw/master/screenshot/openclash.png)](https://github.com/xwings/xwingswrt/raw/master/screenshot/openclash.png)

---

#### How To Build:

Build Enviroment (Debian 11/bullseye):
```
sudo apt-get -y install busybox build-essential cmake asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch unzip libz-dev lib32gcc-s1 libc6-dev-i386 subversion flex uglifyjs git gcc-multilib g++-multilib p7zip p7zip-full msmtp libssl-dev texinfo libreadline-dev libglib2.0-dev xmlto qemu-utils upx-ucl libelf-dev autoconf automake libtool autopoint ccache curl wget vim nano python2.7 python3 python3-pip python3-ply haveged lrzsz device-tree-compiler scons antlr3 gperf intltool genisoimage rsync
```

Clone the repo:
```
git clone https://github.com/xwings/xwingswrt.git
```

Compile:
- argv 1: Arch, for now only support x86_64
- argv 2: Firmware location, after compile 
```
cd xwingswrt
./build.sh x86_64 /tmp
```

---
#### Download:

Pre-compiled firmware is also avilable at https://github.com/xwings/xwingswrt/releases

---

#### Credits:
- https://openwrt.org/
- https://github.com/coolsnowwolf/lede
- https://github.com/Hyy2001X
