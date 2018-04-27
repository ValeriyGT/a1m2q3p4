unit amqp_private;

interface

uses
	Windows, Messages, SysUtils, Classes, amqp_h, amqp_framing_h, config;


(* vim:set ft=c ts=2 sw=2 sts=2 et cindent: *)
{$ifndef librabbitmq_amqp_private_h}
{$define librabbitmq_amqp_private_h}


{$ifdef HAVE_CONFIG_H}
{$endif}

const AMQ_COPYRIGHT = 'Copyright (c) 2007-2014 VMWare Inc, Tony Garnock-Jones,';
{$EXTERNALSYM AMQ_COPYRIGHT}
                      ' and Alan Antonuk.'

{$HPPEMIT '#include <aString.h>'}

{$ifdef _WIN32}
{$HPPEMIT '# ifndef WINVER'}
(* WINVER 0x0502 is WinXP SP2+, Windows Server 2003 SP1+
 * See: http://msdn.microsoft.com/en-us/library/windows/desktop/aa383745(v=vs.85).aspx#macros_for_conditional_declarations */
{$HPPEMIT '#  define WINVER 0x0502'}
{$HPPEMIT '# endif'}
{$HPPEMIT '# ifndef WIN32_LEAN_AND_MEAN'}
{$HPPEMIT '#  define WIN32_LEAN_AND_MEAN'}
{$HPPEMIT '# endif'}
{$HPPEMIT '# include <Winsock2.h>'}
{$else}
{$HPPEMIT '# include <arpa/inet.h>'}
{$HPPEMIT '# include <sys/uio.h>'}
{$endif}

(* GCC attributes *)
{$if Defined(__GNUC__) and (__GNUC__ __GNUC__ > 2 or = 2  and  __GNUC_MINOR__ > 4)}
{$define AMQP_NORETURN}
  __attribute__ ((__noreturn__))
{$define AMQP_UNUSED}
  __attribute__ ((__unused__))
{$else}
{$define AMQP_NORETURN}
{$define AMQP_UNUSED}
{$endif}

{$if Defined(__GNUC__) and (__GNUC__ >= 4)}
{$define AMQP_PRIVATE}
  __attribute__ ((visibility ('hidden')))
{$else}
{$define AMQP_PRIVATE}
{$endif}

PChar
amqp_os_error_string(Integer err);

{$ifdef WITH_SSL}
PChar
amqp_ssl_error_string(Integer err);
{$endif}

{$HPPEMIT '#include 'amqp_socket.h''}
{$HPPEMIT '#include 'amqp_time.h''}

(*
 * Connection states: XXX FIX
 *
 * - CONNECTION_STATE_INITIAL: The initial state, when we cannot be
 *   sure if the next thing we will get is the first AMQP frame, or a
 *   protocol header from the server.
 *
 * - CONNECTION_STATE_IDLE: The normal state between
 *   frames. Connections may only be reconfigured, and the
 *   connection's pools recycled, when in this state. Whenever we're
 *   in this state, the inbound_buffer's bytes pointer must be NULL;
 *   any other state, and it must point to a block of memory allocated
 *   from the frame_pool.
 *
 * - CONNECTION_STATE_HEADER: Some bytes of an incoming frame have
 *   been seen, but not a complete frame header's worth.
 *
 * - CONNECTION_STATE_BODY: A complete frame header has been seen, but
 *   the frame is not yet complete. When it is completed, it will be
 *   returned, and the connection will Result:= to IDLE state.
 *
 *)
const CONNECTION_STATE_IDLE = 0;
const CONNECTION_STATE_INITIAL	= 1;
const CONNECTION_STATE_HEADER	= 2;
const CONNECTION_STATE_BODY	= 3;

type	CONNECTION_STATE_IDLE..CONNECTION_STATE_BODY	amqp_connection_state_const type
	 struct amqp_link_t_ *next	= 0 = record
	end;_SIZE = 16;
{$EXTERNALSYM POOL_TABLE_SIZE};
const type	= 3;
const  amqp_pool_table_entry_t_ begin;
	 amqp_pool_table_entry_t_ begin;
const type
	 struct amqp_pool_table_entry_t_ *next	= 4 = record
	end;t amqp_pool_t pool	= 5;
const amqp_channel_t channel	= 6;
const end	= 7; amqp_pool_table_entry_t;
const type
	= record amqp_connection_state_t_ begin	= 8;
const amqp_pool_table_entry_t *pool_table[POOL_TABLE_SIZE]	= 9;
const amqp_connection_state_enum state	= 10;
const Integer channel_max	= 11;
const Integer frame_max	= 12;
(* Heartbeat interval in seconds. If this is <= 0, then heartbeats are not
   * enabled, and next_recv_heartbeat and next_send_heartbeat are set to
   * infinite *)
const Integer heartbeat	= 15;
const amqp_time_t next_recv_heartbeat	= 16;
const amqp_time_t next_send_heartbeat	= 17;
(* buffer for holding frame headers.  Allows us to delay allocating
   * the raw frame buffer until the type, channel, and size are all known
   *)
const char header_buffer[HEADER_SIZE + 1]	= 21;
const amqp_bytes_t inbound_buffer	= 22;
const size_t inbound_offset	= 23;
const size_t target_size	= 24;
const amqp_bytes_t outbound_buffer	= 25;
const amqp_socket_t *socket	= 26;
const amqp_bytes_t sock_inbound_buffer	= 27;
const size_t sock_inbound_offset	= 28;
const size_t sock_inbound_limit	= 29;
const amqp_link_t *first_queued_frame	= 30;
const amqp_link_t *last_queued_frame	= 31;
const amqp_rpc_reply_t most_recent_api_result	= 32;
const amqp_table_t server_properties	= 33;
const amqp_table_t client_properties	= 34;
const amqp_pool_t properties_pool	= 35;

type
	next..amqp_pool_t properties_pool = ^struct amqp_link_t_;
	{$EXTERNALSYM next..amqp_pool_t properties_pool}


(* 0x00xx -> AMQP_STATUS_*/
(* 0x01xx -> AMQP_STATUS_TCP_* *)
(* 0x02xx -> AMQP_STATUS_SSL_* *)
const AMQP_PRIVATE_STATUS_SOCKET_NEEDREAD =  -$1301;
const AMQP_PRIVATE_STATUS_SOCKET_NEEDWRITE = -$1302;

type
	amqp_status_private_enum = AMQP_PRIVATE_STATUS_SOCKET_NEEDREAD..AMQP_PRIVATE_STATUS_SOCKET_NEEDWRITE;
	{$EXTERNALSYM amqp_status_private_enum}


(* 7 bytes up front; then payload; then 1 byte footer *)
const HEADER_SIZE = 7;
{$EXTERNALSYM HEADER_SIZE}
const FOOTER_SIZE = 1;
{$EXTERNALSYM FOOTER_SIZE}

const AMQP_PSEUDOFRAME_PROTOCOL_HEADER = 'A';
{$EXTERNALSYM AMQP_PSEUDOFRAME_PROTOCOL_HEADER}

type
	= record
		dwBitField: Result:=;
	end;

  function amqp_heartbeat_recv(state: amqp_connection_state_t): Integer begin
  Result:= 2 * state^.heartbeat;
 end;

function amqp_try_recv(var data: procedure; offset: size_t): Pointer: Integerhar )data + offset;  end;

(* This macro defines the encoding and decoding functions associated with a
   simple aType. *)

const DECLARE_CODEC_BASE_TYPEhtonx, ntohx);
{$EXTERNALSYM DECLARE_CODEC_BASE_TYPE}

