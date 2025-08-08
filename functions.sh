#!/usr/bin/env bash
set -euo pipefail

# ========== Version ==========
VERSION="1.0.0"

# ========== Colors ==========
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# ========== Banner ==========
show_banner() {
    clear
    echo -e "${YELLOW}${BOLD}"
    cat << "EOF"
███████╗████████╗ █████╗ ██╗     ██╗  ██╗███████╗██████╗
██╔════╝╚══██╔══╝██╔══██╗██║     ██║ ██╔╝██╔════╝██╔══██╗
███████╗   ██║   ███████║██║     █████╔╝ █████╗  ██████╔╝
╚════██║   ██║   ██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
███████║   ██║   ██║  ██║███████╗██║  ██╗███████╗██║  ██║
╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
EOF
    echo -e "${CYAN}          G.A.M.M.A Linux Installer${RESET}\n"
}

# ========== Logging ==========
log_info()    { echo -e " ${CYAN}ℹ${RESET} $*"; }
log_warn()    { echo -e " ${YELLOW}⚠${RESET} $*"; }
log_error()   { echo -e " ${RED}✖${RESET} $*" >&2; exit 1; }

# ========== Spinner ==========
run_step() {
    local step_desc="$1"
    local step_func="$2"
    local pid spinner chars delay

    echo -ne "${BOLD}${WHITE}─── $step_desc ───────────────────────────────${RESET}\n"

    (
        "$step_func"
    ) &
    pid=$!

    chars="/-\|"
    delay=0.15
    while kill -0 $pid 2>/dev/null; do
        for c in $chars; do
            echo -ne " ${GREEN}$c${RESET}  \r"
            sleep $delay
        done
    done

    wait $pid
    local status=$?
    if [[ $status -eq 0 ]]; then
        echo -e " ${GREEN}✔${RESET} $step_desc completed"
    else
        echo -e " ${RED}✖${RESET} $step_desc failed"
        exit 1
    fi
    echo
}

# ========== Trap for Ctrl+C ==========
trap 'echo -e "\n${RED}✖ Installation cancelled by user${RESET}"; exit 1' INT

# ========= Core Variables =========
INSTALL_DIR="$HOME/StalkerGAMMA"
CACHE_DIR="$INSTALL_DIR/cache"
CONFIG_DIR="$HOME/.config/stalker-gamma-installer"
CONFIG_FILE="$CONFIG_DIR/config.ini"
WINEPREFIX="$INSTALL_DIR/proton-prefix"
MO2_DIR="$INSTALL_DIR/MO2"
ANOMALY_DIR="$INSTALL_DIR/Anomaly"
GAMMA_DIR="$INSTALL_DIR/GAMMA"
PROTON=""
PROTON_VERSION=""

# ========= Core Functions (your unchanged logic) =========

show_help() {
    cat <<EOF
Usage: $0 [install|update|--dry-run|--version|--help|--reset|--hard-reset]

Commands:
  install       Full installation (Proton, Wine prefix, GAMMA, MO2, shortcuts)
  update        Update existing installation without recreating Proton/prefix
  --dry-run     Preview steps without executing them
  --version     Show installer version
  --help        Show this help message
  --reset       Remove only the installer configuration (keeps game/mod files)
  --hard-reset  Remove everything: config, cache, and all installation files
EOF
}

reset_config() {
    echo "This will remove the installer configuration only (Proton path, settings)."
    read -rp "Are you sure? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -f "$CONFIG_FILE"
        log_info "Configuration reset. Installation files remain."
    else
        log_info "Reset cancelled."
    fi
}

hard_reset_installer() {
    echo "This will COMPLETELY remove all S.T.A.L.K.E.R. GAMMA files, cache, and config."
    read -rp "Are you sure? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf "$INSTALL_DIR" "$CACHE_DIR" "$CONFIG_DIR"
        log_info "Full hard reset complete. All data removed."
    else
        log_info "Hard reset cancelled."
    fi
}

