## S.T.A.L.K.E.R. GAMMA - Linux Installer


A fully automated installer and updater for the S.T.A.L.K.E.R. GAMMA modpack on Linux.
This script handles dependencies, Wineprefix creation, GAMMA installation via the official launcher,
Mod Organizer 2 configuration, and shortcut creation. It is designed to be a one-stop solution for getting into The Zone on a Linux system.
```
███████╗████████╗ █████╗ ██╗     ██╗  ██╗███████╗██████╗
██╔════╝╚══██╔══╝██╔══██╗██║     ██║ ██╔╝██╔════╝██╔══██╗
███████╗   ██║   ███████║██║     █████╔╝ █████╗  ██████╔╝
╚════██║   ██║   ██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
███████║   ██║   ██║  ██║███████╗██║  ██╗███████╗██║  ██║
╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
          G.A.M.M.A Linux Installer
```


## Features


- Automated Dependency Installation: Automatically detects your package manager (apt for Debian/Ubuntu, pacman for Arch) and installs all required tools: git, wget, curl, steam, aria2, unzip, and unrar.
- Arch Linux Support: Specifically checks for libunrar.so on Arch-based systems and, if missing, attempts to install it using an AUR helper (yay or paru).
- Guided Setup: On the first run, prompts you to use default paths or specify your own for a customized setup.
- Configuration Management: Saves your path choices to a configuration file (~/.config/stalker-gamma-installer/config.ini) for easy re-runs and updates.
- Wineprefix Management: Automatically creates a clean Wineprefix for S.T.A.L.K.E.R. Anomaly and GAMMA, ensuring a sandboxed and stable environment.
- Official GAMMA Launcher: Downloads and uses the official gamma-launcher within a dedicated Python virtual environment to install or update the full modpack.
- Mod Organizer 2 Setup: Fetches the latest release of Mod Organizer 2 and automatically generates a ModOrganizer.ini file configured for portable use with your GAMMA installation.
- Shortcut Creation: Creates both a Lutris entry and a .desktop application shortcut to easily launch Mod Organizer 2 through Proton.
- Easy Maintenance: Simple commands to update your installation or perform a clean reset.



## Requirements


- A Linux system (tested on Debian/Ubuntu and Arch-based distributions).
- Approximately 100GB of free disk space.
- A fast and stable internet connection.


---

## Installation
```bash
git clone https://github.com/bradleygit/Stalker-GAMMA-Linux-Installer.git
cd Stalker-GAMMA-Linux-Installer
chmod +x stalker-gamma-installer.sh
./stalker-gamma-installer.sh install
```

---

## Usage
```bash
./stalker-gamma-installer.sh [command]
```

### Commands
| Command        | Description |
|----------------|-------------|
| `install`      | Full installation (Proton, Wineprefix, GAMMA, MO2, shortcuts) |
| `update`       | Update existing installation without recreating Proton/Wineprefix |
| `--dry-run`    | Preview steps without executing them |
| `--version`    | Show installer version |
| `--help`       | Show help message |
| `--reset`      | Remove only installer configuration (keep game/mod files) |
| `--hard-reset` | Remove **everything** — config, cache, and all installation files |

---

## Configuration

On first run, the installer will ask:

- Do you want to set custom directories?  
  - If **Yes**, you’ll be prompted for paths to:
    - Proton directory 
    - Install directory 
    - MO2 directory 
    - Wineprefix directory 
  - If **No**, defaults will be used. 

Configuration is stored in: 
~/.config/stalker-gamma-installer/config.ini

---

## Troubleshooting

- **`Couldn't find path to unrar library` error on Arch**  
  → Installer will attempt to install `libunrar` automatically.  
  If you have no AUR helper, install manually:
```bash
git clone https://aur.archlinux.org/libunrar.git
cd libunrar
makepkg -si
```

## License

This project is licensed under the GNU General Public License v3.0 — see the [LICENSE](LICENSE) file for details.

---
## Credits

- [Mord3rca](https://github.com/Mord3rca) — GAMMA Launcher
- [Anomaly Team](https://www.moddb.com/mods/stalker-anomaly) — S.T.A.L.K.E.R. Anomaly 
- [Mod Organizer 2 Team](https://github.com/ModOrganizer2) — MO2 