{$HPPEMIT 'static    static  procedure amqp_e##bits(void *data, size_t offset,                                            uint##bits##_t val)'}
  begin
    (* The AMQP data might be unaligned. So we encode and then copy the       \
             aResult into place. *)                                            \
{$HPPEMIT 'uint##bits##_t res := htonx(val);'}
    memcpy(amqp_offset(data, offset), @res, bits/8);
   end;

{$HPPEMIT 'static  uint##bits##_t   static  uint##bits##_t amqp_d##bits(procedure *data, size_t offset)'}     (* The AMQP data might be unaligned.  So we copy the source value         \
             into a variable and then decode it. *)                           \
{$HPPEMIT 'uint##bits##_t val;'}
    memcpy(@val, amqp_offset(data, offset), bits/8);
    Result:= ntohx(val);
   end;

{$HPPEMIT 'static  int amqp_encode_##bits(amqp_bytes_t encoded, size_t *offset,'}
{$HPPEMIT 'uint##bits##_t input)'}

  begin
    size_t o := *offset;
    if ((offset = o + bits / 8) <= encoded.len) then  begin
{$HPPEMIT 'amqp_e##bits(encoded.bytes, o, input);'}
      Result:= 1;
     end;
    else begin
      Result:= 0;
     end;
   end;

{$HPPEMIT 'static  int amqp_decode_##bits(amqp_bytes_t encoded, size_t *offset,'}
{$HPPEMIT 'uint##bits##_t *output)'}

  begin
    size_t o := *offset;
    if ((offset = o + bits / 8) <= encoded.len) then  begin
{$HPPEMIT '*output := amqp_d##bits(encoded.bytes, o);'}
      Result:= 1;
     end;
    else begin
      Result:= 0;
     end;
   end;

