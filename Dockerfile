FROM freeradius/freeradius-server:latest

# Default environment variables
ENV MYSQL_SERVER db \
    MYSQL_PORT 3306

ENV CA_COUNTRYCODE FI
ENV CA_STATE Uusimaa
ENV CA_CITY Helsinki
ENV CA_ORGANIZATION Example Inc
ENV CA_EMAIL test@example.org
ENV CA_COMMONNAME Example CA
ENV SERVER_COMMONNAME Example Server

ENV SEVER_COUNTRYCODE ${CA_COUNTRYCODE}
ENV SERVER_STATE ${CA_STATE}
ENV SERVER_CITY ${CA_CITY}
ENV SERVER_ORGANIZATION ${CA_ORGANIZATION}
ENV SERVER_EMAIL ${CA_EMAIL}

ENV CA_PASSWORD whatever
ENV SERVER_PASSWORD whatever

# Install some packages
RUN apt-get update && apt-get install -y \
    moreutils \
    gettext-base \
    mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY mods-available/sql /etc/raddb/mods-available
COPY mods-available/eap /etc/raddb/mods-available
COPY sites-available/default /etc/raddb/sites-available
COPY radiusd.conf /etc/raddb

# Fix some file permissions
RUN chmod 640 /etc/raddb/radiusd.conf /etc/raddb/mods-available/sql /etc/raddb/mods-available/eap /etc/raddb/sites-available/default

RUN cd /etc/raddb/mods-enabled/ \
    && ln -s ../mods-available/sql sql

# Copy certificate configurations to server
COPY certs/* /etc/raddb/certs/

RUN chmod 640 /etc/raddb/certs/ca.cnf /etc/raddb/certs/server.cnf

COPY docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["radiusd"]  