install_dependencies() {
    if command -v apt &>/dev/null; then
        sudo apt update
        sudo apt install -y git wget curl steam aria2 unzip unrar
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --needed git wget curl steam aria2 unzip unrar

        if ! ldconfig -p | grep -q libunrar.so; then
            log_warn "libunrar.so not found — required for gamma-launcher to handle .rar files."
            if command -v yay &>/dev/null; then
                yay -S --needed libunrar
            elif command -v paru &>/dev/null; then
                paru -S --needed libunrar
            else
                log_warn "No AUR helper found. Please install 'libunrar' from AUR manually:"
                log_warn "  https://aur.archlinux.org/packages/libunrar"
                log_error "Missing libunrar.so — cannot continue without it."
            fi
        fi
    else
        log_error "Unsupported package manager. Install dependencies manually (including 'unrar' and 'libunrar')."
    fi
}

initial_setup() {
    mkdir -p "$CONFIG_DIR"

    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        log_info "Loaded configuration from $CONFIG_FILE"
        return
    fi

    log_info "No configuration found. Let's set up your directories."
    read -rp "Do you want to set custom directories? (y/N): " custom_dirs

    if [[ "$custom_dirs" =~ ^[Yy]$ ]]; then
        read -rp "Enter full path to Proton folder (default: $HOME/.local/share/Steam/steamapps/common/Proton - Experimental): " proton_path
        proton_path="${proton_path:-$HOME/.local/share/Steam/steamapps/common/Proton - Experimental}"
        proton_path="${proton_path%/}"
        if [[ ! -d "$proton_path" ]]; then
            log_error "Directory not found: $proton_path"
        fi
        PROTON="$proton_path/proton"
        PROTON_VERSION="$(basename "$proton_path")"

        read -rp "Enter installation directory (default: $HOME/StalkerGAMMA): " install_dir
        install_dir="${install_dir:-$HOME/StalkerGAMMA}"
        install_dir="${install_dir%/}"
        INSTALL_DIR="$install_dir"

        read -rp "Enter Mod Organizer 2 directory (default: $INSTALL_DIR/MO2): " mo2_dir
        mo2_dir="${mo2_dir:-$INSTALL_DIR/MO2}"
        mo2_dir="${mo2_dir%/}"
        MO2_DIR="$mo2_dir"

        read -rp "Enter Wine prefix directory (default: $INSTALL_DIR/proton-prefix): " wineprefix_dir
        wineprefix_dir="${wineprefix_dir:-$INSTALL_DIR/proton-prefix}"
        wineprefix_dir="${wineprefix_dir%/}"
        WINEPREFIX="$wineprefix_dir"
    else
        PROTON="$HOME/.local/share/Steam/steamapps/common/Proton - Experimental/proton"
        PROTON_VERSION="Proton - Experimental"
        INSTALL_DIR="$HOME/StalkerGAMMA"
        MO2_DIR="$INSTALL_DIR/MO2"
        WINEPREFIX="$INSTALL_DIR/proton-prefix"
    fi

    CACHE_DIR="$INSTALL_DIR/cache"
    ANOMALY_DIR="$INSTALL_DIR/Anomaly"
    GAMMA_DIR="$INSTALL_DIR/GAMMA"

    cat > "$CONFIG_FILE" <<EOF
PROTON="$PROTON"
PROTON_VERSION="$PROTON_VERSION"
INSTALL_DIR="$INSTALL_DIR"
MO2_DIR="$MO2_DIR"
WINEPREFIX="$WINEPREFIX"
CACHE_DIR="$CACHE_DIR"
ANOMALY_DIR="$ANOMALY_DIR"
GAMMA_DIR="$GAMMA_DIR"
EOF

    log_info "Configuration saved to $CONFIG_FILE"

    if [[ ! -x "$PROTON" ]]; then
        log_error "Proton not found at $PROTON. Please install it or specify the correct path."
    fi
}

check_or_create_wineprefix() {
    if [[ -d "$WINEPREFIX" && -f "$WINEPREFIX/system.reg" ]]; then
        log_info "Wine prefix already exists at $WINEPREFIX — skipping creation."
    else
        log_info "Creating Wine prefix at $WINEPREFIX..."
        mkdir -p "$WINEPREFIX"
        WINEPREFIX="$WINEPREFIX" wineboot --init
        log_info "Wine prefix created."
    fi
}

