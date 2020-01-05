#!/bin/bash

# curl

BASE_DIR=$PWD
OUT_DIR="$BASE_DIR/.build/out"
CURL_DIR="$OUT_DIR/usr/local/bin"

CURL_BACKENDS=(openssl gnutls mbedtls)

for backend in ${CURL_BACKENDS[@]}; do
    echo "Test curl with $backend: "
    LD_PRELOAD=$BASE_DIR/x509hook.so LD_LIBRARY_PATH="$CURL_DIR/../lib" CURL_SSL_BACKEND="$backend" $CURL_DIR/curl --silent --output /dev/null https://self-signed.badssl.com/
    echo "$?"
done
