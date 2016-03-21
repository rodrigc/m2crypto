/* -*- Mode: C; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */
/* Copyright (c) 1999-2004 Ng Pheng Siong. All rights reserved. */
/*
** Portions created by Open Source Applications Foundation (OSAF) are
** Copyright (C) 2004-2005 OSAF. All Rights Reserved.
**
** Copyright (c) 2009-2010 Heikki Toivonen. All rights reserved.
**
*/
/* $Id$ */

%{
#include <pythread.h>
#include <limits.h>
#include <openssl/bio.h>
#include <openssl/dh.h>
#include <openssl/ssl.h>
#include <openssl/tls1.h>
#include <openssl/x509.h>
/*
WSAPoll is a bad replacement for poll().
See https://daniel.haxx.se/blog/2012/10/10/wsapoll-is-broken/ for
reasons.
Also
http://thread.gmane.org/gmane.comp.web.curl.library/36487/focus=36494
and
http://thread.gmane.org/gmane.comp.web.curl.library/36495
*/
#ifdef _WIN32
#include <winsock2.h>
#include <time.h>
#include <windows.h>
#else
#include <poll.h>
#include <sys/time.h>
#endif
%}

%apply Pointer NONNULL { SSL_CTX * };
%apply Pointer NONNULL { SSL * };
%apply Pointer NONNULL { SSL_CIPHER * };
%apply Pointer NONNULL { STACK_OF(SSL_CIPHER) * };
%apply Pointer NONNULL { STACK_OF(X509) * };
%apply Pointer NONNULL { BIO * };
%apply Pointer NONNULL { DH * };
%apply Pointer NONNULL { RSA * };
%apply Pointer NONNULL { EVP_PKEY *};
%apply Pointer NONNULL { PyObject *pyfunc };

%rename(ssl_get_ciphers) SSL_get_ciphers;
extern STACK_OF(SSL_CIPHER) *SSL_get_ciphers(const SSL *ssl);

%rename(ssl_get_version) SSL_get_version;
extern const char *SSL_get_version(CONST SSL *);
%rename(ssl_get_error) SSL_get_error;
extern int SSL_get_error(CONST SSL *, int);
%rename(ssl_get_state) SSL_state_string;
extern const char *SSL_state_string(const SSL *);
%rename(ssl_get_state_v) SSL_state_string_long;
extern const char *SSL_state_string_long(const SSL *);
%rename(ssl_get_alert_type) SSL_alert_type_string;
extern const char *SSL_alert_type_string(int);
%rename(ssl_get_alert_type_v) SSL_alert_type_string_long;
extern const char *SSL_alert_type_string_long(int);
%rename(ssl_get_alert_desc) SSL_alert_desc_string;
extern const char *SSL_alert_desc_string(int);
%rename(ssl_get_alert_desc_v) SSL_alert_desc_string_long;
extern const char *SSL_alert_desc_string_long(int);

#ifndef OPENSSL_NO_SSL2
%rename(sslv2_method) SSLv2_method;
extern SSL_METHOD *SSLv2_method(void);
#endif
#ifndef OPENSSL_NO_SSL3
%rename(sslv3_method) SSLv3_method;
extern SSL_METHOD *SSLv3_method(void);
#endif
%rename(sslv23_method) SSLv23_method;
extern SSL_METHOD *SSLv23_method(void);
%rename(tlsv1_method) TLSv1_method;
extern SSL_METHOD *TLSv1_method(void);

%typemap(out) SSL_CTX * {
    PyObject *self = NULL; /* bug in SWIG_NewPointerObj as of 3.0.5 */

    if ($1 != NULL)
        $result = SWIG_NewPointerObj($1, $1_descriptor, 0);
    else {
        PyErr_SetString(_ssl_err, ERR_reason_error_string(ERR_get_error()));
        $result = NULL;
    }
}
%rename(ssl_ctx_new) SSL_CTX_new;
extern SSL_CTX *SSL_CTX_new(SSL_METHOD *);
%typemap(out) SSL_CTX *;

