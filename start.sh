#!/bin/sh

/usr/local/bin/wait-for-it.sh ${DB_HOST}:${DB_PORT} -s -t 15 -- /usr/sbin/radiusd -f -d /etc/raddb
