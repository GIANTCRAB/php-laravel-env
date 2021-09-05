FROM php:8.0-apache-bullseye
MAINTAINER Huiren Woo <giantcrabby@gmail.com>
LABEL maintainer="Huiren Woo <giantcrabby@gmail.com>" \
        php="8.0"

# Set Apache work directory
ENV APACHE_DOCUMENT_ROOT /var/www/html
WORKDIR APACHE_DOCUMENT_ROOT

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Install Laravel PHP requirements
RUN BUILD_DEPENDENCIES="autoconf" \
    DEV_DEPENDENCIES="libcurl4-gnutls-dev \
            libzip-dev \
     	    libicu-dev \
     	    libreadline-dev \
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
    	    libtidy-dev \
    	    openssh-client \
    	    iputils-ping \
    	    git \
    	    zip \
    	    unzip \
    	    chromedriver" \
    && docker-php-source extract \
    && apt-get update && apt-get install -y \
        $BUILD_DEPENDENCIES \
        $DEV_DEPENDENCIES \
    && docker-php-ext-install mbstring pdo_mysql pdo_pgsql curl json intl exif gd xml zip bz2 opcache bcmath soap tidy ctype \
    && pecl install xdebug-3.0.4 \
    && pecl install redis-5.3.4 \
    && docker-php-ext-enable xdebug redis \
    && php -v \
    && ping -c 3 localhost

# Install composer
RUN cd ~ \
    && EXPECTED_SIGNATURE=$(curl -q -sS https://composer.github.io/installer.sig) \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');") \
    && if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then >&2 echo 'ERROR: Invalid installer signature' && rm composer-setup.php && exit 1; fi \
    && php composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer \
    && RESULT=$? \
    && composer --version \
    && rm composer-setup.php \
    && echo "" >> composer.lock \
    && mkdir vendor \
    && docker-php-source delete \
    && exit $RESULT