%rename(ssl_ctx_free) SSL_CTX_free;
extern void SSL_CTX_free(SSL_CTX *);
%rename(ssl_ctx_set_verify_depth) SSL_CTX_set_verify_depth;
extern void SSL_CTX_set_verify_depth(SSL_CTX *, int);
%rename(ssl_ctx_get_verify_depth) SSL_CTX_get_verify_depth;
extern int SSL_CTX_get_verify_depth(CONST SSL_CTX *);
%rename(ssl_ctx_get_verify_mode) SSL_CTX_get_verify_mode;
extern int SSL_CTX_get_verify_mode(CONST SSL_CTX *);
%rename(ssl_ctx_set_cipher_list) SSL_CTX_set_cipher_list;
extern int SSL_CTX_set_cipher_list(SSL_CTX *, const char *);
%rename(ssl_ctx_add_session) SSL_CTX_add_session;
extern int SSL_CTX_add_session(SSL_CTX *, SSL_SESSION *);
%rename(ssl_ctx_remove_session) SSL_CTX_remove_session;
extern int SSL_CTX_remove_session(SSL_CTX *, SSL_SESSION *);
%rename(ssl_ctx_set_session_timeout) SSL_CTX_set_timeout;
extern long SSL_CTX_set_timeout(SSL_CTX *, long);
%rename(ssl_ctx_get_session_timeout) SSL_CTX_get_timeout;
extern long SSL_CTX_get_timeout(CONST SSL_CTX *);
%rename(ssl_ctx_get_cert_store) SSL_CTX_get_cert_store;
extern X509_STORE *SSL_CTX_get_cert_store(CONST SSL_CTX *);

%rename(bio_new_ssl) BIO_new_ssl;
extern BIO *BIO_new_ssl(SSL_CTX *, int);

%rename(ssl_new) SSL_new;
extern SSL *SSL_new(SSL_CTX *);
%rename(ssl_free) SSL_free;
%threadallow SSL_free;
extern void SSL_free(SSL *);
%rename(ssl_dup) SSL_dup;
extern SSL *SSL_dup(SSL *);
%rename(ssl_set_bio) SSL_set_bio;
extern void SSL_set_bio(SSL *, BIO *, BIO *);
%rename(ssl_set_accept_state) SSL_set_accept_state;
extern void SSL_set_accept_state(SSL *);
%rename(ssl_set_connect_state) SSL_set_connect_state;
extern void SSL_set_connect_state(SSL *);
%rename(ssl_get_shutdown) SSL_get_shutdown;
extern int SSL_get_shutdown(CONST SSL *);
%rename(ssl_set_shutdown) SSL_set_shutdown;
extern void SSL_set_shutdown(SSL *, int);
%rename(ssl_shutdown) SSL_shutdown;
%threadallow SSL_shutdown;
extern int SSL_shutdown(SSL *);
%rename(ssl_clear) SSL_clear;
extern int SSL_clear(SSL *);
%rename(ssl_do_handshake) SSL_do_handshake;
%threadallow SSL_do_handshake;
extern int SSL_do_handshake(SSL *);
%rename(ssl_renegotiate) SSL_renegotiate;
%threadallow SSL_renegotiate;
extern int SSL_renegotiate(SSL *);
%rename(ssl_pending) SSL_pending;
extern int SSL_pending(CONST SSL *);

%rename(ssl_get_peer_cert) SSL_get_peer_certificate;
extern X509 *SSL_get_peer_certificate(CONST SSL *);
%rename(ssl_get_current_cipher) SSL_get_current_cipher;
extern SSL_CIPHER *SSL_get_current_cipher(CONST SSL *);
%rename(ssl_get_verify_mode) SSL_get_verify_mode;
extern int SSL_get_verify_mode(CONST SSL *);
%rename(ssl_get_verify_depth) SSL_get_verify_depth;
extern int SSL_get_verify_depth(CONST SSL *);
%rename(ssl_get_verify_result) SSL_get_verify_result;
extern long SSL_get_verify_result(CONST SSL *);
%rename(ssl_get_ssl_ctx) SSL_get_SSL_CTX;
extern SSL_CTX *SSL_get_SSL_CTX(CONST SSL *);
%rename(ssl_get_default_session_timeout) SSL_get_default_timeout;
extern long SSL_get_default_timeout(CONST SSL *);

%rename(ssl_set_cipher_list) SSL_set_cipher_list;
extern int SSL_set_cipher_list(SSL *, const char *);
%rename(ssl_get_cipher_list) SSL_get_cipher_list;
extern const char *SSL_get_cipher_list(CONST SSL *, int);

%rename(ssl_cipher_get_name) SSL_CIPHER_get_name;
extern const char *SSL_CIPHER_get_name(CONST SSL_CIPHER *);
%rename(ssl_cipher_get_version) SSL_CIPHER_get_version;
extern char *SSL_CIPHER_get_version(CONST SSL_CIPHER *);

