unit amqp_ssl_socket;

interface

uses
	Windows, Messages, SysUtils, Classes, amqp_h;


(* vim:set ft=c ts=2 sw=2 sts=2 et cindent: *)
(** \file *)
(*
 * Portions created by Alan Antonuk are Copyright (c) 2013-2014 Alan Antonuk.
 * All Rights Reserved.
 *
 * Portions created by Michael Steinert are Copyright (c) 2012-2013 Michael
 * Steinert. All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the 'Software'),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER  AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM,  OF OR  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS  THE SOFTWARE.
 *)

{$ifndef AMQP_SSL_H}
{$define AMQP_SSL_H}

AMQP_BEGIN_DECLS

(**
 * Create a new SSL/TLS socket object.
 *
 * The returned socket object is owned by the ref amqp_connection_state_t object
 * and will be destroyed when the state object is destroyed or a new socket
 * object is created.
 *
 * If the socket object creation fails, the ref amqp_connection_state_t object
 * will not be changed.
 *
 * The object returned by this aFunction can be retrieved from the
 * amqp_connection_state_t object later using the amqp_get_socket() aFunction.
 *
 * Calling this aFunction may aResult in the underlying SSL aLibrary being initialized.
 * sa amqp_set_initialize_ssl_library()
 *
 * param [in,out] state The connection object that owns the SSL/TLS socket
 * Result:= A new socket object or 0 if an error occurred.
 *
 * since v0.4.0
 *)
AMQP_PUBLIC_FUNCTION
amqp_socket_t *
AMQP_CALL
amqp_ssl_socket_new(amqp_connection_state_t state);

(**
 * Set the CA certificate.
 *
 * param [in,out] self An SSL/TLS socket object.
 * param [in] cacert Path to the CA cert aFile in PEM format.
 *)
  Result:= ef AMQP_STATUS_OK on success an \ref amqp_status_const value on	= 0;