install_gamma() {
    local mode="${1:-install}"
    local gl_dir="$CACHE_DIR/gamma-launcher"
    local venv_dir="$gl_dir/env"

    mkdir -p "$CACHE_DIR"

    if [[ "$mode" == "update" ]]; then
        log_info "Updating gamma-launcher..."
        if [[ ! -d "$gl_dir" ]]; then
            log_error "gamma-launcher not found in $gl_dir — run full install first."
        fi
        cd "$gl_dir"
        git pull
        source "$venv_dir/bin/activate"
        pip install --upgrade .
        log_info "Updating GAMMA..."
        gamma-launcher update --gamma "$GAMMA_DIR" --cache-directory "$CACHE_DIR"
        deactivate
        log_info "Updating Mod Organizer 2..."
        rm -rf "$MO2_DIR"
    else
        log_info "Installing gamma-launcher..."
        rm -rf "$gl_dir"
        git clone https://github.com/Mord3rca/gamma-launcher.git "$gl_dir"
        cd "$gl_dir"
        python3 -m venv env
        source "$venv_dir/bin/activate"
        pip install --upgrade pip
        pip install .
        gamma-launcher --version
        log_info "Installing GAMMA..."
        gamma-launcher full-install --anomaly "$ANOMALY_DIR" --gamma "$GAMMA_DIR" --cache-directory "$CACHE_DIR"
        deactivate
    fi
}

install_mod_organizer() {
    log_info "Installing Mod Organizer 2..."
    mkdir -p "$MO2_DIR"
    local mo2_zip="$CACHE_DIR/MO2.zip"
    aria2c -x 16 -s 16 -o "$mo2_zip" "https://github.com/ModOrganizer2/modorganizer/releases/latest/download/Mod.Organizer-2.zip" \
        || wget -O "$mo2_zip" "https://github.com/ModOrganizer2/modorganizer/releases/latest/download/Mod.Organizer-2.zip"
    unzip -o "$mo2_zip" -d "$MO2_DIR"
}

write_mo2_config() {
    log_info "Writing MO2 configuration..."
    mkdir -p "$MO2_DIR/downloads" "$MO2_DIR/overwrite"
    cat > "$MO2_DIR/ModOrganizer.ini" <<EOF
[General]
gameName=Anomaly
gamePath=$ANOMALY_DIR
modsPath=$GAMMA_DIR
downloadPath=$MO2_DIR/downloads
overwritePath=$MO2_DIR/overwrite
style=dark
portable=true
enableNotifications=true
showToolbars=true

[Logging]
logLevel=info

[Paths]
instancePath=$MO2_DIR
EOF
}

create_lutris_entry() {
    log_info "Creating Lutris entry"
    echo "Creating Lutris entry..."

    # Ensure variables
    LUTRIS_CONFIG_DIR="${HOME}/.config/lutris/games"
    PROTON_DIR="$(dirname "$PROTON")"
    GAME_NAME="S.T.A.L.K.E.R. GAMMA (Proton MO2)"

    mkdir -p "$LUTRIS_CONFIG_DIR"
    cat > "${LUTRIS_CONFIG_DIR}/${GAME_NAME}.yml" <<EOF
game:
  exe: ${PROTON_DIR}/proton
  args: run "${MO2_DIR}/ModOrganizer.exe"
  working_dir: "${MO2_DIR}"
  prefix: "${WINEPREFIX}"
  name: "${GAME_NAME}"
runner: wine
EOF

    log_info "Lutris entry created at: ${LUTRIS_CONFIG_DIR}/${GAME_NAME}.yml"
}

create_desktop_shortcut() {
    log_info "Creating desktop shortcut"
    echo "Creating desktop shortcut..."

    PROTON_DIR="$(dirname "$PROTON")"
    DESKTOP_FILE="${HOME}/.local/share/applications/stalker-gamma.desktop"

    mkdir -p "$(dirname "${DESKTOP_FILE}")"
    cat > "${DESKTOP_FILE}" <<EOF
[Desktop Entry]
Name=S.T.A.L.K.E.R. GAMMA (Proton MO2)
Exec=${PROTON_DIR}/proton run "${MO2_DIR}/ModOrganizer.exe"
Type=Application
Categories=Game;
EOF
    chmod +x "${DESKTOP_FILE}"

    log_info "Desktop shortcut created at: ${DESKTOP_FILE}"
}
