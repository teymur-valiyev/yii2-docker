FROM php:5.6-fpm

RUN apt-get update && \
    apt-get -y install \
        gnupg2 && \
    apt-key update && \
    apt-get update && \
    apt-get -y install \
            g++ \
            git \
            curl \
            imagemagick \
            libfreetype6-dev \
            libcurl3-dev \
            libicu-dev \
            libmcrypt-dev \
            libfreetype6-dev \
            libjpeg-dev \
            libjpeg62-turbo-dev \
            libmagickwand-dev \
            libmcrypt-dev \
            libpq-dev \
            libpng-dev \
            libxml2-dev \
            zlib1g-dev \
            mysql-client \
            openssh-client \
            nano \
            unzip \
        --no-install-recommends && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install PHP extensions required for Yii 2.0 Framework
RUN docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-configure bcmath && \
    docker-php-ext-install \
        soap \
        zip \
        curl \
        bcmath \
        exif \
        gd \
        iconv \
        intl \
        mbstring \
        opcache \
        pdo_mysql \
        pdo_pgsql

# Install PECL extensions
RUN printf "\n" | pecl install \
        imagick \
        mcrypt-1.0.0 && \
    docker-php-ext-enable \
        imagick

RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && chmod a+x /usr/local/bin/composer
RUN composer global require --prefer-dist "fxp/composer-asset-plugin:~1.1.3"

    RUN mkdir -p /opt/icu/icudt52l/ \
    && curl http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/2015e/44/le/metaZones.res > /opt/icu/icudt52l/metaZones.res \
    && curl http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/2015e/44/le/timezoneTypes.res > /opt/icu/icudt52l/timezoneTypes.res \
    && curl http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/2015e/44/le/windowsZones.res > /opt/icu/icudt52l/windowsZones.res \
    && curl http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/2015e/44/le/zoneinfo64.res > /opt/icu/icudt52l/zoneinfo64.res

RUN mkdir -p /var/log/php-fpm
RUN ln -sf /dev/stdout /var/log/php-fpm/access.log
RUN ln -sf /dev/stderr /var/log/php-fpm/error.log

# Install the 2.4 version of xdebug that's compatible with php7
RUN pecl install -o -f xdebug-2.4.0

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENV YII_ROOT /var/www/yii

COPY etc/php-fpm.ini /usr/local/etc/php/conf.d/yii-website.ini
COPY etc/php-xdebug.ini /usr/local/etc/php/conf.d/yii-xdebug-settings.ini
COPY etc/php-mail.ini /usr/local/etc/php/conf.d/yii-mail.ini
COPY etc/php-fpm.conf /usr/local/etc/
COPY etc/auth.json /root/.composer/auth.json

RUN chsh -s /bin/bash www-data
RUN chown -R www-data:www-data /var/www

WORKDIR /var/www

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN ["chmod", "+x", "/docker-entrypoint.sh"]

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["php-fpm", "-F"]