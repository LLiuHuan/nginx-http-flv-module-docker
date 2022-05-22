ARG NGINX_VERSION=1.21.6
ARG NGINX_HTTP_FLV_MODULE=1.2.10
ARG HTTP_PORT=80
ARG HTTPS_PORT=443
ARG RTMP_PORT=1935
ARG HTTP_FLV_MODULE=9000

###################################################
# Base Image
FROM alpine:latest as base-image

# Bake dependencies
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories\
	&& apk add --no-cache g++ pcre-dev zlib-dev make openssl openssl-dev

###################################################
# Build Stage
FROM base-image
ARG NGINX_VERSION
ARG NGINX_HTTP_FLV_MODULE

WORKDIR /workspace

# Get nginx and nginx-http-flv module
RUN wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar -zxvf nginx-${NGINX_VERSION}.tar.gz \
  && rm nginx-${NGINX_VERSION}.tar.gz \
  && wget https://github.com/winshining/nginx-http-flv-module/archive/refs/tags/v${NGINX_HTTP_FLV_MODULE}.tar.gz \
  && tar -zxvf v${NGINX_HTTP_FLV_MODULE}.tar.gz \
  && rm v${NGINX_HTTP_FLV_MODULE}.tar.gz

WORKDIR /workspace/nginx-${NGINX_VERSION}

# Build from source
RUN \
  ./configure \
  --prefix=/usr/local/nginx \
  --add-module=/workspace/nginx-http-flv-module-${NGINX_HTTP_FLV_MODULE} \
  --conf-path=/etc/nginx/nginx.conf \
  --with-threads \
  --with-http_ssl_module \
  --with-debug \
  --with-http_stub_status_module \
  --with-cc-opt="-Wimplicit-fallthrough=0" && \
  make && \
  make install

#######################################
# Production Stage
FROM base-image

ARG HTTP_PORT
ARG HTTPS_PORT
ARG RTMP_PORT
ARG HTTP_FLV_MODULE

ENV HTTP_PORT ${HTTP_PORT}}
# ENV HTTPS_PORT ${HTTPS_PORT}
ENV RTMP_PORT ${RTMP_PORT}}
ENV HTTP_FLV_MODULE ${HTTP_FLV_MODULE}}

COPY --from=build-stage /usr/local/nginx /usr/local/nginx
COPY --from=build-stage /etc/nginx /etc/nginx

# Add NGINX path, config and static files.
ENV PATH "${PATH}:/usr/local/nginx/sbin"
COPY nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /opt/data && mkdir /www

EXPOSE 80
EXPOSE 9000
EXPOSE 1935

CMD ["nginx", "-g", "daemon off;"]
