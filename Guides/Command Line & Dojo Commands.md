# General CL

`sudo shutdown`

Shutdown device

`sudo reboot`

Reboots device 

`CTRL+C`

Back out of any menu or go back to CL

**Docker:**

`sudo docker info`

`sudo docker info | grep "Docker Root Dir:"`

Pulls docker info

`sudo docker restart tor`

Restarts tor

`sudo docker -v`

Shows docker version

`sudo systemctl status docker`

Docker status 

**Chmod**

`sudo chmod +x ~/RoninDojo/ronin.sh`

? 

**Pacman**

`sudo pacman -Syu`

Runs system wide update 

`sudo pacman -S git`

Downloads and installs git

**SD & Drive info** 

`sudo lsblk -f`

Shows attached drives data

`sudo df -h /dev/sda1`

Shows SD card info

`sudo df -h /mnt/usb`

Shows mounted USB drive info 

**Systemctl**

`sudo systemctl daemon-reload`

Reloads daemon

`sudo systemctl stop docker`

Stop docker

`sudo systemctl start docker`

`sudo systemctl enable docker `

Start docker

`sudo rm -rf ~/`

Remove file by force, can drop f

**Git**

`git clone (url) `

`git clone -b development (url) `

Clones a branch of git, must specify branch

`git checkout development`
 
Switches to development branch

**Nano**

`sudo nano`

Launch file explorer 



# Dojo
 
### Usage: `./dojo.sh command [module] [options] `

**Available commands:**

`help` 

Display the help message. 

`bitcoin-cli` 

Launch a bitcoin-cli console for interacting with bitcoind RPC API. 

`clean` 

Free disk space by deleting docker dangling images and images of previous versions.

`install`

 Install your Dojo. 

**Logs**

----

`logs [module] [options]`

Display the logs of your Dojo. Use `CTRL+C` to stop the logs. 

**Available modules:**

`dojo.sh logs` : display the logs of all containers 

`dojo.sh logs bitcoind` : display the logs of bitcoind 

`dojo.sh logs db` : display the logs of the MySQL database 

`dojo.sh logs tor` : display the logs of tor 

`dojo.sh logs api` : display the logs of the REST API (nodejs) 

`dojo.sh logs tracker` : display the logs of the Tracker (nodejs) 

`dojo.sh logs pushtx` : display the logs of the pushTx API (nodejs) 

`dojo.sh logs pushtx-orchest` : display the logs of the Orchestrator (nodejs) 

**Available options:** _(for api, tracker, pushtx and pushtx-orchest modules):_

`-d [VALUE]` : select the type of log to be displayed. VALUE can be output (default) or error.

` -n [VALUE]` : display the last VALUE lines 

----

`onion` 

Display the Tor onion address allowing your wallet to access your Dojo. 

`restart` 

Restart your Dojo. 

`start` 

Start your Dojo. 

`stop` 

Stop your Dojo. 

`uninstall` 

Delete your Dojo. Be careful! This command will also remove all data. 

`upgrade` 

Upgrade your Dojo. 

`version` 

Display the version of dojo.
