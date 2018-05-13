#!/usr/bin/env bash
set -euo pipefail

# Create the modsecurity run dir
mkdir -p /run/apache2/modsecurity/data
mkdir -p /run/apache2/modsecurity/tmp
chown -R www-data:www-data /run/apache2/modsecurity

# Start Apache
exec apache2 -DFOREGROUND