FROM alpine:3.7
USER root
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php
RUN apk update && \
    apk add build-base && \
    apk add perl && \
    apk add tesseract-ocr && \
    apk add tesseract-ocr-data-spa && \
    apk add unpaper && \
    apk add imagemagick && \
    apk add poppler-utils && \
    apk add ghostscript && \
    apk add gawk && \
    apk add ocaml
ADD extra /root/extra
RUN cd /root/extra && \
    tar -xvf pdfsandwich-0.1.6.tar.bz2 && \
    cd pdfsandwich-0.1.6 && \
    ./configure && \
    make && \
    make install && \
    apk add php7 && \
    apk add php7-dev && \
    apk add php7-pear && \
    apk add php7-ctype && \
    apk add php7-iconv && \
    apk add php7-iconv && \
    apk add php7-xml && \
    apk add php7-dom && \
    pecl install inotify && \
    touch /etc/php7/conf.d/01_inotify.ini && \
    echo "extension=inotify.so" > /etc/php7/conf.d/01_inotify.ini
ADD app /app
CMD php /app/bin/console app:ocr /tmp/php-ocr
# Example Build
# docker build -t php-ocr .
# Example run:
# docker run --name=php-ocr -d -v /opt/development/data/php-ocr:/tmp/php-ocr php-ocr
