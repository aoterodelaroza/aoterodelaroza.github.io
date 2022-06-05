---
layout: single
title: "Raspberry Pi 4 model B diskless HPC cluster"
permalink: /devnotes/diskless-rpi-cluster/
excerpt: >-
  Instructions on how to build a diskless HPC cluster using Raspberry
  Pi 4 model B computers.
class: wide
sidebar:
  - nav: "devnotes"
toc: true
toc_label: "Raspberry Pi 4 diskless HPC cluster"
toc_sticky: true
---

### Introduction

This document describes how to build a fully functioning
high-performance computing (HPC) cluster using Raspberry Pi 4
single-board computers, model B, circa May 2022. The purpose of the
Raspberry Pi HPC cluster is to create a teaching environment for
computational science (e.g. computational chemistry) where students
can learn about the Linux operating system and the tools and workflow
in scientific computing. This project has been funded by the 2022
Teaching Innovation Project calls (INIE-PINN-2022-23-124538) at the
University of Oviedo, who provided the necessary funds to acquire the
hardware.

For this installation, we need at least two Raspberry Pi 4 model B
(rPI) computers, an equivalent amount of SD cards, ethernet cables,
USB-C cables for powering the rPIs, and an SD card reader. In
addition, a monitor, keyboard, and mouse are required to perform the
head node installation, as well as a desktop computer running Linux to
flash the SDs and perform other ancillary operations. If you plan on
incorporating more than two rPIs into the cluster, you also need an
ethernet switch for the local network, probably a USB power bank for
powering all the rPIs, and a case to keep things organized. The head
node connects to a wireless network (perhaps at home or at your
workplace) and the rPIs use their ethernet interfaces to communicate
with each other over the local network. The instructions below apply
to rPI 4 model B, but they can probably be adapted to other models as
well as other computer types, single-board or not.

The compute nodes in our cluster run in diskless mode. This means that
they have no OS installed and, instead, boot over the network. The
head node acting as server. This simplifies the administration of a
(small) cluster considerably as there is no need to install an OS
on the compute nodes or worry about how they are provisioned. In the
rest of this document, commands issued as `root` in the head node are
denoted by:
```
head# <command>
```
Commands issued as `root` on any of the compute nodes are:
```
compute# <command>
```
The contents of the disk image served to the compute nodes are
modified by using a chroot environment on the head node. Whenever we
issue commands inside the chroot, it appears as:
```
chroot# <command>
```
Commands issued on the auxiliary desktop PC are:
```
aux# <command>
```
Lastly, we also sometimes issue commands as unprivileged users (for
instance, submitting a job), which are denoted by the prompts
`head$`, `compute$`, etc.

The Debian operating system is used for the installation. Debian has
an excellent and well-curated repository of high-quality packages, is
stable and reliable, and has been tested on the rPI architecture. The
ultimate reason for this choice, however, comes down to personal
preference. The SLURM workload manager is used as scheduling system.

### Step 1: Flash the SD card

