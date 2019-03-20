#!/bin/sh
if [ "${RAD_DEBUG}" = "yes" ]
  then
    /wait-for.sh ${DB_HOST}:${DB_PORT} -t 15 -- /usr/sbin/radiusd -X -f -d /etc/raddb
  else
    /wait-for.sh ${DB_HOST}:${DB_PORT} -t 15 -- /usr/sbin/radiusd -f -d /etc/raddb
fi
