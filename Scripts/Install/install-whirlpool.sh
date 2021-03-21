#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

cat <<EOF
${red}
***
Comprobando si whirlpool ya esta instalado...
***
${nc}
EOF

if [ -f "$HOME"/whirlpool/whirlpool.jar ]; then
    cat <<EOF
${red}
***
Whirlpool esta instalado!
***
${nc}
EOF
    _sleep

    _pause volver
    bash "$HOME"/RoninDojo/Scripts/Menu/menu-whirlpool.sh
    exit
fi
# checks if whirlpool.jar exists, if so kick back to menu

cat <<EOF
${red}
***
Cromprobando que Tor esté instalado...
***
${nc}
EOF

if hash tor; then
    _pacman_update_mirrors

    cat <<EOF
${red}
***
El paquete Tor esta instalado...
***
${nc}
EOF
else
    cat <<EOF
${red}
***
El paquete Tor se va a instalar ahora....
***
${nc}
EOF
    sudo pacman --quiet -S --noconfirm tor
    _sleep

    # Torrc setup
    _setup_tor
fi

cat <<EOF
${red}
***
Instalando Whirlpool...
***
${nc}
EOF
_sleep 3

cat <<EOF
${red}
***
Una regla de UFW se hará para Whirlpool...
***
${nc}
EOF
_sleep

cat <<EOF
${red}
***
La Whirlpool GUI será capaz de acceder a la Whirlpool CLI desde cualquier ordenador que este en la misma red local que tu RoninDojo...
***
${nc}
EOF
_sleep 5

if sudo ufw status | grep 8899 > /dev/null ; then
    cat <<EOF
${red}
***
La regla del Cortafuegos para Whirlpool ya esta configurada...
***
${nc}
EOF
    _sleep
else
    ip addr | sed -rn '/state UP/{n;n;s:^ *[^ ]* *([^ ]*).*:\1:;s:[^.]*$:0/24:p}' > "$HOME"/ip_tmp.txt
    # creates ip_tmp.txt with IP address listed in ip addr, and makes ending .0/24

    sed -i '2,12d' "$HOME"/ip_tmp.txt
    # delete lines 2-12 (in the systemsetup script it is 2,10d
    # had to be modified for whirlpool setup as an extra value gets added to "$HOME"/ip_tmp.txt)

    while read -r ip ; do echo "### tuple ### allow any 8899 0.0.0.0/0 any ""$ip" > "$HOME"/whirlpool_rule_tmp.txt; done <"$HOME"/ip_tmp.txt
    # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
    # for line 19 in /etc/ufw/user.rules

    while read -r ip ; do echo "-A ufw-user-input -p tcp --dport 8899 -s $ip -j ACCEPT" >> "$HOME"/whirlpool_rule_tmp.txt; done <"$HOME"/ip_tmp.txt
    # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
    # for line 20 /etc/ufw/user.rules

    while read -r ip ; do echo "-A ufw-user-input -p udp --dport 8899 -s $ip -j ACCEPT" >> "$HOME"/whirlpool_rule_tmp.txt; done <"$HOME"/ip_tmp.txt
    # pipes output from ip_tmp.txt into read, then uses echo to make next text file with needed changes plus the ip address
    # for line 21 /etc/ufw/user.rules

    awk 'NR==1{a=$0}NR==FNR{next}FNR==19{print a}1' "$HOME"/whirlpool_rule_tmp.txt /etc/ufw/user.rules > "$HOME"/user.rules_tmp.txt && sudo mv "$HOME"/user.rules_tmp.txt /etc/ufw/user.rules
    # copying from line 1 in whirlpool_rule_tmp.txt to line 19 in /etc/ufw/user.rules
    # using awk to get /lib/ufw/user.rules output, including newly added values, then makes a tmp file
    # after temp file is made it is mv to /lib/ufw/user.rules
    # awk does not have -i to write changes like sed does, that's why I took this approach

    awk 'NR==2{a=$0}NR==FNR{next}FNR==20{print a}1' "$HOME"/whirlpool_rule_tmp.txt /etc/ufw/user.rules > "$HOME"/user.rules_tmp.txt && sudo mv "$HOME"/user.rules_tmp.txt /etc/ufw/user.rules
    # copying from line 2 in whirlpool_rule_tmp.txt to line 20 in /etc/ufw/user.rules

    awk 'NR==3{a=$0}NR==FNR{next}FNR==21{print a}1' "$HOME"/whirlpool_rule_tmp.txt /etc/ufw/user.rules > "$HOME"/user.rules_tmp.txt && sudo mv "$HOME"/user.rules_tmp.txt /etc/ufw/user.rules
    # copying from line 3 in whirlpool_rule_tmp.txt to line 21 in /etc/ufw/user.rules

     sudo sed -i "18G" /etc/ufw/user.rules
    # adds a space to keep things formatted nicely

     sudo chown root:root /etc/ufw/user.rules
    # this command changes ownership back to root:root
    # when /etc/ufw/user.rules is edited using awk or sed, the owner gets changed from Root to whatever User that edited that file
    # that causes a warning to be displayed as /etc/ufw/user.rules does need to be owned by root:root

     sudo rm "$HOME"/ip_tmp.txt "$HOME"/whirlpool_rule_tmp.txt
    # removes txt files that are no longer needed

    cat <<EOF
${red}
***
Recargando UFW...
***
${nc}
EOF
    _sleep
    sudo ufw reload
fi
# checks for port 8899 ufw rule and skips if found, if not found it is set up

cat <<EOF
${red}
***
Comprobando el estado de UFW...
***
${nc}
EOF
_sleep
sudo ufw status

cat <<EOF
${red}
***
Un directorio para Whirlpool ha sido creado...
***
${nc}
EOF
_sleep

cd "$HOME" || exit
mkdir whirlpool
cd whirlpool || exit
# create whirlpool directory

cat <<EOF
${red}
***
Descargando Whirlpool de git...
***
${nc}
EOF
_sleep
wget -qO whirlpool.jar https://code.samourai.io/whirlpool/whirlpool-client-cli/uploads/7998ea5a9bb180451616809bc346b9ac/whirlpool-client-cli-0.10.8-run.jar
# pull Whirlpool run times

# whirlpool service. Check if present else create it
cat <<EOF
${red}
***
Comprobando que Whirlpool.service sea existente...
***
${nc}
EOF

if [ -f /etc/systemd/system/whirlpool.service ]; then
    cat <<EOF
${red}
***
Whirlpool Service ya ha sido instalado!
***
EOF
    _sleep
    sudo systemctl stop --quiet whirlpool
else
    cat <<EOF
${red}
***
Configurando Whirlpool Service...
***
${nc}
EOF
    _sleep

sudo bash -c 'cat << EOF > /etc/systemd/system/whirlpool.service
[Unit]
Description=Whirlpool
After=tor.service

[Service]
WorkingDirectory=/home/${ronindojo_user}/whirlpool
ExecStart=/usr/bin/java -jar /home/${ronindojo_user}/whirlpool/whirlpool.jar --server=mainnet --tor --auto-mix --listen
User=${ronindojo_user}
Group=${ronindojo_user}
Type=simple
KillMode=process
TimeoutSec=60
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF'
fi
# checks for whirlpool.service and if found skips, if not found sets up whirlpool.service

sudo systemctl daemon-reload
_sleep 3

cat <<EOF
${red}
***
Iniciando Whirlpool en segundo plano...
***
${nc}
EOF
_sleep

sudo systemctl start --quiet whirlpool
sudo systemctl enable --quiet whirlpool
_sleep 3

cat <<EOF
${red}
***
Instala Whirpool GUI para inciar Whirlpool y procede a abrir el monedero/wallet para empezar a mezclar...
***
${nc}
EOF
_sleep

cat <<EOF
${red}
***
Para enlazar con la GUI dirigete a la guia: https://wiki.ronindojo.io/en/cli-setup/step3
***
${nc}
EOF
_sleep

cat <<EOF
${red}
***
Esta instalción es sin Tor whirlpool, solo se puede acceder en la red local...
***
${nc}
EOF
_sleep

_pause volver