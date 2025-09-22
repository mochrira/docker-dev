FROM php:fpm-alpine3.21

RUN apk update \
    && apk add --no-cache nodejs npm zip sudo apache2 apache2-proxy apache2-ssl supervisor icu-dev libzip-dev libpng-dev busybox-suid git shadow linux-headers \
    && docker-php-ext-install mysqli pdo pdo_mysql intl gd zip sockets pcntl

RUN addgroup -g 1000 devuser && adduser -G devuser -u 1000 -D devuser \
    && mkdir -p /etc/sudoers.d \
    && echo "devuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/devuser \
    && chmod 0440 /etc/sudoers.d/devuser

RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && apk add imagemagick imagemagick-dev libgomp jpeg-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && rm -rf /tmp/pear \
    && apk del .build-deps

RUN cd /tmp && apk add --no-cache coreutils \
    && wget https://github.com/composer/composer/releases/download/2.8.8/composer.phar -O ./composer.phar \
    && echo "fb2bdaa0b59572c8b07b3b4d64af72bf223beaf62b4a8ffdfe5c863d28fdd08a0e2c006db19e0fb988b4f05be4a61e56 /tmp/composer.phar" | sha384sum -c \
    && mv ./composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer

RUN sed -i "s/user = www-data/user = devuser/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i "s/group = www-data/group = devuser/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/;pidfile/pidfile/g' /etc/supervisord.conf \
    && sed -i 's/;user=chrism/user=root/g' /etc/supervisord.conf \
    && mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && rm -f /var/log/apache2/error.log \
    && rm -f /var/log/apache2/access.log \
    && ln -s /dev/stdout /var/log/apache2/access.log \
    && ln -s /dev/stderr /var/log/apache2/error.log

RUN cd /tmp && wget https://github.com/jvoisin/snuffleupagus/archive/refs/tags/v0.11.0.zip -O snuffleupagus.zip \
    && echo "ea9b6d5c662a89902cc078df467ea287243da6c49044da378691975bad77a7d420952caaee15c8877bc63d8eface3254 /tmp/snuffleupagus.zip" | sha384sum -c \
    && unzip -d /tmp /tmp/snuffleupagus.zip \
    && rm /tmp/snuffleupagus.zip \
    && docker-php-ext-configure /tmp/snuffleupagus-0.11.0/src --enable-snuffleupagus \
    && docker-php-ext-install /tmp/snuffleupagus-0.11.0/src \
    && rm -r /tmp/snuffleupagus-0.11.0 \
    && rm -r /var/cache/apk/* \
    && mkdir -p /usr/local/etc/snuffleupagus

RUN rm /etc/apache2/conf.d/ssl.conf

COPY httpd.conf /etc/apache2/httpd.conf
COPY supervisor.ini /etc/supervisor.d/default.ini
COPY snuffleupagus.ini /usr/local/etc/php/conf.d/docker-php-ext-snuffleupagus.ini
COPY entrypoint.sh /entrypoint.sh

USER devuser
WORKDIR /workspace
ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]