# Description

FreeRADIUS Server.

It depends on a MySQL Server to work and allows you to configure the server connections via environment variables.

## Supported tags
| Tag | Alpine Version | FreeRADIUS Version | Description | Release Date |
| --- | :---: | :---: | --- | :---: |
| [1.2, latest](https://github.com/2stacks/docker-freeradius/blob/master/Dockerfile) | 3.8.2 | 3.0.17-r2 | Latest stable release | 2018-12-23 |
| [1.1](https://github.com/2stacks/docker-freeradius/blob/1.1/Dockerfile) | 3.8.0 | 3.0.17 | Initial stable release | 2018-05-11 | 
| [1.0](https://github.com/2stacks/docker-freeradius/blob/1.0/Dockerfile) | 3.7 | 3.0.15-r3 | Initial release | 2017-10-16 | 


# Build the container

```shell
docker build --pull -t 2stacks/freeradius
```

# Running the container
-   With MySQL
```shell
docker run -d -t --name freeradius -p 1812:1812/udp -p 1813:1813/udp -e DB_HOST=<mysql.server> 2stacks/freeradius
```

-   Without MySQL
```shell
docker run -d -t --name freeradius -p 1812:1812/udp -p 1813:1813/udp \
-v /$PWD/configs/radius/users:/etc/raddb/users 2stacks/freeradius
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

Next an example of a docker-compose.yml file:

```yaml
version: '3.2'

services:
  freeradius:
    image: "2stacks/freeradius"
    #ports:
      #- "1812:1812/udp"
      #- "1813:1813/udp"
    #volumes:
      #- "./configs/radius/users:/etc/raddb/users"
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
    image: "mysql:5.7"
    command: mysqld
    ports:
      - "3306:3306"
    volumes:
      - "./configs/mysql/master/data:/var/lib/mysql"
      - "./configs/mysql/master/conf.d:/etc/mysql/conf.d"
      - "./configs/mysql/radius.sql:/docker-entrypoint-initdb.d/radius.sql"
    environment:
      - MYSQL_ROOT_PASSWORD=radius
      - MYSQL_USER=radius
      - MYSQL_PASSWORD=radpass
      - MYSQL_DATABASE=radius
    restart: always
    networks:
      - backend
        
    radtest:
    image: "2stacks/radtest"
    command: radtest testing password freeradius 0 testing123
    depends_on:
      - freeradius
      - mysql
    networks:
      - backend

networks:
  backend:
    ipam:
      config:
        - subnet: 10.0.0.0/24
```

This compose file can be used from within this code repository by executing;
```
docker-compose -f docker-compose.yml up -d
```

Note: This example binds freeradius with a mysql database. Take note of this repository's conf.d volume, as it contains specific configurations for mysql:

File: configs/mysql/master/conf.d/max_allowed_packet.cnf
```
max_allowed_packet=256M
```
File: configs/mysql/master/conf.d/sql_mode.cnf
```
[mysqld]
sql_mode = STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
```
Note: The mysql docker image, associated schema, volumes and configs are not a part of the 2stacks/freeradius image that can be pulled from docker hub.  See .dockerignore file for the parts of this repository that are excluded from the image.

# Testing Authentication
The freeradius container can be tested against the mysql backend created in the above compose file using a separate container running the radtest client.

```shell
docker run -it --rm --network=dockerfreeradius_backend 2stacks/radtest radtest testing password freeradius 0 testing123

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

A default SQL scheme for FreeRadius on MySQL can be found [here](https://raw.githubusercontent.com/FreeRADIUS/freeradius-server/v3.0.x/raddb/mods-config/sql/main/mysql/schema.sql).

# To Do
This image is known not to work with mysql version 8.x due to a change in the [Preferred Authentication Plugin](https://dev.mysql.com/doc/refman/8.0/en/caching-sha2-pluggable-authentication.html) from previous versions.
