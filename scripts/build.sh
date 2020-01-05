#!/bin/bash

apt-get update

apt-get install -y build-essential git autoconf libtool libssl-dev libwolfssl-dev libnss3-dev libmbedtls-dev libghc-gnutls-dev

# curl

git clone https://github.com/curl/curl .build/curl

BASE_DIR=$PWD
OUT_DIR="$BASE_DIR/.build/out"
BINS_DIR="$BASE_DIR/.build/bins"
mkdir -p $OUT_DIR $BINS_DIR
cd .build/curl
git checkout 7.67.0
#./buildconf

num_cpu=$(nproc)

./configure --with-gnutls --with-ssl --with-mbedtls
make -j ${num_cpu:-1}
DESTDIR="$OUT_DIR" make install
