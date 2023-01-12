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

[![Overview](https://github.com/xwings/xwingswrt/raw/master/screenshot/overview.png)](https://github.com/xwings/xwingswrt/raw/master/screenshot/overview.png)

[![Realtime](https://github.com/xwings/xwingswrt/raw/master/screenshot/realtime.png)](https://github.com/xwings/xwingswrt/raw/master/screenshot/realtime.png)

[![OpenClash](https://github.com/xwings/xwingswrt/raw/master/screenshot/openclash.png)](https://github.com/xwings/xwingswrt/raw/master/screenshot/openclash.png)

---

#### How To Build:

Build Enviroment (Debian 11/bullseye):
```
sudo apt install -y ack antlr3 aria2 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev \
libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool lrzsz \
mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-pip libpython3-dev qemu-utils \
rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev
```

Clone:
```
git clone https://github.com/xwings/xwingswrt.git
```

Build option:
- -c : kernel config
- -p : Firmware location, after compile (optional)
- -r : github repo, default: coolsnowwolf/lede:master (optional)

```
cd xwingswrt
./build.sh -c x86_64 -p /tmp -r coolsnowwolf/lede:master
```

Username: root
Password: password

---
#### Download:

Pre-compiled firmware is also avilable at https://github.com/xwings/xwingswrt/releases

---

#### Credits:
- https://openwrt.org/
- https://github.com/coolsnowwolf/lede
- https://github.com/Hyy2001X
