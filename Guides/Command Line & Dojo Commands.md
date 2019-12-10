# General CL

### *This is an incomplete list!*

Shutdown device: `sudo shutdown`

Reboot device: `sudo reboot`

Go back: `CTRL+C`

**Docker:**

Docker info: `sudo docker info` or `sudo docker info | grep "Docker Root Dir:"`

Restart tor: `sudo docker restart tor`

Show Docker version: `sudo docker -v`

Docker status: `sudo systemctl status docker`

**Chmod**

Makes file executable: `sudo chmod +x ~/"RoninDojo/ronin.sh"`
 
**Pacman**

Sync & Upgrade: `sudo pacman -Syu`

Downloads and installs git: `sudo pacman -S git`

**SD & Drive info** 

Show attached drives info: `sudo lsblk -f`

Shows mounted USB drive info: `sudo df -h /dev/sda1` or `sudo df -h /mnt/usb`

**Systemctl**

Reload daemon: `sudo systemctl daemon-reload`

Stop Docker: `sudo systemctl stop docker`

Start Docker: `sudo systemctl start docker` or `sudo systemctl enable docker `

Remove file: `sudo rm -r ~/`

Remove file by force: `sudo rm -rf ~/`

**Git**

Clone git repository: `git clone "url" `

Clone a branch of repository(must choose branch, ie "development") : `git clone -b "development" "url" `

Switches to development branch: `git checkout development`
 
**Nano**

Launch file explorer: `sudo nano`

# Dojo
 
### Usage: `./dojo.sh  "command"  "module" "options"`

**To use these commands you must be in the correct directory**

So first:

`cd dojo/docker/my-dojo`

**Available commands:**

Display the help message: `help` 

Launch a bitcoin-cli console for interacting with bitcoind RPC API: `bitcoin-cli` 

Free disk space by deleting docker dangling images and images of previous versions: `clean` 

Install your Dojo: `install`

**Logs**

----

`logs "module" "options"`

Display the logs of your Dojo. Use `CTRL+C` to stop the logs. 

**Available modules:**

Display the logs of all containers: `dojo.sh logs` 

Display the logs of bitcoind: `dojo.sh logs bitcoind`

Display the logs of the MySQL database: `dojo.sh logs db` 

Display the logs of tor: `dojo.sh logs tor`

Display the logs of the REST API (nodejs): `dojo.sh logs api`

Display the logs of the Tracker (nodejs): `dojo.sh logs tracker`

Display the logs of the pushTx API (nodejs): `dojo.sh logs pushtx`

Display the logs of the Orchestrator (nodejs): `dojo.sh logs pushtx-orchest`

**Available options:** _(for api, tracker, pushtx and pushtx-orchest modules):_

Select the type of log to be displayed. VALUE can be output (default) or error: `-d [VALUE]`

Display the last VALUE lines: ` -n [VALUE]`

----

Display the Tor onion address allowing your wallet to access your Dojo: `onion` 

Restart your Dojo: `restart` 

Start your Dojo: `start` 

Stop your Dojo: `stop` 

Delete your Dojo. **Be careful! This command will also remove all data**: `uninstall` 

Upgrade your Dojo: `upgrade` 

Display the version of dojo: `version` 
