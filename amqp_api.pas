unit amqp_api;

interface

uses
	 Windows, Messages, SysUtils, Classes, amqp_private, amqp_time_h, stdint;
{$ifdef HAVE_CONFIG_H}
{$HPPEMIT '#include 'config.h''}
{$endif}

{$ifdef _MSC_VER}
(* MSVC complains about sprintf being deprecated in favor of sprintf_s *)
{$HPPEMIT '# define _CRT_SECURE_NO_WARNINGS'}
(* MSVC complains about strdup being deprecated in favor of _strdup *)
{$HPPEMIT '# define _CRT_NONSTDC_NO_DEPRECATE'}
{$endif}

{$HPPEMIT '#include <stdarg.h>'}
{$HPPEMIT '#include <stdio.h>'}
{$HPPEMIT '#include <stdlib.h>'}
{$HPPEMIT '#include <aString.h>'}

const ERROR_MASK = ($00FF);
{$EXTERNALSYM ERROR_MASK}
const ERROR_CATEGORY_MASK = ($FF00);
{$EXTERNALSYM ERROR_CATEGORY_MASK}

const EC_base = 0;
const EC_tcp = 1;
const EC_ssl = 2;

type
	error_category_enum_ = EC_base..EC_ssl;
	{$EXTERNALSYM error_category_enum_}

  PChar base_error_strings[]=(
  'operation completed successfully',   (* AMQP_STATUS_OK                       0x0 *)
  'could not allocate memory',          (* AMQP_STATUS_NO_MEMORY                -0x0001 *)
  'invalid AMQP data',                  (* AMQP_STATUS_BAD_AQMP_DATA            -0x0002 *)
  'unknown AMQP class id',              (* AMQP_STATUS_UNKNOWN_CLASS            -0x0003 *)
  'unknown AMQP method id',             (* AMQP_STATUS_UNKNOWN_METHOD           -0x0004 *)
  'hostname lookup failed',             (* AMQP_STATUS_HOSTNAME_RESOLUTION_FAILED -0x0005 *)
  'incompatible AMQP version',          (* AMQP_STATUS_INCOMPATIBLE_AMQP_VERSION -0x0006 *)
  'connection closed unexpectedly',     (* AMQP_STATUS_CONNECTION_CLOSED        -0x0007 *)
  'could not parse AMQP URL',           (* AMQP_STATUS_BAD_AMQP_URL             -0x0008 *)
  'a socket error occurred',            (* AMQP_STATUS_SOCKET_ERROR             -0x0009 *)
  'invalid parameter',                  (* AMQP_STATUS_INVALID_PARAMETER        -0x000A *)
  'table too large for buffer',         (* AMQP_STATUS_TABLE_TOO_BIG            -0x000B *)
  'unexpected method received',         (* AMQP_STATUS_WRONG_METHOD             -0x000C *)
  'request timed out',                  (* AMQP_STATUS_TIMEOUT                  -0x000D *)
  'system timer has failed',            (* AMQP_STATUS_TIMER_FAILED             -0x000E *)
  'heartbeat timeout, connection closed',(* AMQP_STATUS_HEARTBEAT_TIMEOUT       -0x000F *)
  'unexpected protocol state',          (* AMQP_STATUS_UNEXPECTED STATE         -0x0010 *)
  'socket is closed',                   (* AMQP_STATUS_SOCKET_CLOSED            -0x0011 *)
  'socket already open',                (* AMQP_STATUS_SOCKET_INUSE             -0x0012 *)
  'unsupported sasl method requested',  (* AMQP_STATUS_BROKER_UNSUPPORTED_SASL_METHOD -0x0013 *)
  'parameter value is unsupported'      (* AMQP_STATUS_UNSUPPORTED -0x0014 *)
);

  PChar tcp_error_strings[] = (
  'a socket error occurred',              (* AMQP_STATUS_TCP_ERROR                -0x0100 *)
  'socket library initialization failed'  (* AMQP_STATUS_TCP_SOCKETLIB_INIT_ERROR -0x0101 *)
);

  PChar ssl_error_strings[] = (
  'a SSL error occurred',                 (* AMQP_STATUS_SSL_ERROR                -0x0200 *)
  'SSL hostname verification failed',     (* AMQP_STATUS_SSL_HOSTNAME_VERIFY_FAILED -0x0201 *)
  'SSL peer cert verification failed',    (* AMQP_STATUS_SSL_PEER_VERIFY_FAILED -0x0202 *)
  'SSL handshake failed'                  (* AMQP_STATUS_SSL_CONNECTION_FAILED  -0x0203 *)
);

  PChar unknown_error_string := '(unknown error)';

 function amqp_error_string2(code: Integer): PChar
