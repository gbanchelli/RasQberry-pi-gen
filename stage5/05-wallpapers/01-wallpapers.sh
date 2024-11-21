#!/bin/bash

# TODO: Improve error checking. 
#       Get rid of the chmod hack for conf files.
#       Use the higher resolution image for HDMI.
# Both WP_DIR and RQPI_DIR must exist, and RQPI_DIR must contain our wallpaper files.

# Define variables for the wallpaper image fine name, source and destination.
CONF_DIR=/home/$FIRST_USER/.config/pcmanfm/LXDE-pi
RQPI_DIR=/home/$FIRST_USER/.local/config/Artwork/Logo-Wallpaper
WP_DIR=/usr/share/rpd-wallpaper
WALLPAPER='RasQberry 2 Wallpaper FHD.png'

# Config file for HDMI-attached screen.
HDMI_CONF=desktop-items-HDMI-A-1.conf
# Config file for headless operation
NOOP_CONF=desktop-items-NOOP-1.conf
CONF_FILES=($NOOP_CONF $HDMI_CONF)

# Ensure source and destination directories exist.
if ! [[ -e $RQPI_DIR  && -e $WP_DIR ]]; then
    echo "The environment is not properly set up. Exiting."
    exit 1    
fi

# Check that the wallpaper file is present.
if ! [ -e $RQPI_DIR/"$WALLPAPER" ]; then
    echo "The chosen wallpaper $WALLPAPER is not present in $RQPI_DIR. Exiting."
    exit 1
fi

# Copy the background image to WP_DIR.
if ! [ -e $WP_DIR/"$WALLPAPER" ]; then
    sudo cp $RQPI_DIR/"$WALLPAPER" $WP_DIR
fi
 
# Ensure CONF_DIR is present.
if ! [ -e $CONF_DIR ]; then
    sudo -u $FIRST_USER mkdir -p $CONF_DIR
fi

echo "Generating config files."

for configfile in "${CONF_FILES[@]}"; do
  if ! [ -e $CONF_DIR/$configfile ]; then
    sudo -u $FIRST_USER touch $CONF_DIR/$configfile
    # There should be a better way of doing this.
    sudo -u $FIRST_USER chmod 606 $CONF_DIR/$configfile
    sudo -u $FIRST_USER cat <<EOF >> $CONF_DIR/$configfile
[*]
wallpaper_mode=fit
wallpaper=$WP_DIR/$WALLPAPER
EOF

    sudo -u $FIRST_USER chmod 644 $CONF_DIR/$configfile

    echo "File $configfile updated."
  else
    echo "File $configfile already exists. Exiting."
    exit -1
  fi
done
