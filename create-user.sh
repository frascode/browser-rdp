#!/bin/bash

# Check if arguments are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

USERNAME=$1
PASSWORD=$2

# Create user if it doesn't exist
if ! id "$USERNAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    usermod -aG sudo "$USERNAME"
    
    # Copy Openbox configuration if it doesn't exist
    if [ ! -d "/home/$USERNAME/.config/openbox" ]; then
        mkdir -p "/home/$USERNAME/.config/openbox"
        cp /etc/skel/.config/openbox/autostart "/home/$USERNAME/.config/openbox/"
        chmod +x "/home/$USERNAME/.config/openbox/autostart"
        chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.config"
    fi
    
    # Create the Epiphany profile directory
    mkdir -p "/tmp/epiphany-profile-$USERNAME"
    chown "$USERNAME:$USERNAME" "/tmp/epiphany-profile-$USERNAME"
    
    echo "User $USERNAME created successfully."
else
    echo "User $USERNAME already exists."
    
    # Make sure Openbox configuration exists
    if [ ! -d "/home/$USERNAME/.config/openbox" ]; then
        mkdir -p "/home/$USERNAME/.config/openbox"
        cp /etc/skel/.config/openbox/autostart "/home/$USERNAME/.config/openbox/"
        chmod +x "/home/$USERNAME/.config/openbox/autostart"
        chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.config"
    fi
    
    # Make sure Epiphany profile directory exists
    mkdir -p "/tmp/epiphany-profile-$USERNAME"
    chown "$USERNAME:$USERNAME" "/tmp/epiphany-profile-$USERNAME"
fi