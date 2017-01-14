#!/bin/sh

if ! [ -e /var/www/html/index.php ]; then
    echo >&2 "October is not installed, launching installation"
    cd /october_install && composer create-project october/october /var/www/html/ dev-master
    cp /october_install/config/* /var/www/html/config/
    cd /var/www/html && php artisan october:up
    composer update && php artisan october:update
    chmod -R 777 /var/www/html
else
    echo >&2 "October is installed, nothing to do, enjoy !!"
fi

exec "$@"