#!/bin/sh
if [ "${RAD_DEBUG}" = "yes" ]
  then
    /usr/sbin/radiusd -X -f -d /etc/raddb
  else
    /usr/sbin/radiusd -f -d /etc/raddb
fi
