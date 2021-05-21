#!/bin/bash
# shellcheck source=/dev/null disable=SC2154

. "$HOME"/RoninDojo/Scripts/defaults.sh
. "$HOME"/RoninDojo/Scripts/functions.sh

if [ ! -d "$HOME"/Whirlpool-Stats-Tool ]; then
    cat <<EOF
${red}
***
Instalando herramienta estadística de Whirlpool...
***
${nc}
EOF
    _sleep

    bash "$HOME"/RoninDojo/Scripts/Install/install-wst.sh
else
    _sleep
    cd "$HOME"/Whirlpool-Stats-Tool/whirlpool_stats || exit
fi
# if "$HOME"/whirlpool_stats is not found then run install script
# else inform user and launch

cat <<EOF
${red}
Instrucciones de la herramienta estadística de Whirlpool:
${nc}
EOF

_sleep
# instructions are given to user

cat <<EOF
${red}
Descarga en el directorio de trabajo un Snapshot para las pools de 0.01 BTC:
${nc}
download 001
EOF

_sleep

cat <<EOF
${red}
Carga y computa las estadísticas para el Snapshot:
${nc}
load 001
EOF

_sleep

cat <<EOF
${red}
Muestra las métricas computadas para una transacción guardada en el snapshot activo:
${nc}
Puntuación <INTRODUCE LA TXID DE LA TRANSACCIÓN DE 0.01 BTC DESEADA>
EOF

_sleep

cat <<EOF
${red}
Ejemplo de salida...
${nc}
Metricas retrospectivas para los outputs de este mix:
    anonset = 92
    spread = 89%

Metricas retrospectivas para los outputs de Tx0s teniendo esta transacción su primer mix:
    anonset = 127
    spread = 76%
EOF

_sleep

cat <<EOF
${red}
***
Escribe : 'quit' en cualquier momento para salir de la herramienta estadística de Whirlpool.
***
EOF

_pause volver
# press any key to continue

if ! pipenv run python wst.py -w=/tmp 2>/dev/null; then
    _check_pkg "pipenv" "python-pipenv"

    cat <<EOF
${red}
***
Comprobando actualizaciones...
***
${nc}
EOF
    _sleep

    cd .. || exit

    # Upgrade dependencies
    pipenv update &>/dev/null

    cd - &>/dev/null || exit
    pipenv run python wst.py -w=/tmp
fi
# run wst.py

_pause volver
bash -c "${ronin_samourai_toolkit_menu}"