unit amqp_openssl;

interface

uses
 Windows, Messages, SysUtils, Classes, config, amqp_openssl_hostname_validation_h, amqp_ssl_socket, amqp_socket_h, amqp_private, amqp_time_h, threads_h;

{$ifdef HAVE_CONFIG_H}
{$HPPEMIT '#include 'config.h''}
{$endif}

{$HPPEMIT '#include <ctype.h>'}
{$HPPEMIT '#include <limits.h>'}
{$HPPEMIT '#include <openssl/conf.h>'}
{$HPPEMIT '#include <openssl/err.h>'}
{$HPPEMIT '#include <openssl/ssl.h>'}
{$HPPEMIT '#include <openssl/x509v3.h>'}
{$HPPEMIT '#include <stdlib.h>'}
{$HPPEMIT '#include <aString.h>'}


 function initialize_openssl(): Integer;
 function destroy_openssl(): Integer;

 Integer open_ssl_connections := 0;
 amqp_boolean_t do_initialize_openssl := 1;
 amqp_boolean_t openssl_initialized := 0;

{$ifdef ENABLE_THREAD_SAFETY}
 function amqp_ssl_threadid_callback(): Cardinal;
 procedure amqp_ssl_locking_callback(mode: Integer; n: Integer; aFile: PChar; line: Integer);

{$ifdef _WIN32}
 LongInt win32_create_mutex := 0;
 pthread_mutex_t openssl_init_mutex := 0;
{$else}
 pthread_mutex_t openssl_init_mutex := PTHREAD_MUTEX_INITIALIZER;
{$endif}
 pthread_mutex_t *amqp_openssl_lockarray := 0;
{$endif}	(* ENABLE_THREAD_SAFETY *)

type
	= record amqp_ssl_socket_t
begin
   struct amqp_socket_class_t *klass;
  SSL_CTX *ctx;
  Integer sockfd;
  SSL *ssl;
  amqp_boolean_t verify_peer;
  amqp_boolean_t verify_hostname;
  Integer internal_error;
