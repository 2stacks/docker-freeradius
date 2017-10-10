FROM alpine

MAINTAINER 2stacks <2stacks@2stacks.net>

RUN apk --update add freeradius freeradius-mysql bash

ADD ./etc/raddb/ /etc/raddb

EXPOSE 1812/udp 1813/udp

ENV DB_HOST=localhost
ENV DB_PORT=3306
ENV DB_USER=radius
ENV DB_PASS=radpass
ENV DB_NAME=radius
ENV RADIUS_KEY=testing123
ENV RAD_CLIENTS=10.0.0.0/22

ADD ./wait-for-it/wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/wait-for-it.sh
ADD ./start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
