unit amqp_connection;

interface

uses
	Windows, Messages, SysUtils, Classes, amqp_tcp_socket_h, amqp_private, amqp_time_h, stdint, config;

{$ifdef HAVE_CONFIG_H}
{$endif}

{$ifdef _MSC_VER}
{$HPPEMIT '# define _CRT_SECURE_NO_WARNINGS'}
{$endif}

{$HPPEMIT '#include <errno.h>'}
{$HPPEMIT '#include <stdio.h>'}
{$HPPEMIT '#include <stdlib.h>'}
{$HPPEMIT '#include <aString.h>'}

{$ifndef AMQP_INITIAL_FRAME_POOL_PAGE_SIZE}
const AMQP_INITIAL_FRAME_POOL_PAGE_SIZE = 65536;
{$EXTERNALSYM AMQP_INITIAL_FRAME_POOL_PAGE_SIZE}
{$endif}

{$ifndef AMQP_INITIAL_INBOUND_SOCK_BUFFER_SIZE}
const AMQP_INITIAL_INBOUND_SOCK_BUFFER_SIZE = 131072;
{$EXTERNALSYM AMQP_INITIAL_INBOUND_SOCK_BUFFER_SIZE}
{$endif}

const ENFORCE_STATEstatenum);
{$EXTERNALSYM ENFORCE_STATE}
  begin
    amqp_connection_state_t _check_state := (statevec);
    amqp_connection_state_const _wanted_state := (statenum;

    if (_check_state^.state  <>  _wanted_state) then
      amqp_abort(
          'Programming error: invalid AMQP connection state: expected %d, '
          'got %d',
          _wanted_state, _check_state^.state);
  end;

amqp_connection_state_t amqp_connection_state_t amqp_new_connection(procedure)connection_state_t state =     (
	v1: ;  SizeOf(type
	v2: calloc(1;  SizeOf(struct amqp_connection_state_t_)) = record
	v3: end;;;
	v4: end;;
	v5: ;
	:= amqp_tune_connection(state res 0, AMQP_INITIAL_FRAME_POOL_PAGE_SIZE, 0);
    if (0 <> res) then
    begin
    goto out_nomem;
    end;

  state^.inbound_buffer.bytes := state^.header_buffer;
  state^.inbound_buffer.len := SizeOf(state^.header_buffer);

  state^.state := CONNECTION_STATE_INITIAL;
  (* the server protocol version response is 8 bytes, which conveniently
     is also the minimum frame size *)
  state^.target_size := 8;

  state^.sock_inbound_buffer.len := AMQP_INITIAL_INBOUND_SOCK_BUFFER_SIZE;
  state^.sock_inbound_buffer.bytes := malloc(AMQP_INITIAL_INBOUND_SOCK_BUFFER_SIZE);
    if (state^.sock_inbound_buffer.bytes = 0) then
    begin
    goto out_nomem;
    end;

  init_amqp_pool(@state^.properties_pool, 512);

  Result:= state;

out_nomem:
  free(state^.sock_inbound_buffer.bytes);
  free(state);
  Result:= 0;
 end;

function amqp_get_sockfd(state: amqp_connection_state_t): Integer
  begin
  Result:= state^.socket ? amqp_socket_get_sockfd(state^.socket) : -1;
  end;

procedure amqp_set_sockfd(v1: state);
    if ( not socket) then
    begin
    amqp_abort('%s', strerror(errno));
    end;
  amqp_tcp_socket_set_sockfd(socket, sockfd);
 end;

procedure amqp_set_socket(v1: state^.socket);
  state^.socket := socket;
 end;

amqp_socket_t *
amqp_get_socket(amqp_connection_state_t state)
  begin
  Result:= state^.socket;
  end;

function amqp_tune_connection(
	state: amqp_connection_state_t;
	channel_max: Integer;
	frame_max: Integer;
	heartbeat: Integer): Integer
begin
  Pointer newbuf;
  Integer res;

  ENFORCE_STATE(state, CONNECTION_STATE_IDLE);

  state^.channel_max := channel_max;
  state^.frame_max := frame_max;

  state^.heartbeat := heartbeat;
    if (0 > state^.heartbeat) then
   begin
    state^.heartbeat := 0;
   end;

  res = amqp_time_s_from_now(@state^.next_send_heartbeat,
                             amqp_heartbeat_send(state));
    if (AMQP_STATUS_OK <> res) then
   begin
    Result:= res;
   end;
  res = amqp_time_s_from_now(@state^.next_recv_heartbeat,
                             amqp_heartbeat_recv(state));
   if (AMQP_STATUS_OK <> res) then
   begin
    Result:= res;
   end;

  state^.outbound_buffer.len := frame_max;
  newbuf := realloc(state^.outbound_buffer.bytes, frame_max);
   if (newbuf = 0) then
   begin
    Result:= AMQP_STATUS_NO_MEMORY;
   end;
  state^.outbound_buffer.bytes := newbuf;

  Result:= AMQP_STATUS_OK;
end;

function amqp_get_channel_max(state: amqp_connection_state_t): Integer
 begin
  Result:= state^.channel_max;
 end;

function amqp_get_frame_max(state: amqp_connection_state_t): Integer
 begin
  Result:= state^.frame_max;
 end;

function amqp_get_heartbeat(state: amqp_connection_state_t): Integer
 begin
  Result:= state^.heartbeat;
 end;

function amqp_destroy_connection(state: amqp_connection_state_t): Integer
 begin
  Integer status := AMQP_STATUS_OK;
   if (state) then
   begin
    Integer i;
      for (i := 0; i < POOL_TABLE_SIZE; ++i)
     begin
      amqp_pool_table_entry_t *entry := state^.pool_table[i];
       while (0 <> entry)
       begin
        amqp_pool_table_entry_t *todelete := entry;
        empty_amqp_pool(@entry^.pool);
        entry := entry^.next;
        free(todelete);
       end;
     end;

    free(state^.outbound_buffer.bytes);
    free(state^.sock_inbound_buffer.bytes);
    amqp_socket_delete(state^.socket);
    empty_amqp_pool(@state^.properties_pool);
    free(state);
   end;
  Result:= status;
 end;

 static procedure return_to_idle(v1: state^.header_buffer);
  state^.inbound_buffer.bytes := state^.header_buffer;
  state^.inbound_offset := 0;
  state^.target_size := HEADER_SIZE;
  state^.state := CONNECTION_STATE_IDLE;
 end;

 size_t consume_data(amqp_connection_state_t state,
                           amqp_bytes_t *received_data)
 begin
  (* how much data is available and will fit? *)
  size_t bytes_consumed := state^.target_size - state^.inbound_offset;
    if (received_data^.len < bytes_consumed) then
   begin
    bytes_consumed := received_data^.len;
   end;

  memcpy(amqp_offset(state^.inbound_buffer.bytes, state^.inbound_offset),
         received_data^.bytes, bytes_consumed);
  state^.inbound_offset:= mod + bytes_consumed;
  received_data^.bytes := amqp_offset(received_data^.bytes, bytes_consumed);
  received_data^.len:= mod - bytes_consumed;

  Result:= bytes_consumed;
 end;

function amqp_handle_input(
	state: amqp_connection_state_t;
	received_data: amqp_bytes_t;
	var decoded_frame: amqp_frame_t): Integer
 begin
  size_t bytes_consumed;
  Pointer raw_frame;

  (* Returning frame_type of zero indicates either insufficient input,
     or a complete, ignored frame was read. *)
  decoded_frame^.frame_type = 0;

    if (received_data.len = 0) then
   begin
    Result:= AMQP_STATUS_OK;
   end;

    if (state^.state = CONNECTION_STATE_IDLE) then
   begin
    state^.state := CONNECTION_STATE_HEADER;
   end;

  bytes_consumed := consume_data(state, @received_data);

  (* do we have target_size data yet? if not, return with the
     expectation that more will arrive *)
    if (state^.inbound_offset < state^.target_size) then
   begin
    Result:= (Integer)bytes_consumed;
   end;

  raw_frame := state^.inbound_buffer.bytes;

      case (state^.state)
     begin  of
      CONNECTION_STATE_INITIAL:
      (* check for a protocol header from the server *)
      if (CompareMem(raw_frame, 'AMQP', 4) == 0) then
      decoded_frame^.frame_type = AMQP_PSEUDOFRAME_PROTOCOL_HEADER;
      decoded_frame^.channel := 0;

      decoded_frame^.payload.protocol_header.transport_high
        := amqp_d8(raw_frame, 4);
      decoded_frame^.payload.protocol_header.transport_low
        := amqp_d8(raw_frame, 5);
      decoded_frame^.payload.protocol_header.protocol_version_major
        := amqp_d8(raw_frame, 6);
      decoded_frame^.payload.protocol_header.protocol_version_minor
        := amqp_d8(raw_frame, 7);

      return_to_idle(state);
      Result:= (Integer)bytes_consumed;
     end;

    (* it's not a protocol header; fall through to process it as a
       regular frame header *)

   CONNECTION_STATE_HEADER:
   begin
    amqp_channel_t channel;
    amqp_pool_t *channel_pool;
    (* frame length is 3 bytes in *)
    channel := amqp_d16(raw_frame, 1);

    state^.target_size := amqp_d32(raw_frame, 3) + HEADER_SIZE + FOOTER_SIZE;

      if ((size_t)state^.frame_max < state^.target_size) then
     begin
      Result:= AMQP_STATUS_BAD_AMQP_DATA;
     end;

    channel_pool := amqp_get_or_create_channel_pool(state, channel);
      if (0 = channel_pool) then
     begin
      Result:= AMQP_STATUS_NO_MEMORY;
     end;

    amqp_pool_alloc_bytes(channel_pool, state^.target_size, @state^.inbound_buffer);
      if (0 = state^.inbound_buffer.bytes) then
     begin
      Result:= AMQP_STATUS_NO_MEMORY;
     end;
    memcpy(state^.inbound_buffer.bytes, state^.header_buffer, HEADER_SIZE);
    raw_frame := state^.inbound_buffer.bytes;

    state^.state := CONNECTION_STATE_BODY;

    bytes_consumed:= mod + consume_data(state, @received_data);

    (* do we have target_size data yet? if not, return with the
       expectation that more will arrive *)
     if (state^.inbound_offset < state^.target_size) then
     begin
      Result:= (Integer)bytes_consumed;
     end;

   end;
    (* fall through to process body *)

   CONNECTION_STATE_BODY:
   begin
    amqp_bytes_t encoded;
    Integer res;
    amqp_pool_t *channel_pool;

    (* Check frame end marker (footer) *)
     if (amqp_d8(raw_frame, state^.target_size - 1) <> AMQP_FRAME_END) then
     begin
      Result:= AMQP_STATUS_BAD_AMQP_DATA;
     end;

    decoded_frame^.frame_type = amqp_d8(raw_frame, 0);
    decoded_frame^.channel := amqp_d16(raw_frame, 1);

    channel_pool := amqp_get_or_create_channel_pool(state, decoded_frame^.channel);
     if (0 = channel_pool) then
     begin
      Result:= AMQP_STATUS_NO_MEMORY;
     end;

     case (decoded_frame^.frame_type)
     begin  of
     AMQP_FRAME_METHOD:
      decoded_frame^.payload.method.id := amqp_d32(raw_frame, HEADER_SIZE);
      encoded.bytes := amqp_offset(raw_frame, HEADER_SIZE + 4);
      encoded.len := state^.target_size - HEADER_SIZE - 4 - FOOTER_SIZE;

      res = amqp_decode_method(decoded_frame^.payload.method.id,
                               channel_pool, encoded,
                               @decoded_frame^.payload.method.decoded);
        if (res < 0) then
       begin
        Result:= res;
       end;

      break;

     AMQP_FRAME_HEADER:
      decoded_frame^.payload.properties.class_id
        := amqp_d16(raw_frame, HEADER_SIZE);
      (* unused 2-byte weight field goes here *)
      decoded_frame^.payload.properties.body_size
        := amqp_d64(raw_frame, HEADER_SIZE + 4);
      encoded.bytes := amqp_offset(raw_frame, HEADER_SIZE + 12);
      encoded.len := state^.target_size - HEADER_SIZE - 12 - FOOTER_SIZE;
      decoded_frame^.payload.properties.raw := encoded;

      res = amqp_decode_properties(decoded_frame^.payload.properties.class_id,
                                   channel_pool, encoded,
                                   @decoded_frame^.payload.properties.decoded);
       if (res < 0) then
       begin
        Result:= res;
       end;

      break;

     AMQP_FRAME_BODY:
      decoded_frame^.payload.body_fragment.len
        := state^.target_size - HEADER_SIZE - FOOTER_SIZE;
      decoded_frame^.payload.body_fragment.bytes
        := amqp_offset(raw_frame, HEADER_SIZE);
      break;

     AMQP_FRAME_HEARTBEAT:
      break;

      default:
      (* Ignore the frame *)
      decoded_frame^.frame_type = 0;
      break;
     end;

    return_to_idle(state);
    Result:= (Integer)bytes_consumed;
   end;

    default:
    amqp_abort('Internal error: invalid amqp_connection_state_t->state %d',
               state^.state);
   end;
 end;

  amqp_boolean_t amqp_release_buffers_ok(amqp_connection_state_t state)
  begin
  Result:= (state^.state = CONNECTION_STATE_IDLE);
  end;

  procedure amqp_release_buffers(v1: state; v2: CONNECTION_STATE_IDLE);

    for (i := 0; i < POOL_TABLE_SIZE; ++i)
  begin
    amqp_pool_table_entry_t *entry := state^.pool_table[i];

      for ( ;0 <> entry; entry := entry^.next)
    begin
      amqp_maybe_release_buffers_on_channel(state, entry^.channel);
    end;
  end;
 end;

procedure amqp_maybe_release_buffers(
	  then
  begin: amqp_release_buffers_ok(state));
  	v2: amqp_release_buffers(state);
  end;
 end;

procedure amqp_maybe_release_buffers_on_channel(
	<> state^.state) then
  begin: CONNECTION_STATE_IDLE;
	v2: Exit;;
	v3:
  end;;
	v4: ;
	:= state^.first_queued_frame; queued_link;
	v6: ;
	(0 <> queued_link)
  begin: while;
	var frame := queued_link^.data; amqp_frame_t;
	(channel = frame^.channel) then
  begin: if
	v10: Exit;;
	v11:
  end;;
	v12: ;
	:= queued_link^.next; queued_link;
	v14:
  end;;
	v15: ;
	:= amqp_get_channel_pool(state pool channel);

    if (pool <> 0) then
  begin
    recycle_amqp_pool(pool);
  end;
 end;

 function amqp_frame_to_bytes(
	var frame: amqp_frame_t;  amqp_bytes_t buffer,
	var encoded: amqp_bytes_t): Integer
begin
  Pointer out_frame := buffer.bytes;
  size_t out_frame_len;
  Integer res;

  amqp_e8(out_frame, 0, frame^.frame_type);
  amqp_e16(out_frame, 1, frame^.channel);

 case (frame^.frame_type)
  begin  of
     AMQP_FRAME_BODY:
     begin
       amqp_bytes_t *body := @frame^.payload.body_fragment;

      memcpy(amqp_offset(out_frame, HEADER_SIZE), body^.bytes, body^.len);

      out_frame_len := body^.len;
      break;
     end;
     AMQP_FRAME_METHOD:
     begin
      amqp_bytes_t method_encoded;

      amqp_e32(out_frame, HEADER_SIZE, frame^.payload.method.id);

      method_encoded.bytes := amqp_offset(out_frame, HEADER_SIZE + 4);
      method_encoded.len := buffer.len - HEADER_SIZE - 4 - FOOTER_SIZE;

      res = amqp_encode_method(frame^.payload.method.id,
                               frame^.payload.method.decoded, method_encoded);
       if (res < 0) then
       begin
        Result:= res;
       end;

      out_frame_len := res + 4;
      break;
     end;

     AMQP_FRAME_HEADER:
     begin
      amqp_bytes_t properties_encoded;

      amqp_e16(out_frame, HEADER_SIZE, frame^.payload.properties.class_id);
      amqp_e16(out_frame, HEADER_SIZE + 2, 0); (* "weight" *)
      amqp_e64(out_frame, HEADER_SIZE + 4, frame^.payload.properties.body_size);

      properties_encoded.bytes := amqp_offset(out_frame, HEADER_SIZE + 12);
      properties_encoded.len := buffer.len - HEADER_SIZE - 12 - FOOTER_SIZE;

      res = amqp_encode_properties(frame^.payload.properties.class_id,
                                   frame^.payload.properties.decoded,
                                   properties_encoded);
        if (res < 0) then
       begin
        Result:= res;
       end;

      out_frame_len := res + 12;
      break;
     end;

     AMQP_FRAME_HEARTBEAT:
      out_frame_len := 0;
      break;

    default:
      Result:= AMQP_STATUS_INVALID_PARAMETER;
  end;

  amqp_e32(out_frame, 3, (uint32_t)out_frame_len);
  amqp_e8(out_frame, HEADER_SIZE + out_frame_len, AMQP_FRAME_END);

  encoded^.bytes := out_frame;
  encoded^.len := out_frame_len + HEADER_SIZE + FOOTER_SIZE;

  Result:= AMQP_STATUS_OK;
 end;

function amqp_send_frame(
	state: amqp_connection_state_t;
	var frame: amqp_frame_t): Integer
 begin
  Result:= amqp_send_frame_inner(state, frame, AMQP_SF_NONE);
 end;

function amqp_send_frame_inner(
	state: amqp_connection_state_t;
	var frame: amqp_frame_t Integer flags): Integer
 begin
  Integer res;
  ssize_t sent;
  amqp_bytes_t encoded;

  (* TODO: if the AMQP_SF_MORE socket optimization can be shown to work
   * correctly, then this could be un-done so that body-frames are sent as 3
   * send calls, getting rid of the copy of the body content, some testing
   * would need to be done to see if this would actually a win for performance.
   * *)
  res := amqp_frame_to_bytes(frame, state^.outbound_buffer, @encoded);
    if (AMQP_STATUS_OK <> res) then
   begin
    Result:= res;
   end;

  start_send:
  sent = amqp_try_send(state, encoded.bytes, encoded.len,
                       state^.next_recv_heartbeat, flags);
    if (0 > sent) then
   begin
    Result:= (Integer)sent;
   end;

  (* A partial send has occurred, because of a heartbeat timeout, try and recv
   * something *)
    if ((ssize_t)encoded.len <> sent) then
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

    encoded.bytes := (uint8_t)encoded.bytes + sent;
    encoded.len:= mod - sent;
    goto start_send;
   end;

  res = amqp_time_s_from_now(@state^.next_send_heartbeat,
                             amqp_heartbeat_send(state));
  Result:= res;
 end;

amqp_table_t *
amqp_get_server_properties(amqp_connection_state_t state)
begin
  Result:= @state^.server_properties;
end;

amqp_table_t *
amqp_get_client_properties(amqp_connection_state_t state)
begin
  Result:= @state^.client_properties;
end;

implementation

end.