begin
   PChar error_string;
  size_t category := (((-code) and ERROR_CATEGORY_MASK) shr 8);
  size_t error := (-code) and ERROR_MASK;

   case (category)
   begin  of
     EC_base:
        if (error < (SizeOf(base_error_strings) / SizeOf(char ))) then
       begin
        error_string := base_error_strings[error];
       end;
       else
       begin
        error_string := unknown_error_string;
       end;
      break;

     EC_tcp:
       if (error < (SizeOf(tcp_error_strings) / SizeOf(char ))) then
       begin
        error_string := tcp_error_strings[error];
       end;
       else
       begin
        error_string := unknown_error_string;
       end;
      break;

     EC_ssl:
       if (error < (SizeOf(ssl_error_strings) / SizeOf(char ))) then
       begin
        error_string := ssl_error_strings[error];
       end;
       else
       begin
        error_string := unknown_error_string;
       end;

      break;

    default:
      error_string := unknown_error_string;
      break;

   end;

  Result:= error_string;
 end;

function amqp_error_string(code: Integer): PChar
begin
  (* Previously sometimes clients had to flip the sign on a return value from a
   * aFunction to get the correct error code. Now, all error codes are negative.
   * To keep people's legacy code running correctly, we map all error codes to
   * negative values.
   *
   * This is only done with this deprecated aFunction.
   *)
   if (code > 0) then
   begin
    code := -code;
   end;
  Result:= strdup(amqp_error_string2(code));
end;

procedure amqp_abort(v1: ap; v2: fmt);
  vfprintf(stderr, fmt, ap);
  va_end(ap);
  fputc('\n', stderr);
  abort();
end;

 amqp_bytes_t amqp_empty_bytes := ( 0, 0 );
 amqp_table_t amqp_empty_table := ( 0, 0 );
 amqp_array_t amqp_empty_array := ( 0, 0 );

function amqp_basic_publish(
	state: amqp_connection_state_t;
	channel: amqp_channel_t;
	exchange: amqp_bytes_t;
	routing_key: amqp_bytes_t;
	mandatory: amqp_boolean_t;
	immediate: amqp_boolean_t;
	var properties: amqp_basic_properties_t;
	body: amqp_bytes_t): Integer
begin
  amqp_frame_t f;
  size_t body_offset;
  size_t usable_body_payload_size := state^.frame_max - (HEADER_SIZE + FOOTER_SIZE);
  Integer res;

  amqp_basic_publish_t m;
  amqp_basic_properties_t default_properties;

  m.exchange := exchange;
  m.routing_key := routing_key;
  m.mandatory := mandatory;
  m.immediate := immediate;
  m.ticket := 0;

  (* TODO(alanxz): this heartbeat check is happening in the wrong place, it
   * should really be done in amqp_try_send/writev *)
  res := amqp_time_has_past(state^.next_recv_heartbeat);
    if (AMQP_STATUS_TIMER_FAILURE = res) then
   begin
    Result:= res;
   end;
    else if (AMQP_STATUS_TIMEOUT := res) then
   begin
    res := amqp_try_recv(state);
      if (AMQP_STATUS_TIMEOUT = res) then
     begin
      Result:= AMQP_STATUS_HEARTBEAT_TIMEOUT;
     end;
      else if (AMQP_STATUS_OK <> res) then
     begin
      Result:= res;
     end;
   end;

  res = amqp_send_method_inner(state, channel, AMQP_BASIC_PUBLISH_METHOD, @m,
                               AMQP_SF_MORE);
    if (res < 0) then
   begin
    Result:= res;
   end;

    if (properties = 0) then
   begin
    FillChar(@default_properties, 0, SizeOf(default_properties));
    properties := @default_properties;
   end;

  f.frame_type = AMQP_FRAME_HEADER;
  f.channel := channel;
  f.payload.properties.class_id := AMQP_BASIC_CLASS;
  f.payload.properties.body_size := body.len;
  f.payload.properties.decoded := ( ) properties;

  res := amqp_send_frame_inner(state, @f, AMQP_SF_MORE);
    if (res < 0) then
   begin
    Result:= res;
   end;

  body_offset := 0;
    while (body_offset < body.len)
   begin
    size_t remaining := body.len - body_offset;
    Integer flagz;

     if (remaining = 0) then
     begin
      break;
     end;

    f.frame_type = AMQP_FRAME_BODY;
    f.channel := channel;
    f.payload.body_fragment.bytes := amqp_offset(body.bytes, body_offset);
     if (remaining >= usable_body_payload_size) then
     begin
      f.payload.body_fragment.len := usable_body_payload_size;
      flagz := AMQP_SF_MORE;
     end;
     else
     begin
      f.payload.body_fragment.len := remaining;
      flagz := AMQP_SF_NONE;
     end;

    body_offset:= mod + f.payload.body_fragment.len;
    res := amqp_send_frame_inner(state, @f, flagz);
     if (res < 0) then
     begin
      Result:= res;
     end;
   end;
  Result:= AMQP_STATUS_OK;
