FROM alpine:3.3
MAINTAINER Andrey Arapov <andrey.arapov@nixaid.com>

RUN echo '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    apk update && \
    apk add nginx-naxsi@testing inotify-tools && \
    mkdir /tmp/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY launch /launch
ENTRYPOINT /launch
