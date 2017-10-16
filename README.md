# Description

FreerRADIUS Server.

It depends on a MySQL Server to work and allows to configure those server connections via environment variables. See below. 

# Running the container

```
docker run -d -t freeradius -p 1812/udp:1812/sdp -p 1813/udp:1813/udp -e DB_HOST=mysql.server 2stacks/freeradius
```

# Environment Variables

- DB_HOST=localhost
- DB_PORT=3306
- DB_USER=radius
- DB_PASS=radpass
- DB_NAME=radius
- RADIUS_KEY=testing123
- RAD_DEBUG=no

# Docker Compose Example

Next an example of a docker-compose.yml file:

```
version: '3.2'

services:
freeradius:
    image: "2stacks/freeradius:latest"
    #ports:
      #- "1812:1812/udp"
      #- "1813:1813/udp"
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
      #- RAD_CLIENTS=10.0.0.0/22
      - RAD_DEBUG=yes
    depends_on:
      - mysql
    links:
      - mysql
    restart: always
    networks:
      - backend

  mysql:
    image: mysql
    command: mysqld --server-id=1
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

networks:
  backend:
    ipam:
      config:
        - subnet: 10.0.0.0/24

```

Note: This example binds freeradius with a mysql database. Take note of conf.d dir volume, as it contains specific configuration from mysql:

File: conf.d/max_allowed_packer.cnf
```
max_allowed_packet=256M
```

An SQL scheme for FreeRadius on MySQL can be found here: https://raw.githubusercontent.com/FreeRADIUS/freeradius-server/v3.0.x/raddb/mods-config/sql/main/mysql/schema.sql
