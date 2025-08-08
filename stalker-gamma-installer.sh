#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/functions.sh"

show_banner

if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

case "$1" in
    install)
        run_step "Installing dependencies" install_dependencies
        run_step "Initial setup" initial_setup
        run_step "Checking or creating Wine prefix" check_or_create_wineprefix
        run_step "Installing GAMMA" install_gamma
        run_step "Installing Mod Organizer 2" install_mod_organizer
        run_step "Writing MO2 configuration" write_mo2_config
        run_step "Creating Lutris entry" create_lutris_entry
        run_step "Creating desktop shortcut" create_desktop_shortcut
        log_info "Installation complete."
        ;;
    update)
        run_step "Installing dependencies" install_dependencies
        run_step "Initial setup" initial_setup
        run_step "Checking or creating Wine prefix" check_or_create_wineprefix
        run_step "Updating GAMMA" "install_gamma update"
        run_step "Installing Mod Organizer 2" install_mod_organizer
        run_step "Writing MO2 configuration" write_mo2_config
        run_step "Creating Lutris entry" create_lutris_entry
        run_step "Creating desktop shortcut" create_desktop_shortcut
        log_info "Update complete."
        ;;
    --dry-run)
        DRY_RUN=1
        log_info "Dry run mode enabled. No changes will be made."
        ;;
    --version)
        echo "Stalker GAMMA Installer v${VERSION}"
        ;;
    --help|-h)
        show_help
        ;;
    --reset)
        run_step "Resetting configuration" reset_config
        ;;
    --hard-reset)
        run_step "Performing hard reset" hard_reset_installer
        ;;
    *)
        show_help
        ;;
esac

echo -e "\n${GREEN}${BOLD}✔ INSTALL COMPLETE — You are ready to play!${RESET}\n"
