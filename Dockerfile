# syntax=docker/dockerfile:1
FROM --platform=$BUILDPLATFORM golang:alpine AS build
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM" > /log

FROM php:8.2-apache

# Create a user with the same UID and GID as the web user in docker-compose.yml
RUN addgroup --gid 1000 web && \
    adduser --uid 1000 --gid 1000 --disabled-password --gecos '' web

# Install dependencies
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y apt-utils libzip-dev zip unzip git wget zsh curl sudo
RUN docker-php-ext-install mysqli pdo_mysql bcmath
RUN a2enmod rewrite ssl

# Install Xdebug
RUN pecl install xdebug
COPY xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN docker-php-ext-enable xdebug

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN chsh -s $(which zsh)
COPY .zshrc-alias /root/.zshrc-alias
RUN sed -i '$ a\source /root/.zshrc-alias' ~/.zshrc

ENV APACHE_DOCUMENT_ROOT /var/www/html/public_html
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_RUN_USER web
ENV APACHE_RUN_GROUP web

COPY apache.conf /etc/apache2/sites-available/000-default.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

WORKDIR /var/www/html
RUN chown web:web -R .

EXPOSE 80