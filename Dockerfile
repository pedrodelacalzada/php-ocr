FROM alpine:3.7
USER root
RUN apk update
RUN apk add build-base
RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php
RUN apk add perl
RUN apk add tesseract-ocr
RUN apk add tesseract-ocr-data-spa
RUN apk add unpaper
RUN apk add imagemagick
RUN apk add poppler-utils
RUN apk add ghostscript
RUN apk add gawk
RUN apk add ocaml
ADD extra /root/extra
RUN cd /root/extra
RUN cd /root/extra && \
    tar -xvf pdfsandwich-0.1.6.tar.bz2 && \
    cd pdfsandwich-0.1.6 && \
    ./configure && \
    make && \
    make install
RUN apk add php7
RUN apk add php7-dev
RUN apk add php7-pear
RUN apk add php7-ctype
RUN apk add php7-iconv
RUN apk add php7-iconv
RUN apk add php7-xml
RUN apk add php7-dom
RUN pecl install inotify
RUN touch /etc/php7/conf.d/01_inotify.ini
RUN echo "extension=inotify.so" > /etc/php7/conf.d/01_inotify.ini
ADD app /tmp/app
CMD php /tmp/app/bin/console app:ocr /tmp/php-ocr
# Example Build
# docker build -t php-ocr .
# Example run:
# docker run -d -v /opt/php-tesseract/data:/tmp/php-ocr php-ocr