%rename(ssl_get_session) SSL_get_session;
extern SSL_SESSION *SSL_get_session(CONST SSL *);
%rename(ssl_get1_session) SSL_get1_session;
extern SSL_SESSION *SSL_get1_session(SSL *);
%rename(ssl_set_session) SSL_set_session;
extern int SSL_set_session(SSL *, SSL_SESSION *);
%rename(ssl_session_free) SSL_SESSION_free;
extern void SSL_SESSION_free(SSL_SESSION *);
%rename(ssl_session_print) SSL_SESSION_print;
%threadallow SSL_SESSION_print;
extern int SSL_SESSION_print(BIO *, CONST SSL_SESSION *);
%rename(ssl_session_set_timeout) SSL_SESSION_set_timeout;
extern long SSL_SESSION_set_timeout(SSL_SESSION *, long);
%rename(ssl_session_get_timeout) SSL_SESSION_get_timeout;
extern long SSL_SESSION_get_timeout(CONST SSL_SESSION *);

extern PyObject *ssl_accept(SSL *ssl, double timeout = -1);
extern PyObject *ssl_connect(SSL *ssl, double timeout = -1);
extern PyObject *ssl_read(SSL *ssl, int num, double timeout = -1);
extern int ssl_write(SSL *ssl, PyObject *blob, double timeout = -1);

%constant int ssl_error_none              = SSL_ERROR_NONE;
%constant int ssl_error_ssl               = SSL_ERROR_SSL;
%constant int ssl_error_want_read         = SSL_ERROR_WANT_READ;
%constant int ssl_error_want_write        = SSL_ERROR_WANT_WRITE;
%constant int ssl_error_want_x509_lookup  = SSL_ERROR_WANT_X509_LOOKUP;
%constant int ssl_error_syscall           = SSL_ERROR_SYSCALL;
%constant int ssl_error_zero_return       = SSL_ERROR_ZERO_RETURN;
%constant int ssl_error_want_connect      = SSL_ERROR_WANT_CONNECT;

%constant int SSL_VERIFY_NONE                 = 0x00;
%constant int SSL_VERIFY_PEER                 = 0x01;
%constant int SSL_VERIFY_FAIL_IF_NO_PEER_CERT = 0x02;
%constant int SSL_VERIFY_CLIENT_ONCE          = 0x04;

%constant int SSL_ST_CONNECT                  = 0x1000;
%constant int SSL_ST_ACCEPT                   = 0x2000;
%constant int SSL_ST_MASK                     = 0x0FFF;
%constant int SSL_ST_INIT                     = (SSL_ST_CONNECT|SSL_ST_ACCEPT);
%constant int SSL_ST_BEFORE                   = 0x4000;
%constant int SSL_ST_OK                       = 0x03;
%constant int SSL_ST_RENEGOTIATE              = (0x04|SSL_ST_INIT);

%constant int SSL_CB_LOOP                     = 0x01;
%constant int SSL_CB_EXIT                     = 0x02;
%constant int SSL_CB_READ                     = 0x04;
%constant int SSL_CB_WRITE                    = 0x08;
%constant int SSL_CB_ALERT                    = 0x4000; /* used in callback */
%constant int SSL_CB_READ_ALERT               = (SSL_CB_ALERT|SSL_CB_READ);
%constant int SSL_CB_WRITE_ALERT              = (SSL_CB_ALERT|SSL_CB_WRITE);
%constant int SSL_CB_ACCEPT_LOOP              = (SSL_ST_ACCEPT|SSL_CB_LOOP);
%constant int SSL_CB_ACCEPT_EXIT              = (SSL_ST_ACCEPT|SSL_CB_EXIT);
%constant int SSL_CB_CONNECT_LOOP             = (SSL_ST_CONNECT|SSL_CB_LOOP);
%constant int SSL_CB_CONNECT_EXIT             = (SSL_ST_CONNECT|SSL_CB_EXIT);
%constant int SSL_CB_HANDSHAKE_START          = 0x10;
%constant int SSL_CB_HANDSHAKE_DONE           = 0x20;

%constant int SSL_SENT_SHUTDOWN              = 1;
%constant int SSL_RECEIVED_SHUTDOWN          = 2;

%constant int SSL_SESS_CACHE_OFF            = 0x000;
%constant int SSL_SESS_CACHE_CLIENT         = 0x001;
%constant int SSL_SESS_CACHE_SERVER         = 0x002;
%constant int SSL_SESS_CACHE_BOTH           = (SSL_SESS_CACHE_CLIENT|SSL_SESS_CACHE_SERVER);

%constant int SSL_OP_ALL                  = 0x00000FFFL;

%constant int SSL_OP_NO_SSLv2             = 0x01000000L;
%constant int SSL_OP_NO_SSLv3             = 0x02000000L;
%constant int SSL_OP_NO_TLSv1             = 0x04000000L;
%constant int SSL_OP_DONT_INSERT_EMPTY_FRAGMENTS = 0x00000800L;

%constant int SSL_MODE_ENABLE_PARTIAL_WRITE = SSL_MODE_ENABLE_PARTIAL_WRITE;
%constant int SSL_MODE_ACCEPT_MOVING_WRITE_BUFFER = SSL_MODE_ENABLE_PARTIAL_WRITE;
%constant int SSL_MODE_AUTO_RETRY           = SSL_MODE_AUTO_RETRY;

