FROM phusion/baseimage:0.9.16
MAINTAINER g33kidd <hello@g33kidd.com>

RUN apt-get update
RUN apt-get -y upgrade

# Install Basics and WP Requirements
RUN apt-get -y install \
    nginx \
    php5-mysql \
    php-apc \
    curl \
    unzip \
    php5-curl \
    php5-gd \
    php5-intl \
    php-pear \
    php5-imagick \
    php5-imap \
    php5-mcrypt \
    php5-memcache \
    php5-ming \
    php5-ps \
    php5-pspell \
    php5-recode \
    php5-sqlite \
    php5-tidy \
    php5-xmlrpc \
    php5-xsl

# Install Nginx and Configure
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD ./nginx-site.conf /etc/nginx/sites-available/default

# HHVM Installation
RUN curl http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
RUN echo deb http://dl.hhvm.com/ubuntu trusty main | sudo tee /etc/apt/sources.list.d/hhvm.list
RUN apt-get update && apt-get install -y hhvm

# Install and configure WordPress
ADD http://wordpress.org/latest.zip /wordpress.zip
RUN mkdir -p /app && \
    unzip wordpress.zip && \
    mv /wordpress /app && \
    rm -f wordpress.zip

ADD wp-config.php /app/wp-config.php
RUN chown -R www-data:www-data /app
# RUN php -r "define('WP_SITEURL', '"${WP_SITEURL}"'); include '/app/wp-admin/install.php';" \
#     "wp_install('"${WP_SITE}"', 'admin', '"${WP_EMAIL}"', 1, '', '"${DB_PASSWORD}"');"

RUN mkdir /etc/service/nginx
ADD nginx.sh /etc/service/nginx/run

RUN mkdir /etc/service/hhvm
ADD hhvm.sh /etc/service/hhvm/run
RUN sudo /usr/share/hhvm/install_fastcgi.sh

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp
RUN wp --info

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Define mountable directories.
VOLUME ["/app/","/var/log/nginx/"]

# private expose
EXPOSE 80
EXPOSE 443

CMD ["/sbin/my_init"]