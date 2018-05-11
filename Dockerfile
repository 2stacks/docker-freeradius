FROM alpine

MAINTAINER 2stacks <2stacks@2stacks.net>

# Use docker build --pull --build-arg BUILD_DATE='date' -t 2stacks/freeradius .
ARG BUILD_DATE

# Image details
LABEL net.2stacks.build-date="$BUILD_DATE" \
      net.2stacks.name="2stacks" \
      net.2stacks.license="MIT" \
      net.2stacks.description="Dockerfile for autobuilds" \
      net.2stacks.url="http://www.2stacks.net" \
      net.2stacks.vcs-type="Git" \
      net.2stacks.version="1.1"

RUN apk --update add freeradius freeradius-mysql freeradius-eap bash

ADD ./etc/raddb/ /etc/raddb

EXPOSE 1812/udp 1813/udp

ENV DB_HOST=localhost
ENV DB_PORT=3306
ENV DB_USER=radius
ENV DB_PASS=radpass
ENV DB_NAME=radius
ENV RADIUS_KEY=testing123
ENV RAD_CLIENTS=10.0.0.0/22
ENV RAD_DEBUG=no

ADD ./wait-for-it/wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/wait-for-it.sh
ADD ./start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
