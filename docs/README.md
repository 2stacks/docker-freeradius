# FreeRADIUS Docker Container

This repository builds a FreeRADIUS Docker container using Alpine Linux.  It requires a MySQL database and can be configured with environment variables.

[![Build Status](https://travis-ci.org/2stacks/docker-freeradius.svg?branch=master)](https://travis-ci.org/2stacks/docker-freeradius)
[![Docker Stars](https://img.shields.io/docker/stars/2stacks/freeradius.svg?style=popout-square)](https://hub.docker.com/r/2stacks/freeradius)
[![Docker Pulls](https://img.shields.io/docker/pulls/2stacks/freeradius.svg?style=popout-square)](https://hub.docker.com/r/2stacks/freeradius)
[![Build Details](https://images.microbadger.com/badges/image/2stacks/freeradius.svg)](https://microbadger.com/images/2stacks/freeradius)

## Supported tags
| Tag | Alpine Version | FreeRADIUS Version | Release Date | Changes |
| --- | :---: | :---: | :---: | :---: |
| [1.5.1, latest](https://github.com/2stacks/docker-freeradius/blob/master/Dockerfile) | 3.11.0 | 3.0.20-r1 | 2019-12-23 | [Changelog](https://github.com/2stacks/docker-freeradius/compare/v1.5.0...master) |
| [1.5.0](https://github.com/2stacks/docker-freeradius/blob/v1.5.0/Dockerfile) | 3.10.3 | 3.0.19-r3 | 2019-11-14 | [Changelog](https://github.com/2stacks/docker-freeradius/compare/v1.4.3...v1.5.0) |
| [1.4.3](https://github.com/2stacks/docker-freeradius/blob/v1.4.3/Dockerfile) | 3.9.4 | 3.0.17-r5 | 2019-06-14 | [Changelog](https://github.com/2stacks/docker-freeradius/compare/v1.4.2...v1.4.3) |
| [1.4.2](https://github.com/2stacks/docker-freeradius/blob/v1.4.2/Dockerfile) | 3.9.3 | 3.0.17-r4 | 2019-04-12 | [Changelog](https://github.com/2stacks/docker-freeradius/compare/v1.4.1...v1.4.2) |

# Running the container
-   With MySQL
```bash
$ docker run -d -t --name freeradius -p 1812:1812/udp -p 1813:1813/udp -e DB_HOST=<mysql.server> 2stacks/freeradius
```

# Environment Variables

-   DB_HOST=localhost
-   DB_PORT=3306
-   DB_USER=radius
-   DB_PASS=radpass
-   DB_NAME=radius
-   RADIUS_KEY=testing123
-   RAD_CLIENTS=10.0.0.0/24
-   RAD_DEBUG=no

# Docker Compose Example

You can use the included docker-compose.yml file to test Freeradius and MySQL integration:

```yaml
version: '3.2'

services:
  freeradius:
    image: "2stacks/freeradius"
    ports:
      - "1812:1812/udp"
      - "1813:1813/udp"
    #volumes:
      #- "./configs/radius/users:/etc/raddb/users"
      #- "./configs/radius/clients.conf:/etc/raddb/clients.conf"
    environment:
      #- DB_NAME=radius
      - DB_HOST=mysql
      #- DB_USER=radius
      #- DB_PASS=radpass
      #- DB_PORT=3306
      #- RADIUS_KEY=testing123
      #- RAD_CLIENTS=10.0.0.0/24
      - RAD_DEBUG=yes
    depends_on:
      - mysql
    links:
      - mysql
    restart: always
    networks:
      - backend

  mysql:
    image: "mysql"
    command: --default-authentication-plugin=mysql_native_password
    ports:
      - "3306:3306"
    volumes:
      - "./configs/mysql/master/data:/var/lib/mysql"
      #- "./configs/mysql/master/conf.d:/etc/mysql/conf.d"
      - "./configs/mysql/radius.sql:/docker-entrypoint-initdb.d/radius.sql"
    environment:
      - MYSQL_ROOT_PASSWORD=radius
      - MYSQL_USER=radius
      - MYSQL_PASSWORD=radpass
      - MYSQL_DATABASE=radius
    restart: always
    networks:
      - backend

networks:
  backend:
    ipam:
      config:
        - subnet: 10.0.0.0/24
```

This compose file can be used from within this code repository by executing;
```bash
$ docker-compose up -d
```

Note: The example above binds freeradius with a mysql database.  The mysql docker image, associated schema, volumes and configs are not a part of the 2stacks/freeradius image that can be pulled from docker hub.  See .dockerignore file for the parts of this repository that are excluded from the image.

# Testing Authentication
The freeradius container can be tested against the mysql backend created in the above compose file using a separate container running the radtest client.

```bash
$ docker run -it --rm --network docker-freeradius_backend 2stacks/radtest radtest testing password freeradius 0 testing123

Sent Access-Request Id 42 from 0.0.0.0:48898 to 10.0.0.3:1812 length 77
        User-Name = "testing"
        User-Password = "password"
        NAS-IP-Address = 10.0.0.4
        NAS-Port = 0
        Message-Authenticator = 0x00
        Cleartext-Password = "password"
Received Access-Accept Id 42 from 10.0.0.3:1812 to 0.0.0.0:0 length 20
```

Note: The username and password used in the radtest example above are pre-loaded in the mysql database by the radius.sql schema included in this repository.  The preconfigured mysql database is for validating freeradius functionality only and not intended for production use.

A default SQL schema for FreeRadius on MySQL can be found [here](https://github.com/FreeRADIUS/freeradius-server/blob/master/raddb/mods-config/sql/main/mysql/schema.sql).

# Build the container
If you would like to make modifications or customizations, clone this repository, make your changes and then run the following from the root of the repository.

```bash
$ docker build --pull -t <docker_hub_account>/freeradius .
```

Note: Some users have reported broken symlinks when building the container.  Check that you have the default servers enabled via symlinks in the repository's `./etc/raddb/sites-enabled` directory.  If there are no symlinks in this directory you can create them with;

```bash
cd docker-freeradius/etc/raddb/sites-enabled
ln -s ../sites-available/default default
ln -s ../sites-available/inner-tunnel inner-tunnel
``` 

See [this thread](https://github.com/2stacks/docker-freeradius/issues/3) for additional information.

# Certificates
The container has a set of test certificates that are generated each time the container is built using the included Dockerfile.  These certificates are configured with the default settings from the Freeradius package and are set to expire after sixty days.
These certificates are not meant to be used in production and should be recreated/replaced as needed.  Follow the steps below to generate new certificates.  It is important that you read and understand the instructions in '/etc/raddb/certs/README'
  
#### Generate new certs
From your docker host machine

  - Clone the git repository
```bash
$ git clone https://github.com/2stacks/docker-freeradius.git
```
  - Make changes to the .cnf files in /etc/raddb/certs as needed. (Optional)
  - Run the container
```bash
$ docker run -it --rm -v $PWD/etc/raddb:/etc/raddb 2stacks/freeradius:latest sh
```

From inside the container
```bash
/ # cd /etc/raddb/certs/
/ # rm -f *.pem *.der *.csr *.crt *.key *.p12 serial* index.txt*
/ # ./bootstrap
/ # chown -R root:radius /etc/raddb/certs
/ # chmod 640 /etc/raddb/certs/*.pem
/ # exit
```

You can bind mount these certificates back in to the container or rebuild the container as mentioned above.
You'll have to change the permissions to your local user before rebuilding the container.
```bash
$ sudo chown -R $USER:$USER etc/raddb/certs
```
