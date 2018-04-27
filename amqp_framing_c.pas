unit amqp_framing_c;

interface

uses
	Windows, Messages, SysUtils, Classes, amqp_private, stdint, config;
{$ifdef HAVE_CONFIG_H}
{$endif}

{$HPPEMIT '#include <stdio.h>'}
{$HPPEMIT '#include <stdlib.h>'}
{$HPPEMIT '#include <aString.h>'}


PChar amqp_constant_name(Integer constantNumber)
begin
    case (constantNumber)
   begin  of
     AMQP_FRAME_METHOD: Result:= 'AMQP_FRAME_METHOD';
     AMQP_FRAME_HEADER: Result:= 'AMQP_FRAME_HEADER';
     AMQP_FRAME_BODY: Result:= 'AMQP_FRAME_BODY';
     AMQP_FRAME_HEARTBEAT: Result:= 'AMQP_FRAME_HEARTBEAT';
     AMQP_FRAME_MIN_SIZE: Result:= 'AMQP_FRAME_MIN_SIZE';
     AMQP_FRAME_END: Result:= 'AMQP_FRAME_END';
     AMQP_REPLY_SUCCESS: Result:= 'AMQP_REPLY_SUCCESS';
     AMQP_CONTENT_TOO_LARGE: Result:= 'AMQP_CONTENT_TOO_LARGE';
     AMQP_NO_ROUTE: Result:= 'AMQP_NO_ROUTE';
     AMQP_NO_CONSUMERS: Result:= 'AMQP_NO_CONSUMERS';
     AMQP_ACCESS_REFUSED: Result:= 'AMQP_ACCESS_REFUSED';
     AMQP_NOT_FOUND: Result:= 'AMQP_NOT_FOUND';
     AMQP_RESOURCE_LOCKED: Result:= 'AMQP_RESOURCE_LOCKED';
     AMQP_PRECONDITION_FAILED: Result:= 'AMQP_PRECONDITION_FAILED';
     AMQP_CONNECTION_FORCED: Result:= 'AMQP_CONNECTION_FORCED';
     AMQP_INVALID_PATH: Result:= 'AMQP_INVALID_PATH';
     AMQP_FRAME_ERROR: Result:= 'AMQP_FRAME_ERROR';
     AMQP_SYNTAX_ERROR: Result:= 'AMQP_SYNTAX_ERROR';
     AMQP_COMMAND_INVALID: Result:= 'AMQP_COMMAND_INVALID';
     AMQP_CHANNEL_ERROR: Result:= 'AMQP_CHANNEL_ERROR';
     AMQP_UNEXPECTED_FRAME: Result:= 'AMQP_UNEXPECTED_FRAME';
     AMQP_RESOURCE_ERROR: Result:= 'AMQP_RESOURCE_ERROR';
     AMQP_NOT_ALLOWED: Result:= 'AMQP_NOT_ALLOWED';
     AMQP_NOT_IMPLEMENTED: Result:= 'AMQP_NOT_IMPLEMENTED';
     AMQP_INTERNAL_ERROR: Result:= 'AMQP_INTERNAL_ERROR';
    default: Result:= '(unknown)';
   end;
 end;

amqp_boolean_t amqp_constant_is_hard_error(Integer constantNumber)
begin
    case (constantNumber)
   begin  of
     AMQP_CONNECTION_FORCED: Result:= 1;
     AMQP_INVALID_PATH: Result:= 1;
     AMQP_FRAME_ERROR: Result:= 1;
     AMQP_SYNTAX_ERROR: Result:= 1;
     AMQP_COMMAND_INVALID: Result:= 1;
     AMQP_CHANNEL_ERROR: Result:= 1;
     AMQP_UNEXPECTED_FRAME: Result:= 1;
     AMQP_RESOURCE_ERROR: Result:= 1;
     AMQP_NOT_ALLOWED: Result:= 1;
     AMQP_NOT_IMPLEMENTED: Result:= 1;
     AMQP_INTERNAL_ERROR: Result:= 1;
    default: Result:= 0;
   end;
 end;

function amqp_method_name(methodNumber: amqp_method_number_t): PChar
begin
    case (methodNumber)
   begin  of
     AMQP_CONNECTION_START_METHOD: Result:= 'AMQP_CONNECTION_START_METHOD';
     AMQP_CONNECTION_START_OK_METHOD: Result:= 'AMQP_CONNECTION_START_OK_METHOD';
     AMQP_CONNECTION_SECURE_METHOD: Result:= 'AMQP_CONNECTION_SECURE_METHOD';
     AMQP_CONNECTION_SECURE_OK_METHOD: Result:= 'AMQP_CONNECTION_SECURE_OK_METHOD';
     AMQP_CONNECTION_TUNE_METHOD: Result:= 'AMQP_CONNECTION_TUNE_METHOD';
     AMQP_CONNECTION_TUNE_OK_METHOD: Result:= 'AMQP_CONNECTION_TUNE_OK_METHOD';
     AMQP_CONNECTION_OPEN_METHOD: Result:= 'AMQP_CONNECTION_OPEN_METHOD';
     AMQP_CONNECTION_OPEN_OK_METHOD: Result:= 'AMQP_CONNECTION_OPEN_OK_METHOD';
     AMQP_CONNECTION_CLOSE_METHOD: Result:= 'AMQP_CONNECTION_CLOSE_METHOD';
     AMQP_CONNECTION_CLOSE_OK_METHOD: Result:= 'AMQP_CONNECTION_CLOSE_OK_METHOD';
     AMQP_CONNECTION_BLOCKED_METHOD: Result:= 'AMQP_CONNECTION_BLOCKED_METHOD';
     AMQP_CONNECTION_UNBLOCKED_METHOD: Result:= 'AMQP_CONNECTION_UNBLOCKED_METHOD';
     AMQP_CHANNEL_OPEN_METHOD: Result:= 'AMQP_CHANNEL_OPEN_METHOD';
     AMQP_CHANNEL_OPEN_OK_METHOD: Result:= 'AMQP_CHANNEL_OPEN_OK_METHOD';
     AMQP_CHANNEL_FLOW_METHOD: Result:= 'AMQP_CHANNEL_FLOW_METHOD';
     AMQP_CHANNEL_FLOW_OK_METHOD: Result:= 'AMQP_CHANNEL_FLOW_OK_METHOD';
     AMQP_CHANNEL_CLOSE_METHOD: Result:= 'AMQP_CHANNEL_CLOSE_METHOD';
     AMQP_CHANNEL_CLOSE_OK_METHOD: Result:= 'AMQP_CHANNEL_CLOSE_OK_METHOD';
     AMQP_ACCESS_REQUEST_METHOD: Result:= 'AMQP_ACCESS_REQUEST_METHOD';
     AMQP_ACCESS_REQUEST_OK_METHOD: Result:= 'AMQP_ACCESS_REQUEST_OK_METHOD';
     AMQP_EXCHANGE_DECLARE_METHOD: Result:= 'AMQP_EXCHANGE_DECLARE_METHOD';
     AMQP_EXCHANGE_DECLARE_OK_METHOD: Result:= 'AMQP_EXCHANGE_DECLARE_OK_METHOD';
     AMQP_EXCHANGE_DELETE_METHOD: Result:= 'AMQP_EXCHANGE_DELETE_METHOD';
     AMQP_EXCHANGE_DELETE_OK_METHOD: Result:= 'AMQP_EXCHANGE_DELETE_OK_METHOD';
     AMQP_EXCHANGE_BIND_METHOD: Result:= 'AMQP_EXCHANGE_BIND_METHOD';
     AMQP_EXCHANGE_BIND_OK_METHOD: Result:= 'AMQP_EXCHANGE_BIND_OK_METHOD';
     AMQP_EXCHANGE_UNBIND_METHOD: Result:= 'AMQP_EXCHANGE_UNBIND_METHOD';
     AMQP_EXCHANGE_UNBIND_OK_METHOD: Result:= 'AMQP_EXCHANGE_UNBIND_OK_METHOD';
     AMQP_QUEUE_DECLARE_METHOD: Result:= 'AMQP_QUEUE_DECLARE_METHOD';
     AMQP_QUEUE_DECLARE_OK_METHOD: Result:= 'AMQP_QUEUE_DECLARE_OK_METHOD';
     AMQP_QUEUE_BIND_METHOD: Result:= 'AMQP_QUEUE_BIND_METHOD';
     AMQP_QUEUE_BIND_OK_METHOD: Result:= 'AMQP_QUEUE_BIND_OK_METHOD';
     AMQP_QUEUE_PURGE_METHOD: Result:= 'AMQP_QUEUE_PURGE_METHOD';
     AMQP_QUEUE_PURGE_OK_METHOD: Result:= 'AMQP_QUEUE_PURGE_OK_METHOD';
     AMQP_QUEUE_DELETE_METHOD: Result:= 'AMQP_QUEUE_DELETE_METHOD';
     AMQP_QUEUE_DELETE_OK_METHOD: Result:= 'AMQP_QUEUE_DELETE_OK_METHOD';
     AMQP_QUEUE_UNBIND_METHOD: Result:= 'AMQP_QUEUE_UNBIND_METHOD';
     AMQP_QUEUE_UNBIND_OK_METHOD: Result:= 'AMQP_QUEUE_UNBIND_OK_METHOD';
     AMQP_BASIC_QOS_METHOD: Result:= 'AMQP_BASIC_QOS_METHOD';
     AMQP_BASIC_QOS_OK_METHOD: Result:= 'AMQP_BASIC_QOS_OK_METHOD';
     AMQP_BASIC_CONSUME_METHOD: Result:= 'AMQP_BASIC_CONSUME_METHOD';
     AMQP_BASIC_CONSUME_OK_METHOD: Result:= 'AMQP_BASIC_CONSUME_OK_METHOD';
     AMQP_BASIC_CANCEL_METHOD: Result:= 'AMQP_BASIC_CANCEL_METHOD';
     AMQP_BASIC_CANCEL_OK_METHOD: Result:= 'AMQP_BASIC_CANCEL_OK_METHOD';
     AMQP_BASIC_PUBLISH_METHOD: Result:= 'AMQP_BASIC_PUBLISH_METHOD';
     AMQP_BASIC_RETURN_METHOD: Result:= 'AMQP_BASIC_RETURN_METHOD';
     AMQP_BASIC_DELIVER_METHOD: Result:= 'AMQP_BASIC_DELIVER_METHOD';
     AMQP_BASIC_GET_METHOD: Result:= 'AMQP_BASIC_GET_METHOD';
     AMQP_BASIC_GET_OK_METHOD: Result:= 'AMQP_BASIC_GET_OK_METHOD';
     AMQP_BASIC_GET_EMPTY_METHOD: Result:= 'AMQP_BASIC_GET_EMPTY_METHOD';
     AMQP_BASIC_ACK_METHOD: Result:= 'AMQP_BASIC_ACK_METHOD';
     AMQP_BASIC_REJECT_METHOD: Result:= 'AMQP_BASIC_REJECT_METHOD';
     AMQP_BASIC_RECOVER_ASYNC_METHOD: Result:= 'AMQP_BASIC_RECOVER_ASYNC_METHOD';
     AMQP_BASIC_RECOVER_METHOD: Result:= 'AMQP_BASIC_RECOVER_METHOD';
     AMQP_BASIC_RECOVER_OK_METHOD: Result:= 'AMQP_BASIC_RECOVER_OK_METHOD';
     AMQP_BASIC_NACK_METHOD: Result:= 'AMQP_BASIC_NACK_METHOD';
     AMQP_TX_SELECT_METHOD: Result:= 'AMQP_TX_SELECT_METHOD';
     AMQP_TX_SELECT_OK_METHOD: Result:= 'AMQP_TX_SELECT_OK_METHOD';
     AMQP_TX_COMMIT_METHOD: Result:= 'AMQP_TX_COMMIT_METHOD';
     AMQP_TX_COMMIT_OK_METHOD: Result:= 'AMQP_TX_COMMIT_OK_METHOD';
     AMQP_TX_ROLLBACK_METHOD: Result:= 'AMQP_TX_ROLLBACK_METHOD';
     AMQP_TX_ROLLBACK_OK_METHOD: Result:= 'AMQP_TX_ROLLBACK_OK_METHOD';
     AMQP_CONFIRM_SELECT_METHOD: Result:= 'AMQP_CONFIRM_SELECT_METHOD';
     AMQP_CONFIRM_SELECT_OK_METHOD: Result:= 'AMQP_CONFIRM_SELECT_OK_METHOD';
    default: Result:= 0;
   end;
 end;

