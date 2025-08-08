#!/usr/bin/env bash
set -e

INSTALL_DIR="${HOME}/StalkerGAMMA"
ANOMALY_DIR="${INSTALL_DIR}/Anomaly"
GAMMA_DIR="${INSTALL_DIR}/GAMMA"
CACHE_DIR="${INSTALL_DIR}/cache"
MO2_DIR="${INSTALL_DIR}/MO2"
CONFIG_DIR="${HOME}/.config/stalker-gamma-installer"
CONFIG_FILE="${CONFIG_DIR}/config.ini"
WINEPREFIX="${INSTALL_DIR}/proton-prefix"
LUTRIS_CONFIG_DIR="${HOME}/.local/share/lutris"
DESKTOP_FILE="${HOME}/.local/share/applications/stalker-gamma.desktop"

echo "Checking dependencies..."
PKGS=(git python3 python3-venv steamcmd wine winetricks unzip curl)
for pkg in "${PKGS[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
        echo "Missing: $pkg. Installing..."
        if command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y "$pkg"
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -Sy --noconfirm "$pkg"
        else
            echo "Unsupported package manager. Install $pkg manually."
            exit 1
        fi
    fi
done

if command -v aria2c >/dev/null 2>&1; then
    DL="aria2c -x 16 -s 16 -k 1M --continue"
else
    DL="wget -c"
fi

mkdir -p "${INSTALL_DIR}" "${CACHE_DIR}" "${CONFIG_DIR}" "${LUTRIS_CONFIG_DIR}"

if [ ! -f "${CONFIG_FILE}" ]; then
    echo "Select Proton version (leave empty for Proton Experimental):"
    read -r PROTON_VER
    PROTON_VER="${PROTON_VER:-Proton Experimental}"
    echo "PROTON_VERSION=${PROTON_VER}" > "${CONFIG_FILE}"
else
    source "${CONFIG_FILE}"
fi

PROTON_DIR="${HOME}/.local/share/Steam/steamapps/common/${PROTON_VERSION}"
if [ ! -d "${PROTON_DIR}" ]; then
    echo "Installing ${PROTON_VERSION} via steamcmd..."
    steamcmd +login anonymous +app_install 1887720 validate +quit
fi

if [ "$1" == "update" ]; then
    echo "Updating gamma-launcher..."
    cd "${INSTALL_DIR}/gamma-launcher" && git pull
    source env/bin/activate
    pip install --upgrade .
    echo "Updating GAMMA..."
    gamma-launcher update --gamma "${GAMMA_DIR}" --cache-directory "${CACHE_DIR}"
    deactivate
    echo "Updating Mod Organizer 2..."
    rm -rf "${MO2_DIR}"
else
    echo "Installing gamma-launcher..."
    cd "${INSTALL_DIR}"
    git clone https://github.com/Mord3rca/gamma-launcher.git
    cd gamma-launcher
    python3 -m venv env
    source env/bin/activate
    pip install --upgrade pip
    pip install .
    gamma-launcher --version
    echo "Installing GAMMA..."
    gamma-launcher full-install --anomaly "${ANOMALY_DIR}" --gamma "${GAMMA_DIR}" --cache-directory "${CACHE_DIR}"
    deactivate
fi

if [ ! -d "${WINEPREFIX}" ]; then
    echo "Creating Proton prefix..."
    WINEPREFIX="${WINEPREFIX}" "${PROTON_DIR}/proton" run wineboot
    winetricks -q vcrun2019 dotnet48
fi

echo "Installing Mod Organizer 2..."
mkdir -p "${MO2_DIR}"
MO2_URL=$(curl -s https://api.github.com/repos/ModOrganizer2/modorganizer/releases/latest | grep "browser_download_url" | grep "portable" | cut -d '"' -f 4)
$DL -o "${MO2_DIR}/MO2.zip" "$MO2_URL"
unzip -o -q "${MO2_DIR}/MO2.zip" -d "${MO2_DIR}"
rm "${MO2_DIR}/MO2.zip"

echo "Configuring Mod Organizer 2..."
cat > "${MO2_DIR}/ModOrganizer.ini" <<EOF
[General]
gamePath=${ANOMALY_DIR}
modsPath=${GAMMA_DIR}/mods
profilePath=${GAMMA_DIR}/profiles
EOF

echo "Creating Lutris entry..."
GAME_NAME="S.T.A.L.K.E.R. GAMMA (Proton MO2)"
cat > "${LUTRIS_CONFIG_DIR}/${GAME_NAME}.yml" <<EOF
game:
  exe: ${PROTON_DIR}/proton
  args: run "${MO2_DIR}/ModOrganizer.exe"
  working_dir: "${MO2_DIR}"
  prefix: "${WINEPREFIX}"
  name: "${GAME_NAME}"
runner: wine
EOF

echo "Creating desktop shortcut..."
mkdir -p "$(dirname "${DESKTOP_FILE}")"
cat > "${DESKTOP_FILE}" <<EOF
[Desktop Entry]
Name=S.T.A.L.K.E.R. GAMMA (Proton MO2)
Exec=${PROTON_DIR}/proton run "${MO2_DIR}/ModOrganizer.exe"
Type=Application
Categories=Game;
EOF
chmod +x "${DESKTOP_FILE}"

echo "Installation complete."
echo "Launch via Lutris, desktop shortcut, or:"
echo "WINEPREFIX=\"${WINEPREFIX}\" \"${PROTON_DIR}/proton\" run \"${MO2_DIR}/ModOrganizer.exe\""
