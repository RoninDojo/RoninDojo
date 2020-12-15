#!/bin/bash
# shellcheck source=/dev/null

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

shopt -s nullglob

cd "${HOME}" || exit

for dir in specter*; do
   if [[ ! -d "${dir}" ]]; then
      cat <<EOF
${RED}
***
Installing Specter $SPECTER_VERSION ...
***
${NC}
EOF
      _sleep
      sed -i 's/  -disablewallet=.*$/  -disablewallet=0/' "${dojo_path_my_dojo}"/bitcoin/restart.sh
      sudo sed -i "s:^#ControlPort .*$:ControlPort 9051:" /etc/tor/torrc
      sudo systemctl restart tor

      if ! hash gcc 2>/dev/null; then
         cat <<EOF
${RED}
***
Installing gcc
***
${NC}
EOF
         sudo pacman -S --noconfirm gcc
      fi
   else
      if [[ "${dir}" != specter-$SPECTER_VERSION ]]; then
         cat <<EOF
${RED}
***
Proceeding to upgrade to $SPECTER_VERSION ...
***
${NC}
EOF
         _sleep

         sudo systemctl stop specter
         sudo rm /etc/systemd/system/specter.service

         sudo rm -rf "${dir}"

         sed -i 's/  -disablewallet=.*$/  -disablewallet=0/' "${dojo_path_my_dojo}"/bitcoin/restart.sh
      else
         cat <<EOF
${RED}
***
On latest version of Specter ...
***
${NC}
EOF
         _sleep 2
         ronin
      fi
   fi
done

wget --quiet "$SPECTER_SIGN_KEY_URL"
gpg --import "$SPECTER_SIGN_KEY"
rm "$SPECTER_SIGN_KEY"

wget --quiet "$SPECTER_URL"/v"$SPECTER_VERSION"/sha256.signed.txt
gpg --verify sha256.signed.txt

wget --quiet "$SPECTER_URL"/v"$SPECTER_VERSION"/cryptoadvance.specter-"$SPECTER_VERSION".tar.gz

if grep cryptoadvance.specter-"$SPECTER_VERSION".tar.gz sha256.signed.txt | sha256sum -c -; then
   cat <<EOF
${RED}
***
Good verification... Installing now
***
${NC}
EOF
else
   cat <<EOF
${RED}
***
Verification failed...
***
${NC}
EOF
   _sleep 5 --msg "Returning to main menu in"
   ronin
fi

mkdir "$HOME"/specter-"$SPECTER_VERSION"
tar -zxf cryptoadvance.specter-"$SPECTER_VERSION".tar.gz -C "$HOME"/specter-"$SPECTER_VERSION" --strip-components 1

rm sha256.signed.txt ./*.tar.gz

if [ -d .venv_specter ]; then
   cat <<EOF
${RED}
***
venv is already set ...
***
${NC}
EOF
else
   python3 -m venv "$HOME"/.venv_specter
fi

cd "$HOME"/specter-"$SPECTER_VERSION" || exit
"$HOME"/.venv_specter/bin/python3 setup.py install

#create file .flaskenv

cat <<EOF > "${HOME}"/specter-"$SPECTER_VERSION"/.flaskenv
CONNECT_TOR=True

FLASK_ENV=production
EOF

sudo bash -c "cat <<EOF > /etc/systemd/system/specter.service
[Unit]
Description=Specter Desktop Service
After=multi-user.target

[Service]
User=$USER
Type=simple
ExecStart=$HOME/.venv_specter/bin/python -m cryptoadvance.specter server --tor
Environment=PATH=$HOME/.venv_specter/bin
WorkingDirectory=$HOME/specter-$SPECTER_VERSION/src
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF
"

sudo systemctl daemon-reload

# Make sure dojo is stopped by us before upgrade
_stop_dojo

cd "${dojo_path_my_dojo}" || exit

./dojo.sh upgrade --nolog
# Upgrade dojo to implement changes to bitcoin/restart.sh

sudo systemctl enable specter 2>/dev/null
sudo systemctl start specter
# Start specter service

   cat <<EOF
${RED}
***
Specter v$SPECTER_VERSION as been installed ...
***
${NC}
EOF

_sleep

ronin