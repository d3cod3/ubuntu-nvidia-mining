
**This guide is specifically designed for, and tested on ubuntu server 18.04, and for NVIDIA GPUs**

# Start with your rig running WITHOUT the GPUs connected

# Install Ubuntu Server 18.04

Don't update the installer when asked, just follow normal installation

# Fix pciebus error severity corrected

[pcie-bus-error-severity-corrected](https://itsfoss.com/pcie-bus-error-severity-corrected/)

```bash
sudo nano /etc/default/grub

GRUB_CMDLINE_LINUX_DEFAULT="pci=noaer"

sudo update-grub

sudo shutdown -h now
```

# Now connect the GPUs to risers and motherboard

then start the rig again.

# Set Static IP

[Set static ip address](https://linuxize.com/post/how-to-configure-static-ip-address-on-ubuntu-18-04/)

First list your network interfaces:

```bash
ip link
```

And a tipical output could be:

```bash
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
```

Where ```ens3``` will be the interface name

So create the config for static ip:

```bash
sudo nano /etc/netplan/01-netcfg.yaml
```
Use spaces, no tabs, the interpreter is very strict, and obviously choose your address and gateway accordingly to your home intranet, as the name of the interface.

```
network:
  version: 2
  renderer: networkd
  ethernets:
    ens3:
      dhcp4: no
      addresses:
        - 192.168.121.199/24
      gateway4: 192.168.121.1
      nameservers:
          addresses: [8.8.8.8, 1.1.1.1]
```
Apply it and reboot:

```bash
sudo netplan apply

sudo reboot
```

# SSH from now on!!!

Now your rig will always have the same IP

# update system

```bash
sudo apt update && sudo apt dist-upgrade -y
```

# install needed packages

```bash
sudo apt install dkms libmicrohttpd-dev libssl-dev libudev-dev libncurses5-dev libncursesw5-dev cmake build-essential libhwloc-dev git curl nano p7zip unrar unzip xinit inxi xterm
```

# install nvidia cuda and drivers

```bash
sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/3bf863cc.pub
sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub

curl -O "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.0.130-1_amd64.deb"

sudo apt update
sudo apt dist-upgrade
sudo apt install cuda
```

Then reboot:

```bash
sudo reboot
```

Now install the cuda toolkit:

```bash
sudo apt install nvidia-cuda-toolkit
```

and check to see what the hugepages is set at for your current user:

```bash
/sbin/sysctl vm.nr_hugepages ; ulimit -l
```

If the result is vm.nr_hugepages = 0 then hugepages is not on.  We will now enable hugepages:

```bash
sudo nano /etc/sysctl.d/60-hugepages.conf
```

Then add the following

```bash
vm.nr_hugepages=128
```

Now edit memlock size:

```bash
sudo nano /etc/security/limits.d/60-memlock.conf
```

The add the following:

```bash
* - memlock 262144
root - memlock 262144
```

reboot again

```bash
sudo reboot
```

# Check nvidia hardware

Check nvidia-smi

```bash
nvidia-smi

nvidia-smi -L

nvidia-smi --query-gpu=index,name,gpu_bus_id,pci.device_id,pci.sub_device_id --format=csv
```

List pcie VGA devices:

```bash
lspci -vnn | grep VGA -A 12
```

# Create and edit xorg.conf for overclocking

```bash
sudo nvidia-xconfig --cool-bits=31 --allow-empty-initial-configuration
```

Do not consider the ```No package 'xorg-server' found```, the xorg config file is now available.

Now, before editing xorg config, copy the ```edid.bin``` file included in this repo in your home folder

```bash
cp edid.bin /home/YOUR_USERNAME/edid.bin
```

Now edit ```xorg.conf```

```bash
sudo nano /etx/X11/xorg.conf
```

Then use the ```xorg.conf``` included in this repo as a template, just modify it to fit the number of GPUs installed in your rig.

Here an exemple of an hypotetical rig with 6 GPUs installed:

```bash
# nvidia-xconfig: X configuration file generated by nvidia-xconfig

###########################################################

Section "ServerFlags"
    Option "BlankTime" "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "0"
EndSection

###########################################################
# edit this section to fit your number of GPUs installed ( rig of 6, rig of 9, etc... )
# in this example i'm configuring a rig of 6 GPUs

Section "ServerLayout"
    Identifier     "Layout0"

    Screen      0  "Screen0" 0 0
    Screen      1  "Screen1" 0 0
    Screen      2  "Screen2" 0 0
    Screen      3  "Screen3" 0 0
    Screen      4  "Screen4" 0 0
    Screen      5  "Screen5" 0 0

    InputDevice    "Keyboard0" "CoreKeyboard"
    InputDevice    "Mouse0" "CorePointer"
EndSection

###########################################################

Section "Module"
    Disable "glx"
EndSection

###########################################################

Section "Files"
EndSection

###########################################################

Section "InputDevice"
    Identifier     "Mouse0"
    Driver         "mouse"
    Option         "Protocol" "auto"
    Option         "Device" "/dev/psaux"
    Option         "Emulate3Buttons" "no"
    Option         "ZAxisMapping" "4 5"
EndSection

Section "InputDevice"
    Identifier     "Keyboard0"
    Driver         "kbd"
EndSection

###########################################################

Section "Monitor"
    Identifier     "Monitor0"
    Option         "DPMS" "0"
EndSection

# next here the 6 GPUs devices, change this in order to match your BusID
# you can check that with nvidia-smi
# and the right number of GPUs installed

# and remember to change the CustomEDID path with your username

# --- 01:00.0 --------------------------------------------
Section "Device"
    Identifier     "Device0"
    Driver         "nvidia"
    Option         "Coolbits" "31"
    BusID          "PCI:1:0:0"
    Option         "ConnectedMonitor" "DFP-0"
    Option         "CustomEDID" "DFP-0:/home/YOUR_USERNAME/edid.bin"
EndSection

Section "Screen"
    Identifier     "Screen0"
    Device         "Device0"
    Option         "Coolbits" "31"
EndSection

# --- 02:00.0 --------------------------------------------
Section "Device"
    Identifier     "Device1"
    Driver         "nvidia"
    Option         "Coolbits" "31"
    BusID          "PCI:2:0:0"
    Option         "ConnectedMonitor" "DFP-0"
    Option         "CustomEDID" "DFP-0:/home/YOUR_USERNAME/edid.bin"
EndSection

Section "Screen"
    Identifier     "Screen1"
    Device         "Device1"
    Option         "Coolbits" "31"
    Option         "UseDisplayDevice" "none"
EndSection

# --- 03:00.0 --------------------------------------------
Section "Device"
    Identifier     "Device2"
    Driver         "nvidia"
    Option         "Coolbits" "31"
    BusID          "PCI:3:0:0"
    Option         "ConnectedMonitor" "DFP-0"
    Option         "CustomEDID" "DFP-0:/home/YOUR_USERNAME/edid.bin"
EndSection

Section "Screen"
    Identifier     "Screen2"
    Device         "Device2"
    Option         "Coolbits" "31"
    Option         "UseDisplayDevice" "none"
EndSection

# --- 04:00.0 --------------------------------------------
Section "Device"
    Identifier     "Device3"
    Driver         "nvidia"
    Option         "Coolbits" "31"
    BusID          "PCI:4:0:0"
    Option         "ConnectedMonitor" "DFP-0"
    Option         "CustomEDID" "DFP-0:/home/YOUR_USERNAME/edid.bin"
EndSection

Section "Screen"
    Identifier     "Screen3"
    Device         "Device3"
    Option         "Coolbits" "31"
    Option         "UseDisplayDevice" "none"
EndSection

# --- 05:00.0 --------------------------------------------
Section "Device"
    Identifier     "Device4"
    Driver         "nvidia"
    Option         "Coolbits" "31"
    BusID          "PCI:5:0:0"
    Option         "ConnectedMonitor" "DFP-0"
    Option         "CustomEDID" "DFP-0:/home/YOUR_USERNAME/edid.bin"
EndSection

Section "Screen"
    Identifier     "Screen4"
    Device         "Device4"
    Option         "Coolbits" "31"
    Option         "UseDisplayDevice" "none"
EndSection

# --- 06:00.0 --------------------------------------------
Section "Device"
    Identifier     "Device5"
    Driver         "nvidia"
    Option         "Coolbits" "31"
    BusID          "PCI:6:0:0"
    Option         "ConnectedMonitor" "DFP-0"
    Option         "CustomEDID" "DFP-0:/home/YOUR_USERNAME/edid.bin"
EndSection

Section "Screen"
    Identifier     "Screen5"
    Device         "Device5"
    Option         "Coolbits" "31"
    Option         "UseDisplayDevice" "none"
EndSection


# --- in case of lspci giving 0000:0A:00.0 or another letter, is actually an hex base number, so we need to convert it to decimal for xorg

# --- 0A -> 10
# --- BusID          "PCI:10:0:0"
# --- 10:00.0 --------------------------------------------

# --- 0B -> 11
# --- ........
```

# Edit visudo

We need to add NOPASSWD permissions to some commands in order to have overclock working, edit visudo:

```bash
sudo visudo
```

then add this at the end of file:

```bash
# nvidia overclock
user    ALL = (ALL) NOPASSWD: /usr/bin/xinit
user    ALL = (ALL) NOPASSWD: /usr/bin/nvidia-persistenced
user    ALL = (ALL) NOPASSWD: /usr/bin/nvidia-smi
```

save and exit, then reboot

```bash
sudo reboot
```

# Test it and start mining

Everything is configured now, just use the included resetGPUs.sh script to test the system ( the script just remove any overclock and stops all fans ) and if no error appears, then you're ready to mine, just download the last release of the miners of your choice and configure them!

Included in this repo there is a generic template script for that, just use it as a guide to configure and overclock properly your gpus.

# Enjoy! and Donate

This mini guide seems an easy one, but it really took a lot of time to clean it up and redude it to the minimum, it's not a wide documented topic, there are a lot of tutorials over there, but most of them always lack some information or are outdated.

If you want to mine DIY, without pre-builded mining OS, this guide will be really helpful, but if you want to have it easier and don't mind paying a little for that, HiveOS ( free for the first worker, and for other three if mining on their Hiveon pool ) or Simple Mining ( first month free, then 2$ per worker per month ) are really good options.

**If you like my work, please consider to donate**

BTC

```1c4Cw6gdiA9fZVGkDbafSwn58Z3HrogsZ```

ETH

```0xdF1a8772A50a201aE17611706148B25f7B2eC7fB```
