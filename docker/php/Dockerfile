FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo_mysql mbstring

RUN pecl install redis && docker-php-ext-enable redis

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

RUN echo "[www]" > /usr/local/etc/php-fpm.d/zz-optimizations.conf && \
    echo "pm = static" >> /usr/local/etc/php-fpm.d/zz-optimizations.conf && \
    echo "pm.max_children = 20" >> /usr/local/etc/php-fpm.d/zz-optimizations.conf && \
    echo "pm.start_servers = 5" >> /usr/local/etc/php-fpm.d/zz-optimizations.conf && \
    echo "pm.max_spare_servers = 10" >> /usr/local/etc/php-fpm.d/zz-optimizations.conf

RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.max_accelerated_files=20000" >> /usr/local/etc/php/conf.d/opcache.ini

CMD ["php-fpm"]
