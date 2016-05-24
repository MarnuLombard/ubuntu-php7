FROM ubuntu:16.04
MAINTAINER Marnu Lombard <marnu@mar.nu>

##### SET ENV VARS
# User
ENV USER_NAME           marnu
ENV USER_PASS           marnu
ENV USER_ID             1000
ENV USER_GROUP_ID       1000

# Apache
ENV APACHE_RUN_USER     www-data
ENV APACHE_RUN_GROUP    www-data

# SSH
ENV SSH_KEY_PATH        ~/.ssh/id_rsa

# Unix
ENV TERM                xterm
##### CONFIGURE SOFTWARE

# Unix Path
RUN echo 'PATH=/usr/local/bin:~.composer/vendor/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'>>.profile;

# Get closest mirror - as per https://repogen.simplylinux.ch/
RUN echo 'deb http://za.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse\n\
deb http://za.archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse\n\
deb http://za.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse\n\
deb http://za.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse\n\
deb http://archive.canonical.com/ubuntu xenial partner' > /etc/apt/sources.list;

# Update
RUN apt-get update -qy \
    && apt-get upgrade -qy;

# Install basics
RUN apt-get install -qy \
    locales ntp ntpdate dialog python-software-properties software-properties-common apt-utils;


# Add the Fish shell ppa
# RUN apt-add-repository ppa:fish-shell/release-2;

# Download everything first
RUN apt-get download -qy \
    apache2 \
    mysql-client mysql-server libmysqlclient-dev \
    libapache2-mod-php7.0 php php-cli php-pear php-gd php-curl php-mysql php-sqlite3 php-imap php-intl php-xdebug php-imagick php7.0-opcache \
    nodejs \
    vim git;

#  Set up basics
RUN locale-gen en_GB en_GB.UTF-8 && dpkg-reconfigure --terse --default-priority locales && update-locale en_GB.UTF-8;
RUN ln -sf /usr/share/zoneinfo/Africa/Johannesburg /etc/localtime;

#### INSTALL SOFTWARE

# Apache
RUN apt-get install -qy apache2;

# Mysql
RUN DEBIAN_FRONTEND=noninteractive apt-get install -qy mysql-client mysql-server libmysqlclient-dev;

# Php 7
RUN apt-get install -qy libapache2-mod-php7.0 php php-cli php-pear php-gd php-curl php-mysql php-sqlite3 php-imap php-intl php-xdebug php-imagick;

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '92102166af5abdb03f49ce52a40591073a7b859a86e8ff13338cf7db58a19f7844fbc0bb79b2773bf30791e935dbd938') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    php composer-setup.php -- --install-dir=/usr/local/bin --filename=composer \
    php -r "unlink('composer-setup.php');";

# Node, NPM, Gulp, Bower
RUN apt-get install -qy nodejs;
RUN apt-get install -qy npm;
RUN npm install -g gulp bower;

# Install important tools
RUN apt-get install -qy fish vim git;

# Clean up
RUN apt-get autoremove -qy; \
    apt-get autoclean -qy;


#### SET UP SYSTEM

# Create a non-root user
RUN apt-get install -qy sudo
ENV TERM xterm-256color
RUN addgroup --gid $USER_GROUP_ID $USER_NAME;
RUN adduser --system --shell $(which fish) --uid $USER_ID --gecos "" --ingroup $USER_NAME --disabled-password $USER_NAME;
RUN echo "$USER_NAME ALL=NOPASSWD: ALL" >> /etc/sudoers

# Open up ports
EXPOSE 3306
EXPOSE 80
EXPOSE 22

# Create volumes
VOLUME /conf
VOLUME /data
VOLUME /var/www

# Script when `docker exec` is called
ENTRYPOINT fish

# Run as new user
USER $USER_NAME
WORKDIR /home/$USER_NAME

CMD ['entrypoint.sh']