function amqp_method_has_content(methodNumber: amqp_method_number_t): amqp_boolean_t
begin
    case (methodNumber)
   begin  of
     AMQP_BASIC_PUBLISH_METHOD: Result:= 1;
     AMQP_BASIC_RETURN_METHOD: Result:= 1;
     AMQP_BASIC_DELIVER_METHOD: Result:= 1;
     AMQP_BASIC_GET_OK_METHOD: Result:= 1;
    default: Result:= 0;
   end;
 end;

function amqp_decode_method(
	methodNumber: amqp_method_number_t;
	var pool: amqp_pool_t;
	encoded: amqp_bytes_t;
	var decoded: Pointer): Integer
begin
  size_t offset := 0;
  uint8_t bit_buffer;

    case (methodNumber)
    begin  of
     AMQP_CONNECTION_START_METHOD:
     begin
      amqp_connection_start_t *m := (amqp_connection_start_t ) amqp_pool_alloc(pool, SizeOf(amqp_connection_start_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_8(encoded, @offset, @m^.version_major)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_decode_8(encoded, @offset, @m^.version_minor)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        Integer res := amqp_decode_table(encoded, pool, @(m^.server_properties), @offset);
        if (res < 0) then  Result:= res;
      end;
      begin
        uint32_t len;
        if ( not amqp_decode_32(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.mechanisms, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint32_t len;
        if ( not amqp_decode_32(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.locales, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CONNECTION_START_OK_METHOD:
     begin
      amqp_connection_start_ok_t *m := (amqp_connection_start_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_connection_start_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      begin
        Integer res := amqp_decode_table(encoded, pool, @(m^.client_properties), @offset);
        if (res < 0) then  Result:= res;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.mechanism, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint32_t len;
        if ( not amqp_decode_32(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.response, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.locale, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CONNECTION_SECURE_METHOD:
     begin
      amqp_connection_secure_t *m := (amqp_connection_secure_t ) amqp_pool_alloc(pool, SizeOf(amqp_connection_secure_t));
      if (m = 0) then
       begin
       Result:= AMQP_STATUS_NO_MEMORY;
       end;
        uint32_t len;
        if ( not amqp_decode_32(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.challenge, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
     end;
      *decoded := m;
      Result:= 0;
    end;
     AMQP_CONNECTION_SECURE_OK_METHOD:
     begin
      amqp_connection_secure_ok_t *m := (amqp_connection_secure_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_connection_secure_ok_t));
      if (m = 0) then  
      begin  
      Result:= AMQP_STATUS_NO_MEMORY;  
      end;
      begin
        uint32_t len;
        if ( not amqp_decode_32(encoded, @offset, @len) then
        or  not amqp_decode_bytes(encoded, @offset, @m^.response, len))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CONNECTION_TUNE_METHOD:
     begin
      amqp_connection_tune_t *m := (amqp_connection_tune_t ) amqp_pool_alloc(pool, SizeOf(amqp_connection_tune_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.channel_max)) then Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_decode_32(encoded, @offset, @m^.frame_max)) then Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_decode_16(encoded, @offset, @m^.heartbeat)) then Result:= AMQP_STATUS_BAD_AMQP_DATA;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CONNECTION_TUNE_OK_METHOD:
     begin
      amqp_connection_tune_ok_t *m := (amqp_connection_tune_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_connection_tune_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.channel_max)) then Resulte:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_decode_32(encoded, @offset, @m^.frame_max)) then Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_decode_16(encoded, @offset, @m^.hearbeat)) then Result:= AMQP_STATUS_BAD_AMQP_DATA; 
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CONNECTION_OPEN_METHOD:
     begin
      amqp_connection_open_t *m := (amqp_connection_open_t ) amqp_pool_alloc(pool, SizeOf(amqp_connection_open_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not 
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.capabilities, len)
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.insist := (bit_buffer and (1 shl 0)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CONNECTION_OPEN_OK_METHOD:
     begin
      amqp_connection_open_ok_t *m := (amqp_connection_open_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_connection_open_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.known_hosts, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CONNECTION_CLOSE_METHOD:
     begin
      amqp_connection_close_t *m := (amqp_connection_close_t ) amqp_pool_alloc(pool, SizeOf(amqp_connection_close_t));
      if (m = 0) then
      begin
      Result:= AMQPS_TATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.reply_code)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.reply_text, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.class_id)) then Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_decode_16(encoded, @offset, @m^.method_id)) then Result:= AMQP_STATUS_BAD_AMQP_DATA;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CONNECTION_CLOSE_OK_METHOD:
     begin
      amqp_connection_close_ok_t *m := (amqp_connection_close_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_connection_close_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CONNECTION_BLOCKED_METHOD:
     begin
      amqp_connection_blocked_t *m := (amqp_connection_blocked_t ) amqp_pool_alloc(pool, SizeOf(amqp_connection_blocked_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.reason, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CONNECTION_UNBLOCKED_METHOD:
     begin
      amqp_connection_unblocked_t *m := (amqp_connection_unblocked_t ) amqp_pool_alloc(pool, SizeOf(amqp_connection_unblocked_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CHANNEL_OPEN_METHOD:
     begin
      amqp_channel_open_t *m := (amqp_channel_open_t ) amqp_pool_alloc(pool, SizeOf(amqp_channel_open_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.out_of_band, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CHANNEL_OPEN_OK_METHOD:
     begin
      amqp_channel_open_ok_t *m := (amqp_channel_open_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_channel_open_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      begin
        uint32_t len;
        if ( not amqp_decode_32(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.channel_id, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CHANNEL_FLOW_METHOD:
     begin
      amqp_channel_flow_t *m := (amqp_channel_flow_t ) amqp_pool_alloc(pool, SizeOf(amqp_channel_flow_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.active := (bit_buffer and (1 shl 0)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CHANNEL_FLOW_OK_METHOD:
     begin
      amqp_channel_flow_ok_t *m := (amqp_channel_flow_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_channel_flow_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.active := (bit_buffer and (1 shl 0)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CHANNEL_CLOSE_METHOD:
     begin
      amqp_channel_close_t *m := (amqp_channel_close_t ) amqp_pool_alloc(pool, SizeOf(amqp_channel_close_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.reply_code)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.reply_text, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.class_id)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_decode_16(encoded, @offset, @m^.method_id)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CHANNEL_CLOSE_OK_METHOD:
     begin
      amqp_channel_close_ok_t *m := (amqp_channel_close_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_channel_close_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_ACCESS_REQUEST_METHOD:
     begin
      amqp_access_request_t *m := (amqp_access_request_t ) amqp_pool_alloc(pool, SizeOf(amqp_access_request_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.realm, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.exclusive := (bit_buffer and (1 shl 0)) ? 1 : 0;
      m^.passive := (bit_buffer and (1 shl 1)) ? 1 : 0;
      m^.active := (bit_buffer and (1 shl 2)) ? 1 : 0;
      m^.write := (bit_buffer and (1 shl 3)) ? 1 : 0;
      m^.read := (bit_buffer and (1 shl 4)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_ACCESS_REQUEST_OK_METHOD:
     begin
      amqp_access_request_ok_t *m := (amqp_access_request_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_access_request_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_EXCHANGE_DECLARE_METHOD:
     begin
      amqp_exchange_declare_t *m := (amqp_exchange_declare_t ) amqp_pool_alloc(pool, SizeOf(amqp_exchange_declare_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.exchange, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.aType, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.passive := (bit_buffer and (1 shl 0)) ? 1 : 0;
      m^.durable := (bit_buffer and (1 shl 1)) ? 1 : 0;
      m^.auto_delete := (bit_buffer and (1 shl 2)) ? 1 : 0;
      m^.internal := (bit_buffer and (1 shl 3)) ? 1 : 0;
      m^.nowait := (bit_buffer and (1 shl 4)) ? 1 : 0;
      begin
        Integer res := amqp_decode_table(encoded, pool, @(m^.arguments), @offset);
        if (res < 0) then  Result:= res;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_EXCHANGE_DECLARE_OK_METHOD:
     begin
      amqp_exchange_declare_ok_t *m := (amqp_exchange_declare_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_exchange_declare_ok_t));
      if (m = 0) then
       begin
        Result:= AMQP_STATUS_NO_MEMORY;
       end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_EXCHANGE_DELETE_METHOD:
     begin
      amqp_exchange_delete_t *m := (amqp_exchange_delete_t ) amqp_pool_alloc(pool, SizeOf(amqp_exchange_delete_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.exchange, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.if_unused := (bit_buffer and (1 shl 0)) then  ? 1 : 0;
      m^.nowait := (bit_buffer and (1 shl 1)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_EXCHANGE_DELETE_OK_METHOD:
     begin
      amqp_exchange_delete_ok_t *m := (amqp_exchange_delete_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_exchange_delete_ok_t));
      if (m = 0) then  begin  Result:= AMQP_STATUS_NO_MEMORY;  end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_EXCHANGE_BIND_METHOD:
     begin
      amqp_exchange_bind_t *m := (amqp_exchange_bind_t ) amqp_pool_alloc(pool, SizeOf(amqp_exchange_bind_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.destination, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.source, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.routing_key, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.nowait := (bit_buffer and (1 shl 0)) ? 1 : 0;
      begin
        Integer res := amqp_decode_table(encoded, pool, @(m^.arguments), @offset);
        if (res < 0) then  Result:= res;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_EXCHANGE_BIND_OK_METHOD:
     begin
      amqp_exchange_bind_ok_t *m := (amqp_exchange_bind_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_exchange_bind_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_EXCHANGE_UNBIND_METHOD:
     begin
      amqp_exchange_unbind_t *m := (amqp_exchange_unbind_t ) amqp_pool_alloc(pool, SizeOf(amqp_exchange_unbind_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.destination, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.source, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.routing_key, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.nowait := (bit_buffer and (1 shl 0)) ? 1 : 0;
      begin
        Integer res := amqp_decode_table(encoded, pool, @(m^.arguments), @offset);
        if (res < 0) then  Result:= res;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_EXCHANGE_UNBIND_OK_METHOD:
     begin
      amqp_exchange_unbind_ok_t *m := (amqp_exchange_unbind_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_exchange_unbind_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_QUEUE_DECLARE_METHOD:
     begin
      amqp_queue_declare_t *m := (amqp_queue_declare_t ) amqp_pool_alloc(pool, SizeOf(amqp_queue_declare_t));
      if (m = 0) then
      begin
        Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.queue, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.passive := (bit_buffer and (1 shl 0)) ? 1 : 0;
      m^.durable := (bit_buffer and (1 shl 1)) ? 1 : 0;
      m^.exclusive := (bit_buffer and (1 shl 2)) ? 1 : 0;
      m^.auto_delete := (bit_buffer and (1 shl 3)) ? 1 : 0;
      m^.nowait := (bit_buffer and (1 shl 4)) ? 1 : 0;
      begin
        Integer res := amqp_decode_table(encoded, pool, @(m^.arguments), @offset);
        if (res < 0) then  Result:= res;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_QUEUE_DECLARE_OK_METHOD:
     begin
      amqp_queue_declare_ok_t *m := (amqp_queue_declare_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_queue_declare_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.queue, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_32(encoded, @offset, @m^.message_count)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_decode_32(encoded, @offset, @m^.consumer_count)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_QUEUE_BIND_METHOD:
     begin
      amqp_queue_bind_t *m := (amqp_queue_bind_t ) amqp_pool_alloc(pool, SizeOf(amqp_queue_bind_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.queue, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.exchange, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.routing_key, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.nowait := (bit_buffer and (1 shl 0)) ? 1 : 0;
      begin
        Integer res := amqp_decode_table(encoded, pool, @(m^.arguments), @offset);
        if (res < 0) then  Result:= res;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_QUEUE_BIND_OK_METHOD:
     begin
      amqp_queue_bind_ok_t *m := (amqp_queue_bind_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_queue_bind_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_QUEUE_PURGE_METHOD:
     begin
      amqp_queue_purge_t *m := (amqp_queue_purge_t ) amqp_pool_alloc(pool, SizeOf(amqp_queue_purge_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.queue, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.nowait := (bit_buffer and (1 shl 0)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_QUEUE_PURGE_OK_METHOD:
     begin
      amqp_queue_purge_ok_t *m := (amqp_queue_purge_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_queue_purge_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_32(encoded, @offset, @m^.message_count)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_QUEUE_DELETE_METHOD:
     begin
      amqp_queue_delete_t *m := (amqp_queue_delete_t ) amqp_pool_alloc(pool, SizeOf(amqp_queue_delete_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.queue, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.if_unused := (bit_buffer and (1 shl 0)) then  ? 1 : 0;
      m^.if_empty := (bit_buffer and (1 shl 1)) then  ? 1 : 0;
      m^.nowait := (bit_buffer and (1 shl 2)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_QUEUE_DELETE_OK_METHOD:
     begin
      amqp_queue_delete_ok_t *m := (amqp_queue_delete_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_queue_delete_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_32(encoded, @offset, @m^.message_count)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_QUEUE_UNBIND_METHOD:
     begin
      amqp_queue_unbind_t *m := (amqp_queue_unbind_t ) amqp_pool_alloc(pool, SizeOf(amqp_queue_unbind_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.queue, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.exchange, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.routing_key, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        Integer res := amqp_decode_table(encoded, pool, @(m^.arguments), @offset);
        if (res < 0) then  Result:= res;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_QUEUE_UNBIND_OK_METHOD:
     begin
      amqp_queue_unbind_ok_t *m := (amqp_queue_unbind_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_queue_unbind_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_QOS_METHOD:
     begin
      amqp_basic_qos_t *m := (amqp_basic_qos_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_qos_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_32(encoded, @offset, @m^.prefetch_size)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_decode_16(encoded, @offset, @m^.prefetch_count)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.global := (bit_buffer and (1 shl 0)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_QOS_OK_METHOD:
     begin
      amqp_basic_qos_ok_t *m := (amqp_basic_qos_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_qos_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_CONSUME_METHOD:
     begin
      amqp_basic_consume_t *m := (amqp_basic_consume_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_consume_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.queue, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.consumer_tag, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.no_local := (bit_buffer and (1 shl 0)) ? 1 : 0;
      m^.no_ack := (bit_buffer and (1 shl 1)) ? 1 : 0;
      m^.exclusive := (bit_buffer and (1 shl 2)) ? 1 : 0;
      m^.nowait := (bit_buffer and (1 shl 3)) ? 1 : 0;
      begin
        Integer res := amqp_decode_table(encoded, pool, @(m^.arguments), @offset);
        if (res < 0) then  Result:= res;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_CONSUME_OK_METHOD:
     begin
      amqp_basic_consume_ok_t *m := (amqp_basic_consume_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_consume_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.consumer_tag, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_CANCEL_METHOD:
     begin
      amqp_basic_cancel_t *m := (amqp_basic_cancel_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_cancel_t));
      if (m = 0) then
       begin
       Result:= AMQP_STATUS_NO_MEMORY;
       end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.consumer_tag, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.nowait := (bit_buffer and (1 shl 0)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_CANCEL_OK_METHOD:
     begin
      amqp_basic_cancel_ok_t *m := (amqp_basic_cancel_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_cancel_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
       end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.consumer_tag, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_PUBLISH_METHOD:
     begin
      amqp_basic_publish_t *m := (amqp_basic_publish_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_publish_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.exchange, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.routing_key, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.mandatory := (bit_buffer and (1 shl 0)) ? 1 : 0;
      m^.immediate := (bit_buffer and (1 shl 1)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_RETURN_METHOD:
     begin
      amqp_basic_return_t *m := (amqp_basic_return_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_return_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.reply_code)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.reply_text, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.exchange, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.routing_key, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_DELIVER_METHOD:
     begin
      amqp_basic_deliver_t *m := (amqp_basic_deliver_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_deliver_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.consumer_tag, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_64(encoded, @offset, @m^.delivery_tag)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.redelivered := (bit_buffer and (1 shl 0)) ? 1 : 0;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.exchange, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.routing_key, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_GET_METHOD:
     begin
      amqp_basic_get_t *m := (amqp_basic_get_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_get_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_16(encoded, @offset, @m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.queue, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.no_ack := (bit_buffer and (1 shl 0)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_GET_OK_METHOD:
     begin
      amqp_basic_get_ok_t *m := (amqp_basic_get_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_get_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_64(encoded, @offset, @m^.delivery_tag)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.redelivered := (bit_buffer and (1 shl 0)) ? 1 : 0;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.exchange, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.routing_key, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      if ( not amqp_decode_32(encoded, @offset, @m^.message_count)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_GET_EMPTY_METHOD:
     begin
      amqp_basic_get_empty_t *m := (amqp_basic_get_empty_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_get_empty_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @m^.cluster_id, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_ACK_METHOD:
     begin
      amqp_basic_ack_t *m := (amqp_basic_ack_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_ack_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_64(encoded, @offset, @m^.delivery_tag)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.multiple := (bit_buffer and (1 shl 0)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_REJECT_METHOD:
     begin
      amqp_basic_reject_t *m := (amqp_basic_reject_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_reject_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_64(encoded, @offset, @m^.delivery_tag)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.requeue := (bit_buffer and (1 shl 0)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_RECOVER_ASYNC_METHOD:
     begin
      amqp_basic_recover_async_t *m := (amqp_basic_recover_async_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_recover_async_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.requeue := (bit_buffer and (1 shl 0)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_RECOVER_METHOD:
     begin
      amqp_basic_recover_t *m := (amqp_basic_recover_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_recover_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.requeue := (bit_buffer and (1 shl 0)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_RECOVER_OK_METHOD:
     begin
      amqp_basic_recover_ok_t *m := (amqp_basic_recover_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_recover_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_BASIC_NACK_METHOD:
     begin
      amqp_basic_nack_t *m := (amqp_basic_nack_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_nack_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_64(encoded, @offset, @m^.delivery_tag)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.multiple := (bit_buffer and (1 shl 0)) ? 1 : 0;
      m^.requeue := (bit_buffer and (1 shl 1)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_TX_SELECT_METHOD:
     begin
      amqp_tx_select_t *m := (amqp_tx_select_t ) amqp_pool_alloc(pool, SizeOf(amqp_tx_select_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_TX_SELECT_OK_METHOD:
     begin
      amqp_tx_select_ok_t *m := (amqp_tx_select_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_tx_select_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_TX_COMMIT_METHOD:
     begin
      amqp_tx_commit_t *m := (amqp_tx_commit_t ) amqp_pool_alloc(pool, SizeOf(amqp_tx_commit_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_TX_COMMIT_OK_METHOD:
     begin
      amqp_tx_commit_ok_t *m := (amqp_tx_commit_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_tx_commit_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_TX_ROLLBACK_METHOD:
     begin
      amqp_tx_rollback_t *m := (amqp_tx_rollback_t ) amqp_pool_alloc(pool, SizeOf(amqp_tx_rollback_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_TX_ROLLBACK_OK_METHOD:
     begin
      amqp_tx_rollback_ok_t *m := (amqp_tx_rollback_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_tx_rollback_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CONFIRM_SELECT_METHOD:
     begin
      amqp_confirm_select_t *m := (amqp_confirm_select_t ) amqp_pool_alloc(pool, SizeOf(amqp_confirm_select_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      if ( not amqp_decode_8(encoded, @offset, @bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      m^.nowait := (bit_buffer and (1 shl 0)) ? 1 : 0;
      *decoded := m;
      Result:= 0;
     end;
     AMQP_CONFIRM_SELECT_OK_METHOD:
     begin
      amqp_confirm_select_ok_t *m := (amqp_confirm_select_ok_t ) amqp_pool_alloc(pool, SizeOf(amqp_confirm_select_ok_t));
      if (m = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      *decoded := m;
      Result:= 0;
     end;
    default: Result:= AMQP_STATUS_UNKNOWN_METHOD;
   end;
 end;

function amqp_decode_function (
	class_id: uint16_t;
	var pool: amqp_pool_t;
	encoded: amqp_bytes_t;
	var decoded: Pointer): properties: Integer
begin
  size_t offset := 0;

  amqp_flags_t flags := 0;
  Integer flagword_index := 0;
  uint16_t partial_flags;

    do
   begin
    if ( not amqp_decode_16(encoded, @offset, @partial_flags)) then
      Result:= AMQP_STATUS_BAD_AMQP_DATA;
    flags:= mod or (partial_flags shl (flagword_index * 16));
    flagword_index:= mod + 1;
   end; while (partial_flags and 1);

   case (class_id) begin  of
     10:begin
      amqp_connection_properties_t *p := (amqp_connection_properties_t ) amqp_pool_alloc(pool, SizeOf(amqp_connection_properties_t));
      if (p = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      p->_flags := flags;
      *decoded := p;
      Result:= 0;
     end;
     20: begin
      amqp_channel_properties_t *p := (amqp_channel_properties_t ) amqp_pool_alloc(pool, SizeOf(amqp_channel_properties_t));
      if (p = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      p->_flags := flags;
      *decoded := p;
      Result:= 0;
     end;
     30: begin
      amqp_access_properties_t *p := (amqp_access_properties_t ) amqp_pool_alloc(pool, SizeOf(amqp_access_properties_t));
      if (p = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      p->_flags := flags;
      *decoded := p;
      Result:= 0;
     end;
     40: begin
      amqp_exchange_properties_t *p := (amqp_exchange_properties_t ) amqp_pool_alloc(pool, SizeOf(amqp_exchange_properties_t));
      if (p = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      p->_flags := flags;
      *decoded := p;
      Result:= 0;
     end;
     50: begin
      amqp_queue_properties_t *p := (amqp_queue_properties_t ) amqp_pool_alloc(pool, SizeOf(amqp_queue_properties_t));
      if (p = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      p->_flags := flags;
      *decoded := p;
      Result:= 0;
     end;
     60: begin
      amqp_basic_properties_t *p := (amqp_basic_properties_t ) amqp_pool_alloc(pool, SizeOf(amqp_basic_properties_t));
      if (p = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      p->_flags := flags;
        if (flags and AMQP_BASIC_CONTENT_TYPE_FLAG) then
       begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @p^.content_type, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
        if (flags and AMQP_BASIC_CONTENT_ENCODING_FLAG) then
       begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @p^.content_encoding, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
       if (flags and AMQP_BASIC_HEADERS_FLAG) then
        begin
        Integer res := amqp_decode_table(encoded, pool, @(p^.headers), @offset);
        if (res < 0) then  Result:= res;
       end;
        if (flags and AMQP_BASIC_DELIVERY_MODE_FLAG) then
        begin
       if ( not amqp_decode_8(encoded, @offset, @p^.delivery_mode)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
       if (flags and AMQP_BASIC_PRIORITY_FLAG) then  begin
        if ( not amqp_decode_8(encoded, @offset, @p^.priority)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
       if (flags and AMQP_BASIC_CORRELATION_ID_FLAG) then
        begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @p^.correlation_id, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
       if (flags and AMQP_BASIC_REPLY_TO_FLAG) then
       begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @p^.reply_to, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
        if (flags and AMQP_BASIC_EXPIRATION_FLAG) then
       begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @p^.expiration, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
        if (flags and AMQP_BASIC_MESSAGE_ID_FLAG) then
        begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @p^.message_id, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
        if (flags and AMQP_BASIC_TIMESTAMP_FLAG) then
        begin
        if ( not amqp_decode_64(encoded, @offset, @p^.timestamp)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
       if (flags and AMQP_BASIC_TYPE_FLAG) then
       begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @p^.aType, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
       if (flags and AMQP_BASIC_USER_ID_FLAG) then
       begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @p^.user_id, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
        if (flags and AMQP_BASIC_APP_ID_FLAG) then
       begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @p^.app_id, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
        if (flags and AMQP_BASIC_CLUSTER_ID_FLAG) then
        begin
        uint8_t len;
        if ( not amqp_decode_8(encoded, @offset, @len) then
            or  not amqp_decode_bytes(encoded, @offset, @p^.cluster_id, len))
          Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
      *decoded := p;
      Result:= 0;
     end;
     90: begin
      amqp_tx_properties_t *p := (amqp_tx_properties_t ) amqp_pool_alloc(pool, SizeOf(amqp_tx_properties_t));
      if (p = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      p->_flags := flags;
      *decoded := p;
      Result:= 0;
     end;
     85: begin
      amqp_confirm_properties_t *p := (amqp_confirm_properties_t ) amqp_pool_alloc(pool, SizeOf(amqp_confirm_properties_t));
      if (p = 0) then
      begin
      Result:= AMQP_STATUS_NO_MEMORY;
      end;
      p->_flags := flags;
      *decoded := p;
      Result:= 0;
     end;
    default: Result:= AMQP_STATUS_UNKNOWN_CLASS;
   end;
 end;

function amqp_encode_method(
	methodNumber: amqp_method_number_t;
	decoded: Pointer;
	encoded: amqp_bytes_t): Integer
begin
  size_t offset := 0;
  uint8_t bit_buffer;

 case (methodNumber)
   begin  of
     AMQP_CONNECTION_START_METHOD:
     begin
      amqp_connection_start_t *m := (amqp_connection_start_t ) decoded;
      if ( not amqp_encode_8(encoded, @offset, m^.version_major)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_encode_8(encoded, @offset, m^.version_minor)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        Integer res := amqp_encode_table(encoded, @(m^.server_properties), @offset);
        if (res < 0) then  Result:= res;
      end;
      if (UINT32_MAX < m^.mechanisms.len then
          or  not amqp_encode_32(encoded, @offset, (uint32_t)m^.mechanisms.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.mechanisms))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT32_MAX < m^.locales.len then
          or  not amqp_encode_32(encoded, @offset, (uint32_t)m^.locales.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.locales))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CONNECTION_START_OK_METHOD:
     begin
      amqp_connection_start_ok_t *m := (amqp_connection_start_ok_t ) decoded;
      begin
        Integer res := amqp_encode_table(encoded, @(m^.client_properties), @offset);
        if (res < 0) then  Result:= res;
      end;
      if (UINT8_MAX < m^.mechanism.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.mechanism.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.mechanism))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT32_MAX < m^.response.len then
          or  not amqp_encode_32(encoded, @offset, (uint32_t)m^.response.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.response))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.locale.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.locale.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.locale))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CONNECTION_SECURE_METHOD:
     begin
      amqp_connection_secure_t *m := (amqp_connection_secure_t ) decoded;
      if (UINT32_MAX < m^.challenge.len then
          or  not amqp_encode_32(encoded, @offset, (uint32_t)m^.challenge.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.challenge))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CONNECTION_SECURE_OK_METHOD:
     begin
      amqp_connection_secure_ok_t *m := (amqp_connection_secure_ok_t ) decoded;
      if (UINT32_MAX < m^.response.len then
          or  not amqp_encode_32(encoded, @offset, (uint32_t)m^.response.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.response))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CONNECTION_TUNE_METHOD:
     begin
      amqp_connection_tune_t *m := (amqp_connection_tune_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.channel_max)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_encode_32(encoded, @offset, m^.frame_max)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_encode_16(encoded, @offset, m^.heartbeat)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CONNECTION_TUNE_OK_METHOD:
     begin
      amqp_connection_tune_ok_t *m := (amqp_connection_tune_ok_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.channel_max)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_encode_32(encoded, @offset, m^.frame_max)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_encode_16(encoded, @offset, m^.heartbeat)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CONNECTION_OPEN_METHOD:
     begin
      amqp_connection_open_t *m := (amqp_connection_open_t ) decoded;
      if (UINT8_MAX < m^.virtual_host.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.virtual_host.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.virtual_host))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.capabilities.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.capabilities.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.capabilities))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.insist) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CONNECTION_OPEN_OK_METHOD:
     begin
      amqp_connection_open_ok_t *m := (amqp_connection_open_ok_t ) decoded;
      if (UINT8_MAX < m^.known_hosts.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.known_hosts.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.known_hosts))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CONNECTION_CLOSE_METHOD:
      begin
      amqp_connection_close_t *m := (amqp_connection_close_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.reply_code)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.reply_text.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.reply_text.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.reply_text))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_encode_16(encoded, @offset, m^.class_id)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_encode_16(encoded, @offset, m^.method_id)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CONNECTION_CLOSE_OK_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_CONNECTION_BLOCKED_METHOD:
     begin
      amqp_connection_blocked_t *m := (amqp_connection_blocked_t ) decoded;
      if (UINT8_MAX < m^.reason.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.reason.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.reason))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CONNECTION_UNBLOCKED_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_CHANNEL_OPEN_METHOD:
     begin
      amqp_channel_open_t *m := (amqp_channel_open_t ) decoded;
      if (UINT8_MAX < m^.out_of_band.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.out_of_band.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.out_of_band))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CHANNEL_OPEN_OK_METHOD:
     begin
      amqp_channel_open_ok_t *m := (amqp_channel_open_ok_t ) decoded;
      if (UINT32_MAX < m^.channel_id.len then
          or  not amqp_encode_32(encoded, @offset, (uint32_t)m^.channel_id.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.channel_id))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CHANNEL_FLOW_METHOD:
     begin
      amqp_channel_flow_t *m := (amqp_channel_flow_t ) decoded;
      bit_buffer := 0;
      if (m^.active) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CHANNEL_FLOW_OK_METHOD:
     begin
      amqp_channel_flow_ok_t *m := (amqp_channel_flow_ok_t ) decoded;
      bit_buffer := 0;
      if (m^.active) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CHANNEL_CLOSE_METHOD:
     begin
      amqp_channel_close_t *m := (amqp_channel_close_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.reply_code)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.reply_text.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.reply_text.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.reply_text))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_encode_16(encoded, @offset, m^.class_id)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_encode_16(encoded, @offset, m^.method_id)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CHANNEL_CLOSE_OK_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_ACCESS_REQUEST_METHOD:
     begin
      amqp_access_request_t *m := (amqp_access_request_t ) decoded;
      if (UINT8_MAX < m^.realm.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.realm.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.realm))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.exclusive) bit_buffer:= mod or (1 shl 0) then ;
      if (m^.passive) bit_buffer:= mod or (1 shl 1) then ;
      if (m^.active) bit_buffer:= mod or (1 shl 2) then ;
      if (m^.write) bit_buffer:= mod or (1 shl 3) then ;
      if (m^.read) bit_buffer:= mod or (1 shl 4) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_ACCESS_REQUEST_OK_METHOD:
     begin
      amqp_access_request_ok_t *m := (amqp_access_request_ok_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_EXCHANGE_DECLARE_METHOD:
     begin
      amqp_exchange_declare_t *m := (amqp_exchange_declare_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.exchange.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.exchange.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.exchange))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.aType.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.aType.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.aType))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.passive) bit_buffer:= mod or (1 shl 0) then ;
      if (m^.durable) bit_buffer:= mod or (1 shl 1) then ;
      if (m^.auto_delete) bit_buffer:= mod or (1 shl 2) then ;
      if (m^.internal) bit_buffer:= mod or (1 shl 3) then ;
      if (m^.nowait) bit_buffer:= mod or (1 shl 4) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        Integer res := amqp_encode_table(encoded, @(m^.arguments), @offset);
        if (res < 0) then  Result:= res;
       end;
      Result:= (Integer)offset;
     end;
     AMQP_EXCHANGE_DECLARE_OK_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_EXCHANGE_DELETE_METHOD:
     begin
      amqp_exchange_delete_t *m := (amqp_exchange_delete_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.exchange.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.exchange.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.exchange))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.if_unused) bit_buffer:= mod or (1 shl 0) then ;
      if (m^.nowait) bit_buffer:= mod or (1 shl 1) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_EXCHANGE_DELETE_OK_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_EXCHANGE_BIND_METHOD:
     begin
      amqp_exchange_bind_t *m := (amqp_exchange_bind_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.destination.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.destination.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.destination))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.source.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.source.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.source))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.routing_key.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.routing_key.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.routing_key))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.nowait) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        Integer res := amqp_encode_table(encoded, @(m^.arguments), @offset);
        if (res < 0) then  Result:= res;
      end;
      Result:= (Integer)offset;
     end;
     AMQP_EXCHANGE_BIND_OK_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_EXCHANGE_UNBIND_METHOD:
     begin
      amqp_exchange_unbind_t *m := (amqp_exchange_unbind_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.destination.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.destination.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.destination))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.source.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.source.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.source))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.routing_key.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.routing_key.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.routing_key))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.nowait) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        Integer res := amqp_encode_table(encoded, @(m^.arguments), @offset);
        if (res < 0) then  Result:= res;
      end;
      Result:= (Integer)offset;
     end;
     AMQP_EXCHANGE_UNBIND_OK_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_QUEUE_DECLARE_METHOD:
     begin
      amqp_queue_declare_t *m := (amqp_queue_declare_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.queue.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.queue.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.queue))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.passive) bit_buffer:= mod or (1 shl 0) then ;
      if (m^.durable) bit_buffer:= mod or (1 shl 1) then ;
      if (m^.exclusive) bit_buffer:= mod or (1 shl 2) then ;
      if (m^.auto_delete) bit_buffer:= mod or (1 shl 3) then ;
      if (m^.nowait) bit_buffer:= mod or (1 shl 4) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        Integer res := amqp_encode_table(encoded, @(m^.arguments), @offset);
        if (res < 0) then  Result:= res;
      end;
      Result:= (Integer)offset;
     end;
     AMQP_QUEUE_DECLARE_OK_METHOD:
     begin
      amqp_queue_declare_ok_t *m := (amqp_queue_declare_ok_t ) decoded;
      if (UINT8_MAX < m^.queue.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.queue.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.queue))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_encode_32(encoded, @offset, m^.message_count)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_encode_32(encoded, @offset, m^.consumer_count)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_QUEUE_BIND_METHOD:
     begin
      amqp_queue_bind_t *m := (amqp_queue_bind_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.queue.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.queue.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.queue))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.exchange.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.exchange.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.exchange))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.routing_key.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.routing_key.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.routing_key))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.nowait) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        Integer res := amqp_encode_table(encoded, @(m^.arguments), @offset);
        if (res < 0) then  Result:= res;
      end;
      Result:= (Integer)offset;
     end;
     AMQP_QUEUE_BIND_OK_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_QUEUE_PURGE_METHOD:
     begin
      amqp_queue_purge_t *m := (amqp_queue_purge_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.queue.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.queue.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.queue))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.nowait) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_QUEUE_PURGE_OK_METHOD:
     begin
      amqp_queue_purge_ok_t *m := (amqp_queue_purge_ok_t ) decoded;
      if ( not amqp_encode_32(encoded, @offset, m^.message_count)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_QUEUE_DELETE_METHOD:
     begin
      amqp_queue_delete_t *m := (amqp_queue_delete_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.queue.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.queue.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.queue))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.if_unused) bit_buffer:= mod or (1 shl 0) then ;
      if (m^.if_empty) bit_buffer:= mod or (1 shl 1) then ;
      if (m^.nowait) bit_buffer:= mod or (1 shl 2) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_QUEUE_DELETE_OK_METHOD:
     begin
      amqp_queue_delete_ok_t *m := (amqp_queue_delete_ok_t ) decoded;
      if ( not amqp_encode_32(encoded, @offset, m^.message_count)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_QUEUE_UNBIND_METHOD:
     begin
      amqp_queue_unbind_t *m := (amqp_queue_unbind_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.queue.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.queue.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.queue))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.exchange.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.exchange.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.exchange))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.routing_key.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.routing_key.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.routing_key))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        Integer res := amqp_encode_table(encoded, @(m^.arguments), @offset);
        if (res < 0) then  Result:= res;
      end;
      Result:= (Integer)offset;
     end;
     AMQP_QUEUE_UNBIND_OK_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_QOS_METHOD:
     begin
      amqp_basic_qos_t *m := (amqp_basic_qos_t ) decoded;
      if ( not amqp_encode_32(encoded, @offset, m^.prefetch_size)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_encode_16(encoded, @offset, m^.prefetch_count)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.global) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_QOS_OK_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_CONSUME_METHOD:
     begin
      amqp_basic_consume_t *m := (amqp_basic_consume_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.queue.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.queue.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.queue))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.consumer_tag.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.consumer_tag.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.consumer_tag))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.no_local) bit_buffer:= mod or (1 shl 0) then ;
      if (m^.no_ack) bit_buffer:= mod or (1 shl 1) then ;
      if (m^.exclusive) bit_buffer:= mod or (1 shl 2) then ;
      if (m^.nowait) bit_buffer:= mod or (1 shl 3) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      begin
        Integer res := amqp_encode_table(encoded, @(m^.arguments), @offset);
        if (res < 0) then  Result:= res;
      end;
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_CONSUME_OK_METHOD:
     begin
      amqp_basic_consume_ok_t *m := (amqp_basic_consume_ok_t ) decoded;
      if (UINT8_MAX < m^.consumer_tag.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.consumer_tag.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.consumer_tag))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_CANCEL_METHOD:
     begin
      amqp_basic_cancel_t *m := (amqp_basic_cancel_t ) decoded;
      if (UINT8_MAX < m^.consumer_tag.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.consumer_tag.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.consumer_tag))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.nowait) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_CANCEL_OK_METHOD:
     begin
      amqp_basic_cancel_ok_t *m := (amqp_basic_cancel_ok_t ) decoded;
      if (UINT8_MAX < m^.consumer_tag.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.consumer_tag.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.consumer_tag))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_PUBLISH_METHOD:
     begin
      amqp_basic_publish_t *m := (amqp_basic_publish_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.exchange.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.exchange.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.exchange))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.routing_key.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.routing_key.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.routing_key))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.mandatory) bit_buffer:= mod or (1 shl 0) then ;
      if (m^.immediate) bit_buffer:= mod or (1 shl 1) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_RETURN_METHOD:
     begin
      amqp_basic_return_t *m := (amqp_basic_return_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.reply_code)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.reply_text.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.reply_text.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.reply_text))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.exchange.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.exchange.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.exchange))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.routing_key.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.routing_key.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.routing_key))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_DELIVER_METHOD:
     begin
      amqp_basic_deliver_t *m := (amqp_basic_deliver_t ) decoded;
      if (UINT8_MAX < m^.consumer_tag.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.consumer_tag.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.consumer_tag))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_encode_64(encoded, @offset, m^.delivery_tag)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.redelivered) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.exchange.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.exchange.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.exchange))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.routing_key.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.routing_key.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.routing_key))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_GET_METHOD:
     begin
      amqp_basic_get_t *m := (amqp_basic_get_t ) decoded;
      if ( not amqp_encode_16(encoded, @offset, m^.ticket)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.queue.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.queue.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.queue))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.no_ack) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_GET_OK_METHOD:
     begin
      amqp_basic_get_ok_t *m := (amqp_basic_get_ok_t ) decoded;
      if ( not amqp_encode_64(encoded, @offset, m^.delivery_tag)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.redelivered) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.exchange.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.exchange.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.exchange))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if (UINT8_MAX < m^.routing_key.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.routing_key.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.routing_key))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      if ( not amqp_encode_32(encoded, @offset, m^.message_count)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_GET_EMPTY_METHOD:
     begin
      amqp_basic_get_empty_t *m := (amqp_basic_get_empty_t ) decoded;
      if (UINT8_MAX < m^.cluster_id.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)m^.cluster_id.len)
          or  not amqp_encode_bytes(encoded, @offset, m^.cluster_id))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_ACK_METHOD:
     begin
      amqp_basic_ack_t *m := (amqp_basic_ack_t ) decoded;
      if ( not amqp_encode_64(encoded, @offset, m^.delivery_tag)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.multiple) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_REJECT_METHOD:
     begin
      amqp_basic_reject_t *m := (amqp_basic_reject_t ) decoded;
      if ( not amqp_encode_64(encoded, @offset, m^.delivery_tag)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.requeue) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_RECOVER_ASYNC_METHOD:
     begin
      amqp_basic_recover_async_t *m := (amqp_basic_recover_async_t ) decoded;
      bit_buffer := 0;
      if (m^.requeue) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_RECOVER_METHOD:
     begin
      amqp_basic_recover_t *m := (amqp_basic_recover_t ) decoded;
      bit_buffer := 0;
      if (m^.requeue) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_RECOVER_OK_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_BASIC_NACK_METHOD:
     begin
      amqp_basic_nack_t *m := (amqp_basic_nack_t ) decoded;
      if ( not amqp_encode_64(encoded, @offset, m^.delivery_tag)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      bit_buffer := 0;
      if (m^.multiple) bit_buffer:= mod or (1 shl 0) then ;
      if (m^.requeue) bit_buffer:= mod or (1 shl 1) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_TX_SELECT_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_TX_SELECT_OK_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_TX_COMMIT_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_TX_COMMIT_OK_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_TX_ROLLBACK_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_TX_ROLLBACK_OK_METHOD:
     begin
      Result:= (Integer)offset;
     end;
     AMQP_CONFIRM_SELECT_METHOD:
     begin
      amqp_confirm_select_t *m := (amqp_confirm_select_t ) decoded;
      bit_buffer := 0;
      if (m^.nowait) bit_buffer:= mod or (1 shl 0) then ;
      if ( not amqp_encode_8(encoded, @offset, bit_buffer)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
      Result:= (Integer)offset;
     end;
     AMQP_CONFIRM_SELECT_OK_METHOD:
     begin
      Result:= (Integer)offset;
     end;
    default: Result:= AMQP_STATUS_UNKNOWN_METHOD;
   end;
 end;

function amqp_encode_function (
	class_id: uint16_t;
	decoded: Pointer;
	encoded: amqp_bytes_t): properties: Integer
begin
  size_t offset := 0;

  (* Cheat, and get the flags out generically, relying on the
     similarity of structure between classes *)
  amqp_flags_t flags := * (amqp_flags_t ) decoded; (* cheating! *)

  begin
    (* We take a copy of flags to avoid destroying it, as it is used
       in the autogenerated code below. *)
    amqp_flags_t remaining_flags := flags;
      do
     begin
      amqp_flags_t remainder := remaining_flags shr 16;
      uint16_t partial_flags := remaining_flags and $FFFE;
      if (remainder <> 0) then
      begin
      partial_flags:= mod or 1;
      end;
      if ( not amqp_encode_16(encoded, @offset, partial_flags)) then
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
      remaining_flags := remainder;
     end; while (remaining_flags <> 0);
  end;

 case (class_id)
   begin  of
     10: begin
      Result:= (Integer)offset;
     end;
     20: begin
      Result:= (Integer)offset;
     end;
     30: begin
      Result:= (Integer)offset;
     end;
     40: begin
      Result:= (Integer)offset;
     end;
     50: begin
      Result:= (Integer)offset;
     end;
     60: begin
      amqp_basic_properties_t *p := (amqp_basic_properties_t ) decoded;
            if (flags and AMQP_BASIC_CONTENT_TYPE_FLAG) then
       begin
        if (UINT8_MAX < p^.content_type.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)p^.content_type.len)
          or  not amqp_encode_bytes(encoded, @offset, p^.content_type))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
            if (flags and AMQP_BASIC_CONTENT_ENCODING_FLAG) then
       begin
       if (UINT8_MAX < p^.content_encoding.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)p^.content_encoding.len)
          or  not amqp_encode_bytes(encoded, @offset, p^.content_encoding))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
            if (flags and AMQP_BASIC_HEADERS_FLAG) then
       begin
        Integer res := amqp_encode_table(encoded, @(p^.headers), @offset);
        if (res < 0) then  Result:= res;
       end;
            if (flags and AMQP_BASIC_DELIVERY_MODE_FLAG) then
       begin
       if ( not amqp_encode_8(encoded, @offset, p^.delivery_mode)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
            if (flags and AMQP_BASIC_PRIORITY_FLAG) then
       begin
       if ( not amqp_encode_8(encoded, @offset, p^.priority)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
            if (flags and AMQP_BASIC_CORRELATION_ID_FLAG) then
       begin
        if (UINT8_MAX < p^.correlation_id.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)p^.correlation_id.len)
          or  not amqp_encode_bytes(encoded, @offset, p^.correlation_id))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
            if (flags and AMQP_BASIC_REPLY_TO_FLAG) then
       begin
       if (UINT8_MAX < p^.reply_to.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)p^.reply_to.len)
          or  not amqp_encode_bytes(encoded, @offset, p^.reply_to))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
            if (flags and AMQP_BASIC_EXPIRATION_FLAG) then
       begin
        if (UINT8_MAX < p^.expiration.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)p^.expiration.len)
          or  not amqp_encode_bytes(encoded, @offset, p^.expiration))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
            if (flags and AMQP_BASIC_MESSAGE_ID_FLAG) then
       begin
       if (UINT8_MAX < p^.message_id.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)p^.message_id.len)
          or  not amqp_encode_bytes(encoded, @offset, p^.message_id))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
            if (flags and AMQP_BASIC_TIMESTAMP_FLAG) then
       begin
        if ( not amqp_encode_64(encoded, @offset, p^.timestamp)) then  Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
            if (flags and AMQP_BASIC_TYPE_FLAG) then
       begin
        if (UINT8_MAX < p^.aType.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)p^.aType.len)
          or  not amqp_encode_bytes(encoded, @offset, p^.aType))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
            if (flags and AMQP_BASIC_USER_ID_FLAG) then
       begin
        if (UINT8_MAX < p^.user_id.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)p^.user_id.len)
          or  not amqp_encode_bytes(encoded, @offset, p^.user_id))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
            if (flags and AMQP_BASIC_APP_ID_FLAG) then
       begin
        if (UINT8_MAX < p^.app_id.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)p^.app_id.len)
          or  not amqp_encode_bytes(encoded, @offset, p^.app_id))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
            if (flags and AMQP_BASIC_CLUSTER_ID_FLAG) then
       begin
        if (UINT8_MAX < p^.cluster_id.len then
          or  not amqp_encode_8(encoded, @offset, (uint8_t)p^.cluster_id.len)
          or  not amqp_encode_bytes(encoded, @offset, p^.cluster_id))
        Result:= AMQP_STATUS_BAD_AMQP_DATA;
       end;
      Result:= (Integer)offset;
     end;
     90: begin
      Result:= (Integer)offset;
     end;
     85: begin
      Result:= (Integer)offset;
     end;
    default: Result:= AMQP_STATUS_UNKNOWN_CLASS;
   end;
 end;

(**
 * amqp_channel_open
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @returns amqp_channel_open_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_channel_open_ok_t *
AMQP_CALL amqp_channel_open(amqp_connection_state_t state, amqp_channel_t channel)
begin
  amqp_channel_open_t req;
  req.out_of_band := amqp_empty_bytes;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_CHANNEL_OPEN_METHOD, AMQP_CHANNEL_OPEN_OK_METHOD, @req);
end;


(**
 * amqp_channel_flow
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @param [in] active active
 * @returns amqp_channel_flow_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_channel_flow_ok_t *
AMQP_CALL amqp_channel_flow(amqp_connection_state_t state, amqp_channel_t channel, amqp_boolean_t active)
begin
  amqp_channel_flow_t req;
  req.active := active;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_CHANNEL_FLOW_METHOD, AMQP_CHANNEL_FLOW_OK_METHOD, @req);
end;


(**
 * amqp_exchange_declare
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @param [in] exchange exchange
 * @param [in] aType aType
 * @param [in] passive passive
 * @param [in] durable durable
 * @param [in] auto_delete auto_delete
 * @param [in] internal internal
 * @param [in] arguments arguments
 * @returns amqp_exchange_declare_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_exchange_declare_ok_t *
AMQP_CALL amqp_exchange_declare(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t exchange, amqp_bytes_t aType, amqp_boolean_t passive, amqp_boolean_t durable, amqp_boolean_t auto_delete, amqp_boolean_t internal, amqp_table_t arguments)
begin
  amqp_exchange_declare_t req;
  req.ticket := 0;
  req.exchange := exchange;
  req.aType := aType;
  req.passive := passive;
  req.durable := durable;
  req.auto_delete := auto_delete;
  req.internal := internal;
  req.nowait := 0;
  req.arguments := arguments;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_EXCHANGE_DECLARE_METHOD, AMQP_EXCHANGE_DECLARE_OK_METHOD, @req);
end;


(**
 * amqp_exchange_delete
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @param [in] exchange exchange
 * @param [in] if_unused if_unused
 * @returns amqp_exchange_delete_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_exchange_delete_ok_t *
AMQP_CALL amqp_exchange_delete(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t exchange, amqp_boolean_t if_unused) then
begin
  amqp_exchange_delete_t req;
  req.ticket := 0;
  req.exchange := exchange;
  req.if_unused := if_unused;
  req.nowait := 0;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_EXCHANGE_DELETE_METHOD, AMQP_EXCHANGE_DELETE_OK_METHOD, @req);
end;


(**
 * amqp_exchange_bind
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @param [in] destination destination
 * @param [in] source source
 * @param [in] routing_key routing_key
 * @param [in] arguments arguments
 * @returns amqp_exchange_bind_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_exchange_bind_ok_t *
AMQP_CALL amqp_exchange_bind(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t destination, amqp_bytes_t source, amqp_bytes_t routing_key, amqp_table_t arguments)
begin
  amqp_exchange_bind_t req;
  req.ticket := 0;
  req.destination := destination;
  req.source := source;
  req.routing_key := routing_key;
  req.nowait := 0;
  req.arguments := arguments;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_EXCHANGE_BIND_METHOD, AMQP_EXCHANGE_BIND_OK_METHOD, @req);
end;


(**
 * amqp_exchange_unbind
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @param [in] destination destination
 * @param [in] source source
 * @param [in] routing_key routing_key
 * @param [in] arguments arguments
 * @returns amqp_exchange_unbind_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_exchange_unbind_ok_t *
AMQP_CALL amqp_exchange_unbind(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t destination, amqp_bytes_t source, amqp_bytes_t routing_key, amqp_table_t arguments)
begin
  amqp_exchange_unbind_t req;
  req.ticket := 0;
  req.destination := destination;
  req.source := source;
  req.routing_key := routing_key;
  req.nowait := 0;
  req.arguments := arguments;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_EXCHANGE_UNBIND_METHOD, AMQP_EXCHANGE_UNBIND_OK_METHOD, @req);
end;


(**
 * amqp_queue_declare
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @param [in] queue queue
 * @param [in] passive passive
 * @param [in] durable durable
 * @param [in] exclusive exclusive
 * @param [in] auto_delete auto_delete
 * @param [in] arguments arguments
 * @returns amqp_queue_declare_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_queue_declare_ok_t *
AMQP_CALL amqp_queue_declare(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t queue, amqp_boolean_t passive, amqp_boolean_t durable, amqp_boolean_t exclusive, amqp_boolean_t auto_delete, amqp_table_t arguments)
begin
  amqp_queue_declare_t req;
  req.ticket := 0;
  req.queue := queue;
  req.passive := passive;
  req.durable := durable;
  req.exclusive := exclusive;
  req.auto_delete := auto_delete;
  req.nowait := 0;
  req.arguments := arguments;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_QUEUE_DECLARE_METHOD, AMQP_QUEUE_DECLARE_OK_METHOD, @req);
end;


(**
 * amqp_queue_bind
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @param [in] queue queue
 * @param [in] exchange exchange
 * @param [in] routing_key routing_key
 * @param [in] arguments arguments
 * @returns amqp_queue_bind_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_queue_bind_ok_t *
AMQP_CALL amqp_queue_bind(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t queue, amqp_bytes_t exchange, amqp_bytes_t routing_key, amqp_table_t arguments)
begin
  amqp_queue_bind_t req;
  req.ticket := 0;
  req.queue := queue;
  req.exchange := exchange;
  req.routing_key := routing_key;
  req.nowait := 0;
  req.arguments := arguments;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_QUEUE_BIND_METHOD, AMQP_QUEUE_BIND_OK_METHOD, @req);
end;


(**
 * amqp_queue_purge
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @param [in] queue queue
 * @returns amqp_queue_purge_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_queue_purge_ok_t *
AMQP_CALL amqp_queue_purge(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t queue)
begin
  amqp_queue_purge_t req;
  req.ticket := 0;
  req.queue := queue;
  req.nowait := 0;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_QUEUE_PURGE_METHOD, AMQP_QUEUE_PURGE_OK_METHOD, @req);
end;


(**
 * amqp_queue_delete
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @param [in] queue queue
 * @param [in] if_unused if_unused
 * @param [in] if_empty if_empty
 * @returns amqp_queue_delete_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_queue_delete_ok_t *
AMQP_CALL amqp_queue_delete(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t queue, amqp_boolean_t if_unused, amqp_boolean_t if_empty) then
begin
  amqp_queue_delete_t req;
  req.ticket := 0;
  req.queue := queue;
  req.if_unused := if_unused;
  req.if_empty := if_empty;
  req.nowait := 0;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_QUEUE_DELETE_METHOD, AMQP_QUEUE_DELETE_OK_METHOD, @req);
end;


(**
 * amqp_queue_unbind
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @param [in] queue queue
 * @param [in] exchange exchange
 * @param [in] routing_key routing_key
 * @param [in] arguments arguments
 * @returns amqp_queue_unbind_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_queue_unbind_ok_t *
AMQP_CALL amqp_queue_unbind(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t queue, amqp_bytes_t exchange, amqp_bytes_t routing_key, amqp_table_t arguments)
begin
  amqp_queue_unbind_t req;
  req.ticket := 0;
  req.queue := queue;
  req.exchange := exchange;
  req.routing_key := routing_key;
  req.arguments := arguments;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_QUEUE_UNBIND_METHOD, AMQP_QUEUE_UNBIND_OK_METHOD, @req);
end;


(**
 * amqp_basic_qos
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @param [in] prefetch_size prefetch_size
 * @param [in] prefetch_count prefetch_count
 * @param [in] global global
 * @returns amqp_basic_qos_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_basic_qos_ok_t *
AMQP_CALL amqp_basic_qos(amqp_connection_state_t state, amqp_channel_t channel, uint32_t prefetch_size, uint16_t prefetch_count, amqp_boolean_t global)
begin
  amqp_basic_qos_t req;
  req.prefetch_size := prefetch_size;
  req.prefetch_count := prefetch_count;
  req.global := global;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_BASIC_QOS_METHOD, AMQP_BASIC_QOS_OK_METHOD, @req);
end;


(**
 * amqp_basic_consume
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @param [in] queue queue
 * @param [in] consumer_tag consumer_tag
 * @param [in] no_local no_local
 * @param [in] no_ack no_ack
 * @param [in] exclusive exclusive
 * @param [in] arguments arguments
 * @returns amqp_basic_consume_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_basic_consume_ok_t *
AMQP_CALL amqp_basic_consume(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t queue, amqp_bytes_t consumer_tag, amqp_boolean_t no_local, amqp_boolean_t no_ack, amqp_boolean_t exclusive, amqp_table_t arguments)
begin
  amqp_basic_consume_t req;
  req.ticket := 0;
  req.queue := queue;
  req.consumer_tag := consumer_tag;
  req.no_local := no_local;
  req.no_ack := no_ack;
  req.exclusive := exclusive;
  req.nowait := 0;
  req.arguments := arguments;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_BASIC_CONSUME_METHOD, AMQP_BASIC_CONSUME_OK_METHOD, @req);
end;


(**
 * amqp_basic_cancel
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @param [in] consumer_tag consumer_tag
 * @returns amqp_basic_cancel_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_basic_cancel_ok_t *
AMQP_CALL amqp_basic_cancel(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t consumer_tag)
begin
  amqp_basic_cancel_t req;
  req.consumer_tag := consumer_tag;
  req.nowait := 0;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_BASIC_CANCEL_METHOD, AMQP_BASIC_CANCEL_OK_METHOD, @req);
end;


(**
 * amqp_basic_recover
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @param [in] requeue requeue
 * @returns amqp_basic_recover_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_basic_recover_ok_t *
AMQP_CALL amqp_basic_recover(amqp_connection_state_t state, amqp_channel_t channel, amqp_boolean_t requeue)
begin
  amqp_basic_recover_t req;
  req.requeue := requeue;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_BASIC_RECOVER_METHOD, AMQP_BASIC_RECOVER_OK_METHOD, @req);
end;


(**
 * amqp_tx_select
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @returns amqp_tx_select_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_tx_select_ok_t *
AMQP_CALL amqp_tx_select(amqp_connection_state_t state, amqp_channel_t channel)
begin
  amqp_tx_select_t req;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_TX_SELECT_METHOD, AMQP_TX_SELECT_OK_METHOD, @req);
end;


(**
 * amqp_tx_commit
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @returns amqp_tx_commit_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_tx_commit_ok_t *
AMQP_CALL amqp_tx_commit(amqp_connection_state_t state, amqp_channel_t channel)
begin
  amqp_tx_commit_t req;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_TX_COMMIT_METHOD, AMQP_TX_COMMIT_OK_METHOD, @req);
end;


(**
 * amqp_tx_rollback
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @returns amqp_tx_rollback_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_tx_rollback_ok_t *
AMQP_CALL amqp_tx_rollback(amqp_connection_state_t state, amqp_channel_t channel)
begin
  amqp_tx_rollback_t req;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_TX_ROLLBACK_METHOD, AMQP_TX_ROLLBACK_OK_METHOD, @req);
end;


(**
 * amqp_confirm_select
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @returns amqp_confirm_select_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_confirm_select_ok_t *
AMQP_CALL amqp_confirm_select(amqp_connection_state_t state, amqp_channel_t channel)
begin
  amqp_confirm_select_t req;
  req.nowait := 0;

  Result:= amqp_simple_rpc_decoded(state, channel, AMQP_CONFIRM_SELECT_METHOD, AMQP_CONFIRM_SELECT_OK_METHOD, @req);

end;
end;
end;
end;
end;
end;
end;
end;


implementation

end.

