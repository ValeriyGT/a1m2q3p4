unit amqp_consumer;

interface

uses
	Windows, Messages, SysUtils, Classes, amqp_h, amqp_private, amqp_socket_h;


(* vim:set ft=c ts=2 sw=2 sts=2 et cindent: *)
(*
 * ***** aBegin LICENSE BLOCK *****
 * Version: MIT
 *
 * Portions created by Alan Antonuk are Copyright (c) 2013-2014
 * Alan Antonuk. All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the 'Software'), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT.  NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER  AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OF OR
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS  THE
 * SOFTWARE.
 * ***** END LICENSE BLOCK *****
 *)

{$HPPEMIT '#include <stdlib.h>'}
{$HPPEMIT '#include <aString.h>'}


function amqp_basic_function _clone(
	var original: amqp_basic_properties_t;
	var clone: amqp_basic_properties_t;
	var pool: amqp_pool_t): properties: Integer

begin
  FillChar(clone, 0, SizeOf(clone));
  clone->_flags := original->_flags;

const CLONE_BYTES_POOLclone, pool);
{$EXTERNALSYM CLONE_BYTES_POOL}
    if (0 = original.len) then
  begin
    clone := amqp_empty_bytes;
  end;
   else
   begin
    amqp_pool_alloc_bytes(pool, original.len, @clone);
     if (0 = clone.bytes) then
     begin
      Result:= AMQP_STATUS_NO_MEMORY;
     end;
    memcpy(clone.bytes, original.bytes, clone.len);
   end;

   if (clone->_flags and AMQP_BASIC_CONTENT_TYPE_FLAG) then
   begin
    CLONE_BYTES_POOL(original^.content_type, clone^.content_type, pool)
   end;

   if (clone->_flags and AMQP_BASIC_CONTENT_ENCODING_FLAG) then
   begin
    CLONE_BYTES_POOL(original^.content_encoding, clone^.content_encoding, pool)
   end;

    if (clone->_flags and AMQP_BASIC_HEADERS_FLAG) then
   begin
    Integer res := amqp_table_clone(@original^.headers, @clone^.headers, pool);
     if (AMQP_STATUS_OK <> res) then
     begin
      Result:= res;
     end;
   end;

   if (clone->_flags and AMQP_BASIC_DELIVERY_MODE_FLAG) then
   begin
    clone^.delivery_mode := original^.delivery_mode;
   end;

   if (clone->_flags and AMQP_BASIC_PRIORITY_FLAG) then
   begin
    clone^.priority := original^.priority;
   end;

   if (clone->_flags and AMQP_BASIC_CORRELATION_ID_FLAG) then
   begin
    CLONE_BYTES_POOL(original^.correlation_id, clone^.correlation_id, pool)
   end;

   if (clone->_flags and AMQP_BASIC_REPLY_TO_FLAG) then
   begin
    CLONE_BYTES_POOL(original^.reply_to, clone^.reply_to, pool)
   end;

   if (clone->_flags and AMQP_BASIC_EXPIRATION_FLAG) then
   begin
    CLONE_BYTES_POOL(original^.expiration, clone^.expiration, pool)
   end;

   if (clone->_flags and AMQP_BASIC_MESSAGE_ID_FLAG) then
   begin
    CLONE_BYTES_POOL(original^.message_id, clone^.message_id, pool)
   end;

   if (clone->_flags and AMQP_BASIC_TIMESTAMP_FLAG) then
   begin
    clone^.timestamp := original^.timestamp;
   end;

    if (clone->_flags and AMQP_BASIC_TYPE_FLAG) then
   begin
    CLONE_BYTES_POOL(original^.aType, clone^.aType, pool)
   end;

   if (clone->_flags and AMQP_BASIC_USER_ID_FLAG) then
   begin
    CLONE_BYTES_POOL(original^.user_id, clone^.user_id, pool)
   end;

   if (clone->_flags and AMQP_BASIC_APP_ID_FLAG) then
   begin
    CLONE_BYTES_POOL(original^.app_id, clone^.app_id, pool)
   end;

   if (clone->_flags and AMQP_BASIC_CLUSTER_ID_FLAG) then
   begin
    CLONE_BYTES_POOL(original^.cluster_id, clone^.cluster_id, pool)
   end;

  Result:= AMQP_STATUS_OK;
{$undef CLONE_BYTES_POOL}
 end;


procedure amqp_destroy_message(v1: @message^.pool);
  amqp_bytes_free(message^.body);
 end;

procedure amqp_destroy_envelope(v1: @envelope^.message);
  amqp_bytes_free(envelope^.routing_key);
  amqp_bytes_free(envelope^.exchange);
  amqp_bytes_free(envelope^.consumer_tag);
 end;


  function amqp_bytes_malloc_dup_failed(bytes: amqp_bytes_t): Integer
 begin
    if (bytes.len <> 0 and bytes.bytes = 0) then
   begin
    Result:= 1;
   end;
  Result:= 0;
 end;

amqp_rpc_reply_t
amqp_consume_message(amqp_connection_state_t state, amqp_envelope_t *envelope,
                      timeval *timeout, AMQP_UNUSED Integer flags)
