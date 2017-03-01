FROM php:7.1
MAINTAINER Huiren Woo <giantcrabby@gmail.com>
LABEL maintainer="Huiren Woo <giantcrabby@gmail.com>" \
        php="7.1"

RUN DEV_DEPENDENCIES="libcurl4-gnutls-dev \
	    libicu-dev \
	    libmcrypt-dev \
	    libvpx-dev \
	    libjpeg-dev \
	    libpng-dev \
	    libxpm-dev \
	    zlib1g-dev \
	    libfreetype6-dev \
	    libxml2-dev \
	    libexpat1-dev \
	    libbz2-dev \
	    libgmp3-dev \
	    libldap2-dev \
	    unixodbc-dev \
	    libpq-dev \
	    libsqlite3-dev \
	    libaspell-dev \
	    libsnmp-dev \
	    libpcre3-dev \
	    libtidy-dev" \
    && apt-get update && apt-get install -y \
	    git \
	    $DEV_DEPENDENCIES \
    && docker-php-ext-install mbstring mcrypt pdo_mysql curl json intl gd xml zip bz2 opcache \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apt-get purge -y $DEV_DEPENDENCIES \
    && apt-get clean \
    && php -v
    && cd ~ \
    && EXPECTED_SIGNATURE=$(curl -q -sS https://composer.github.io/installer.sig) \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');") \
    && echo $EXPECTED_SIGNATURE \
    && echo $ACTUAL_SIGNATURE \
    && if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then >&2 echo 'ERROR: Invalid installer signature' && rm composer-setup.php && exit 1; fi \
    && php composer-setup.php --quiet \
    && RESULT=$? \
    && rm composer-setup.php \
    && echo "" >> composer.lock \
    && mkdir vendor \
    && exit $RESULT