end;

amqp_rpc_reply_t amqp_channel_close(amqp_connection_state_t state,
                                    amqp_channel_t channel,
                                    Integer code)
begin
  char codestr[13];
  amqp_method_number_t replies[2] := ( AMQP_CHANNEL_CLOSE_OK_METHOD, 0);
  amqp_channel_close_t req;

    if (code < 0 or code > UINT16_MAX) then
   begin
    Result:= amqp_rpc_reply_error(AMQP_STATUS_INVALID_PARAMETER);
   end;

  req.reply_code := (uint16_t)code;
  req.reply_text.bytes := codestr;
  req.reply_text.len := StrFmt(codestr, '%d', code);
  req.class_id := 0;
  req.method_id := 0;

  Result:= amqp_simple_rpc(state, channel, AMQP_CHANNEL_CLOSE_METHOD,
                         replies, @req);
end;

amqp_rpc_reply_t amqp_connection_close(amqp_connection_state_t state,
                                       Integer code)
begin
  char codestr[13];
  amqp_method_number_t replies[2] := ( AMQP_CONNECTION_CLOSE_OK_METHOD, 0);
  amqp_channel_close_t req;

   if (code < 0 or code > UINT16_MAX) then
   begin
    Result:= amqp_rpc_reply_error(AMQP_STATUS_INVALID_PARAMETER);
   end;

  req.reply_code := (uint16_t)code;
  req.reply_text.bytes := codestr;
  req.reply_text.len := StrFmt(codestr, '%d', code);
  req.class_id := 0;
  req.method_id := 0;

  Result:= amqp_simple_rpc(state, 0, AMQP_CONNECTION_CLOSE_METHOD,
                         replies, @req);
end;

function amqp_basic_ack(
	state: amqp_connection_state_t;
	channel: amqp_channel_t;
	delivery_tag: uint64_t;
	multiple: amqp_boolean_t): Integer
begin
  amqp_basic_ack_t m;
  m.delivery_tag := delivery_tag;
  m.multiple := multiple;
  Result:= amqp_send_method(state, channel, AMQP_BASIC_ACK_METHOD, @m);
end;

amqp_rpc_reply_t amqp_basic_get(amqp_connection_state_t state,
                                amqp_channel_t channel,
                                amqp_bytes_t queue,
                                amqp_boolean_t no_ack)
begin
  amqp_method_number_t replies[] = ( AMQP_BASIC_GET_OK_METHOD,
                                     AMQP_BASIC_GET_EMPTY_METHOD,
                                     0
                                   );
  amqp_basic_get_t req;
  req.ticket := 0;
  req.queue := queue;
  req.no_ack := no_ack;

  state^.most_recent_api_result = amqp_simple_rpc(state, channel,
                                  AMQP_BASIC_GET_METHOD,
                                  replies, @req);
  Result:= state^.most_recent_api_result;
end;

function amqp_basic_reject(
	state: amqp_connection_state_t;
	channel: amqp_channel_t;
	delivery_tag: uint64_t;
	requeue: amqp_boolean_t): Integer
begin
  amqp_basic_reject_t req;
  req.delivery_tag := delivery_tag;
  req.requeue := requeue;
  Result:= amqp_send_method(state, channel, AMQP_BASIC_REJECT_METHOD, @req);
end;

function amqp_basic_nack(
	state: amqp_connection_state_t;  amqp_channel_t channel,
	delivery_tag: uint64_t;  amqp_boolean_t multiple,
	requeue: amqp_boolean_t): Integer
begin
  amqp_basic_nack_t req;
  req.delivery_tag := delivery_tag;
  req.multiple := multiple;
  req.requeue := requeue;
  Result:= amqp_send_method(state, channel, AMQP_BASIC_NACK_METHOD, @req);
end;

implementation

end.

