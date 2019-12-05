# Manjaro Minimal Installation 

[Manjaro Minimal Installation
Video guide](https://youtube.com/watch?v=ozAWczLqsB4) 

[Download Manjaro Minimal](https://manjaro.org/download/arm/raspberry-pi-4/arm8-raspberry-pi-4-minimal/) 

## Flash OS image on SD card

* Once you have the image on your computer, you need to flash it on an SD card. If you are not familiar with this, here are the steps you have to follow:

  * Download and install [Balena Etcher](https://www.balena.io/etcher/). It’s a tool to flash an operating system image to an SD card.

  * Start Etcher, on the left select the image file corresponding to Manjaro Minimal *(Manjaro-ARM-minimal-rpi4-xx.xx.img.xz)*

  * Then insert an SD card. 
**Everything on it will be erased!**

  * Finally click on **“Flash!”** to start the SD card flashing. After a few minutes, the SD card is ready. You can eject it and insert it into your Raspberry Pi

## Manjaro installation and configuration

* Start the Raspberry Pi

__**To setup remotely via SSH open up terminal and input root@IP address, this can only be done via an ethernet connection**__

  * After a few seconds, the system boot is complete and the wizard appears. 

* Enter the username you want to use and confirm. Then you can add additional groups for additional users but it can be kept blank as well. 

* Then, you need to answer the following questions:

  * User full name

  * User password

  * Root password (yes, there is a root user available) 

   ### __*You can enter the first letter to navigate these menus quicker.*__

   * Timezone

    You can use this site to help with selecting your correct timezone. 
    [World Time Zone](https://worldtimezone.com/)

   * Locale

    Locale names are typically in the form of: 
    *language[_territory][.codeset][@modifier]*

    For example, *en_US.UTF-8* for   American-English

    For more info reference:
    [ArchLinux Locale](https://wiki.archlinux.org/index.php/Locale)

  * Keyboard layout

    There's a multitude of keyboard layouts, choose *US* for standard English keyboard. 

    For more info reference:
    [ArchLinux Keyboard Configuration](https://wiki.archlinux.org/index.php/Linux_console/Keyboard_configuration#Creating_a_custom_keymap)

   * Device host name

* Finally, the wizard gives you a list of all the information entered above. Confirm if everything is OK. 

* The basic configuration takes a few seconds. Then the system resizes the SD card partition and reboots. After the reboot, the system is ready to use with your settings. 

## Network configuration
  * Ethernet 

An ethernet connection is really the best way to get Internet access. 

  * Wifi

*In progress*

* Using SSH

**SSH is a must-have on a minimal system**

To use SSH open up terminal and input "your username"@IP address 

    * If you want to use the root login to connect, you need to edit the configuration file: 

          Open the configuration file:
          sudo nano /etc/ssh/sshd_config

          Then edit the PermitRootLogin line like this:
          PermitRootLogin yes

          Save and exit

          Restart the SSH service

## Useful commands
Now that you have Manjaro Minimal setup your ready to begin the Ronin/Dojo install process. Your going to need a few commands off the bat to get you going. I'll cover a couple below and add a link to the Pacman/Rosetta wiki. 


* To install a new package:
 pacman -S < package >

* To search a package name: 
 pacman -Ss < search >

* To update the system:
 pacman -Syu

## Find your Raspberry Pi IP Address:

* ifconfig is not available by default, you need to install it with: pacman -S net-tools

* Now you can use it: ifconfig

For more commands reference:
[ArchLinux Pacman/Rosetta](https://wiki.archlinux.org/index.php/Pacman/Rosetta)



