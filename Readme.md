# S.T.A.L.K.E.R. GAMMA Linux Installer & Updater (Proton + Mod Organizer 2)

This script automates the installation and updating of **S.T.A.L.K.E.R. GAMMA** on Linux.  
It sets up Proton, configures a Wine prefix, installs Anomaly, the GAMMA modpack, and Mod Organizer 2, and creates both a Lutris entry and a desktop shortcut.  
It supports fast updates without reinstalling Proton or recreating the prefix, and uses resumable high-speed downloads for efficiency.

---

## Features

- Automatic dependency detection and installation  
- First-run Proton version selection, saved for future runs  
- Proton installation via SteamCMD if needed  
- Wine prefix creation and configuration with required runtime libraries  
- Automated installation of [gamma-launcher](https://github.com/Mord3rca/gamma-launcher) and the GAMMA modpack  
- Automatic download and configuration of Mod Organizer 2 (portable)  
- Lutris configuration for easy launching  
- Desktop shortcut creation  
- High-speed resumable downloads using `aria2c` (falls back to `wget`)

---

## Installation

1. Download the script:
```bash
   wget -O stalker-gamma-install https://example.com/stalker-gamma-install
   chmod +x stalker-gamma-install
```
   
2. Run the installer:
```bash
./stalker-gamma-install
```

3. On first run, the script will:
   - Prompt for your preferred Proton version
     (defaults to **Proton Experimental** if you press Enter)
   - Install Proton if it is not already available 
   - Complete the full GAMMA installation automatically

---

## Updating

If S.T.A.L.K.E.R. GAMMA is already installed, you can update it without reinstalling Proton or recreating the Wine prefix:

```bash
./stalker-gamma-install update
```

This will:
- Pull the latest `gamma-launcher`
- Update the GAMMA modpack  
- Download the latest Mod Organizer 2 release

---

## Launching the Game

After installation, you can launch the game in one of the following ways:

- **Lutris**: Find `S.T.A.L.K.E.R. GAMMA (Proton MO2)` and click Play  
- **Desktop Shortcut**: Search your applications menu for `S.T.A.L.K.E.R. GAMMA (Proton MO2)`  
- **Terminal**:
```bash
WINEPREFIX="$HOME/StalkerGAMMA/proton-prefix" \
"$HOME/.local/share/Steam/steamapps/common/<Proton Version>/proton" run \
"$HOME/StalkerGAMMA/MO2/ModOrganizer.exe"
```

## Default Installation Paths

| Path                                                        | Description                  |
|-------------------------------------------------------------|------------------------------|
| `~/StalkerGAMMA`                                            | Main installation directory  |
| `~/StalkerGAMMA/Anomaly`                                    | Anomaly game files           |
| `~/StalkerGAMMA/GAMMA`                                      | GAMMA mod files              |
| `~/StalkerGAMMA/cache`                                      | Installer cache              |
| `~/StalkerGAMMA/MO2`                                        | Mod Organizer 2 portable     |
| `~/StalkerGAMMA/proton-prefix`                              | Proton Wine prefix           |
| `~/.config/stalker-gamma-installer/config.ini`              | Saved Proton version         |

---

## System Requirements

- Linux distribution with either `apt` or `pacman` package manager  
- Steam installed (for Proton support)  
- Sufficient disk space for Anomaly and GAMMA (60+ GB recommended)  
- Internet connection capable of large file downloads

---

## Uninstallation

To completely remove the installation:

```bash
rm -rf ~/StalkerGAMMA \
       ~/.config/stalker-gamma-installer \
       ~/.local/share/lutris/S.T.A.L.K.E.R. GAMMA* \
       ~/.local/share/applications/stalker-gamma.desktop
```
## Troubleshooting

**Game does not start after installation**  
- Make sure Steam is running before launching the game  
- Verify that the Proton version you selected is installed in Steam  
- If unsure, re-run the script and choose the default Proton Experimental

**Installer fails with missing package errors**  
- Install any missing dependencies with your package manager:  
```bash
sudo apt install git wget curl steam aria2   # Debian/Ubuntu
sudo pacman -S git wget curl steam aria2     # Arch
```
## Slow or unstable downloads
- Install aria2 to enable multi-connection downloads:
```bash
sudo apt install aria2    # Debian/Ubuntu
sudo pacman -S aria2      # Arch
```
  
## Slow or unstable downloads
- Install aria2 to enable multi-connection downloads:
```bash
rm -rf ~/StalkerGAMMA
./stalker-gamma-install
```
## Lutris entry is missing

- Re-run the script without the update flag to recreate the Lutris configuration

## Mod Organizer 2 crashes or fails to open

- Check that the Proton prefix folder exists: ~/StalkerGAMMA/proton-prefix

- If it’s missing, run the installer in full install mode (without update) to recreate it

## Support

This installer is an independent community project and is not affiliated with GSC Game World, the S.T.A.L.K.E.R. franchise, or the official GAMMA developers.  
For issues specifically related to GAMMA itself, consult the official GAMMA documentation or community channels.  
For problems with this installer script, please open an issue on the repository where you obtained it.

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0).  
You are free to use, modify, and distribute this software, but any derivative works must also be licensed under GPL-3.0 and include the original license text.

See the [LICENSE](LICENSE) file for the full terms.
