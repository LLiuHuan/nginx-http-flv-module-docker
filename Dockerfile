ARG NGINX_VERSION=1.21.6
ARG NGINX_HTTP_FLV_MODULE=1.2.10

###################################################
# Build this NGINX-build image.
FROM alpine:3.15.3 as build-nginx
ARG NGINX_VERSION
ARG NGINX_HTTP_FLV_MODULE

WORKDIR /tmp

# Get nginx and Get nginx-http-flv-module
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories\
	&& apk add --no-cache g++ pcre-dev zlib-dev make openssl openssl-dev\
  && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz\
  && tar -zxvf nginx-${NGINX_VERSION}.tar.gz\
  && rm nginx-${NGINX_VERSION}.tar.gz\
  && wget https://github.com/winshining/nginx-http-flv-module/archive/refs/tags/v${NGINX_HTTP_FLV_MODULE}.tar.gz\
  && tar -zxvf v${NGINX_HTTP_FLV_MODULE}.tar.gz\
  && rm v${NGINX_HTTP_FLV_MODULE}.tar.gz

WORKDIR /tmp/nginx-${NGINX_VERSION}

RUN \
  ./configure \
  --prefix=/usr/local/nginx \
  --add-module=/tmp/nginx-http-flv-module-${NGINX_HTTP_FLV_MODULE} \
  --conf-path=/etc/nginx/nginx.conf \
  --with-threads \
  --with-http_ssl_module \
  --with-debug \
  --with-http_stub_status_module \
  --with-cc-opt="-Wimplicit-fallthrough=0" && \
  make && \
  make install

#######################################
# Build the release image.
FROM alpine:3.15.3

ENV HTTP_PORT 80
# ENV HTTPS_PORT 443
ENV RTMP_PORT 1935
ENV HTTP_FLV_MODULE 9000

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories\
	&& apk add --no-cache pcre-dev zlib-dev openssl openssl-dev gettext

COPY --from=build-nginx /usr/local/nginx /usr/local/nginx
COPY --from=build-nginx /etc/nginx /etc/nginx

# Add NGINX path, config and static files.
ENV PATH "${PATH}:/usr/local/nginx/sbin"
COPY nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /opt/data && mkdir /www
# COPY static /www/static

EXPOSE 9000
EXPOSE 1935
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]