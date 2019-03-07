FROM alpine:3.9

MAINTAINER 2stacks <2stacks@2stacks.net>

# Use docker build --pull -t 2stacks/freeradius .

# Image details
LABEL net.2stacks.name="2stacks" \
      net.2stacks.license="MIT" \
      net.2stacks.description="Dockerfile for autobuilds" \
      net.2stacks.url="http://www.2stacks.net" \
      net.2stacks.vcs-type="Git" \
      net.2stacks.version="1.4" \
      net.2stacks.radius.version="3.0.17-r2"

RUN apk --update add freeradius freeradius-mysql

EXPOSE 1812/udp 1813/udp

ENV DB_HOST=localhost
ENV DB_PORT=3306
ENV DB_USER=radius
ENV DB_PASS=radpass
ENV DB_NAME=radius
ENV RADIUS_KEY=testing123
ENV RAD_CLIENTS=10.0.0.0/24
ENV RAD_DEBUG=no

ADD --chown=root:radius ./etc/raddb/ /etc/raddb

ADD ./scripts/start.sh /start.sh

RUN chmod +x /start.sh

CMD ["/start.sh"]
