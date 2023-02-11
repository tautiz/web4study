FROM php:8.2-apache
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y apt-utils libzip-dev zip unzip git wget zsh curl sudo
RUN docker-php-ext-install mysqli pdo_mysql bcmath
RUN a2enmod rewrite ssl
RUN pecl install xdebug
COPY xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN docker-php-ext-enable xdebug

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN chsh -s $(which zsh)
COPY .zshrc-alias /root/.zshrc-alias
RUN sed -i '$ a\source /root/.zshrc-alias' ~/.zshrc
RUN chsh -s $(which zsh)

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV APACHE_DOCUMENT_ROOT /var/www/html/public_html
ENV APACHE_LOG_DIR /var/logs

RUN echo $APACHE_DOCUMENT_ROOT

COPY apache.conf /etc/apache2/sites-available/000-default.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

WORKDIR /var/www/html
RUN chown www-data:www-data -R .

EXPOSE 80