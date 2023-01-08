This a customized OpenWRT firmware.

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

Pre-compile firmware is also avilable at [https://github.com/xwings/xwingswrt/releases/tag/AutoUpdate](Release Page)

Credits:
- https://github.com/Hyy2001X
- https://github.com/coolsnowwolf/lede
- https://openwrt.org/