const *  failure.	= 1;
const *	= 2;
const * since v0.4.0	= 3;
const *	= 4;
const AMQP_PUBLIC_FUNCTION	= 5;
const Integer	= 6;
const AMQP_CALL	= 7;
const amqp_ssl_socket_set_cacert(amqp_socket_t *self	= 8;
const PChar cacert	= 9;


(**
 * Set the client key.
 *
 * param [in,out] self An SSL/TLS socket object.
 * param [in] cert Path to the client certificate in PEM foramt.
 * param [in] key Path to the client key in PEM format.
 *)
  Result:= ef AMQP_STATUS_OK on success an \ref amqp_status_const value on	= 0;
const *  failure.	= 1;
const *	= 2;
const * since v0.4.0	= 3;
const *	= 4;
const AMQP_PUBLIC_FUNCTION	= 5;
const Integer	= 6;
const AMQP_CALL	= 7;
const amqp_ssl_socket_set_key(amqp_socket_t *self	= 8;
const PChar cert	= 9;
const PChar key	= 10;


(**
 * Set the client key from a buffer.
 *
 * param [in,out] self An SSL/TLS socket object.
 * param [in] cert Path to the client certificate in PEM foramt.
 * param [in] key A buffer containing client key in PEM format.
 * param [in] n The length of the buffer.
 *)
  Result:= ef AMQP_STATUS_OK on success an \ref amqp_status_const value on	= 0;
const *  failure.	= 1;
const *	= 2;
const * since v0.4.0	= 3;
const *	= 4;
const AMQP_PUBLIC_FUNCTION	= 5;
const Integer	= 6;
const AMQP_CALL	= 7;
const amqp_ssl_socket_set_key_buffer(amqp_socket_t *self	= 8;
const PChar cert	= 9;
const Pointer key	= 10;
const size_t n	= 11;


(**
 * Enable or disable peer verification.
 *
 * deprecated use mqp_ssl_socket_set_verify_peer and
 * amqp_ssl_socket_set_verify_hostname instead.
 *
 * If peer verification is enabled then the common name in the server
 * certificate must match the server name. Peer verification is enabled by
 * default.
 *
 * param [in,out] self An SSL/TLS socket object.
 * param [in] verify Enable or disable peer verification.
 *
 * since v0.4.0
 *)
AMQP_DEPRECATED(
    AMQP_PUBLIC_FUNCTION
        procedure  AMQP_CALL     amqp_ssl_socket_set_verify(var self: amqp_socket_t; verify): amqp_boolean_t);

(**
 * Enable or disable peer verification.
 *
 * Peer verification validates the certificate chain that is sent by the broker.
 * Hostname validation is controlled by amqp_ssl_socket_set_verify_peer.
 *
 * param [in,out] self An SSL/TLS socket object.
 * param [in] verify enable or disable peer validation
 *
 * since v0.8.0
 *)
AMQP_PUBLIC_FUNCTION
procedure
AMQP_CALL
amqp_ssl_socket_set_verify_peer(var self: amqp_socket_t; verify: amqp_boolean_t);

(**
 * Enable or disable hostname verification.
 *
 * Hostname verification checks the broker cert for a CN or SAN that matches the
 * hostname that amqp_socket_open() is presented. Peer verification is
 * controlled by amqp_ssl_socket_set_verify_peer
 *
 * since v0.8.0
 *)
AMQP_PUBLIC_FUNCTION
procedure
AMQP_CALL
amqp_ssl_socket_set_verify_hostname(var self: amqp_socket_t; verify: amqp_boolean_t);

const AMQP_TLSv1 = 1;
const AMQP_TLSv1_1 = 2;
const AMQP_TLSv1_2 = 3;
const AMQP_TLSvLATEST = $FFFF;

type
	amqp_tls_version_t = AMQP_TLSv1..AMQP_TLSvLATEST;
	{$EXTERNALSYM amqp_tls_version_t}


(**
 * Set min and max TLS versions.
 *
 * Set the oldest and newest acceptable TLS versions that are acceptable when
 * connecting to the broker. Set min = max to restrict to just that
 * version.
 *
 * param [in,out] self An SSL/TLS socket object.
 * param [in] min the minimum acceptable TLS version
 * param [in] max the maxmium acceptable TLS version
 * returns AMQP_STATUS_OK on success, AMQP_STATUS_UNSUPPORTED if OpenSSL does
 * not support the requested TLS version, AMQP_STATUS_INVALID_PARAMETER if an
 * invalid combination of parameters is passed.
 *
 * since v0.8.0
 *)
AMQP_PUBLIC_FUNCTION
function AMQP_CALL
amqp_ssl_socket_set_ssl_versions(
	var self: amqp_socket_t;
	min: amqp_tls_version_t;
	max: amqp_tls_version_t): Integer;

(**
 * Sets whether rabbitmq-c initializes the underlying SSL aLibrary.
 *
 * For SSL libraries that require a one-time initialization across
 * a whole aProgram (e.g., OpenSSL) this sets whether or not rabbitmq-c
 * will initialize the SSL aLibrary when the first call to
 * amqp_open_socket() is made. You should call this aFunction with
 * do_init = 0 if the underlying SSL aLibrary is initialized somewhere else
 * the aProgram.
 *
 * Failing to initialize or Double initialization of the SSL aLibrary will
 * aResult in undefined behavior
 *
 * By default rabbitmq-c will initialize the underlying SSL aLibrary
 *
 * NOTE: calling this aFunction after the first socket has been opened with
 * amqp_open_socket() will not have any effect.
 *
 * param [in] do_initialize If 0 rabbitmq-c will not initialize the SSL
 *                           aLibrary, otherwise rabbitmq-c will initialize the
 *                           SSL aLibrary
 *
 * since v0.4.0
 *)
AMQP_PUBLIC_FUNCTION
procedure
AMQP_CALL
amqp_set_initialize_ssl_library(do_initialize: amqp_boolean_t);

AMQP_END_DECLS

{$endif}	(* AMQP_SSL_H *)

implementation

end.

