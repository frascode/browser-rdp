#!/bin/bash

# Setup default user if specified by environment variables
if [ -n "$DEFAULT_USER" ] && [ -n "$DEFAULT_PASSWORD" ]; then
    /usr/local/bin/create-user.sh "$DEFAULT_USER" "$DEFAULT_PASSWORD"
fi

# Make sure RDP directories exist with proper permissions
mkdir -p /var/run/xrdp
chmod 2775 /var/run/xrdp
mkdir -p /var/run/xrdp/sockdir
chmod 3777 /var/run/xrdp/sockdir

# Make sure DBus directories exist with proper permissions
mkdir -p /var/run/dbus
chown -R messagebus:messagebus /var/run/dbus
mkdir -p /run/dbus
chown -R messagebus:messagebus /run/dbus

# Start supervisord which manages all services
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf