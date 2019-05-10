#!/usr/bin/env bash

# hop plus cool comme ça 
change-resolution 1920 1080

# remotix cloud
mkdir -p ~/tmp/remotix/
cd ~/tmp/remotix/
curl -O https://downloads.remotixcloud.com/agent-mac/RemotixAgent.pkg

cat << EOF > config.rxasettings

; 
; Remotix Agent settings
;

; Comma-separated trusted user list
trusted_users=${REMOTIX_EMAIL}

; Hub permissions
enable_system_reports=true
enable_system_actions=true
enable_remote_console=false
enable_screenshots=false
enable_location_tracking=false

; Possible values are:
;    auto:     <access_code_expiration_time> key must be present and have one of the possible values [1 hour, 6 hours, 1 day, 1 week, never]
;              example:
;
;              access_code_type=auto
;              access_code_expiration_time=6 hours
;
;    custom:   <access_code_value> key must be present and have at least four-symbol value
;              example:
;
;              access_code_type=custom
;              access_code_value=12.secure_key.34
;
;    disabled: user has to log in using system login, no additional keys are required.
access_code_type=auto
access_code_expiration_time=6 hours

; Services
enable_rxp=true
allow_trusted_without_auth=true
enable_screen_sharing=true
enable_ask_for_control=false

; Settings
enable_auto_update=true
autostart=true
check_for_updates_automatically=true
hide_main_window_on_startup=true

EOF

open RemotixAgent.pkg