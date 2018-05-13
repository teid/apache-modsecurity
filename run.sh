#!/usr/bin/env bash
set -euo pipefail

# Define the env dir (see debian envvars file)
export APACHE_RUN_USER=www-data
export APACHE_RUN_GROUP=www-data
export APACHE_PID_FILE=/run/apache2/apache2.pid
export APACHE_RUN_DIR=/run/apache2
export APACHE_LOCK_DIR=/run/apache2/lock

# Create the lock folder
mkdir -p $APACHE_LOCK_DIR
chown -R $APACHE_RUN_USER:$APACHE_RUN_USER $APACHE_LOCK_DIR

# Create the modsecurity run dir
mkdir -p /run/apache2/modsecurity/data
mkdir -p /run/apache2/modsecurity/tmp
chown -R $APACHE_RUN_USER:$APACHE_RUN_USER /run/apache2/modsecurity


# Start Apache
exec apache2 -DFOREGROUND