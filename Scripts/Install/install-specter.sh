#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh


SPECTER_SIGN_KEY_URL="https://stepansnigirev.com/ss-specter-release.asc"
SPECTER_SIGN_KEY="ss-specter-release.asc"
SPECTER_URL="https://github.com/cryptoadvance/specter-desktop/releases/download"
SPECTER_VERSION="0.10.4"

cd /home/$USER

if [ ! -d specter* ]; then
   echo "Installing Specter $SPECTER_VERSION";
   sleep 2s
   sed -i 's/  -disablewallet=.*$/  -disablewallet=0/' "${dojo_path_my_dojo}"/bitcoin/restart.sh
   sudo pacman -S --noconfirm gcc
else
   if [ "$HOME"/specter* != "$HOME"/specter-$SPECTER_VERSION ]; then
      echo "Proceeding to upgrade to $SPECTER_VERSION";
      sleep 2s
      sudo systemctl stop specter
      sudo rm -rf /etc/systemd/system/specter.service
      sudo systemctl daemon-reload
      sudo rm -rf "$HOME"/specter*
      sed -i 's/  -disablewallet=.*$/  -disablewallet=0/' "${dojo_path_my_dojo}"/bitcoin/restart.sh
   else
      echo "On latest version of Specter";
      sleep 2s
      sed -i 's/  -disablewallet=.*$/  -disablewallet=0/' "${dojo_path_my_dojo}"/bitcoin/restart.sh
      exit;
   fi
fi

wget --quiet $SPECTER_SIGN_KEY_URL && gpg --import $SPECTER_SIGN_KEY && rm -rf $SPECTER_SIGN_KEY
wget --quiet $SPECTER_URL/v$SPECTER_VERSION/sha256.signed.txt && gpg --verify sha256.signed.txt
wget --quiet $SPECTER_URL/v$SPECTER_VERSION/cryptoadvance.specter-$SPECTER_VERSION.tar.gz
sha256sum -c cryptoadvance.specter-$SPECTER_VERSION.tar.gz sha256.signed.txt
mkdir "$HOME"/specter-$SPECTER_VERSION && tar -zxf cryptoadvance.specter-$SPECTER_VERSION.tar.gz -C "$HOME"/specter-$SPECTER_VERSION --strip-components 1
rm -rf sha256.signed.txt *.tar.gz
cd "$HOME"/specter-$SPECTER_VERSION && sudo python setup.py install

#create file .flaskenv

bash -c "cat <<EOF > "$HOME"/specter-$SPECTER_VERSION/.flaskenv
#Maybe you want another port?
#PORT=25441
#
# If you want to serve over a Tor hidden service, also set FLASK_ENV=production.
#   (The autoreloading in 'development' mode causes problems with the Tor connector)
CONNECT_TOR=True

FLASK_ENV=production
#FLASK_ENV=development
EOF"

sudo bash -c "cat <<EOF > /etc/systemd/system/specter.service
[Unit]
Description=Specter Desktop Service
After=multi-user.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/bin/python3.8 -m cryptoadvance.specter server --tor
WorkingDirectory="$HOME"/specter-$SPECTER_VERSION/src/
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload

cd "${dojo_path_my_dojo}"
./dojo.sh upgrade --nolog
#upgrade dojo to implement changes to bitcoin/restart.sh

sudo systemctl enable specter
sudo systemctl start specter
#start specter server