In the auxiliary PC, download the latest Debian OS image from the
[raspi Debian website](https://raspi.debian.net/tested-images/).
Insert your SD card and find the device file it corresponds to. Then,
uncompress the image and flash it to the SD card:
```
aux# unxz 20220121_raspi_4_bookworm.img.xz
aux# dd if=20220121_raspi_4_bookworm.img of=/dev/sde
```
**Warning: Make sure you get the device file correct and the SD card
contains nothing you care about before flashing.**

Insert the SD card into the rPI that will act as the head
node. Connect it to the monitor, keyboard, and mouse, and boot it up
into Debian.

### Step 2: Create users and set root password

In the rPI you can now log in as root (requires no password) and add
as many users as you need. You should also change the root password:
```
head# adduser --ingroup users user1
...
head# passwd
```

### Step 3: Set up the network

Next we configure the wireless network to be able to talk to the
outside. The `wpa_supplicant` program can be used for this, as
described in [this
guide](https://wiki.debian.org/WiFi/HowToUse#wpa_supplicant). First,
create the configuration file with your wifi ESSID and password:
```
head# wpa_passphrase <ESSID> <password> > /etc/wpa_supplicant/wpa_supplicant.conf
```
and then add the following lines to the same file:
```
#### /etc/wpa_supplicant/wpa_supplicant.conf
...
ctrl_interface=/run/wpa_supplicant
update_config=1
```
For the sake of security, make sure there are not any clear-text
passwords in the file. Now find the wireless interface name with:
```
# iw dev
```
In my case, the interface is `wlan0`. Connect to the wifi and enable
the `wpa_supplicant` on startup with:
```
head# systemctl enable wpa_supplicant.service
head# service wpa_supplicant restart
head# wpa_supplicant -B -Dwext -i wlan0 -c/etc/wpa_supplicant/wpa_supplicant.conf
head# dhclient -v
```
Verify the connection is working:
```
head# ping www.debian.org
```
Set up the interfaces file for `wlan0` so the system connects to the
same network when booted:
```
#### /etc/network/interfaces.d/wlan0
allow-hotplug wlan0
iface wlan0 inet dhcp
  wpa-ssid <from-wpa_supplicant.conf>
  wpa-psk <from-wpa_supplicant.conf>
```
where the `wpa-ssid` and `wpa-psk` can be copied from the
`wpa_supplicant.conf` configuration file above.

Now that we have internet access, we install the `net-tools` package,
which simplifies configuring the network:
```
apt update
apt install net-tools
```
and finally, restart the network:
```
ifdown wlan0
ifup wlan0
```
and check that it can ping the outside.

### Step 4: Configure the package manager and upgrade the system

Modify the `/etc/apt/sources.list` file to set up the source of your
packages and the particular debian version you want. I like the
`testing` distribution because I find it is reasonably stable but also
has somewhat recent packages.
```
#### /etc/apt/sources.list
# testing
deb http://deb.debian.org/debian/ testing main non-free contrib
deb-src http://deb.debian.org/debian/ testing main non-free contrib

# testing/updates
deb http://deb.debian.org/debian/ testing-updates main contrib non-free
deb-src http://deb.debian.org/debian/ testing-updates main contrib non-free

# testing security
deb http://security.debian.org/debian-security testing-security main
deb-src http://security.debian.org/debian-security testing-security main
```
Update the package list and upgrade your distribution:
```
head# apt update
head# apt full-upgrade
```
This may take a while.

### Step 5: Install a few basic pacakages

We need the SSH server and client for connecting to the nodes, as
well as editors and a few basic utilities. We do not need e-mail
utilities or `anacron`, since the system will be running continuously:
```
head# apt install openssh-server openssh-client
head# apt install emacs nfs-common openssh-client openssh-server xz-utils \
          locales bind9-host dbus man apt-install unzip file
head# apt remove 'exim4*'
head# apt remove anacron
```
You should now have access to the head node from your auxiliary PC. To
find the IP of the head node, do:
```
head# /sbin/ifconfig -a
```
If this is the case, you can remove the monitor, keyboard, and mouse,
and work remotely to minimize clutter. You can also copy your SSH key
from the auxiliary PC, if you have one, or generate one with
`ssh-keygen`:
```
aux# ssh-copy-id 192.168.1.135
aux# ssh 192.168.1.135
```
to simplify connecting to it.

### Step 6: Create the compute node image
Now we start configuring the image that will be served to the compute
nodes when they boot up. The image for the nodes resides in
`/image/pi4`. If you have several kinds of rPIs (or other computers)
you can have different images served for them, according to their MAC
address.
```
head# mkdir /image
head# chmod go-rX /image
```
Create the debian base system for the image by using the `debootstrap`
program from the repository:
```
head# apt install debootstrap
head# debootstrap testing /image/pi4
```
It is important that you do NOT set `go-rX` permissions on this
directory or it won't be possible to chroot into it. Lastly, copy the
package manager configuration over to the compute node image:
```
head# cp /etc/apt/sources.list /image/pi4/etc/apt/sources.list
```

### Step 7: Configure the hostname and the names file

To configure the hostname in the head node:
```
head# echo "sebe" > /etc/hostname
```
Then edit the `/etc/hosts` file and fill in the names of the head node
and the compute nodes. In my cluster the head node is `sebe` (or
`b01` in the local network) and the compute nodes are `b02`,
`b03`, etc.
```
#### /etc/hosts
127.0.0.1       localhost

10.0.0.1 sebe b01
10.0.0.2 b02

::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
```
Note that we are using the IPs `10.0.0.1`, `10.0.0.2`,... for the
local network, with the first one being the IP for the head node
(`b01`).

Finally, propagate the hosts file to the compute node image:
```
head# cp /etc/hosts /image/pi4/etc/hosts
```

### Step 8: Configure the local (wired) network

To configure the local network, first find the ethernet interface name
of the head node with:
```
head# /sbin/ifconfig
```
Mine is `eth0`. Then, create the corresponding interfaces file:
```
#### /etc/network/interfaces.d/eth0
allow-hotplug eth0
iface eth0 inet	static
  address 10.0.0.1
  netmask 255.0.0.0
```

### Step 9: Set up and test the chroot environment

To create the chroot environment, you need to mount the `/dev`,
`/proc` and `/sys` directories from the host system, in this case the
head node:
```
head# mount --rbind /dev /image/pi4/dev
head# mount --make-rslave /image/pi4/dev
head# mount -t proc /proc /image/pi4/proc
head# mount --rbind /sys /image/pi4/sys
head# mount --make-rslave /image/pi4/sys
head# mount --rbind /tmp /image/pi4/tmp
```
More information about these commands can be found in the
[kernel documentation](https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt).
Now you can chroot into the compute node image:
```
head# chroot /image/pi4
```
Exit the chroot with `exit` or control-d.

Since we will be chrooting into the image quite a number of times, it
is best if the system mounts the above directories automatically on
start-up. To do this, put the following lines in the head node's fstab
file:
```
#### /etc/fstab
...
/dev /image/pi4/dev none defaults,rbind,rslave 0 0
/proc /image/pi4/proc proc defaults 0 0
/sys /image/pi4/sys none defaults,rbind,rslave 0 0
/tmp /image/pi4/tmp none defaults,rbind 0 0
```

### Step 10: Configure the root bashrc

Edit the head node's root bashrc (`/root/.bashrc`) and enter as many
aliases and tricks as you need for comfortable work. Mine are:
```
# alias
alias mv='mv -f'
alias cp='cp -p'
alias rm='rm -f'
alias ls='ls --color=auto'
alias ll='ls -lrth'
alias la='ls -a'
alias m='less -R'
alias mi='less -i -R'
alias s='cd ..'
alias ss='cd ../.. '
alias sss='cd ../../.. '
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ec='rm -f *~ .*~ >& /dev/null'
alias ecr="find . -name '*~' -delete"
alias b='cd $OLDPWD'
alias last='last -a'
alias p="pwd | sed 's/^\/home\/'$USER'/~/'"

# add paths
export PATH=./:/root/bin:/sbin:/usr/sbin/:$PATH

# emacs
alias e='emacs -nw --no-splash --no-x-resources'
export VISUAL='emacs -nw --no-splash --no-x-resources'
export EDITOR='emacs -nw --no-splash --no-x-resources'
export ALTERNATE_EDITOR='emacs -nw --no-splash --no-x-resources'

# pager
PAGER=/usr/bin/less
export PAGER
```
Copy over the same bashrc to the image:
```
head# cp /root/.bashrc /image/pi4/root/.bashrc
```
In the image, add the following at the end of the bashrc:
```
#### /image/pi4/root/.bashrc
...
if [[ "$HOSTNAME" != "sebe" && "$HOSTNAME" != "b01" ]] ; then
   export PS1="\[\]\[\]\h:\W#\[\] "
else
   export PS1="chroot:\W# "
fi
````
This way, you will be able to tell when you are in the chroot and when
you are connected to a compute node via SSH. (Replace "sebe" and "b01"
with your own names for the head node.)

Lastly, add the following alias to your head node bashrc:
```
#### /root/.bashrc
...
alias pi4='chroot /image/pi4'
```
With this, you will be able to access the image chroot by simply doing:
```
head# pi4
```

### Step 11: Configure the locale

Configure the locale in the head node with:
```
head# locale-gen en_US.UTF-8
head# dpkg-reconfigure locales
```
Install your own locale (instead of en_US.UTF-8) and select it in the
drop-down menu. Repeat in the image after installing the corresponding
package:
```
chroot# apt install locales
chroot# locale-gen en_US.UTF-8
chroot# dpkg-reconfigure locales
```

### Step 12: Upgrade and install packages in the image

Update and upgrade the distribution in the image:
```
chroot# apt update
chroot# apt full-upgrade
```
and then install the kernel image, the firmware, the SSH server, and
the utility packages. Remove `exim` and `anacron`:
```
chroot# apt install linux-image-arm64 firmware-linux firmware-linux-nonfree firmware-misc-nonfree
chroot# apt install raspi-firmware wireless-regdb firmware-brcm80211 bluez-firmware
chroot# apt install net-tools emacs nfs-common openssh-client openssh-server xz-utils bind9-host dbus
chroot# apt install openssh-client openssh-server apt-file
chroot# apt remove 'exim4*'
chroot# apt remove anacron
```

### Step 13: Blacklist the wifi and bluetooth in the image

Blacklisting the wifi and bluetooth prevents starting unnecessary
services and also boot-up errors when operating diskless. Add the
following lines to the `blacklist.conf` file in the image:
```
### /image/pi4/etc/modprobe.d/blacklist.conf
...
blacklist brcmfmac
blacklist brcmutil
blacklist btbcm
blacklist hci_uart
```

### Step 14: Modify the initramfs in the image to be able to network boot

To have the compute nodes boot over the network, we need to configure
their initial ramdisk and filesystem. Modify the image initramfs
configuration file:
```
#### /image/pi4/etc/initramfs-tools/initramfs.conf
MODULES=netboot
BUSYBOX=y
KEYMAP=n
COMPRESS=xz
DEVICE=
NFSROOT=auto
BOOT=nfs
```
and then re-generate the initial ramdisk inside the chroot:
```
chroot# update-initramfs -u
```
Make a note of the initrd file that has been generated. In my
case, this was `/boot/initrd.img-5.17.0-1-arm64`.

### Step 15: Configure ramdisk for temporary files in the image

The compute nodes will have a read-only root filesystem (`/`), so
temporary files cannot be written to `/tmp` in the usual way. To
prevent this from causing errors, create a RAM partition for temporary
files, so they will be written to memory instead. To do this, insert
the following lines in the image configuration files:
```
head# echo ASYNCMOUNTNFS=no >> /image/pi4/etc/default/rcS
head# echo RAMTMP=yes >> /image/pi4/etc/default/tmpfs
```

### Step 16: Configure the FTP server

The image is served to the compute nodes via an FTP server installed
on the head node. First make the directory to contain the served
files:
```
head# mkdir /srv/tftp
```
and then install the FTP server itself:
```
head# apt install tftpd-hpa tftp-hpa
```
The FTP server configuration resides in the `/etc/default/tftpd-hpa`
file of the head node:
```
#### /etc/default/tftpd-hpa
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/tftp"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="-s -v"
```
Lastly, restart the FTP server:
```
head# systemctl restart tftpd-hpa
```

To check that the FTP server works, you can run a simple test. First
create a temporary file in the FTP server directory, then try to copy
it via FTP:
```
head# cd
head# uname -a > /srv/tftp/bleh
head# chmod a+r /srv/tftp/bleh
head# tftp 10.0.0.1
tftp> get bleh
```
Check that the `bleh` file was downloaded and then clean up:
```
head# rm bleh /srv/tftp/bleh
```
At any point in this process you can check what the server is doing
with:
```
head# tail -f /var/log/syslog
```
This command will also be useful to check whether the image is booting
over the network and accessing the FTP server files correctly.

### Step 17: Configure SSH access to the compute nodes

First, we will allow root access to the compute nodes via SSH, for
ease of use:
```
#### /image/pi4/etc/ssh/sshd_config
...
PermitRootLogin yes
TCPKeepAlive yes
...
```
and then we create an ssh key for root and copy it over to the image:
````
head# ssh-keygen
head# cp -r /root/.ssh/ /image/pi4/root/
head# cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
head# cp /root/.ssh/authorized_keys /image/pi4/root/.ssh/
```

### Step 18: Prepare the compute nodes to boot over the network

To have the compute nodes boot over the network, their EEPROM needs to
be flashed with the appropriate image. The easiest way of doing this
is to flash an SD card with raspberry OS, then use the tools that come
with this distro to flash the EEPROM with the image we want. First
download the
[latest raspberry OS](https://downloads.raspberrypi.org/raspbian_latest).
Then, burn it to a clean SD card:
```
aux# unzip 2020-02-13-raspbian-buster.zip
aux# dd if=2020-02-13-raspbian-buster.img of=/dev/sde
```
**Warning: Once again, make sure you get the device file for the SD
card right before using dd.**

Insert the new SD card into the compute node, connect it to the
monitor, mouse, and keyboard, and boot it up. Then, as root, copy the
most recent EEPROM image from the firmware directory:
```
compute# cd
compute# ls /lib/firmware/raspberrypi/bootloader/beta
compute# cp /lib/firmware/raspberrypi/bootloader/beta/pieeprom-2020-01-18.bin .
```
and write its configuration to a file:
```
compute# rpi-eeprrom-config pieeprom-2020-01-18.bin > boot.conf
```
Edit the file and add the line:
```
#### boot.conf
...
BOOT_ORDER=0xf21
```
to prioritize booting over the network. Then, write the image to the
EEPROM:
```
compute# rpi-eeprrom-config --out new.bin --config boot.conf pieeprom-2020-01-18.bin
compute# rpi-eeprom-update -d -f new.bin
```
Lastly, find the MAC address of the compute node by doing:
```
compute# ip addr show eth0
```
and write it down for when we configure the head node DHCP server in
the next step. In my case, the MAC address of the compute node is
`dc:a6:32:f6:e0:b4`.

Repeat flashing the EEPROM for all the compute nodes you have. From
the instructions above, you only need to run the `rpi-eeprom-update`
command, since the `new.bin` image we want to flash has already been
saved in the SD card. Remember to write down the MAC addresses of all
compute nodes.

The MAC address for the head node is easily found with the same
command:
```
head# ip addr show eth0
```
Mine is `e4:5f:01:0b:7f:2a`.

### Step 18: Install and configure the DHCP server

Install the DHCP server in the head node from the package repository:
```
head# apt install isc-dhcp-server
```
Then configure the server by modifying first the
`/etc/default/isc-dhcp-server` file to indicate only the
IPv4 interface is used:
```
#### /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""
```
and then the `/etc/dhcp/dhcpd.conf` for the details on how the compute
nodes will boot over the network:
```
#### /etc/dhcp/dhcpd.conf
ddns-update-style none;
use-host-decl-names on;
default-lease-time 600;
max-lease-time 7200;
subnet 10.0.0.0 netmask 255.0.0.0 {
  option routers 10.0.0.1;
  group {
    option tftp-server-name "10.0.0.1"; # option 66
    option vendor-class-identifier "PXEClient"; # option 60
    option vendor-encapsulated-options "Raspberry Pi Boot"; # option 43
    filename "pxelinux.0";
    host b01 {
      hardware ethernet 38:68:DD:5C:2B:D9; ## sebe/b01
      fixed-address 10.0.0.1;
      option host-name "b01";
    }
    host b02 {
      hardware ethernet 38:68:DD:5C:2A:C1; ## b02
      fixed-address 10.0.0.2;
      option host-name "b02";
      option root-path "10.0.0.1:/image/pi4,v3,tcp,hard,rsize=8192,wsize=8192";
    }
  }
}
```
Note we used the MAC address of each node and associated the
corresponding IPs and names to them. We also indicated the location of
the NFS root filesystem of the compute nodes. If you have different
computers on your cluster that require different images, they can be
served with different image directories by modifying this file.

If you want to do some testing, a simple alternative that gives out
the IPs dynamically is:
```
####/etc/dhcp/dhcpd.conf
ddns-update-style none;
use-host-decl-names on;
default-lease-time 600;
max-lease-time 7200;
subnet 10.0.0.0 netmask 255.0.0.0 {
  option routers 10.0.0.1;
  option tftp-server-name "10.0.0.1"; # option 66
  option vendor-class-identifier "PXEClient"; # option 60
  option vendor-encapsulated-options "Raspberry Pi Boot"; # option 43
  range 10.0.0.1 10.0.0.255;
  filename "pxelinux.0";
}
```
but naturally this will not be the final configuration we use, since
each particular compute node needs to be associated with a particular
IP.

Now, restart the DHCP server:
```
head# systemctl restart isc-dhcp-server
```
(Note: the DHCP server won't start if the `/var/run/dhcpd.pid` file
exists. Remove this file if necessary.) At any point, you can check
the activity of the DHCP server in the same way as for the FTP server:
```
head# tail -f /var/log/syslog
```
This is useful for checking what the compute nodes are doing when they
boot up over the network. You can also use this to find the MAC
address of the compute nodes, as it will be shown in the logs.

### Step 19: Prepare the network boot image

Copy the rPI firmware files over to the FTP server directory:
```
head# cp /boot/firmware/* /srv/tftp
```
Then edit the `cmdline.txt` file:
```
#### /srv/tftp/cmdline.txt
console=tty0 ip=dhcp root=/dev/nfs ro nfsroot=10.0.0.1:/image/pi4,vers=3,nolock panic=60 ipv6.disable=1 rootwait systemd.gpt_auto=no
```
Remove the SD card from the compute node, connect it to the server
with an ethernet cable, and reboot it. If you have more than one
compute nodes, then you should install the ethernet switch now and
connect the head node and all compute nodes to it. Keep an eye on the
syslog in the server to make sure the files are being served properly:
```
head# tail -f /var/log/syslog
```
The compute node should boot only up to some point, but it should not
start completely because no root filesystem could be served, since the
NFS server has not been installed yet.

### Step 20: Set up the NFS server

Install the NFS server in the head node:
```
head# apt install nfs-kernel-server nfs-common
```
Then configure the exports file to serve the image as read-only root
filesystem for the compute nodes and the `/home` directory as
read-write home:
```
#### /etc/exports
/image/pi4  10.0.0.0/24(ro,sync,no_root_squash,no_subtree_check)
/home       10.0.0.0/24(rw,sync,no_root_squash,no_subtree_check)
```
Begin exporting by doing:
```
head# exportfs -rv
```
Then, verify that the NFS server is operative by mounting the image
somewhere:
```
head# cd
head# mkdir temp
head# mount 10.0.0.1:image/pi4 temp/
head# df -h
```
Make sure the NFS mount is in the output of `df -h`, then clean up:
```
head# umount temp/
head# rm -r temp
```
Finally, install the NFS client in the image:
```
chroot# apt install nfs-common
```

### Step 21: Final tweaks and compute node boot up

Configure the mtab in the image by doing:
```
chroot# ln -s /proc/self/mounts /etc/mtab
```
and then comment out the corresponding line the
`/usr/lib/tmpfiles.d/debian.conf` of the image:
```
#### /image/pi4/usr/lib/tmpfiles.d/debian.conf
...
#L+ /etc/mtab   -    -    -    -  ../proc/self/mounts
...
```
Next, disable rcpbind and remove the hostname in the image or the
boot-up may be stuck:
```
chroot# systemctl disable rpcbind
chroot# rm /etc/hostname
```
If you boot up the compute node now, it should be able to fetch the
image and mount the necessary partitions over NFS, and get you to the
login screen. Congratulations!

### Step 22: Add the users to the image

The user and group IDs in the head node and the compute nodes must be
synchronized. Although there are more heavy-duty tools for this, a
simple way is to copy any relevant users and the root lines, as well
as the corresponding groups from the `/etc/passwd`, `/etc/shadow`, and
`/etc/group` to the corresponding files in the `/image/pi4` directory
tree. If you add a new user, you need to propagate the changes in
those files from the head node to the image.

Lastly, copy over the home directory for the users you created in
step 2 over to the image:
```
head# cp -r /home/user1 /image/pi4/home/
head# ...
```

### Step 23: Configure the fstab file and the volatile directories in the image

The root filesystem in the compute nodes is mounted read-only, so we
need to provide RAM partitions for every directory where the compute
node's OS needs to write. Note that the contents of the RAM mounts
will disappear once the compute node is rebooted so things like, for
instance, log files, will not survive a reboot. First set up the
temporary filesystems in the fstab file, so the compute node mounts
them automatically on boot-up:
```
#### /image/pi4/etc/fstab
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
10.0.0.1:/image/pi4    /                nfs     tcp,nolock,ro,v4   1       1
proc                   /proc            proc    defaults           0       0
none                   /tmp             tmpfs   defaults           0       0
none                   /media           tmpfs   defaults           0       0
none                   /var             tmpfs   defaults           0       0
none                   /run             tmpfs   defaults           0       0
10.0.0.1:/home         /home            nfs     tcp,nolock,rw,v4   0       0
```
Then configure systemd in the image to create some directories on
start-up. Even though /var is mounted as tmpfs, various services
running on the compute nodes will complain if these directories do not
exist:
```
#### /image/pi4/etc/tmpfiles.d/vardirs.conf
d /var/backups       0755 root  root -
d /var/cache         0755 root  root -
d /var/lib           0755 root  root -
d /var/local         4755 root  root -
d /var/log           0755 root  root -
d /var/mail          4755 root  root -
d /var/opt           0755 root  root -
d /var/spool         0755 root  root -
d /var/spool/rsyslog 0755 root  root -
d /var/tmp           1777 root  root -
```

### Step 24: Time synchronization between head and compute nodes

It is important to keep the head and compute nodes synchronized
because files are written by both on the shared filesystems. If they
are not in sync, tools that depend on timestamps (like `make`) will
have a hard time working. First install the `ntp` server in the head
node:
```
head# apt install ntp
```
and then the timesyncd service from systemd in the image:
```
chroot# apt install systemd-timesyncd
```
Configure the timesyncd service in the image to get its time from the
NTP server in the head node:
```
#### /image/pi4/etc/systemd/timesyncd.conf
[Time]
FallbackNTP=10.0.0.1
```
and then set up your time zone in both the head node and the image:
```
head# rm /etc/localtime
head# ln -s /usr/share/zoneinfo/Europe/Madrid /etc/localtime
chroot# rm /etc/localtime
chroot# ln -s /usr/share/zoneinfo/Europe/Madrid /etc/localtime
```

### Step 25: Compute node reboot and final checks

Reboot the compute node now. It should boot up all the way to the
login prompt. Check the messages in the journal and verify that there
are no outstanding errors:
```
compute# journalctl -xb
```
Also, check the system status and verify there are no errors as well:
```
compute# systemctl status
compute# systemctl list-units --type=service
```
Check if the volatile directory creation was successful with:
```
compute# systemctl status systemd-tmpfiles-setup.service
```
(Note: You can run the volatile directory create again at any point
with `systemd-tmpfiles --create`.) Lastly, check if the time is
synchronized between the compute node and the head node.
```
compute# timedatectl status
compute# timedatectl show-timesync --all
```

### Step 26: Set up SD cards as scratch space in the compute nodes

The spare SD cards can be mounted in the compute nodes and used as
additional local scratch space for the occasional calculation. Insert
the SD card in the compute node and do:
```
compute# fdisk -l
```
to identify the local disk. To format it, use `fdisk`:
```
compute# fdisk
```
and choose to delete all partitions (`d`), make a new partition table
if necessary (GPT type, with `g`). Then, make a new partition (`n`)
and finally write the partitions and exit (`w`). Once the scratch
partition is ready, create an EXT4 filesystem in it:
```
compute# mkfs.ext4 /dev/mmcblk1p1
```
where the device file is identified from the output of `fdisk`. You
can now try to mount it in a temporary file:
```
compute# cd /home
compute# mkdir temp
compute# mount /dev/mmcblk1p1 temp
```
Check that the new partition works and then clean up:
```
compute# umount temp
compute# rm -r temp
```

The local SD card partition will be mounted automatically in
`/scratch` on start-up. For this, create the scratch directory in the
image:
```
head# mkdir /image/pi4/scratch
head# chmod a+rX /image/pi4/scratch
```
and add the corresponding line in the image's fstab file:
```
#### /image/pi4/etc/fstab
...
/dev/disk/by-path/platform-fe340000.mmc-part1   /scratch         ext4    defaults,nofail    0       2
```
where the use of the "by-path" links ensures that the SD card is
mounted regardless of the device name. You can check on the compute
node the particular name your system uses by listing the contents of
the `by-path` directory. Finally, reboot the client and verify the
disk is mounted.

### Step 27: Create the scratch and opt partitions on the head node

Shut down both nodes and take out the SD card for the head
node. Connect the SD card to the auxiliary desktop PC and use
`gparted` to resize the `/` partition. Then, create two new
partitions: one for `/opt` and one for `/scratch`. The `/opt`
partition will hold the SLURM configuration as well as any computing
software you may want to install. Calculate how much room you will
need for `/opt` and then use the rest for `/scratch`.

Insert the SD card into the head node again and boot it up. Now you
create the entries in the head node's fstab for the two new
partitions:
```
#### /etc/fstab
...
/dev/disk/by-path/platform-fe340000.mmc-part3 /scratch ext4 defaults,nofail 0 2
/dev/disk/by-path/platform-fe340000.mmc-part4 /opt ext4 defaults,nofail 0 2
```
and make the new `/scratch` and `/opt` directories:
```
mkdir /scratch
mkdir /opt
chmod a+rX /scratch
chmod a+rX /opt
```
Share the `/opt` partition via NFS by modifying the exports file:
```
#### /etc/exports
...
/opt        10.0.0.0/24(ro,sync,no_root_squash,no_subtree_check)
```
and re-export with:
```
head# exportfs -rv
```
Enter the corresponding opt line in the fstab of the image, so the
compute nodes mount it over the NFS on start-up:
```
#### /image/pi4/etc/fstab
...
10.0.0.1:/opt     /opt    nfs     tcp,nolock,ro,v4 0 2
```
Optionally, create a software directory in the opt mount to place your
programs:
```
head# mkdir /opt/software
```
Finally, reboot the head node and check the two partitions are
mounted.

### Step 28: Install SLURM

The rPI cluster is now completely installed and ready for
operation. Now we need to install the scheduling system (SLURM). Boot
up the head node. Once it is up, boot up all the compute nodes. In the
head node, install munge:
```
head# apt install libmunge-dev libmunge2 munge
```
Then generate the MUNGE key and set the permissions:
```
head# dd if=/dev/random bs=1 count=1024 > /etc/munge/munge.key
head# chown munge:munge /etc/munge/munge.key
head# chmod 400 /etc/munge/munge.key
```
Restart munge:
```
head# systemctl restart munge
```
To check that munge is working on the head node, generate a credential
on stdout
```
head# munge -n
```
Also, check if a credential can be locally decoded:
```
head# munge -n | unmunge
```
and you can also run a quick benchmark with:
```
head# remunge
```

On the head node, install SLURM from the package repository:
```
head# apt install slurm-wlm slurm-wlm-doc slurm-client
```
Copy over the "munge" and "slurm" users and groups over from the head
node to the compute nodes by propagating them from `/etc/group`,
`/etc/passwd`, and `/etc/shadow` into the corresponding files in the
image directory tree (`/image/pi4`). In the image, install the munge
packages:
```
chroot# apt install libmunge-dev libmunge2 munge
```
Configure new volatile directories using the tmpfiles service of
systemd so that munge can find its directories `/var/log/munge` and
`/var/lib/munge` in the compute nodes:
```
chroot# echo "d /var/log/munge 0700 munge munge -" >> /etc/tmpfiles.d/vardirs.conf
chroot# echo "d /var/lib/munge 0700 munge munge -" >> /etc/tmpfiles.d/vardirs.conf
```
Copy the `munge.key` file from the head node to the image:
```
head# cp /etc/munge/munge.key /image/pi4/etc/munge/
```
and change the permissions of the munge key in the image:
```
chroot# chown munge.munge /etc/munge/munge.key
chroot# chmod 400 /etc/munge/munge.key
```
Boot up (or reboot) the compute node and check that munge is working
by decoding a credential remotely. (You can also restart munge without
rebooting with `systemctl restart munge` if the compute node is
already up.):
```
head# munge -n | ssh 10.0.0.2 unmunge
```
where `10.0.0.2` is the IP of the corresponding compute node.

Finally, install the SLURM daemon in the image:
```
chroot# apt install slurmd slurm-client
```

### Step 29: Configure SLURM

The SLURM configuration file is in `/etc/slurm/slurm.conf` and all
nodes in the cluster must share the same configuration file. To make
this easier, we will direct this file to read the contents of another
file that is shared via NFS, in `/opt/slurm/slurm.conf`:
```
head# mkdir /opt/slurm
head# touch /opt/slurm/slurm.conf
head# echo "include /opt/slurm/slurm.conf" > /etc/slurm/slurm.conf
head# echo "include /opt/slurm/slurm.conf" > /image/pi4/etc/slurm/slurm.conf
```
and now we put our configuration in the configuration file that
resides in the NFS-shared opt partition instead.

To make a configuration file, visit the
[SLURM configurator](https://slurm.schedmd.com/configurator.html)
and fill the entries. For simplicity, I did not use proctracktype
cgroup, because setting up the cgroups would be required. Once the
configuration is generated, write it to `/opt/slurm/slurm.conf`.

The most important part of the SLURM configuration file is at the end,
where the node and partition characteristics are specified. You can
get the configuration details of a particular node by SSHing to it and
doing:
```
head# slurmd -C
compute# slurmd -C
```
Replace the line in the `slurm.conf` with the relevant information
from the output of these commands. In my cluster, I will use the head
node (`b01`) also as a compute node, since there aren't very many
nodes in the cluster anyway. However, I would like the head node to be
used only when all the compute nodes are busy. For this to happen, the
weight of the head node needs to be higher:
```
#### /opt/slurm/slurm.conf
...
NodeName=b01 CPUs=4 CoresPerSocket=4 ThreadsPerCore=1 RealMemory=7807 weight=100 State=UNKNOWN
NodeName=b02 CPUs=4 CoresPerSocket=4 ThreadsPerCore=1 RealMemory=3789 weight=1 State=UNKNOWN
PartitionName=pmain Nodes=ALL Default=YES MaxTime=INFINITE State=UP
```
Note that, in my case, the head node has 8GB memory but the compute
node only 4GB.

Finally, set the permissions, create the SLURM working directory, and
enable and restart the SLURM server:
```
head# chmod a+r /etc/slurm/slurm.conf
head# mkdir /var/spool/slurmctld
head# chown -R slurm.slurm /var/spool/slurmctld
head# systemctl enable slurmctld
head# systemctl restart slurmctld
head# systemctl restart slurmd
```
You can check that the server is running with:
```
head# systemctl status slurmctld
head# systemctl status slurmd
head# scontrol ping
```
(Note: if there is an error, you can look up the problem in the logs
located in `/var/log/slurm*`. You can also run the slurm daemon with
verbose options `slurmd -Dvvvv` in the node to obtain more
information.)

Enable slurm in the client:
```
chroot# systemctl enable slurmd
```
If the compute node is down, reboot it. Otherwise, log into it and
restart the SLURM server:
```
compute# systemctl restart slurmd
```
and verify it works:
```
compute# systemctl status slurmd
```
Finally, check that all the nodes are up by doing:
```
head# sinfo -N
```
A quirk of SLURM is that, by default, nodes that are down (because of
a crash or because they were rebooted) are not automatically brought
back into production. They need to be resumed with:
```
head# scontrol update NodeName=b02 State=RESUME
```
If you want, you can do a power cycle of the whole HPC cluster by
shutting down all the nodes. Then boot up the head node and, once it
is up, start all the compute nodes. Resume the compute nodes and check
the scheduler is working with `sinfo -N`.

### Step 30: submit a test job

As a non-privileged user, submit a test job on the head node. The job
can be:
```
### bleh.sub
#! /bin/bash
#SBATCH -t 28-00:00
#SBATCH -J test
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -c 1

cat /dev/urandom > /dev/null
```
and to submit it, do:
```
head$ sbatch bleh.sub
head$ sbatch bleh.sub
head$ squeue
```
You should have seen the first job be picked by the compute node and
the second job by the head node. Cancel them with:
```
head$ scancel 1
head$ scancel 2
```

### Step 31: SLURM prolog, epilog, and taskprolog scripts

These scripts create the temporary directory in the scratch partition
and set the appropriate permissions and environment variables.
First, set up the script names in the SLURM configuration:
```
#### /opt/slurm/slurm.conf
...
Epilog=/opt/slurm/epilog.sh
...
Prolog=/opt/slurm/prolog.sh
...
TaskProlog=/opt/slurm/taskprolog.sh
...
```
We place these scripts in the shared opt partition so the compute
nodes have access to exactly the same version as he head node. The
scripts create the `SLURM_TMPDIR` directory in the scratch partition
(the SD card each compute node has) and set the appropriate
environment variable. When the job finishes, the temporary directory
is removed. They are:
```
#### /opt/slurm/epilog.sh
#! /bin/bash

# remove the temporary directory
export SLURM_TMPDIR=/scratch/${SLURM_JOB_USER}-${SLURM_JOBID}
if [ -d "$SLURM_TMPDIR" ] ; then
    rm -rf "$SLURM_TMPDIR"
fi

exit 0
```
```
#### /opt/slurm/prolog.sh
#! /bin/bash

# prepare the temporary directory.
export SLURM_TMPDIR=/scratch/${SLURM_JOB_USER}-${SLURM_JOBID}
mkdir $SLURM_TMPDIR
chown ${SLURM_JOB_USER}:users $SLURM_TMPDIR
chmod 700 $SLURM_TMPDIR

exit 0
```
```
#### /opt/slurm/taskprolog.sh
#! /bin/bash

echo export SLURM_TMPDIR=/scratch/${SLURM_JOB_USER}-${SLURM_JOBID}

exit 0
```
Finally, make the three scripts executable with:
```
head# chmod a+rx /opt/slurm/*.sh
```
And re-read the SLURM configuration with:
```
head# scontrol reconfigure
```

### Step 32: Install Quantum ESPRESSO

To show how the rPI cluster can be used to run scientific
calculations, we now install one of the most popular packages for
electronic structure calculations in periodic solids, Quantum ESPRESSO
(QE). QE has been packaged in the Debian repository, so installing the
program can be done via the package manager in the head node and in
the chroot:
```
head# apt install quantum-espresso
chroot# apt install quantum-espresso
```
Now we run a simple total energy calculation on the silicon crystal as
an unprivileged user. First copy over the pseudopotential:
```
head$ cd
head$ cp /usr/share/espresso/pseudo/Si.pbe-rrkj.UPF si.UPF
```
and then write the input file:
```
#### ~/si.scf.in
&control
 title='crystal',
 prefix='crystal',
 pseudo_dir='.',
/
&system
 ibrav=0,
 nat=2,
 ntyp=1,
 ecutwfc=40.0,
 ecutrho=400.0,
/
&electrons
 conv_thr = 1d-8,
/
ATOMIC_SPECIES
Si    28.085500 si.UPF

ATOMIC_POSITIONS crystal
Si    0.12500000     0.12500000     0.12500000
Si    0.87500000     0.87500000     0.87500000

K_POINTS automatic
4 4 4  1 1 1

CELL_PARAMETERS bohr
    0.000000000000     5.131267854931     5.131267854931
    5.131267854931     0.000000000000     5.131267854931
    5.131267854931     5.131267854931     0.000000000000
```
Next the submission script:
```
#### ~/si.sub
#! /bin/bash
#SBATCH -t 28-00:00
#SBATCH -J si
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -c 1

cd
mpirun -np 4 pw.x < si.scf.in > si.scf.out
```
and finally submit the calculation with:
```
head$ sbatch si.sub
```
You can follow the progress of the calculation with `squeue`. It
should eventually finish and produce the `si.scf.out` output file
containing the result of your calculation.

