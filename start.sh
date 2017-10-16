#!/bin/sh
if [ "${RAD_DEBUG}" = "yes" ]
  then
    /usr/local/bin/wait-for-it.sh ${DB_HOST}:${DB_PORT} -s -t 15 -- /usr/sbin/radiusd -X -f -d /etc/raddb
  else
    /usr/local/bin/wait-for-it.sh ${DB_HOST}:${DB_PORT} -s -t 15 -- /usr/sbin/radiusd -f -d /etc/raddb
fi
