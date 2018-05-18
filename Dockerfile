FROM php:7.2-apache-stretch
MAINTAINER Huiren Woo <giantcrabby@gmail.com>
LABEL maintainer="Huiren Woo <giantcrabby@gmail.com>" \
        php="7.2"

# Set Apache work directory
ENV APACHE_DOCUMENT_ROOT /var/www/html
WORKDIR APACHE_DOCUMENT_ROOT

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Install Laravel PHP requirements
RUN BUILD_DEPENDENCIES="autoconf" \
    DEV_DEPENDENCIES="libcurl4-gnutls-dev \
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
    	    libtidy-dev \
    	    openssh-client \
    	    git \
    	    zip \
    	    unzip \
    	    chromedriver" \
    && docker-php-source extract \
    && apt-get update && apt-get install -y \
        $BUILD_DEPENDENCIES \
        $DEV_DEPENDENCIES \
    && docker-php-ext-install mbstring mcrypt pdo_mysql pdo_pgsql curl json intl gd xml zip bz2 opcache bcmath soap tidy ctype \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && php -v

# Install composer
RUN cd ~ \
    && EXPECTED_SIGNATURE=$(curl -q -sS https://composer.github.io/installer.sig) \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');") \
    && if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then >&2 echo 'ERROR: Invalid installer signature' && rm composer-setup.php && exit 1; fi \
    && php composer-setup.php --quiet \
    && RESULT=$? \
    && rm composer-setup.php \
    && echo "" >> composer.lock \
    && mkdir vendor \
    && docker-php-source delete \
    && exit $RESULT
