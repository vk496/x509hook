#!/bin/bash
set -e

BASE_DIR=$PWD
OUT_DIR="$BASE_DIR/.build/out"
PREFIX="/usr/local/"
CURL_VERSION="7.67.0"
num_cpu=$(nproc)
CURL_SSL_LIBS=(ssl gnutls nss mbedtls)

mkdir -p $OUT_DIR

apt-get update

apt-get install -y build-essential pkg-config git autoconf libtool libssl-dev libwolfssl-dev libnss3-dev libmbedtls-dev libgnutls28-dev

# curl

git clone https://github.com/curl/curl .build/curl
git clone https://www.bearssl.org/git/BearSSL .build/bearssl
( cd .build/bearssl && git checkout v0.6 )
cd .build/curl
git checkout $CURL_VERSION


# ./buildconf

set -xe
for curl_lib in ${CURL_SSL_LIBS[@]}; do
    ./configure --libdir=$PREFIX/lib_curl_$curl_lib --prefix=$PREFIX --without-ssl --with-$curl_lib
    make -j ${num_cpu:-1}
    DESTDIR="$OUT_DIR" make install

done