begin
  Integer res;
  amqp_frame_t frame;
  amqp_basic_deliver_t *delivery_method;
  amqp_rpc_reply_t ret;

  FillChar(@ret, 0, SizeOf(ret));
  FillChar(envelope, 0, SizeOf(envelope));

  res := amqp_simple_wait_frame_noblock(state, @frame, timeout);
    if (AMQP_STATUS_OK <> res) then
  begin
    ret.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
    ret.library_error := res;
    goto error_out1;
  end;

  if (AMQP_FRAME_METHOD <> frame.frame_type then
      or AMQP_BASIC_DELIVER_METHOD <> frame.payload.method.id)
  begin
    amqp_put_back_frame(state, @frame);
    ret.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
    ret.library_error := AMQP_STATUS_UNEXPECTED_STATE;
    goto error_out1;
  end;

  delivery_method := frame.payload.method.decoded;

  envelope^.channel := frame.channel;
  envelope^.consumer_tag := amqp_bytes_malloc_dup(delivery_method^.consumer_tag);
  envelope^.delivery_tag := delivery_method^.delivery_tag;
  envelope^.redelivered := delivery_method^.redelivered;
  envelope^.exchange := amqp_bytes_malloc_dup(delivery_method^.exchange);
  envelope^.routing_key := amqp_bytes_malloc_dup(delivery_method^.routing_key);

  if (amqp_bytes_malloc_dup_failed(envelope^.consumer_tag) then   or
      amqp_bytes_malloc_dup_failed(envelope^.exchange)  or
      amqp_bytes_malloc_dup_failed(envelope^.routing_key))
  begin
    ret.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
    ret.library_error := AMQP_STATUS_NO_MEMORY;
    goto error_out2;
  end;

  ret := amqp_read_message(state, envelope^.channel, @envelope^.message, 0);
    if (AMQP_RESPONSE_NORMAL <> ret.reply_type) then
  begin
    goto error_out2;
  end;

  ret.reply_type = AMQP_RESPONSE_NORMAL;
  Result:= ret;

error_out2:
  amqp_bytes_free(envelope^.routing_key);
  amqp_bytes_free(envelope^.exchange);
  amqp_bytes_free(envelope^.consumer_tag);
error_out1:
  Result:= ret;
end;

amqp_rpc_reply_t amqp_read_message(amqp_connection_state_t state,
                                   amqp_channel_t channel,
                                   amqp_message_t *message,
                                   AMQP_UNUSED Integer flags)
begin
  amqp_frame_t frame;
  amqp_rpc_reply_t ret;

  size_t body_read;
  PChar body_read_ptr;
  Integer res;

  FillChar(@ret, 0, SizeOf(ret));
  FillChar(message, 0, SizeOf(message));

  res := amqp_simple_wait_frame_on_channel(state, channel, @frame);
   if (AMQP_STATUS_OK <> res) then
   begin
    ret.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
    ret.library_error := res;

    goto error_out1;
   end;

   if (AMQP_FRAME_HEADER <> frame.frame_type) then
   begin
    if (AMQP_FRAME_METHOD = frame.frame_type  and then
        (AMQP_CHANNEL_CLOSE_METHOD = frame.payload.method.id  or
         AMQP_CONNECTION_CLOSE_METHOD = frame.payload.method.id))
    `begin

      ret.reply_type = AMQP_RESPONSE_SERVER_EXCEPTION;
      ret.reply := frame.payload.method;

     end;
     else
     begin
      ret.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
      ret.library_error := AMQP_STATUS_UNEXPECTED_STATE;

      amqp_put_back_frame(state, @frame);
     end;
    goto error_out1;
   end;

  init_amqp_pool(@message^.pool, 4096);
  res = amqp_basic_properties_clone(frame.payload.properties.decoded,
                                    @message^.properties, @message^.pool);

    if (AMQP_STATUS_OK <> res) then
   begin
    ret.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
    ret.library_error := res;
    goto error_out3;
   end;

   if (0 = frame.payload.properties.body_size) then
   begin
    message^.body := amqp_empty_bytes;
   end;
   else
   begin
      if (SIZE_MAX < frame.payload.properties.body_size) then
     begin
      ret.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
      ret.library_error := AMQP_STATUS_NO_MEMORY;
      goto error_out1;
     end;
    message^.body := amqp_bytes_malloc((size_t)frame.payload.properties.body_size);
     if (0 = message^.body.bytes) then
     begin
      ret.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
      ret.library_error := AMQP_STATUS_NO_MEMORY;
      goto error_out1;
     end;
   end;

  body_read := 0;
  body_read_ptr := message^.body.bytes;

  while (body_read < message^.body.len)
  begin
    res := amqp_simple_wait_frame_on_channel(state, channel, @frame);
     if (AMQP_STATUS_OK <> res) then
     begin
      ret.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
      ret.library_error := res;
      goto error_out2;
     end;
     if (AMQP_FRAME_BODY <> frame.frame_type) then
     begin
      if (AMQP_FRAME_METHOD = frame.frame_type  and then
          (AMQP_CHANNEL_CLOSE_METHOD = frame.payload.method.id  or
           AMQP_CONNECTION_CLOSE_METHOD = frame.payload.method.id))
       begin

        ret.reply_type = AMQP_RESPONSE_SERVER_EXCEPTION;
        ret.reply := frame.payload.method;
       end;
       else
       begin
        ret.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
        ret.library_error := AMQP_STATUS_BAD_AMQP_DATA;
       end;
      goto error_out2;
     end;

      if (body_read + frame.payload.body_fragment.len > message^.body.len) then
     begin
      ret.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
      ret.library_error := AMQP_STATUS_BAD_AMQP_DATA;
      goto error_out2;
     end;

    memcpy(body_read_ptr, frame.payload.body_fragment.bytes, frame.payload.body_fragment.len);

    body_read:= mod + frame.payload.body_fragment.len;
    body_read_ptr:= mod + frame.payload.body_fragment.len;
   end;

  ret.reply_type = AMQP_RESPONSE_NORMAL;
  Result:= ret;

error_out2:
  amqp_bytes_free(message^.body);
error_out3:
  empty_amqp_pool(@message^.pool);
error_out1:
  Result:= ret;
 end;

implementation

end.

