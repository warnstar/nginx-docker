FROM debian:stretch-slim

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime

RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

# Install modules
RUN apt-get update
RUN apt-get install -y \
    curl \
    wget \
    procps \
    vim \
    git \
    openssl \
    libssl-dev \
    zlib1g-dev \
    autoconf \
	dpkg-dev \
	file \
	g++ \
	gcc \
	libc-dev \
	make \
	pkg-config \
	ca-certificates \
	xz-utils \
    libpcre3 libpcre3-dev \
         --no-install-recommends

RUN wget http://nginx.org/download/nginx-1.12.0.tar.gz -O nginx.tar.gz \
    && mkdir -p nginx \
    && tar -xf nginx.tar.gz -C nginx --strip-components=1 \
    && rm nginx.tar.gz

RUN git clone https://github.com/google/ngx_brotli /tmp/ngx_brotli \
    && cd /tmp/ngx_brotli \
    && git submodule update --init

RUN cd nginx && ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=www-data \
    --group=www-data \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' \
    --with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' \
    --add-module=/tmp/ngx_brotli \
    && make \
    && make install \
    && mkdir -p /var/cache/nginx

RUN usermod -u 1000 www-data

ADD ./nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
