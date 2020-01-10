#!/bin/bash

# curl

if [[ $# -gt 0 ]]; then
    echo "DEBUG MODE"
    DEBUG=true
    curl_arg="-v"
else
    curl_arg="--silent"
fi

BASE_DIR=$PWD
OUT_DIR="$BASE_DIR/.build/out"
PREFIX="/usr/local/"
CURL_DIR="$OUT_DIR/$PREFIX/"

BADSSL_TESTS=(expired self-signed untrusted-root revoked)

CURL_BACKENDS=(ssl gnutls nss mbedtls)
echo "curl"
for badssl_test in ${BADSSL_TESTS[@]}; do
    echo "  $badssl_test: "
    for backend in ${CURL_BACKENDS[@]}; do
        printf "%18s" "$backend: "

        if [[ $DEBUG ]]; then
            echo -e "\n"
            set -x
        fi

        LD_PRELOAD=$BASE_DIR/x509hook.so LD_LIBRARY_PATH="$CURL_DIR/lib_curl_$backend" $CURL_DIR/bin/curl $curl_arg https://$badssl_test.badssl.com/ >/dev/null
        exit_code="$?"
        set +x

        if [[ ! -d $CURL_DIR/lib_curl_$backend ]]; then
            exit_code="-6a6"
        fi

        if [[ $exit_code == "-6a6" ]]; then
            echo "SKIP"
        elif [[ $exit_code -eq 0 ]]; then
            LD_LIBRARY_PATH="$CURL_DIR/lib_curl_$backend" $CURL_DIR/bin/curl --silent https://$badssl_test.badssl.com/ &>/dev/null
            if [[ $? -eq 0 ]]; then
                echo "PASS"
            else
                echo "BYPASS"
            fi
        elif [[ $exit_code -eq 60 ]]; then
            LD_LIBRARY_PATH="$CURL_DIR/lib_curl_$backend" $CURL_DIR/bin/curl --silent https://$badssl_test.badssl.com/ &>/dev/null
            if [[ $? -eq 60 ]]; then
                echo "UNM (exit code: $exit_code)"
            else
                echo "BERROR (exit code: $exit_code)"
            fi
        else
            echo "ERROR (exit code: $exit_code)"
        fi
    done
    echo
done