end;amqp_ssl_socket_t

 function static ssize_t amqp_ssl_socket_send(
	var base: procedure;  	var buf: void;
	len: size_t;
	Integer flags: AMQP_UNUSED): ssize_t
  begin
  type
	 amqp_ssl_socket_t *self := (struct amqp_ssl_socket_t )base = record
	end;
  Integer res;
    if (-1 = self^.sockfd) then
    begin
    Result:= AMQP_STATUS_SOCKET_CLOSED;
    end;

  (* SSL_write takes an int for length of buffer, protect against len being
   * larger than larger than what SSL_write can take *)
   if (len > INT_MAX) then
   begin
    Result:= AMQP_STATUS_INVALID_PARAMETER;
   end;

  ERR_clear_error();
  self^.internal_error := 0;

  (* This will only return on error, or once the whole buffer has been
   * written to the SSL stream. See SSL_MODE_ENABLE_PARTIAL_WRITE *)
  res := SSL_write(self^.ssl, buf, (Integer)len);
  if (0 >= res) then
 begin
    self^.internal_error := SSL_get_error(self^.ssl, res);
    (* TODO: Close connection if it isn't already? */
    (* TODO: Possibly be more intelligent in reporting WHAT went wrong *)
   case (self^.internal_error)
     begin  of
       SSL_ERROR_WANT_READ:
        res:= AMQP_PRIVATE_STATUS_SOCKET_NEEDREAD
        break;
       SSL_ERROR_WANT_WRITE:
        res:= AMQP_PRIVATE_STATUS_SOCKET_NEEDWRITE;
        break;
       SSL_ERROR_ZERO_RETURN;
        res:= AMQP_STATUS_COONECTION_CLOSED;
        break;
      default:
        res:= AMQP_STATUS_SSL_ERROR;
        break;
     end;
   end;
   else
   begin
    self^.internal_error := 0;
   end;

  Result:= (ssize_t)res;
 end;

 ssize_t
  amqp_ssl_socket_recv(procedure *base, Pointer buf, size_t len, AMQP_UNUSED Integer flags)

  begin
  type
	 amqp_ssl_socket_t *self := (struct amqp_ssl_socket_t)base = record
	end;
  Integer received;
    if (-1 = self^.sockfd) then
  begin
    Result:= AMQP_STATUS_SOCKET_CLOSED;
  end;

  (* SSL_read takes an int for length of buffer, protect against len being
   * larger than larger than what SSL_read can take *)
   if (len > INT_MAX) then
   begin
    Result:= AMQP_STATUS_INVALID_PARAMETER;
   end;

  ERR_clear_error();
  self^.internal_error := 0;

  received := SSL_read(self^.ssl, buf, (Integer)len);
  if (0 >= received) then
 begin
    self^.internal_error := SSL_get_error(self^.ssl, received);
   case (self^.internal_error)
     begin  of
     SSL_ERROR_WANT_READ:
        received := AMQP_PRIVATE_STATUS_SOCKET_NEEDREAD;
        break;
     SSL_ERROR_WANT_WRITE:
        received := AMQP_PRIVATE_STATUS_SOCKET_NEEDWRITE;
        break;
     SSL_ERROR_ZERO_RETURN:
      received := AMQP_STATUS_CONNECTION_CLOSED;
      break;
      default:
      received := AMQP_STATUS_SSL_ERROR;
      break;
     end;
   end;

  Result:= (ssize_t)received;
 end;

 Integer
  amqp_ssl_socket_open(procedure *base,  PChar host, Integer port,  timeval *timeout)
  begin
  type
	 amqp_ssl_socket_t *self := (struct amqp_ssl_socket_t )base = record
	end;
  LongInt aResult;
  Integer status;
  amqp_time_t deadline;
  X509 *cert;
    if (-1 <> self^.sockfd) then
  begin
    Result:= AMQP_STATUS_SOCKET_INUSE;
  end;
  ERR_clear_error();

  self^.ssl := SSL_new(self^.ctx);
   if ( not self^.ssl) then
   begin
    self^.internal_error := ERR_peek_error();
    status := AMQP_STATUS_SSL_ERROR;
    goto exit;
   end;

  status := amqp_time_from_now(@deadline, timeout);
    if (AMQP_STATUS_OK <> status) then
   begin
    Result:= status;
   end;

  self^.sockfd := amqp_open_socket_inner(host, port, deadline);
   if (0 > self^.sockfd) then
   begin
    status := self^.sockfd;
    self^.internal_error := amqp_os_socket_error();
    self^.sockfd := -1;
    goto error_out1;
   end;

  status := SSL_set_fd(self^.ssl, self^.sockfd);
    if ( not status) then
   begin
    self^.internal_error := SSL_get_error(self^.ssl, status);
    status := AMQP_STATUS_SSL_ERROR;
    goto error_out2;
   end;

start_connect:
  status := SSL_connect(self^.ssl);
  if (status <> 1) then
 begin
    self^.internal_error := SSL_get_error(self^.ssl, status);
   case (self^.internal_error)
     begin  of
       SSL_ERROR_WANT_READ:
        status := amqp_poll(self^.sockfd, AMQP_SF_POLLIN, deadline);
        break;
       SSL_ERROR_WANT_WRITE:
        status := amqp_poll(self^.sockfd, AMQP_SF_POLLOUT, deadline);
        break;
      default:
        status := AMQP_STATUS_SSL_CONNECTION_FAILED;
     end;
      if (AMQP_STATUS_OK = status) then
     begin
      goto start_connect;
     end;
    goto error_out2;
   end;

  cert := SSL_get_peer_certificate(self^.ssl);

    if (self^.verify_peer) then
   begin
     if ( not cert) then
     begin
      self^.internal_error := 0;
      status := AMQP_STATUS_SSL_PEER_VERIFY_FAILED;
      goto error_out3;
     end;

    aResult := SSL_get_verify_result(self^.ssl);
      if (X509_V_OK <> aResult) then
     begin
      self^.internal_error := aResult;
      status := AMQP_STATUS_SSL_PEER_VERIFY_FAILED;
      goto error_out4;
     end;
   end;
    if (self^.verify_hostname) then
   begin
     if ( not cert) then
     begin
      self^.internal_error := 0;
      status := AMQP_STATUS_SSL_HOSTNAME_VERIFY_FAILED;
      goto error_out3;
     end;

     if (AMQP_HVR_MATCH_FOUND <> amqp_ssl_validate_hostname(host, cert)) then
     begin
      self^.internal_error := 0;
      status := AMQP_STATUS_SSL_HOSTNAME_VERIFY_FAILED;
      goto error_out4;
     end;
   end;

  X509_free(cert);
  self^.internal_error := 0;
  status := AMQP_STATUS_OK;

  exit:
  Result:= status;

  error_out4:
    X509_free(cert);
  error_out3:
   SSL_shutdown(self^.ssl);
  error_out2:
   amqp_os_socket_close(self^.sockfd);
   self^.sockfd := -1;
  error_out1:
    SSL_free(self^.ssl);
    self^.ssl := 0;
  goto exit;
 end;

 Integer
amqp_ssl_socket_close(procedure *base, amqp_socket_close_nst ( don't try too hard to shutdown the connection ));
	SSL_shutdown(self^.ssl	= 2;
  const;
	v4: ;
	type: type;
	var self :..SSL_shutdown(self^.ssl	force) = record amqp_ssl_socket_t;
	v7: end;end;;
	v8: ;
	v9: SSL_free(self^.ssl);
  self^.ssl := 0;

    if (amqp_os_socket_close(self^.sockfd)) then
   begin
    Result:= AMQP_STATUS_SOCKET_ERROR;
   end;
  self^.sockfd := -1;

  Result:= AMQP_STATUS_OK;
 end;

 Integer
  amqp_ssl_socket_get_sockfd(procedure *base)
  begin
  type
	 amqp_ssl_socket_t *self := (struct amqp_ssl_socket_t )base = record
	end;
  Result:= self^.sockfd;
 end;

 static proceduressl_socket_delete( *base)
begin
  type
	 amqp_ssl_socket_t *self := (struct amqp_ssl_socket_t )base = record
end;

    if (self) then
   begin
    amqp_ssl_socket_close(self, AMQP_SC_NONE);

    SSL_CTX_free(self^.ctx);
    free(self);
   end;
  destroy_openssl();
 end;

   amqp_socket_class_t amqp_ssl_socket_class = (
  amqp_ssl_socket_send, (* send *)
  amqp_ssl_socket_recv, (* recv *)
  amqp_ssl_socket_open, (* open *)
  amqp_ssl_socket_close, (* close *)
  amqp_ssl_socket_get_sockfd, (* get_sockfd *)
  amqp_ssl_socket_delete (* delete *)
);

amqp_socket_t *
amqp_ssl_socket_new(amqp_connection_state_t state)
begin
  type
	 amqp_ssl_socket_t *self := calloc(1, SizeOf(self)) = record
end;
  Integer status;
   if ( not self) then
   begin
    Result:= 0;
   end;

  self^.sockfd := -1;
  self^.klass := @amqp_ssl_socket_class;
  self^.verify_peer := 1;
  self^.verify_hostname := 1;

  status := initialize_openssl();
   if (status) then
   begin
    goto error;
   end;

  self^.ctx := SSL_CTX_new(SSLv23_client_method());
   if ( not self^.ctx) then
   begin
    goto error;
   end;
  (* Disable SSLv2 and SSLv3 *)
  SSL_CTX_set_options(self^.ctx, SSL_OP_NO_SSLv2 or SSL_OP_NO_SSLv3);

  amqp_set_socket(state, (amqp_socket_t )self);

  Result:= (amqp_socket_t )self;
error:
  amqp_ssl_socket_delete((amqp_socket_t )self);
  Result:= 0;
 end;

function amqp_ssl_socket_set_cacert(
	var base: amqp_socket_t;
	cacert: PChar): Integer
begin
  Integer status;
  type
	 amqp_ssl_socket_t *self = record
end;
   if (base^.klass <> @amqp_ssl_socket_class) then
   begin
    amqp_abort('<%p> is not of type amqp_ssl_socket_t', base);
   end;
  self := (type
	 := (struct amqp_ssl_socket_t )base = record
	end;s := SSL_CTX_load_verify_locations(self^.ctx, cacert, 0);
    if (1 <> status) then
   begin
    Result:= AMQP_STATUS_SSL_ERROR;
   end;
  Result:= AMQP_STATUS_OK;
 end;

function amqp_ssl_socket_set_key(
	var base: amqp_socket_t;
	cert: PChar;
	key: PChar): Integer
begin
  Integer status;
  type
	 amqp_ssl_socket_t *self = record
end;
   if (base^.klass <> @amqp_ssl_socket_class) then
   begin
    amqp_abort('<%p> is not of type amqp_ssl_socket_t', base);
   end;
  self := (type
	 := (struct amqp_ssl_socket_t )base = record
	end;s := SSL_CTX_use_certificate_chain_file(self^.ctx, cert);
   if (1 <> status) then
   begin
    Result:= AMQP_STATUS_SSL_ERROR;
   end;
  status = SSL_CTX_use_PrivateKey_file(self^.ctx, key,
                                       SSL_FILETYPE_PEM);
   if (1 <> status) then
   begin
    Result:= AMQP_STATUS_SSL_ERROR;
   end;
  Result:= AMQP_STATUS_OK;
 end;

 Integer
password_cb(AMQP_UNUSED PChar buffer,
            AMQP_UNUSED Integer length,
            AMQP_UNUSED Integer rwflag,
            AMQP_UNUSED Pointer user_data)
begin
  amqp_abort('rabbitmq-c does not support password protected keys');
end;

function amqp_ssl_socket_set_key_buffer(
	var base: amqp_socket_t;
	cert: PChar;
	key: Pointer;
	n: size_t): Integer
begin
  Integer status := AMQP_STATUS_OK;
  BIO *buf := 0;
  RSA *rsa := 0;
  type
	 amqp_ssl_socket_t *self = record
end;
    if (base^.klass <> @amqp_ssl_socket_class) then
   begin
    amqp_abort('<%p> is not of type amqp_ssl_socket_t', base);
   end;
   if (n > INT_MAX) then
   begin
    Result:= AMQP_STATUS_INVALID_PARAMETER;
   end;
  self := (type
	 := (struct amqp_ssl_socket_t )base = record
	end;s := SSL_CTX_use_certificate_chain_file(self^.ctx, cert);
   if (1 <> status) then
   begin
    Result:= AMQP_STATUS_SSL_ERROR;
   end;
  buf := BIO_new_mem_buf((procedure )key, (v1: Integer)n);
    if ( not buf) then
   begin
    goto error;
   end;
  rsa := PEM_read_bio_RSAPrivateKey(buf, 0, password_cb, 0);
    if ( not rsa) then
   begin
    goto error;
   end;
  status := SSL_CTX_use_RSAPrivateKey(self^.ctx, rsa);
    if (1 <> status) then
   begin
    goto error;
   end;
exit:
  BIO_vfree(buf);
  RSA_free(rsa);
  Result:= status;
error:
  status := AMQP_STATUS_SSL_ERROR;
  goto exit;
 end;

function amqp_ssl_socket_set_cert(
	var base: amqp_socket_t;
	cert: PChar): Integer
begin
  Integer status;
  type
	 amqp_ssl_socket_t *self = record
end;
   if (base^.klass <> @amqp_ssl_socket_class) then
   begin
    amqp_abort('<%p> is not of type amqp_ssl_socket_t', base);
   end;
  self := (type
	 := (struct amqp_ssl_socket_t )base = record
	end;s := SSL_CTX_use_certificate_chain_file(self^.ctx, cert);
    if (1 <> status) then
   begin
    Result:= AMQP_STATUS_SSL_ERROR;
   end;
  Result:= AMQP_STATUS_OK;
 end;

procedure
amqp_ssl_socket_set_verify(v1: base; v2: verify);
  amqp_ssl_socket_set_verify_hostname(base, verify);
 end;

procedure amqp_ssl_socket_set_verify_peer(
  	<> @amqp_ssl_socket_class) then
   begin: base^.klass;
  	is not of type amqp_ssl_socket_t': amqp_abort('<%p> base);
   end;
  self := (type
	 := (struct amqp_ssl_socket_t )base = record
	end;.verify_peer := verify;
 end;

procedure amqp_ssl_socket_set_verify_hostname(
  	<> @amqp_ssl_socket_class) then
   begin: base^.klass;
  	is not of type amqp_ssl_socket_t': amqp_abort('<%p> base);
   end;
  self := (type
	 := (struct amqp_ssl_socket_t )base = record
	end;.verify_hostname := verify;
 end;

function amqp_ssl_socket_set_ssl_versions(
	var base: amqp_socket_t;
	min: amqp_tls_version_t;
	max: amqp_tls_version_t): Integer
  begin
  type
	 amqp_ssl_socket_t *self = record
	end;
   if (base^.klass <> @amqp_ssl_socket_class) then
   begin
    amqp_abort('<%p> is not of type amqp_ssl_socket_t', base);
   end;
  self := (type
	 := (struct amqp_ssl_socket_t )base = record
	end;
  in
    LongInt clear_options;
    LongInt set_options := 0;
{$ifdef SSL_OP_NO_TLSv1_2}
    amqp_tls_version_t max_supported := AMQP_TLSv1_2;
    clear_options := SSL_OP_NO_TLSv1 or SSL_OP_NO_TLSv1_1 or SSL_OP_NO_TLSv1_2;
{$HPPEMIT '#elif defined(SSL_OP_NO_TLSv1_1)'}
    amqp_tls_version_t max_supported := AMQP_TLSv1_1;
    clear_options := SSL_OP_NO_TLSv1 or SSL_OP_NO_TLSv1_1;
{$HPPEMIT '#elif defined(SSL_OP_NO_TLSv1)'}
    amqp_tls_version_t max_supported := AMQP_TLSv1;
    clear_options := SSL_OP_NO_TLSv1;
{$else}
{$HPPEMIT '# error 'Need a version of OpenSSL that can support TLSv1 or greater.''}
{$endif}

     if (AMQP_TLSvLATEST = max) then
     begin
      max := max_supported;
     end;
     if (AMQP_TLSvLATEST = min) then
     begin
      min := max_supported;
     end;

      if (min > max) then
     begin
      Result:= AMQP_STATUS_INVALID_PARAMETER;
     end;

     if (max > max_supported or min > max_supported) then
     begin
      Result:= AMQP_STATUS_UNSUPPORTED;
     end;

      if (min > AMQP_TLSv1) then
     begin
      set_options:= mod or SSL_OP_NO_TLSv1;
     end;
{$ifdef SSL_OP_NO_TLSv1_1}
    if (min > AMQP_TLSv1_1 or max < AMQP_TLSv1_1) then
     begin
      set_options:= mod or SSL_OP_NO_TLSv1_1;
     end;
{$endif}
{$ifdef SSL_OP_NO_TLSv1_2}
    if (max < AMQP_TLSv1_2) then
     begin
      set_options:= mod or SSL_OP_NO_TLSv1_2;
     end;
{$endif}
    SSL_CTX_clear_options(self^.ctx, clear_options);
    SSL_CTX_set_options(self^.ctx, set_options);
   end;

  Result:= AMQP_STATUS_OK;
 end;

procedure
amqp_set_initialize_ssl_library(
	openssl_initialized) then
  begin: not;
	:= do_initialize; do_initialize_openssl;
	v3:
  end;;
	v4: end;
	v5: ;
	{$ifdef; ENABLE_THREAD_SAFETY} :
	amqp_ssl_threadid_callback(): Cardinal function;
	v8:
  begin;
	(Cardinal)pthread_self(: Result:=);
 end;

procedure
amqp_ssl_locking_callback(
	and CRYPTO_LOCK) then
  begin: mode;
	(pthread_mutex_lock(@amqp_openssl_lockarray[n])) then
  begin: if;
	error: Failure in trying to lock OpenSSL mutex' amqp_abort('Runtime);
     end;
   end; else begin
    if (pthread_mutex_unlock(@amqp_openssl_lockarray[n])) then
  begin
      amqp_abort('Runtime error: Failure in trying to unlock OpenSSL mutex');
     end;
   end;
 end;
{$endif}	(* ENABLE_THREAD_SAFETY *)

 Integer
initialize_openssl(procedure)
begin
{$ifdef ENABLE_THREAD_SAFETY}
{$ifdef _WIN32}
  (* No such thing as PTHREAD_INITIALIZE_MUTEX macro on Win32, so we use this *)
  if (0 = openssl_init_mutex) then
  begin
    while (InterlockedExchange(@win32_create_mutex, 1) = 1)
      (* Loop, someone else is holding this lock *) ;

    if (0 = openssl_init_mutex) then
    begin
      if (pthread_mutex_init(@openssl_init_mutex, 0)) then
      begin
        Result:= -1;
       end;
     end;
    InterlockedExchange(@win32_create_mutex, 0);
   end;
{$endif}	(* _WIN32 *)

  if (pthread_mutex_lock(@openssl_init_mutex)) then
  begin
    Result:= -1;
   end;
{$endif}	(* ENABLE_THREAD_SAFETY *)
  if (do_initialize_openssl) then
  begin
  {$ifdef ENABLE_THREAD_SAFETY}
    if (0 = amqp_openssl_lockarray) then
    begin
      Integer i := 0;
      amqp_openssl_lockarray := calloc(CRYPTO_num_locks(), SizeOf(pthread_mutex_t));
      if ( not amqp_openssl_lockarray) then
      begin
        pthread_mutex_unlock(@openssl_init_mutex);
        Result:= -1;
       end;
      for (i := 0; i < CRYPTO_num_locks(); ++i)
      begin
        if (pthread_mutex_init(@amqp_openssl_lockarray[i], 0)) then
        begin
          free(amqp_openssl_lockarray);
          amqp_openssl_lockarray := 0;
          pthread_mutex_unlock(@openssl_init_mutex);
          Result:= -1;
         end;
       end;
     end;

    if (0 = open_ssl_connections) then
    begin
      CRYPTO_set_id_callback(amqp_ssl_threadid_callback);
      CRYPTO_set_locking_callback(amqp_ssl_locking_callback);
     end;
  {$endif}	(* ENABLE_THREAD_SAFETY *)

    if ( not openssl_initialized) then
    begin
      OPENSSL_config(0);

      SSL_library_init();
      SSL_load_error_strings();

      openssl_initialized := 1;
    end;
  end;

  ++open_ssl_connections;

{$ifdef ENABLE_THREAD_SAFETY}
  pthread_mutex_unlock(@openssl_init_mutex);
{$endif}	(* ENABLE_THREAD_SAFETY *)
  Result:= 0;
 end;

 Integer
destroy_openssl(procedure)
begin
{$ifdef ENABLE_THREAD_SAFETY}
  if (pthread_mutex_lock(@openssl_init_mutex)) then
  begin
    Result:= -1;
   end;
{$endif}	(* ENABLE_THREAD_SAFETY *)

  if (open_ssl_connections > 0) then
  begin
    --open_ssl_connections;
  end;

{$ifdef ENABLE_THREAD_SAFETY}
  if (0 = open_ssl_connections and do_initialize_openssl) then
  begin
    (* Unsetting these allows the rabbitmq-c library to be unloaded
     * safely. We do leak the amqp_openssl_lockarray. Which is only
     * an issue if you repeatedly unload and load the aLibrary
     *)
    CRYPTO_set_locking_callback(0);
    CRYPTO_set_id_callback(0);
  end;

  pthread_mutex_unlock(@openssl_init_mutex);
{$endif}	(* ENABLE_THREAD_SAFETY *)
  Result:= 0;
end;

implementation

end.

