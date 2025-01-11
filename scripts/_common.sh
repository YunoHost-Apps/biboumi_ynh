#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Guess which xmpp server is running.
_get_xmpp_app_name() {
    for candidate in prosody metronome ; do
        if systemctl is-active prosody -q ; then
            echo $candidate
            return 0
        fi
    done
    ynh_die "Failed to guess the XMPP server software running"
}

# Compute the config filename where the XMPP component for biboumi is configured.
_get_xmpp_server_config_filename() {
    xmpp_app=$1
    if [ $xmpp_app = prosody ] ; then
        echo "/etc/$xmpp_app/conf.d/$app.cfg.lua"
    elif [ $xmpp_app = metronome ] ; then
        echo "/etc/$xmpp_app/conf.d/$app.cfg.lua"
    else
        ynh_die "Failed to configure unsupported XMPP server $xmpp_app"
    fi
}

# Configure biboumi as an XMPP component for the running XMPP server.
_configure_xmpp_server() {
    xmpp_app=$1
    config_filename=$(_get_xmpp_server_config_filename $xmpp_app)
    if [ $xmpp_app = prosody ] ; then
        ynh_config_add --template="prosody.cfg.lua" --destination="$config_filename"
        chown prosody:prosody "/etc/$xmpp_app/conf.d/$app.cfg.lua"
    elif [ $xmpp_app = metronome ] ; then
        ynh_config_add --template="prosody.cfg.lua" --destination="$config_filename"
        chown metronome:metronome "/etc/$xmpp_app/conf.d/$app.cfg.lua"
    else
        ynh_die "Failed to configure unsupported XMPP server $xmpp_app"
    fi
}

_ynh_config_add_logrotate_for_biboumi() {
    mkdir --parents /var/log/$app
    chmod 750 /var/log/$app
    chown _biboumi:_biboumi /var/log/$app

    echo > /etc/logrotate.d/$app <<EOF
/var/log/$app/$app.log {
    # Rotate if the logfile exceeds 100Mo
    size 100M
    # Keep 12 old log maximum
    rotate 12
    # Compress the logs with gzip
    compress
    # Compress the log at the next cycle. So keep always 2 non compressed logs
    delaycompress
    # Copy and truncate the log to allow to continue write on it. Instead of moving the log.
    copytruncate
    # Do not trigger an error if the log is missing
    missingok
    # Do not rotate if the log is empty
    notifempty
    # Keep old logs in the same dir
    noolddir
}
EOF
    chmod 644 "/etc/logrotate.d/$app"
}