(* Determine byte order *)
{$ifdef __GLIBC__}
{$HPPEMIT '# include <endian.h>'}
{$HPPEMIT '# if (__BYTE_ORDER == __LITTLE_ENDIAN)'}
{$HPPEMIT '#  define AMQP_LITTLE_ENDIAN'}
{$HPPEMIT '# elif (__BYTE_ORDER == __BIG_ENDIAN)'}
{$HPPEMIT '#  define AMQP_BIG_ENDIAN'}
{$HPPEMIT '# else'}
(* Don't define anything *)
{$HPPEMIT '# endif'}
{$HPPEMIT '#elif defined(_BIG_ENDIAN) && !defined(_LITTLE_ENDIAN) ||'}
      defined(__BIG_ENDIAN__) and  not defined(__LITTLE_ENDIAN__)
{$HPPEMIT '# define AMQP_BIG_ENDIAN'}
{$HPPEMIT '#elif defined(_LITTLE_ENDIAN) && !defined(_BIG_ENDIAN) ||'}
      defined(__LITTLE_ENDIAN__) and  not defined(__BIG_ENDIAN__)
{$HPPEMIT '# define AMQP_LITTLE_ENDIAN'}
{$HPPEMIT '#elif defined(__hppa__) || defined(__HPPA__) || defined(__hppa) ||'}
      defined(_POWER) or defined(__powerpc__) or defined(__ppc___) or
      defined(_MIPSEB) or defined(__s390__) or
      defined(__sparc) or defined(__sparc__)
{$HPPEMIT '# define AMQP_BIG_ENDIAN'}
{$HPPEMIT '#elif defined(__alpha__) || defined(__alpha) || defined(_M_ALPHA) ||'}
      defined(__amd64__) or defined(__x86_64__) or defined(_M_X64) or
      defined(__ia64) or defined(__ia64__) or defined(_M_IA64) or
      defined(__arm__) or defined(_M_ARM) or
      defined(__i386__) or defined(_M_IX86)
{$HPPEMIT '# define AMQP_LITTLE_ENDIAN'}
{$else}
(* Don't define anything *)
{$endif}

{$ifdef AMQP_LITTLE_ENDIAN}

{$define DECLARE_XTOXLL(func)}
{$HPPEMIT 'static  uint64_t func##ll(uint64_t val)'}
  begin
    	case Integer of
			0:(uint64_t whole);
			1:(uint32_t halves[2]);
	end; u;
    uint32_t t;
    u.whole := val;
    t := u.halves[0];
{$HPPEMIT 'u.halves[0] := func##l(u.halves[1]);'}
{$HPPEMIT 'u.halves[1] := func##l(t);'}
    Result:= u.whole;
   end;

{$HPPEMIT '#elif defined(AMQP_BIG_ENDIAN)'}

{$define DECLARE_XTOXLL(func)}
{$HPPEMIT 'static  uint64_t func##ll(uint64_t val)'}
  begin
    	case Integer of
			0:(uint64_t whole);
			1:(uint32_t halves[2]);
	end; u;
    u.whole := val;
{$HPPEMIT 'u.halves[0] := func##l(u.halves[0]);'}
{$HPPEMIT 'u.halves[1] := func##l(u.halves[1]);'}
    Result:= u.whole;
   end;

{$else}
{$HPPEMIT '# error Endianness not known'}
{$endif}

{$ifndef HAVE_HTONLL}
DECLARE_XTOXLL(hton)
DECLARE_XTOXLL(ntoh)
{$endif}

DECLARE_CODEC_BASE_TYPE(8, (uint8_t), (uint8_t))
DECLARE_CODEC_BASE_TYPE(16, htons, ntohs)
DECLARE_CODEC_BASE_TYPE(32, htonl, ntohl)
DECLARE_CODEC_BASE_TYPE(64, htonll, ntohll)

  function amqp_encode_bytes(
	encoded: amqp_bytes_t;  size_t *offset,
	input: amqp_bytes_t): Integer
begin
  size_t o := *offset;
  if ((offset = o + input.len) <= encoded.len) then  begin
    memcpy(amqp_offset(encoded.bytes, o), input.bytes, input.len);
    Result:= 1;
   end; else begin
    Result:= 0;
   end;
 end;

  function amqp_decode_bytes(
	encoded: amqp_bytes_t;  size_t *offset,
	var output: amqp_bytes_t size_t len): Integer
begin
  size_t o := *offset;
  if ((offset = o + len) <= encoded.len) then  begin
    output^.bytes := amqp_offset(encoded.bytes, o);
    output^.len := len;
    Result:= 1;
   end; else begin
    Result:= 0;
   end;
 end;

AMQP_NORETURN
procedure
amqp_abort(
	fmt: PChar;  Args: array of ction amqp_bytes_equal(r: amqp_bytes_t; l: amqp_bytes_t): Integer;

  amqp_rpc_reply_t amqp_rpc_reply_error(amqp_status_const amqp_rpc_reply_t reply	= 0;
const reply.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
const reply.library_error := status;
const Result:= reply;
const end	= 1;
const Integer amqp_send_frame_inner(amqp_connection_state_t state	= 2;
const amqp_frame_t *frame	= 3; Integer flags

type	amqp_rpc_reply_t reply..amqp_frame_t *frame	status);
{$endif}

implementation

end.

