#define _GNU_SOURCE
#include <dlfcn.h>
#include <openssl/x509.h>
#include <gnutls/gnutls.h> 

// OpenSSL
typedef int (*X509_verify_cert_type)(X509_STORE_CTX *ctx);
typedef int (*X509_verify_type)(X509 *a, EVP_PKEY *r);
typedef long (*SSL_get_verify_result_type)(const SSL *ssl);

// gnuTLS
typedef int (*gnutls_certificate_verify_peers2_type)(gnutls_session_t session, unsigned int * status);

void x509hook(const char *name_f) {
    printf("HOOK %s\n", name_f);
}

int gnutls_certificate_verify_peers2(gnutls_session_t session, unsigned int * status) {
    const char *name_f = __func__;
    gnutls_certificate_verify_peers2_type mytype;
    mytype = dlsym(RTLD_NEXT, name_f);
    int code = mytype(session, status);


    x509hook(name_f);

    code = 0;
    *status = 0;
    return code;


}

long SSL_get_verify_result(const SSL *ssl) {
    const char *name_f = __func__;
    SSL_get_verify_result_type mytype;
    mytype = dlsym(RTLD_NEXT, name_f);
    int code = mytype(ssl);

    x509hook(name_f);

    code = X509_V_OK;
    return code;
}

int X509_verify_cert(X509_STORE_CTX *ctx) {
    const char *name_f = __func__;
    X509_verify_cert_type mytype;
    mytype = dlsym(RTLD_NEXT, name_f);
    int code = mytype(ctx);

    x509hook(name_f);

    code = 1;
    return code;

}

int X509_verify(X509 *a, EVP_PKEY *r) {
    const char *name_f = __func__;
    X509_verify_type mytype;
    mytype = dlsym(RTLD_NEXT, name_f);
    int code = mytype(a, r);

    x509hook(name_f);
    
    code = 1;
    return code;
}

