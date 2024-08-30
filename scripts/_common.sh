#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

_get_metronome_config_dir() {
    if [[ $YNH_DEBIAN_VERSION == "bullseye" ]]; then
        echo "/etc/metronome/conf.d"
        return 0
    fi

    # multi_instance=false, there's only one
    metronome_app=$(yunohost app list --json | jq -r '.apps[] | select(.id == "metronome") | .id')
    if [[ -z "${metronome_app:-}" ]]; then
        ynh_print_warn "Could not find any metronome app!"
        return 1
    fi

    echo "$(ynh_app_setting_get --app="$metronome_app" --key="install_dir")/conf/conf.d"
}
