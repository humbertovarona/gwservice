FROM debian:bullseye-slim

LABEL maintainer="Humberto L. Varona (humberto.varona@gmail.com)"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nginx nano mc ca-certificates curl gnupg axel wget wget2\
    php-fpm php-mysql php-xml php-cli php-mbstring php-memcache php-zip php-curl \
    php-json php-intl php-gd php-opcache php-bcmath php-soap \
    php-sqlite3 php-pgsql php-fpdf php-mail php-mail-mime php-mailparse \
    mariadb-client postgresql-client postgis git unzip \
    mongoose php-mongodb php-net-smtp php-net-socket php-net-ftp php-net-url && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx /var/www/html

COPY startservices.sh /startservices.sh
RUN chmod +x /startservices.sh
COPY checkservices.sh /checkservices.sh
RUN chmod +x /checkservices.sh


COPY configs/nginx/nginx.conf /etc/nginx/nginx.conf
COPY configs/php/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf

EXPOSE 8083

CMD ["/startservices.sh"]