%ignore ssl_handle_error;
%ignore ssl_sleep_with_timeout;
%inline %{
static PyObject *_ssl_err;
static PyObject *_ssl_timeout_err;

void ssl_init(PyObject *ssl_err, PyObject *ssl_timeout_err) {
    SSL_library_init();
    SSL_load_error_strings();
    Py_INCREF(ssl_err);
    Py_INCREF(ssl_timeout_err);
    _ssl_err = ssl_err;
    _ssl_timeout_err = ssl_timeout_err;
}

void ssl_ctx_passphrase_callback(SSL_CTX *ctx, PyObject *pyfunc) {
    SSL_CTX_set_default_passwd_cb(ctx, passphrase_callback);
    SSL_CTX_set_default_passwd_cb_userdata(ctx, (void *)pyfunc);
    Py_INCREF(pyfunc);
}

int ssl_ctx_use_x509(SSL_CTX *ctx, X509 *x) {
    int i;
    
    if (!(i = SSL_CTX_use_certificate(ctx, x))) {
        PyErr_SetString(_ssl_err, ERR_reason_error_string(ERR_get_error()));
        return -1;
    }
    return i;

}

int ssl_ctx_use_cert(SSL_CTX *ctx, char *file) {
    int i;
    
    if (!(i = SSL_CTX_use_certificate_file(ctx, file, SSL_FILETYPE_PEM))) {
        PyErr_SetString(_ssl_err, ERR_reason_error_string(ERR_get_error()));
        return -1;
    }
    return i;
}

int ssl_ctx_use_cert_chain(SSL_CTX *ctx, char *file) {
    int i;

    if (!(i = SSL_CTX_use_certificate_chain_file(ctx, file))) {
        PyErr_SetString(_ssl_err, ERR_reason_error_string(ERR_get_error()));
        return -1;
    }
    return i;
}


int ssl_ctx_use_privkey(SSL_CTX *ctx, char *file) {
    int i;
    
    if (!(i = SSL_CTX_use_PrivateKey_file(ctx, file, SSL_FILETYPE_PEM))) {
        PyErr_SetString(_ssl_err, ERR_reason_error_string(ERR_get_error()));
        return -1;
    }
    return i;
}

int ssl_ctx_use_rsa_privkey(SSL_CTX *ctx, RSA *rsakey) {
    int i;

    if (!(i = SSL_CTX_use_RSAPrivateKey(ctx, rsakey))) {
        PyErr_SetString(_ssl_err, ERR_reason_error_string(ERR_get_error()));
        return -1;
    }
    return i;
}

int ssl_ctx_use_pkey_privkey(SSL_CTX *ctx, EVP_PKEY *pkey) {
    int i;

    if (!(i = SSL_CTX_use_PrivateKey(ctx, pkey))) {
        PyErr_SetString(_ssl_err, ERR_reason_error_string(ERR_get_error()));
        return -1;
    }
    return i;
}


int ssl_ctx_check_privkey(SSL_CTX *ctx) {
    int ret;
    
    if (!(ret = SSL_CTX_check_private_key(ctx))) {
        PyErr_SetString(_ssl_err, ERR_reason_error_string(ERR_get_error()));
        return -1;
    }
    return ret;
}

void ssl_ctx_set_client_CA_list_from_file(SSL_CTX *ctx, const char *ca_file) {
    SSL_CTX_set_client_CA_list(ctx, SSL_load_client_CA_file(ca_file));
}

void ssl_ctx_set_verify_default(SSL_CTX *ctx, int mode) {
    SSL_CTX_set_verify(ctx, mode, NULL);
}

void ssl_ctx_set_verify(SSL_CTX *ctx, int mode, PyObject *pyfunc) {
    Py_XDECREF(ssl_verify_cb_func);
    Py_INCREF(pyfunc);
    ssl_verify_cb_func = pyfunc;
    SSL_CTX_set_verify(ctx, mode, ssl_verify_callback);
}

int ssl_ctx_set_session_id_context(SSL_CTX *ctx, PyObject *sid_ctx) {
    const void *buf;
    int len;

    if (m2_PyObject_AsReadBufferInt(sid_ctx, &buf, &len) == -1)
        return -1;

    return SSL_CTX_set_session_id_context(ctx, buf, len);
}

void ssl_ctx_set_info_callback(SSL_CTX *ctx, PyObject *pyfunc) {
    Py_XDECREF(ssl_info_cb_func);
    Py_INCREF(pyfunc);
    ssl_info_cb_func = pyfunc;
    SSL_CTX_set_info_callback(ctx, ssl_info_callback);
}

long ssl_ctx_set_tmp_dh(SSL_CTX *ctx, DH* dh) {
    return SSL_CTX_set_tmp_dh(ctx, dh);
}

void ssl_ctx_set_tmp_dh_callback(SSL_CTX *ctx,  PyObject *pyfunc) {
    Py_XDECREF(ssl_set_tmp_dh_cb_func);
    Py_INCREF(pyfunc);
    ssl_set_tmp_dh_cb_func = pyfunc;
    SSL_CTX_set_tmp_dh_callback(ctx, ssl_set_tmp_dh_callback);
}

long ssl_ctx_set_tmp_rsa(SSL_CTX *ctx, RSA* rsa) {
    return SSL_CTX_set_tmp_rsa(ctx, rsa);
}

void ssl_ctx_set_tmp_rsa_callback(SSL_CTX *ctx,  PyObject *pyfunc) {
    Py_XDECREF(ssl_set_tmp_rsa_cb_func);
    Py_INCREF(pyfunc);
    ssl_set_tmp_rsa_cb_func = pyfunc;
    SSL_CTX_set_tmp_rsa_callback(ctx, ssl_set_tmp_rsa_callback);
}

int ssl_ctx_load_verify_locations(SSL_CTX *ctx, const char *cafile, const char *capath) {
    return SSL_CTX_load_verify_locations(ctx, cafile, capath);
}

/* SSL_CTX_set_options is a macro. */
long ssl_ctx_set_options(SSL_CTX *ctx, long op) {
    return SSL_CTX_set_options(ctx, op);
}

int bio_set_ssl(BIO *bio, SSL *ssl, int flag) {
    SSL_set_mode(ssl, SSL_MODE_AUTO_RETRY);
    return BIO_ctrl(bio, BIO_C_SET_SSL, flag, (char *)ssl);
}

long ssl_set_mode(SSL *ssl, long mode) {
    return SSL_set_mode(ssl, mode);
}

long ssl_get_mode(SSL *ssl) {
    return SSL_get_mode(ssl);
}

int ssl_set_tlsext_host_name(SSL *ssl, const char *name) {
    long l;

    if (!(l = SSL_set_tlsext_host_name(ssl, name))) {
        PyErr_SetString(_ssl_err, ERR_reason_error_string(ERR_get_error()));
        return -1;
    }
    /* Return an "int" to match the 'typemap(out) int' in _lib.i */
    return 1;
}

void ssl_set_client_CA_list_from_file(SSL *ssl, const char *ca_file) {
    SSL_set_client_CA_list(ssl, SSL_load_client_CA_file(ca_file));
}

void ssl_set_client_CA_list_from_context(SSL *ssl, SSL_CTX *ctx) {
    SSL_set_client_CA_list(ssl, SSL_CTX_get_client_CA_list(ctx));
}

int ssl_set_session_id_context(SSL *ssl, PyObject *sid_ctx) {
    const void *buf;
    int len;

    if (m2_PyObject_AsReadBufferInt(sid_ctx, &buf, &len) == -1)
        return -1;

    return SSL_set_session_id_context(ssl, buf, len);
}

int ssl_set_fd(SSL *ssl, int fd) {
    int ret;
    
    if (!(ret = SSL_set_fd(ssl, fd))) {
        PyErr_SetString(_ssl_err, ERR_reason_error_string(ERR_get_error()));
        return -1;
    }
    return ret;
}

static void ssl_handle_error(int ssl_err, int ret) {
    int err;

    switch (ssl_err) {
        case SSL_ERROR_SSL:
            PyErr_SetString(_ssl_err,
                            ERR_reason_error_string(ERR_get_error()));
            break;
        case SSL_ERROR_SYSCALL:
            err = ERR_get_error();
            if (err)
                PyErr_SetString(_ssl_err, ERR_reason_error_string(err));
            else if (ret == 0)
                PyErr_SetString(_ssl_err, "unexpected eof");
            else if (ret == -1)
                PyErr_SetFromErrno(_ssl_err);
            else
                assert(0);
            break;
		default:
            PyErr_SetString(_ssl_err, "unexpected SSL error");
     }
}

#ifdef _WIN32
/* Implementation from
 * http://web.archive.org/web/20130406033313/http://suacommunity.com/dictionary/gettimeofday-entry.php
 */

#if defined(_MSC_VER) || defined(_MSC_EXTENSIONS)
#define DELTA_EPOCH_IN_MICROSECS  11644473600000000Ui64
#else
#define DELTA_EPOCH_IN_MICROSECS  11644473600000000ULL
#endif

struct timezone {
	int tz_minuteswest;	/* minutes W of Greenwich */
	int tz_dsttime;		/* type of dst correction */
};

int gettimeofday(struct timeval *tv, struct timezone *tz) {
/* Define a structure to receive the current Windows filetime */
	FILETIME ft;

/* Initialize the present time to 0 and the timezone to UTC */
	unsigned __int64 tmpres = 0;
	static int tzflag = 0;

	if (NULL != tv) {
		GetSystemTimeAsFileTime(&ft);

/* The GetSystemTimeAsFileTime returns the number of 100 nanosecond 
   intervals since Jan 1, 1601 in a structure. Copy the high bits to 
   the 64 bit tmpres, shift it left by 32 then or in the low 32 bits. */
		tmpres |= ft.dwHighDateTime;
		tmpres <<= 32;
		tmpres |= ft.dwLowDateTime;

/* Convert to microseconds by dividing by 10 */
		tmpres /= 10;

/* The Unix epoch starts on Jan 1 1970.  Need to subtract the difference 
   in seconds from Jan 1 1601. */
		tmpres -= DELTA_EPOCH_IN_MICROSECS;

/* Finally change microseconds to seconds and place in the seconds value. 
   The modulus picks up the microseconds. */
		tv->tv_sec = (long)(tmpres / 1000000UL);
		tv->tv_usec = (long)(tmpres % 1000000UL);
	}

	if (NULL != tz) {
		if (!tzflag) {
			_tzset();
			tzflag++;
		}
/* Adjust for the timezone west of Greenwich */
		tz->tz_minuteswest = _timezone / 60;
		tz->tz_dsttime = _daylight;
	}

	return 0;
}
#endif

static int ssl_sleep_with_timeout(SSL *ssl, const struct timeval *start,
                                  double timeout, int ssl_err) {
    struct pollfd fd;
    struct timeval tv;
    int ms, tmp;

    assert(timeout > 0);
 again:
    gettimeofday(&tv, NULL);
    /* tv >= start */
    if ((timeout + start->tv_sec - tv.tv_sec) > INT_MAX / 1000)
        ms = -1;
    else {
        int fract;

        ms = ((start->tv_sec + (int)timeout) - tv.tv_sec) * 1000;
        fract = (start->tv_usec + (timeout - (int)timeout) * 1000000
                 - tv.tv_usec + 999) / 1000;
        if (ms > 0 && fract > INT_MAX - ms)
            ms = -1;
        else {
            ms += fract;
            if (ms <= 0)
                goto timeout;
        }
    }
    switch (ssl_err) {
	    case SSL_ERROR_WANT_READ:
            fd.fd = SSL_get_rfd(ssl);
            fd.events = POLLIN;
            break;

	    case SSL_ERROR_WANT_WRITE:
            fd.fd = SSL_get_wfd(ssl);
            fd.events = POLLOUT;
            break;

	    case SSL_ERROR_WANT_X509_LOOKUP:
            return 0; /* FIXME: is this correct? */

	    default:
            assert(0);
    }
    if (fd.fd == -1) {
        PyErr_SetString(_ssl_err, "timeout on a non-FD SSL");
        return -1;
    }
    Py_BEGIN_ALLOW_THREADS
    #ifdef _WIN32
    tmp = WSAPoll(&fd, 1, ms);
    #else
    tmp = poll(&fd, 1, ms);
    #endif
    Py_END_ALLOW_THREADS
    switch (tmp) {
    	case 1:
            return 0;
    	case 0:
            goto timeout;
    	case -1:
            if (errno == EINTR)
                goto again;
            PyErr_SetFromErrno(_ssl_err);
            return -1;
    }
    return 0;

 timeout:
    PyErr_SetString(_ssl_timeout_err, "timed out");
    return -1;
}

PyObject *ssl_accept(SSL *ssl, double timeout) {
    PyObject *obj = NULL;
    int r, ssl_err;
    struct timeval tv;

    if (timeout > 0)
        gettimeofday(&tv, NULL);
 again:
    Py_BEGIN_ALLOW_THREADS
    r = SSL_accept(ssl);
    ssl_err = SSL_get_error(ssl, r);
    Py_END_ALLOW_THREADS


    switch (ssl_err) {
        case SSL_ERROR_NONE:
        case SSL_ERROR_ZERO_RETURN:
            obj = PyInt_FromLong((long)1);
            break;
        case SSL_ERROR_WANT_WRITE:
        case SSL_ERROR_WANT_READ:
            if (timeout <= 0) {
                obj = PyInt_FromLong((long)0);
                break;
            }
            if (ssl_sleep_with_timeout(ssl, &tv, timeout, ssl_err) == 0)
                goto again;
            obj = NULL;
            break;
        case SSL_ERROR_SSL:
        case SSL_ERROR_SYSCALL:
            ssl_handle_error(ssl_err, r);
            obj = NULL;
            break;
    }


    return obj;
}

PyObject *ssl_connect(SSL *ssl, double timeout) {
    PyObject *obj = NULL;
    int r, ssl_err;
    struct timeval tv;

    if (timeout > 0)
        gettimeofday(&tv, NULL);
 again:
    Py_BEGIN_ALLOW_THREADS
    r = SSL_connect(ssl);
    ssl_err = SSL_get_error(ssl, r);
    Py_END_ALLOW_THREADS

    
    switch (ssl_err) {
        case SSL_ERROR_NONE:
        case SSL_ERROR_ZERO_RETURN:
            obj = PyInt_FromLong((long)1);
            break;
        case SSL_ERROR_WANT_WRITE:
        case SSL_ERROR_WANT_READ:
            if (timeout <= 0) {
                obj = PyInt_FromLong((long)0);
                break;
            }
            if (ssl_sleep_with_timeout(ssl, &tv, timeout, ssl_err) == 0)
                goto again;
            obj = NULL;
            break;
        case SSL_ERROR_SSL:
        case SSL_ERROR_SYSCALL:
            ssl_handle_error(ssl_err, r);
            obj = NULL;
            break;
    }
    
    
    return obj;
}

void ssl_set_shutdown1(SSL *ssl, int mode) {
    SSL_set_shutdown(ssl, mode);
}

PyObject *ssl_read(SSL *ssl, int num, double timeout) {
    PyObject *obj = NULL;
    void *buf;
    int r;
    struct timeval tv;

    if (!(buf = PyMem_Malloc(num))) {
        PyErr_SetString(PyExc_MemoryError, "ssl_read");
        return NULL;
    }


    if (timeout > 0)
        gettimeofday(&tv, NULL);
 again:
    Py_BEGIN_ALLOW_THREADS
    r = SSL_read(ssl, buf, num);
    Py_END_ALLOW_THREADS


    if (r >= 0) {
        buf = PyMem_Realloc(buf, r);
        obj = PyString_FromStringAndSize(buf, r);
    } else {
        int ssl_err;

        ssl_err = SSL_get_error(ssl, r);
        switch (ssl_err) {
            case SSL_ERROR_NONE:
            case SSL_ERROR_ZERO_RETURN:
                assert(0);

            case SSL_ERROR_WANT_WRITE:
            case SSL_ERROR_WANT_READ:
            case SSL_ERROR_WANT_X509_LOOKUP:
                if (timeout <= 0) {
                    Py_INCREF(Py_None);
                    obj = Py_None;
                    break;
                }
                if (ssl_sleep_with_timeout(ssl, &tv, timeout, ssl_err) == 0)
                    goto again;
                obj = NULL;
                break;
            case SSL_ERROR_SSL:
            case SSL_ERROR_SYSCALL:
                ssl_handle_error(ssl_err, r);
                obj = NULL;
                break;
        }
    }
    PyMem_Free(buf);


    return obj;
}

PyObject *ssl_read_nbio(SSL *ssl, int num) {
    PyObject *obj = NULL;
    void *buf;
    int r, err;


    if (!(buf = PyMem_Malloc(num))) {
        PyErr_SetString(PyExc_MemoryError, "ssl_read");
        return NULL;
    }
    
    
    Py_BEGIN_ALLOW_THREADS
    r = SSL_read(ssl, buf, num);
    Py_END_ALLOW_THREADS
    
    
    switch (SSL_get_error(ssl, r)) {
        case SSL_ERROR_NONE:
        case SSL_ERROR_ZERO_RETURN:
            buf = PyMem_Realloc(buf, r);
            obj = PyString_FromStringAndSize(buf, r);
            break;
        case SSL_ERROR_WANT_WRITE:
        case SSL_ERROR_WANT_READ:
        case SSL_ERROR_WANT_X509_LOOKUP:
            Py_INCREF(Py_None);
            obj = Py_None;
            break;
        case SSL_ERROR_SSL:
            PyErr_SetString(_ssl_err, ERR_reason_error_string(ERR_get_error()));
            obj = NULL;
            break;
        case SSL_ERROR_SYSCALL:
            err = ERR_get_error();
            if (err)
                PyErr_SetString(_ssl_err, ERR_reason_error_string(err));
            else if (r == 0)
                PyErr_SetString(_ssl_err, "unexpected eof");
            else if (r == -1)
                PyErr_SetFromErrno(_ssl_err);
            obj = NULL;
            break;
    }
    PyMem_Free(buf);
    
    
    return obj;
}

int ssl_write(SSL *ssl, PyObject *blob, double timeout) {
    Py_buffer buf;
    int r, ssl_err, ret;
    struct timeval tv;


    if (m2_PyObject_GetBufferInt(blob, &buf, PyBUF_CONTIG_RO) == -1) {
        return -1;
    }

    if (timeout > 0)
        gettimeofday(&tv, NULL);
 again:
    Py_BEGIN_ALLOW_THREADS
    r = SSL_write(ssl, buf.buf, buf.len);
    ssl_err = SSL_get_error(ssl, r);
    Py_END_ALLOW_THREADS


    switch (ssl_err) {
        case SSL_ERROR_NONE:
        case SSL_ERROR_ZERO_RETURN:
            ret = r;
            break;
        case SSL_ERROR_WANT_WRITE:
        case SSL_ERROR_WANT_READ:
        case SSL_ERROR_WANT_X509_LOOKUP:
            if (timeout <= 0) {
                ret = -1;
                break;
            }
            if (ssl_sleep_with_timeout(ssl, &tv, timeout, ssl_err) == 0)
                goto again;
            ret = -1;
            break;
        case SSL_ERROR_SSL:
        case SSL_ERROR_SYSCALL:
            ssl_handle_error(ssl_err, r);
        default:
            ret = -1;
    }
    
    m2_PyBuffer_Release(blob, &buf);
    return ret;
}

int ssl_write_nbio(SSL *ssl, PyObject *blob) {
    Py_buffer buf;
    int r, err, ret;


    if (m2_PyObject_GetBufferInt(blob, &buf, PyBUF_CONTIG_RO) == -1) {
        return -1;
    }

    
    Py_BEGIN_ALLOW_THREADS
    r = SSL_write(ssl, buf.buf, buf.len);
    Py_END_ALLOW_THREADS
    
    
    switch (SSL_get_error(ssl, r)) {
        case SSL_ERROR_NONE:
        case SSL_ERROR_ZERO_RETURN:
            ret = r;
            break;
        case SSL_ERROR_WANT_WRITE:
        case SSL_ERROR_WANT_READ:
        case SSL_ERROR_WANT_X509_LOOKUP:
            ret = -1;
            break;
        case SSL_ERROR_SSL:
            ret = -1;
            break;
        case SSL_ERROR_SYSCALL:
            err = ERR_get_error();
            if (err)
                PyErr_SetString(_ssl_err, ERR_reason_error_string(err));
            else if (r == 0)
                PyErr_SetString(_ssl_err, "unexpected eof");
            else if (r == -1)
                PyErr_SetFromErrno(_ssl_err);
        default:
            ret = -1;
    }
    
    m2_PyBuffer_Release(blob, &buf);
    return ret;
}

int ssl_cipher_get_bits(SSL_CIPHER *c) {
    return SSL_CIPHER_get_bits(c, NULL);
}

int sk_ssl_cipher_num(STACK_OF(SSL_CIPHER) *stack) {
    return sk_SSL_CIPHER_num(stack);
}

SSL_CIPHER *sk_ssl_cipher_value(STACK_OF(SSL_CIPHER) *stack, int idx) {
    return sk_SSL_CIPHER_value(stack, idx);
}

STACK_OF(X509) *ssl_get_peer_cert_chain(SSL *ssl) {
    return SSL_get_peer_cert_chain(ssl);
}

int sk_x509_num(STACK_OF(X509) *stack) {
    return sk_X509_num(stack);
}

X509 *sk_x509_value(STACK_OF(X509) *stack, int idx) {
    return sk_X509_value(stack, idx);
}
%}

%threadallow i2d_ssl_session;
%inline %{
void i2d_ssl_session(BIO *bio, SSL_SESSION *sess) {
    i2d_SSL_SESSION_bio(bio, sess);
}
%}

%threadallow ssl_session_read_pem;
%inline %{
SSL_SESSION *ssl_session_read_pem(BIO *bio) {
    return PEM_read_bio_SSL_SESSION(bio, NULL, NULL, NULL);
}
%}

%threadallow ssl_session_write_pem;
%inline %{
int ssl_session_write_pem(SSL_SESSION *sess, BIO *bio) {
    return PEM_write_bio_SSL_SESSION(bio, sess);
}

int ssl_ctx_set_session_cache_mode(SSL_CTX *ctx, int mode)
{
    return SSL_CTX_set_session_cache_mode(ctx, mode);
}

int ssl_ctx_get_session_cache_mode(SSL_CTX *ctx)
{
    return SSL_CTX_get_session_cache_mode(ctx);
}

static long ssl_ctx_set_cache_size(SSL_CTX *ctx, long arg)
{
  return SSL_CTX_sess_set_cache_size(ctx, arg);
}

int ssl_is_init_finished(SSL *ssl)
{
  return SSL_is_init_finished(ssl);
}
%}

