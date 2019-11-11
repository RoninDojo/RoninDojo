# Ronin UI Guide

This guide is out of date and needs to be updated! If you are testing please see section 5.

Get your Dojo running in a few easy steps! Once setup, simply enter `ronin` into the Terminal anytime to manage your System, Dojo, or other features using the Ronin UI.

Please report any issues that you are having. Thank you for trying Ronin UI!

## Table of Contents
* [**1. HARDWARE REQUIREMENTS**](https://github.com/BTCxZelko/Ronin-Dojo/blob/master/Odroid/Manjaro/Ronin-UI-Guide.md#1-hardware-requirements)
* [**2. PREPARE OPERATING SYSTEM**](https://github.com/BTCxZelko/Ronin-Dojo/blob/master/Odroid/Manjaro/Ronin-UI-Guide.md#2-prepare-operating-system)
* [**3. STATIC IP AND REMOTE LOGIN**](https://github.com/BTCxZelko/Ronin-Dojo/blob/master/Odroid/Manjaro/Ronin-UI-Guide.md#3-static-ip-and-remote-login)
* [**4. SETUP OPERATING SYSTEM**](https://github.com/BTCxZelko/Ronin-Dojo/blob/master/Odroid/Manjaro/Ronin-UI-Guide.md#4-setup-operating-system)
* [**5. RONIN UI**](https://github.com/BTCxZelko/Ronin-Dojo/blob/master/Odroid/Manjaro/Ronin-UI-Guide.md#5-ronin-ui)

```
# My sources:

Dojo Telegram - https://t.me/samourai_dojo
Dojo Docs - https://github.com/Samourai-Wallet/samourai-dojo/blob/master/doc/DOCKER_setup.md#first-time-setup
Advanced Setups - https://github.com/Samourai-Wallet/samourai-dojo/blob/master/doc/DOCKER_advanced_setups.md
```


---------------------------------------------------------------------------------------------------------------


## 1. [HARDWARE REQUIREMENTS]

* [Odroid N2 4gb](https://forum.odroid.com/viewtopic.php?f=176&t=33781)
* [Samsung T5](https://www.amazon.com/Samsung-T5-Portable-SSD-MU-PA1T0B/dp/B073H552FJ/ref=sr_1_1?fst=as%3Aoff&qid=1571081118&refinements=p_n_feature_three_browse-bin%3A6797521011&rnid=6797515011&s=pc&sr=1-1) or [Seagate Fast SSD](https://www.amazon.com/Seagate-External-Reversible-Type-C-STCM1000400/dp/B07DX7D744)
* [Samsung EVO+ 64GB](https://www.amazon.com/Samsung-MicroSDXC-Memory-Adapter-MB-MC64GA/dp/B06XFWPXYD/ref=sr_1_4?keywords=EVO%2B+SD+card&qid=1571081610&s=electronics&sr=1-4)

I suggest adding a UPS battery back up to be sure your Odroid wont lose power during bad weather etc.

More info on Hardware can be found [here](https://github.com/BTCxZelko/Ronin-Dojo#recommended-hardware).

## 2. [OPERATING SYSTEM]

* [Manjaro ARM Minimal](https://manjaro.org/)

Download the OS, verify it, and flash to SD card.

```
DOWNLOAD:  
MD5: 
SHA512: 
SIG: 

PGP PUBLIC KEY: 
```
Use the md5, sha512, sig, and the PGP public key to check that the Manjaro `.img.xz` you have downloaded is authentic. Do not trust, verify! If you are not sure on this please look up “md5 to verify software” and “gpg to verify software.” This method is used to verify things very often.

Please take some time to learn, ask questions, watch videos, and do any other method of research you prefer. Watch the playlist below if you are a newbie, working on getting comfortable using the Windows CMD, or Linux Terminal.  

Now you can go ahead and use something like Balena Etcher to flash the image on to an SD card, then insert it into the Odroid's SD card slot. 

Plug in the SSD, Ethernet cable, and finally the power cable to the Odroid.

```
Newbie Playlist: 
https://www.youtube.com/watch?v=plUQ3ZRBL54&list=PLmoQ11MXEmajkNPMvmc8OEeZ0zxOKbGRa

ADD YOUTUBE VIDEO HERE for gpg
Optional Reading: Installing Images - https://www.raspberrypi.org/documentation/installation/installing-images/
Optional Reading: Software: https://www.balena.io/etcher/
Optional Reading: How To gpg - https://www.dewinter.com/gnupg_howto/english/GPGMiniHowto-3.html
Optional Reading: How To md5 - https://www.lifewire.com/validate-md5-checksum-file-4037391 
```


## 3. [STATIC IP AND REMOTE LOGIN]

Log in to your router and set a Static IP address for your Odroid. Take a look at this [explainer](https://github.com/BTCxZelko/Ronin-Dojo/blob/master/Odroid/Debian/Explainers/Network.md) if you need help.

Now you can SSH (remote login) to your Odroid by installing the Ubuntu Subsystem on Windows, opening a Terminal window, and entering the SSH command. 

For Mac or Linux, simply open a Terminal window, and use the same process.
```
# SSH login to your Odroid using the root user

# Windows:
# Install Ubuntu Subsystem - ADD YOUTUBE VIDEO HERE of ubuntu subsystem install@!#%!@#%@!#%!@%@!%!#
# Open a terminal window
# Enter your username, the Odroid's static IP address, connect, and then enter the password
$ ssh root@IP.OF.ODROID.HERE
# Example: root@192.168.0.5
> Enter password:

# Mac or Linux:
# Open a terminal window
# Enter your username, the Odroid's static IP address, connect, and then enter the password
$ ssh root@IP.OF.ODROID.HERE
# Example: root@192.168.0.5
> Enter password:
```

**NEWBIE TIPS:** Each command has `$` before it, and the outputs of the command are marked `>` to avoid confusion. `#` is symbol for a comment. Do not enter ANY of these symbols as part of a command. If you are not sure about commands, stuck, learning, etc. try visiting the information links and doing the Optional Reading. Look up terms that you do not know. The Dojo Telegram chat is also very active and helpful.

SSH is technically optional, but encouraged as it is very helpful. It can be done from any computer on the same network as the Odroid.

If you login with SSH regularly, then you can run "headless". This means you don't need to plug in a keyboard or monitor to the Odroid.

```
# Disabling password login and using SSH Key for login is highly recommended!
Optional Reading: SSH Key Info - https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#login-with-ssh-keys
Optional Reading: SSH Key Info - https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2
```

## 4. [SETUP OPERATING SYSTEM]

Now that you have logged in via SSH, let's setup the OS.

Here is an example setup for John Doe, who speaks english, and wants to use the "Chicago Illinois USA" timezone. 
```
Username=slicesoon
Name=John Doe
Password=secure123
Root Password=secure123456789
Timezone=
Locale=
Keyboard Layout=us
Hostname=RedRover
```

Please alter where needed if you want different settings than the example above.

Use a password manager or write down this information. Store it in a secure place that you will not forget.

Now that you system is setup you can continue with Ronin UI.

## 5. [RONIN UI]

After first run of ./ronin.sh, you can simply type `ronin` into the terminal, no need to type ./ before it.

1. cd ~

2. sudo pacman -Syu git

3. git clone -b development https://github.com/RoninDojo/RoninDojo.git

4. sudo chmod +x ~/RoninDojo/ronin.sh

5. Type `ronin` and hit enter

```
Donations:
SegWit native address (Bech32) bc1q5s6jhl0uz9lsj3vgclvftqqap9p60ztpurpax7
Segwit compatible address (P2SH) 3LdWJ2op2Ba51BndUkUuX7qxoecXaK5FWk
```
