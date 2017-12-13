#!/bin/bash

[ "$DEBUG" = "true" ] && set -x

# Ensure our YII directory exists
mkdir -p $YII_ROOT
chown www-data:www-data $YII_ROOT

if [ -n "$HOST_UID" ] && [ "$HOST_UID" -ne $(id -u www-data) ]; then usermod -u $HOST_UID www-data ; fi
if [ -n "$HOST_GID" ] && [ "$HOST_GID" -ne $(id -g www-data) ]; then groupmod -g $HOST_GID www-data ; fi
if [ -n  "$(find /var/www/yii -maxdepth 0 -empty )" ]; then # change /var/www/yii - to YII_ROOT
    echo "Create Yii Project ..."
    su www-data -c "composer create-project yiisoft/yii2-app-advanced yii"
fi

# Configure Sendmail if required
if [ "$ENABLE_SENDMAIL" == "true" ]; then
    /etc/init.d/sendmail start
fi

# Substitute in php.ini values
[ ! -z "${PHP_MEMORY_LIMIT}" ] && sed -i "s/!PHP_MEMORY_LIMIT!/${PHP_MEMORY_LIMIT}/" /usr/local/etc/php/conf.d/yii-phpfpm.ini
[ ! -z "${UPLOAD_MAX_FILESIZE}" ] && sed -i "s/!UPLOAD_MAX_FILESIZE!/${UPLOAD_MAX_FILESIZE}/" /usr/local/etc/php/conf.d/yii-phpfpm.ini

[ ! -z "${XDEBUG_REMOTE_HOST}" ] && sed -i "s/!XDEBUG_REMOTE_HOST!/${XDEBUG_REMOTE_HOST}/" /usr/local/etc/php/conf.d/yii-xdebug-settings.ini
[ ! -z "${XDEBUG_IDEKEY}" ] && sed -i "s/!XDEBUG_IDEKEY!/${XDEBUG_IDEKEY}/" /usr/local/etc/php/conf.d/yii-xdebug-settings.ini

[ "$PHP_ENABLE_XDEBUG" = "true" ] && \
    docker-php-ext-enable xdebug && \
    echo "Xdebug is enabled"

exec "$@"