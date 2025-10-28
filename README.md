[![Chat on Telegram](https://img.shields.io/badge/Chat%20on-Telegram-brightgreen.svg)](https://t.me/xwingswrt)

---

Customized OpenWRT firmware, build for national level harden Internet access. LANG=EN mostly.

Firmware includes :-
- Linux Kernel 6.x
- Latest OpenWrt (Vanilla)
- OpenClash
- Argon Theme
- Bash Shell
- USB Modem Support (QMI)

Supported Hardware:
- x86_64
- Airpi AP3000E
- GL-iNet AX1800
- GL-iNet MT3000
- GL-iNet MT6000
- Zyxel EX5700 (Custom)

---

#### Screenshot:

[![Overview](https://github.com/xwings/xwingswrt/raw/master/screenshot/overview.png)](https://github.com/xwings/xwingswrt/raw/master/screenshot/overview.png)

[![Realtime](https://github.com/xwings/xwingswrt/raw/master/screenshot/realtime.png)](https://github.com/xwings/xwingswrt/raw/master/screenshot/realtime.png)

[![OpenClash](https://github.com/xwings/xwingswrt/raw/master/screenshot/openclash.png)](https://github.com/xwings/xwingswrt/raw/master/screenshot/openclash.png)

---

#### How To Build:

Build Enviroment (Debian 11/12):
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

Configuration:
Edit `settings.sh` to customize build settings:
- `CPU_COUNT`: Number of CPU cores to use for compilation (default: 4)
- `DEFAULT_SOURCE`: Default OpenWRT repository (default: openwrt/openwrt)
- `LUCI_DEFAULT_LANG`: Default LuCI language (default: en)
- `ADD_PACKAGES`: Additional packages to include in firmware
- `DEL_PACKAGES`: Packages to exclude from firmware

Build options:
- -c : Config name (required) - e.g., x86_64, airpi-ap3000e, gl-inet-ax1800, gl-inet-mt3000, gl-inet-mt6000, custom-zyxel-ex5700
- -r : GitHub repo (optional) - default: openwrt/openwrt (format: user/repo:branch)
- -d : Debug mode (optional) - set to 1 for verbose single-threaded build (make -j1 V=sc)

Simple build:
```
cd xwingswrt
./build.sh -c x86_64
```

Build with custom repository:
```
./build.sh -c x86_64 -r coolsnowwolf/lede:master
```

Debug build:
```
./build.sh -c x86_64 -d 1
```

#### Login information

Via http://192.168.1.1
```
Username: root
Password: password
```

#### How To Setup x86_64:

- [How to Install Proxmox 7.3 - The Complete Guide](https://www.youtube.com/watch?v=6NfZ1R6jrXQ)
- [Run an OpenWRT VM on Proxmox VE](https://www.youtube.com/watch?v=_fh7tnQW034)

---

#### Credits:
- https://openwrt.org/ - OpenWrt Project
- https://github.com/coolsnowwolf/lede - Alternative OpenWrt source (optional)
- https://github.com/Hyy2001X - AutoBuild framework
- https://github.com/vernesong/OpenClash - OpenClash
- https://github.com/jerrykuku/luci-theme-argon - Argon Theme
- https://github.com/jerrykuku/luci-app-argon-config - Argon Config
