FROM alpine:latest
MAINTAINER guillaumearnould
LABEL Description="Image based on Alpine with Nginx and Php7"

# Install packages
RUN apk upgrade -U && \
    apk --update add php7 php7-fpm php7-json php7-curl php7-pdo php7-mbstring php7-openssl php7-zip php7-gd php7-phar php7-dom php7-pgsql php7-pdo_pgsql php7-zlib php7-ctype nginx supervisor --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ && \
    apk --update add curl --repository http://dl-cdn.alpinelinux.org/alpine/edge/main/

# Symlink for PHP
RUN ln -s /etc/php7 /etc/php && \
    ln -s /usr/bin/php7 /usr/bin/php && \
    ln -s /usr/lib/php7 /usr/lib/php

# Download and Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/zzz_custom.conf
COPY config/php.ini /etc/php7/conf.d/zzz_custom.ini
COPY config/opcache-recommended.ini /etc/php7/conf.d/opcache-recommended.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Get OctoberCMS
VOLUME /var/www/html
COPY october_config/*.php /october_install_temp/
RUN mkdir /october_install && cd /october_install && \
    curl -s https://octobercms.com/api/installer | php && \
    cp /october_install_temp/* /october_install/config

# Resolve problems lol
RUN rm /etc/nginx/conf.d/default.conf && \
    adduser -H -D www && \
    chown -R www:www /var/www/html && \
    chmod -R 777 /var/www/html

# Clean packages
RUN apk del curl && \
    rm -f /var/cache/apk/*

# Entrypoint > Install and Configure October
COPY config/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh

EXPOSE 80 443
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]



