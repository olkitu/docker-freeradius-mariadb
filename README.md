# Docker Freeradius MySQL

Freeradius with MySQL

## Deploy

Deploy to Docker Swarm. You can optionally also use external MySQL-server.

```yml
version: '3.7'
services:
  freeradius:
    image: ghcr.io/olkitu/docker-freeradius-mysql:main
      replicas: 1
      update_config:
        delay: 10s
        failure_action: pause
        monitor: 1m
        order: start-first
      restart_policy:
        condition: on-failure
    ports:
    - 1812:1812
    - 1813:1813
    environment:
      MYSQL_DATABASE: radius
      MYSQL_USER: radius
      MYSQL_PASSWORD: radius
  db:
    image: mysql
    volumes:
    - freeradiusdb:/var/lib/mysql
    environment:
      # Database details
      MYSQL_SERVER: db
      MYSQL_DATABASE: radius
      MYSQL_USER: radius
      MYSQL_PASSWORD: radius
      # CA Certificate
      CA_COUNTRYCODE: FI
      CA_STATE: Uusimaa
      CA_CITY: Helsinki
      CA_ORGANIZATION: Example Inc
      CA_EMAIL: test@example.org
      CA_COMMONNAME: Example CA
      # Server Certificate
      SEVER_COUNTRYCODE: ${CA_COUNTRYCODE}
      SERVER_STATE: ${CA_STATE}
      SERVER_CITY: ${CA_CITY}
      SERVER_ORGANIZATION: ${CA_ORGANIZATION}
      SERVER_EMAIL: ${CA_EMAIL}
      SERVER_COMMONNAME: radius-wifi.example.org
      # Passwords for Certs
      CA_PASSWORD: whatever
      SERVER_PASSWORD: whatever

volumes:
  freeradiusdb:
```

Import database schema to MySQL-server.

## Add Host

Add to MySQL database in radius table NAS-host. Change IP-address to host and generate secret.

```sql
INSERT INTO nas (nasname, secret) VALUES ('127.0.0.1', 'secret');
```

## Add User

Add user to radcheck table. Replace username `testuser` and password `testpassword` to own.

```sql
INSERT INTO radcheck (username,attribute,op,value) VALUES ('testuser','Cleartext-Password',':=','testpassword')
```