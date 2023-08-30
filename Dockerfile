FROM debian:bookworm-slim
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends -y upgrade  && \
    DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
    ca-certificates curl git unzip wget zip \
    php8.2-fpm php8.2-cli php8.2-mysql php8.2-mbstring \
    php8.2-xml php8.2-curl php8.2-zip php8.2-gd php8.2-intl \
    php8.2-bcmath php8.2-igbinary php8.2-imagick php8.2-int php8.2-msgpack php8.2-opcache \
    php8.2-readline php8.2-soap php8.2-sqlite3 php8.2-ssh2 php8.2-xml php8.2-xmlrpc php8.2-yaml \
    php8.2-zmq php8.2-uuid  php8.2-apcu && rm -rf /var/lib/apt/lists/* \

RUN rm /etc/php/8.2/fpm/pool.d/www.conf && \
    {  \
        echo '[global]'; \
        echo 'error_log = /proc/self/fd/2'; \
        echo 'log_limit = 8192'; \
        echo 'daemonize = no'; \
        echo; \
        echo '[www]'; \
        echo '; php-fpm closes STDOUT on startup, so sending logs to /proc/self/fd/1 does not work.'; \
        echo '; https://bugs.php.net/bug.php?id=73886'; \
        echo 'access.log = /proc/self/fd/2'; \
        echo; \
        echo 'clear_env = no'; \
        echo; \
        echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
        echo 'catch_workers_output = yes'; \
        echo 'decorate_workers_output = no'; \
        echo 'listen = 127.0.0.1:9001'; \
        echo 'listen.allowed_clients = 127.0.0.1'; \
        echo; \
        echo 'pm = dynamic'; \
        echo 'pm.max_children = 10'; \
        echo 'pm.start_servers = 3'; \
        echo 'pm.min_spare_servers = 1'; \
        echo 'pm.max_spare_servers = 3'; \
        echo; \
        echo 'user = www-data'; \
        echo 'group = www-data'; \
    } | tee /etc/php/8.2/fpm/pool.d/www.conf

STOPSIGNAL SIGQUIT

EXPOSE 9001/tcp

CMD ["/usr/sbin/php-fpm8.2"]
