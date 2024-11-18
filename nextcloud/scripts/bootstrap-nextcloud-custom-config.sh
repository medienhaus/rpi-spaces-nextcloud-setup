#!/bin/bash

# -- bootstrap nextcloud custom config -----------------------------------------

if ! [[ -r "/var/www/html/config/custom.config.php" ]]; then
  chown www-data:www-data /opt/custom.config.php
  ln -s /opt/custom.config.php /var/www/html/config/custom.config.php
fi
