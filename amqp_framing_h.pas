unit amqp_framing_h;

interface

uses
 Windows, Messages, SysUtils, Classes, amqp_h;

 (** @file amqp_framing.h *)
{$ifndef AMQP_FRAMING_H}
{$define AMQP_FRAMING_H}

{$HPPEMIT '#include <amqp.h>'}

const AMQP_FRAME_END2 = 207;//for compile

function AMQP_BEGIN_DECLS : PChar;

const AMQP_PROTOCOL_VERSION_MAJOR = 0;	(**< AMQP protocol version major *)
const AMQP_PROTOCOL_VERSION_MINOR = 9;	(**< AMQP protocol version minor *)
const AMQP_PROTOCOL_VERSION_REVISION = 1;	(**< AMQP protocol version revision *)
const AMQP_PROTOCOL_PORT = 5672;	(**< Default AMQP Port *)
const AMQP_FRAME_METHOD = 1;	(**< Constant: FRAME-METHOD *)
const AMQP_FRAME_HEADER = 2;	(**< Constant: FRAME-HEADER *)
const AMQP_FRAME_BODY = 3;	(**< Constant: FRAME-BODY *)
const AMQP_FRAME_HEARTBEAT = 8;	(**< Constant: FRAME-HEARTBEAT *)
const AMQP_FRAME_MIN_SIZE = 4096;	(**< Constant: FRAME-MIN-SIZE *)
const AMQP_FRAME_END = 206;	(**< Constant: FRAME-END *)
const AMQP_REPLY_SUCCESS = 200;	(**< Constant: REPLY-SUCCESS *)
const AMQP_CONTENT_TOO_LARGE = 311;	(**< Constant: CONTENT-TOO-LARGE *)
const AMQP_NO_ROUTE = 312;	(**< Constant: NO-ROUTE *)
const AMQP_NO_CONSUMERS = 313;	(**< Constant: NO-CONSUMERS *)
const AMQP_ACCESS_REFUSED = 403;	(**< Constant: ACCESS-REFUSED *)
const AMQP_NOT_FOUND = 404;	(**< Constant: NOT-FOUND *)
const AMQP_RESOURCE_LOCKED = 405;	(**< Constant: RESOURCE-LOCKED *)
const AMQP_PRECONDITION_FAILED = 406;	(**< Constant: PRECONDITION-FAILED *)
const AMQP_CONNECTION_FORCED = 320;	(**< Constant: CONNECTION-FORCED *)
const AMQP_INVALID_PATH = 402;	(**< Constant: INVALID-PATH *)
const AMQP_FRAME_ERROR = 501;	(**< Constant: FRAME-ERROR *)
const AMQP_SYNTAX_ERROR = 502;	(**< Constant: SYNTAX-ERROR *)
const AMQP_COMMAND_INVALID = 503;	(**< Constant: COMMAND-INVALID *)
const AMQP_CHANNEL_ERROR = 504;	(**< Constant: CHANNEL-ERROR *)
const AMQP_UNEXPECTED_FRAME = 505;	(**< Constant: UNEXPECTED-FRAME *)
const AMQP_RESOURCE_ERROR = 506;	(**< Constant: RESOURCE-ERROR *)
const AMQP_NOT_ALLOWED = 530;	(**< Constant: NOT-ALLOWED *)
const AMQP_NOT_IMPLEMENTED = 540;	(**< Constant: NOT-IMPLEMENTED *)
const AMQP_INTERNAL_ERROR = 541;	(**< Constant: INTERNAL-ERROR *)

(* Function prototypes. *)

(**
 * Get constant name aString from constant
 *
 * @param [in] constantNumber constant to get the name of
 * @returns aString describing the constant. aString is managed by
 *           the aLibrary and should not be free()'d by the program
 *)
AMQP_PUBLIC_FUNCTION
PChar
AMQP_CALL amqp_constant_name(Integer constantNumber);

(**
 * Checks to see if a constant is a hard error
 *
 * A hard error occurs when something severe enough
 * happens that the connection must be closed.
 *
 * @param [in] constantNumber the error constant
 * @returns true if its a hard error, false otherwise
 *)
AMQP_PUBLIC_FUNCTION
amqp_boolean_t
AMQP_CALL amqp_constant_is_hard_error(Integer constantNumber);

(**
 * Get method name aString from method number
 *
 * @param [in] methodNumber the method number
 * @returns method name aString. aString is managed by the aLibrary
 *           and should not be freed()'d by the program
 *)
AMQP_PUBLIC_FUNCTION
PChar
AMQP_CALL amqp_method_name(amqp_method_number_t methodNumber);

(**
 * Check whether a method has content
 *
 * A method that has content will receive the method frame
 * a properties frame, then 1 to N body frames
 *
 * @param [in] methodNumber the method number
 * @returns true if method has content, false otherwise
 *)
AMQP_PUBLIC_FUNCTION
function AMQP_CALL amqp_method_has_content(methodNumber: amqp_method_number_t): amqp_boolean_t;

(**
 * Decodes a method from AMQP wireformat
 *
 * @param [in] methodNumber the method number for the decoded parameter
 * @param [in] pool the memory pool to allocate the decoded method from
 * @param [in] encoded the encoded byte aString buffer
 * @param [out] decoded aPointer to the decoded method
 * @returns 0 on success, an error code otherwise
 *)
AMQP_PUBLIC_FUNCTION
function AMQP_CALL amqp_decode_method(
	methodNumber: amqp_method_number_t;
	var pool: amqp_pool_t;
	encoded: amqp_bytes_t;
	var decoded: Pointer): Integer;

(**
 * Decodes a header frame properties structure from AMQP wireformat
 *
 * @param [in] class_id the class id for the decoded parameter
 * @param [in] pool the memory pool to allocate the decoded properties from
 * @param [in] encoded the encoded byte aString buffer
 * @param [out] decoded aPointer to the decoded properties
 * @returns 0 on success, an error code otherwise
 *)
AMQP_PUBLIC_FUNCTION
function AMQP_CALL amqp_decode_function (
	class_id: uint16_t;
	var pool: amqp_pool_t;
	encoded: amqp_bytes_t;
	var decoded: Pointer): properties: Integer;

(**
 * Encodes a method structure in AMQP wireformat
 *
 * @param [in] methodNumber the method number for the decoded parameter
 * @param [in] decoded the method structure (e.g., amqp_connection_start_t)
 * @param [in] encoded an allocated byte buffer for the encoded method
 *              structure to be written to. If the buffer isn't large enough
 *              to hold the encoded method, an error code will be returned.
 * @returns 0 on success, an error code otherwise.
 *)
AMQP_PUBLIC_FUNCTION
function AMQP_CALL amqp_encode_method(
	methodNumber: amqp_method_number_t;
	decoded: Pointer;
	encoded: amqp_bytes_t): Integer;

(**
 * Encodes a properties structure in AMQP wireformat
 *
 * @param [in] class_id the class id for the decoded parameter
 * @param [in] decoded the function structure (e.g., amqp_basic_properties_t): properties
 * @param [in] encoded an allocated byte buffer for the encoded properties to written to.
 *              If the buffer isn't large enough to hold the encoded method, an
 *              an error code will be returned
 * @returns 0 on success, an error code otherwise.
 *)
AMQP_PUBLIC_FUNCTION
function AMQP_CALL amqp_encode_function (
	class_id: uint16_t;
	decoded: Pointer;
	encoded: amqp_bytes_t): properties: Integer;

(* Method field records. *)

const AMQP_CONNECTION_START_METHOD = ((amqp_method_number_t) $000A000A);	(**< connection.start method id @internal 10, 10; 655370 *)
{$EXTERNALSYM AMQP_CONNECTION_START_METHOD}
(** connection.start method fields *)
type
  begin
	  amqp_connection_start_t_ = record
		version_major: uint8_t;	            (**< version-major *)
		version_minor: uint8_t;	            (**< version-minor *)
		server_properties: amqp_table_t;	  (**< server-properties *)
		mechanisms: amqp_bytes_t;	          (**< mechanisms *)
		locales: amqp_bytes_t;	            (**< locales *)
	end;
	amqp_connection_start_t = amqp_connection_start_t_;
	{$EXTERNALSYM amqp_connection_start_t}

const AMQP_CONNECTION_START_OK_METHOD = ((amqp_method_number_t) $000A000B);	(**< connection.start-ok method id @internal 10, 11; 655371 *)
{$EXTERNALSYM AMQP_CONNECTION_START_OK_METHOD}
(** connection.start-ok method fields *)
type
  begin
  	amqp_connection_start_ok_t_ = record
		client_properties: amqp_table_t;	  (**< client-properties *)
		mechanism: amqp_bytes_t;	          (**< mechanism *)
		response: amqp_bytes_t;	            (**< response *)
		locale: amqp_bytes_t;	              (**< locale *)
	end;
	amqp_connection_start_ok_t = amqp_connection_start_ok_t_;
	{$EXTERNALSYM amqp_connection_start_ok_t}

const AMQP_CONNECTION_SECURE_METHOD = ((amqp_method_number_t) $000A0014);	(**< connection.secure method id @internal 10, 20; 655380 *)
{$EXTERNALSYM AMQP_CONNECTION_SECURE_METHOD}
(** connection.secure method fields *)
type
  begin
	amqp_connection_secure_t_ = record
		challenge: amqp_bytes_t;	 (**< challenge *)
	end;
	amqp_connection_secure_t = amqp_connection_secure_t_;
	{$EXTERNALSYM amqp_connection_secure_t}

const AMQP_CONNECTION_SECURE_OK_METHOD = ((amqp_method_number_t) $000A0015);	(**< connection.secure-ok method id @internal 10, 21; 655381 *)
{$EXTERNALSYM AMQP_CONNECTION_SECURE_OK_METHOD}
(** connection.secure-ok method fields *)
type
  begin
	  amqp_connection_secure_ok_t_ = record
		response: amqp_bytes_t;	 (**< response *)
	end;
	amqp_connection_secure_ok_t = amqp_connection_secure_ok_t_;
	{$EXTERNALSYM amqp_connection_secure_ok_t}

const AMQP_CONNECTION_TUNE_METHOD = ((amqp_method_number_t) $000A001E);	(**< connection.tune method id @internal 10, 30; 655390 *)
{$EXTERNALSYM AMQP_CONNECTION_TUNE_METHOD}
(** connection.tune method fields *)
type
  begin
	  amqp_connection_tune_t_ = record
		channel_max: uint16_t;	 (**< channel-max *)
		frame_max: uint32_t;	   (**< frame-max *)
		heartbeat: uint16_t;	   (**< heartbeat *)
	end;
	amqp_connection_tune_t = amqp_connection_tune_t_;
	{$EXTERNALSYM amqp_connection_tune_t}

const AMQP_CONNECTION_TUNE_OK_METHOD = ((amqp_method_number_t) $000A001F);	(**< connection.tune-ok method id @internal 10, 31; 655391 *)
{$EXTERNALSYM AMQP_CONNECTION_TUNE_OK_METHOD}
(** connection.tune-ok method fields *)
type
  begin
	  amqp_connection_tune_ok_t_ = record
		channel_max: uint16_t;	 (**< channel-max *)
		frame_max: uint32_t;	   (**< frame-max *)
		heartbeat: uint16_t;	   (**< heartbeat *)
	end;
	amqp_connection_tune_ok_t = amqp_connection_tune_ok_t_;
	{$EXTERNALSYM amqp_connection_tune_ok_t}

const AMQP_CONNECTION_OPEN_METHOD = ((amqp_method_number_t) $000A0028);	(**< connection.open method id @internal 10, 40; 655400 *)
{$EXTERNALSYM AMQP_CONNECTION_OPEN_METHOD}
(** connection.open method fields *)
type
  begin
	  amqp_connection_open_t_ = record
		virtual_host: amqp_bytes_t;	 (**< virtual-host *)
		capabilities: amqp_bytes_t;	 (**< capabilities *)
		insist: amqp_boolean_t;	     (**< insist *)
	end;
	amqp_connection_open_t = amqp_connection_open_t_;
	{$EXTERNALSYM amqp_connection_open_t}

const AMQP_CONNECTION_OPEN_OK_METHOD = ((amqp_method_number_t) $000A0029);	(**< connection.open-ok method id @internal 10, 41; 655401 *)
{$EXTERNALSYM AMQP_CONNECTION_OPEN_OK_METHOD}
(** connection.open-ok method fields *)
type
  begin
  	amqp_connection_open_ok_t_ = record
		known_hosts: amqp_bytes_t;	 (**< known-hosts *)
	end;
	amqp_connection_open_ok_t = amqp_connection_open_ok_t_;
	{$EXTERNALSYM amqp_connection_open_ok_t}

const AMQP_CONNECTION_CLOSE_METHOD = ((amqp_method_number_t) $000A0032);	(**< connection.close method id @internal 10, 50; 655410 *)
{$EXTERNALSYM AMQP_CONNECTION_CLOSE_METHOD}
(** connection.close method fields *)
type
  begin
  	amqp_connection_close_t_ = record
		reply_code: uint16_t;	      (**< reply-code *)
		reply_text: amqp_bytes_t;	  (**< reply-text *)
		class_id: uint16_t;	        (**< class-id *)
		method_id: uint16_t;	      (**< method-id *)
	end;
	amqp_connection_close_t = amqp_connection_close_t_;
	{$EXTERNALSYM amqp_connection_close_t}

const AMQP_CONNECTION_CLOSE_OK_METHOD = ((amqp_method_number_t) $000A0033);	(**< connection.close-ok method id @internal 10, 51; 655411 *)
{$EXTERNALSYM AMQP_CONNECTION_CLOSE_OK_METHOD}
(** connection.close-ok method fields *)
type
  begin
  	amqp_connection_close_ok_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_connection_close_ok_t = amqp_connection_close_ok_t_;
	{$EXTERNALSYM amqp_connection_close_ok_t}

const AMQP_CONNECTION_BLOCKED_METHOD = ((amqp_method_number_t) $000A003C);	(**< connection.blocked method id @internal 10, 60; 655420 *)
{$EXTERNALSYM AMQP_CONNECTION_BLOCKED_METHOD}
(** connection.blocked method fields *)
type
  begin
  	amqp_connection_blocked_t_ = record
		reason: amqp_bytes_t;	 (**< reason *)
	end;
	amqp_connection_blocked_t = amqp_connection_blocked_t_;
	{$EXTERNALSYM amqp_connection_blocked_t}

const AMQP_CONNECTION_UNBLOCKED_METHOD = ((amqp_method_number_t) $000A003D);	(**< connection.unblocked method id @internal 10, 61; 655421 *)
{$EXTERNALSYM AMQP_CONNECTION_UNBLOCKED_METHOD}
(** connection.unblocked method fields *)
type
  begin
  	amqp_connection_unblocked_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_connection_unblocked_t = amqp_connection_unblocked_t_;
	{$EXTERNALSYM amqp_connection_unblocked_t}

const AMQP_CHANNEL_OPEN_METHOD = ((amqp_method_number_t) $0014000A);	(**< channel.open method id @internal 20, 10; 1310730 *)
{$EXTERNALSYM AMQP_CHANNEL_OPEN_METHOD}
(** channel.open method fields *)
type
  begin
  	amqp_channel_open_t_ = record
		out_of_band: amqp_bytes_t;	 (**< out-of-band *)
	end;
	amqp_channel_open_t = amqp_channel_open_t_;
	{$EXTERNALSYM amqp_channel_open_t}

const AMQP_CHANNEL_OPEN_OK_METHOD = ((amqp_method_number_t) $0014000B);	(**< channel.open-ok method id @internal 20, 11; 1310731 *)
{$EXTERNALSYM AMQP_CHANNEL_OPEN_OK_METHOD}
(** channel.open-ok method fields *)
type
  begin
	  amqp_channel_open_ok_t_ = record
		channel_id: amqp_bytes_t;	 (**< channel-id *)
	end;
	amqp_channel_open_ok_t = amqp_channel_open_ok_t_;
	{$EXTERNALSYM amqp_channel_open_ok_t}

const AMQP_CHANNEL_FLOW_METHOD = ((amqp_method_number_t) $00140014);	(**< channel.flow method id @internal 20, 20; 1310740 *)
{$EXTERNALSYM AMQP_CHANNEL_FLOW_METHOD}
(** channel.flow method fields *)
type
  begin
	  amqp_channel_flow_t_ = record
		active: amqp_boolean_t;	 (**< active *)
	end;
	amqp_channel_flow_t = amqp_channel_flow_t_;
	{$EXTERNALSYM amqp_channel_flow_t}

const AMQP_CHANNEL_FLOW_OK_METHOD = ((amqp_method_number_t) $00140015);	(**< channel.flow-ok method id @internal 20, 21; 1310741 *)
{$EXTERNALSYM AMQP_CHANNEL_FLOW_OK_METHOD}
(** channel.flow-ok method fields *)
type
  begin
	  amqp_channel_flow_ok_t_ = record
		active: amqp_boolean_t;	 (**< active *)
	end;
	amqp_channel_flow_ok_t = amqp_channel_flow_ok_t_;
	{$EXTERNALSYM amqp_channel_flow_ok_t}

const AMQP_CHANNEL_CLOSE_METHOD = ((amqp_method_number_t) $00140028);	(**< channel.close method id @internal 20, 40; 1310760 *)
{$EXTERNALSYM AMQP_CHANNEL_CLOSE_METHOD}
(** channel.close method fields *)
type
  begin
    amqp_channel_close_t_ = record
		reply_code: uint16_t;	      (**< reply-code *)
		reply_text: amqp_bytes_t;	  (**< reply-text *)
		class_id: uint16_t;	        (**< class-id *)
		method_id: uint16_t;	      (**< method-id *)
	end;
	amqp_channel_close_t = amqp_channel_close_t_;
	{$EXTERNALSYM amqp_channel_close_t}

const AMQP_CHANNEL_CLOSE_OK_METHOD = ((amqp_method_number_t) $00140029);	(**< channel.close-ok method id @internal 20, 41; 1310761 *)
{$EXTERNALSYM AMQP_CHANNEL_CLOSE_OK_METHOD}
(** channel.close-ok method fields *)
type
  begin
	  amqp_channel_close_ok_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_channel_close_ok_t = amqp_channel_close_ok_t_;
	{$EXTERNALSYM amqp_channel_close_ok_t}

const AMQP_ACCESS_REQUEST_METHOD = ((amqp_method_number_t) $001E000A);	(**< access.request method id @internal 30, 10; 1966090 *)
{$EXTERNALSYM AMQP_ACCESS_REQUEST_METHOD}
(** access.request method fields *)
type
  begin
	  amqp_access_request_t_ = record
		realm: amqp_bytes_t;	         (**< realm *)
		exclusive: amqp_boolean_t;	   (**< exclusive *)
		passive: amqp_boolean_t;	     (**< passive *)
		active: amqp_boolean_t;	       (**< active *)
		write: amqp_boolean_t;	       (**< write *)
		read: amqp_boolean_t;	         (**< read *)
	end;
	amqp_access_request_t = amqp_access_request_t_;
	{$EXTERNALSYM amqp_access_request_t}

const AMQP_ACCESS_REQUEST_OK_METHOD = ((amqp_method_number_t) $001E000B);	(**< access.request-ok method id @internal 30, 11; 1966091 *)
{$EXTERNALSYM AMQP_ACCESS_REQUEST_OK_METHOD}
(** access.request-ok method fields *)
type
  begin
	  amqp_access_request_ok_t_ = record
		ticket: uint16_t;	 (**< ticket *)
	end;
	amqp_access_request_ok_t = amqp_access_request_ok_t_;
	{$EXTERNALSYM amqp_access_request_ok_t}

const AMQP_EXCHANGE_DECLARE_METHOD = ((amqp_method_number_t) $0028000A);	(**< exchange.declare method id @internal 40, 10; 2621450 *)
{$EXTERNALSYM AMQP_EXCHANGE_DECLARE_METHOD}
(** exchange.declare method fields *)
type
  begin
	  amqp_exchange_declare_t_ = record
		ticket: uint16_t;	               (**< ticket *)
		exchange: amqp_bytes_t;	         (**< exchange *)
		aType: amqp_bytes_t;	           (**< aType *)
		passive: amqp_boolean_t;	       (**< passive *)
		durable: amqp_boolean_t;      	 (**< durable *)
		auto_delete: amqp_boolean_t;  	 (**< auto-delete *)
		internal: amqp_boolean_t;	       (**< internal *)
		nowait: amqp_boolean_t;	         (**< nowait *)
		arguments: amqp_table_t;	       (**< arguments *)
	end;
	amqp_exchange_declare_t = amqp_exchange_declare_t_;
	{$EXTERNALSYM amqp_exchange_declare_t}

const AMQP_EXCHANGE_DECLARE_OK_METHOD = ((amqp_method_number_t) $0028000B);	(**< exchange.declare-ok method id @internal 40, 11; 2621451 *)
{$EXTERNALSYM AMQP_EXCHANGE_DECLARE_OK_METHOD}
(** exchange.declare-ok method fields *)
type
  begin
	  amqp_exchange_declare_ok_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_exchange_declare_ok_t = amqp_exchange_declare_ok_t_;
	{$EXTERNALSYM amqp_exchange_declare_ok_t}

const AMQP_EXCHANGE_DELETE_METHOD = ((amqp_method_number_t) $00280014);	(**< exchange.delete method id @internal 40, 20; 2621460 *)
{$EXTERNALSYM AMQP_EXCHANGE_DELETE_METHOD}
(** exchange.delete method fields *)
type
  begin
	  amqp_exchange_delete_t_ = record
		ticket: uint16_t;	            (**< ticket *)
		exchange: amqp_bytes_t;	      (**< exchange *)
		if_unused: amqp_boolean_t;	  (**< if-unused *) then
		nowait: amqp_boolean_t;	      (**< nowait *)
	end;
	amqp_exchange_delete_t = amqp_exchange_delete_t_;
	{$EXTERNALSYM amqp_exchange_delete_t}

const AMQP_EXCHANGE_DELETE_OK_METHOD = ((amqp_method_number_t) $00280015);	(**< exchange.delete-ok method id @internal 40, 21; 2621461 *)
{$EXTERNALSYM AMQP_EXCHANGE_DELETE_OK_METHOD}
(** exchange.delete-ok method fields *)
type
  begin
	  amqp_exchange_delete_ok_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_exchange_delete_ok_t = amqp_exchange_delete_ok_t_;
	{$EXTERNALSYM amqp_exchange_delete_ok_t}

const AMQP_EXCHANGE_BIND_METHOD = ((amqp_method_number_t) $0028001E);	(**< exchange.bind method id @internal 40, 30; 2621470 *)
{$EXTERNALSYM AMQP_EXCHANGE_BIND_METHOD}
(** exchange.bind method fields *)
type
  begin
	  amqp_exchange_bind_t_ = record
		ticket: uint16_t;	            (**< ticket *)
		destination: amqp_bytes_t;	  (**< destination *)
		source: amqp_bytes_t;	        (**< source *)
		routing_key: amqp_bytes_t;	  (**< routing-key *)
		nowait: amqp_boolean_t;	      (**< nowait *)
		arguments: amqp_table_t;	    (**< arguments *)
	end;
	amqp_exchange_bind_t = amqp_exchange_bind_t_;
	{$EXTERNALSYM amqp_exchange_bind_t}

const AMQP_EXCHANGE_BIND_OK_METHOD = ((amqp_method_number_t) $0028001F);	(**< exchange.bind-ok method id @internal 40, 31; 2621471 *)
{$EXTERNALSYM AMQP_EXCHANGE_BIND_OK_METHOD}
(** exchange.bind-ok method fields *)
type
  begin
	  amqp_exchange_bind_ok_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_exchange_bind_ok_t = amqp_exchange_bind_ok_t_;
	{$EXTERNALSYM amqp_exchange_bind_ok_t}

const AMQP_EXCHANGE_UNBIND_METHOD = ((amqp_method_number_t) $00280028);	(**< exchange.unbind method id @internal 40, 40; 2621480 *)
{$EXTERNALSYM AMQP_EXCHANGE_UNBIND_METHOD}
(** exchange.unbind method fields *)
type
  begin
	  amqp_exchange_unbind_t_ = record
		ticket: uint16_t;	           (**< ticket *)
	 	destination: amqp_bytes_t;	 (**< destination *)
		source: amqp_bytes_t;	       (**< source *)
	 	routing_key: amqp_bytes_t;	 (**< routing-key *)
		nowait: amqp_boolean_t;	     (**< nowait *)
		arguments: amqp_table_t;	   (**< arguments *)
	end;
	amqp_exchange_unbind_t = amqp_exchange_unbind_t_;
	{$EXTERNALSYM amqp_exchange_unbind_t}

const AMQP_EXCHANGE_UNBIND_OK_METHOD = ((amqp_method_number_t) $00280033);	(**< exchange.unbind-ok method id @internal 40, 51; 2621491 *)
{$EXTERNALSYM AMQP_EXCHANGE_UNBIND_OK_METHOD}
(** exchange.unbind-ok method fields *)
type
  begin
	  amqp_exchange_unbind_ok_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_exchange_unbind_ok_t = amqp_exchange_unbind_ok_t_;
	{$EXTERNALSYM amqp_exchange_unbind_ok_t}

const AMQP_QUEUE_DECLARE_METHOD = ((amqp_method_number_t) $0032000A);	(**< queue.declare method id @internal 50, 10; 3276810 *)
{$EXTERNALSYM AMQP_QUEUE_DECLARE_METHOD}
(** queue.declare method fields *)
type
  begin
	  amqp_queue_declare_t_ = record
		ticket: uint16_t;	              (**< ticket *)
		queue: amqp_bytes_t;	          (**< queue *)
		passive: amqp_boolean_t;	      (**< passive *)
		durable: amqp_boolean_t;	      (**< durable *)
		exclusive: amqp_boolean_t;	    (**< exclusive *)
		auto_delete: amqp_boolean_t;	  (**< auto-delete *)
		nowait: amqp_boolean_t;	        (**< nowait *)
		arguments: amqp_table_t;	      (**< arguments *)
	end;
	amqp_queue_declare_t = amqp_queue_declare_t_;
	{$EXTERNALSYM amqp_queue_declare_t}

const AMQP_QUEUE_DECLARE_OK_METHOD = ((amqp_method_number_t) $0032000B);	(**< queue.declare-ok method id @internal 50, 11; 3276811 *)
{$EXTERNALSYM AMQP_QUEUE_DECLARE_OK_METHOD}
(** queue.declare-ok method fields *)
type
	begin
    amqp_queue_declare_ok_t_ = record
		queue: amqp_bytes_t;	     (**< queue *)
		message_count: uint32_t;	 (**< message-count *)
		consumer_count: uint32_t;	 (**< consumer-count *)
	end;
	amqp_queue_declare_ok_t = amqp_queue_declare_ok_t_;
	{$EXTERNALSYM amqp_queue_declare_ok_t}

const AMQP_QUEUE_BIND_METHOD = ((amqp_method_number_t) $00320014);	(**< queue.bind method id @internal 50, 20; 3276820 *)
{$EXTERNALSYM AMQP_QUEUE_BIND_METHOD}
(** queue.bind method fields *)
type
  begin
	  amqp_queue_bind_t_ = record
		ticket: uint16_t;	          (**< ticket *)
		queue: amqp_bytes_t;	      (**< queue *)
		exchange: amqp_bytes_t;	    (**< exchange *)
		routing_key: amqp_bytes_t;  (**< routing-key *)
		nowait: amqp_boolean_t;	    (**< nowait *)
		arguments: amqp_table_t;	  (**< arguments *)
	end;
	amqp_queue_bind_t = amqp_queue_bind_t_;
	{$EXTERNALSYM amqp_queue_bind_t}

const AMQP_QUEUE_BIND_OK_METHOD = ((amqp_method_number_t) $00320015);	(**< queue.bind-ok method id @internal 50, 21; 3276821 *)
{$EXTERNALSYM AMQP_QUEUE_BIND_OK_METHOD}
(** queue.bind-ok method fields *)
type
  begin
	  amqp_queue_bind_ok_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_queue_bind_ok_t = amqp_queue_bind_ok_t_;
	{$EXTERNALSYM amqp_queue_bind_ok_t}

const AMQP_QUEUE_PURGE_METHOD = ((amqp_method_number_t) $0032001E);	(**< queue.purge method id @internal 50, 30; 3276830 *)
{$EXTERNALSYM AMQP_QUEUE_PURGE_METHOD}
(** queue.purge method fields *)
type
  begin
	  amqp_queue_purge_t_ = record
		ticket: uint16_t;	        (**< ticket *)
		queue: amqp_bytes_t;	    (**< queue *)
		nowait: amqp_boolean_t;	  (**< nowait *)
	end;
	amqp_queue_purge_t = amqp_queue_purge_t_;
	{$EXTERNALSYM amqp_queue_purge_t}

const AMQP_QUEUE_PURGE_OK_METHOD = ((amqp_method_number_t) $0032001F);	(**< queue.purge-ok method id @internal 50, 31; 3276831 *)
{$EXTERNALSYM AMQP_QUEUE_PURGE_OK_METHOD}
(** queue.purge-ok method fields *)
type
  begin
    amqp_queue_purge_ok_t_ = record
		message_count: uint32_t;	 (**< message-count *)
	end;
	amqp_queue_purge_ok_t = amqp_queue_purge_ok_t_;
	{$EXTERNALSYM amqp_queue_purge_ok_t}

const AMQP_QUEUE_DELETE_METHOD = ((amqp_method_number_t) $00320028);	(**< queue.delete method id @internal 50, 40; 3276840 *)
{$EXTERNALSYM AMQP_QUEUE_DELETE_METHOD}
(** queue.delete method fields *)
type
  begin
	  amqp_queue_delete_t_ = record
		ticket: uint16_t;	            (**< ticket *)
		queue: amqp_bytes_t;	        (**< queue *)
		if_unused: amqp_boolean_t;	  (**< if-unused *) then
		if_empty: amqp_boolean_t;	    (**< if-empty *) then
		nowait: amqp_boolean_t;	      (**< nowait *)
	end;
	amqp_queue_delete_t = amqp_queue_delete_t_;
	{$EXTERNALSYM amqp_queue_delete_t}

const AMQP_QUEUE_DELETE_OK_METHOD = ((amqp_method_number_t) $00320029);	(**< queue.delete-ok method id @internal 50, 41; 3276841 *)
{$EXTERNALSYM AMQP_QUEUE_DELETE_OK_METHOD}
(** queue.delete-ok method fields *)
type
  begin
	  amqp_queue_delete_ok_t_ = record
		message_count: uint32_t;	 (**< message-count *)
	end;
	amqp_queue_delete_ok_t = amqp_queue_delete_ok_t_;
	{$EXTERNALSYM amqp_queue_delete_ok_t}

const AMQP_QUEUE_UNBIND_METHOD = ((amqp_method_number_t) $00320032);	(**< queue.unbind method id @internal 50, 50; 3276850 *)
{$EXTERNALSYM AMQP_QUEUE_UNBIND_METHOD}
(** queue.unbind method fields *)
type
  begin
	  amqp_queue_unbind_t_ = record
		ticket: uint16_t;	            (**< ticket *)
		queue: amqp_bytes_t;	        (**< queue *)
		exchange: amqp_bytes_t;	      (**< exchange *)
		routing_key: amqp_bytes_t;	  (**< routing-key *)
		arguments: amqp_table_t;	    (**< arguments *)
	end;
	amqp_queue_unbind_t = amqp_queue_unbind_t_;
	{$EXTERNALSYM amqp_queue_unbind_t}

const AMQP_QUEUE_UNBIND_OK_METHOD = ((amqp_method_number_t) $00320033);	(**< queue.unbind-ok method id @internal 50, 51; 3276851 *)
{$EXTERNALSYM AMQP_QUEUE_UNBIND_OK_METHOD}
(** queue.unbind-ok method fields *)
type
  begin
	  amqp_queue_unbind_ok_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_queue_unbind_ok_t = amqp_queue_unbind_ok_t_;
	{$EXTERNALSYM amqp_queue_unbind_ok_t}

const AMQP_BASIC_QOS_METHOD = ((amqp_method_number_t) $003C000A);	(**< basic.qos method id @internal 60, 10; 3932170 *)
{$EXTERNALSYM AMQP_BASIC_QOS_METHOD}
(** basic.qos method fields *)
type
  begin
  	amqp_basic_qos_t_ = record
		prefetch_size: uint32_t;	 (**< prefetch-size *)
		prefetch_count: uint16_t;	 (**< prefetch-count *)
		global: amqp_boolean_t;	   (**< global *)
	end;
	amqp_basic_qos_t = amqp_basic_qos_t_;
	{$EXTERNALSYM amqp_basic_qos_t}

const AMQP_BASIC_QOS_OK_METHOD = ((amqp_method_number_t) $003C000B);	(**< basic.qos-ok method id @internal 60, 11; 3932171 *)
{$EXTERNALSYM AMQP_BASIC_QOS_OK_METHOD}
(** basic.qos-ok method fields *)
type
  begin
  	amqp_basic_qos_ok_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_basic_qos_ok_t = amqp_basic_qos_ok_t_;
	{$EXTERNALSYM amqp_basic_qos_ok_t}

const AMQP_BASIC_CONSUME_METHOD = ((amqp_method_number_t) $003C0014);	(**< basic.consume method id @internal 60, 20; 3932180 *)
{$EXTERNALSYM AMQP_BASIC_CONSUME_METHOD}
(** basic.consume method fields *)
type
  begin
	  amqp_basic_consume_t_ = record
		ticket: uint16_t;	            (**< ticket *)
		queue: amqp_bytes_t;	        (**< queue *)
		consumer_tag: amqp_bytes_t;	  (**< consumer-tag *)
		no_local: amqp_boolean_t;	    (**< no-local *)
		no_ack: amqp_boolean_t;	      (**< no-ack *)
		exclusive: amqp_boolean_t;	  (**< exclusive *)
		nowait: amqp_boolean_t;	      (**< nowait *)
		arguments: amqp_table_t;	    (**< arguments *)
	end;
	amqp_basic_consume_t = amqp_basic_consume_t_;
	{$EXTERNALSYM amqp_basic_consume_t}

const AMQP_BASIC_CONSUME_OK_METHOD = ((amqp_method_number_t) $003C0015);	(**< basic.consume-ok method id @internal 60, 21; 3932181 *)
{$EXTERNALSYM AMQP_BASIC_CONSUME_OK_METHOD}
(** basic.consume-ok method fields *)
type
  begin
  	amqp_basic_consume_ok_t_ = record
		consumer_tag: amqp_bytes_t;	 (**< consumer-tag *)
	end;
	amqp_basic_consume_ok_t = amqp_basic_consume_ok_t_;
	{$EXTERNALSYM amqp_basic_consume_ok_t}

const AMQP_BASIC_CANCEL_METHOD = ((amqp_method_number_t) $003C001E);	(**< basic.cancel method id @internal 60, 30; 3932190 *)
{$EXTERNALSYM AMQP_BASIC_CANCEL_METHOD}
(** basic.cancel method fields *)
type
  begin
  	amqp_basic_cancel_t_ = record
		consumer_tag: amqp_bytes_t;	  (**< consumer-tag *)
		nowait: amqp_boolean_t;	      (**< nowait *)
	end;
	amqp_basic_cancel_t = amqp_basic_cancel_t_;
	{$EXTERNALSYM amqp_basic_cancel_t}

const AMQP_BASIC_CANCEL_OK_METHOD = ((amqp_method_number_t) $003C001F);	(**< basic.cancel-ok method id @internal 60, 31; 3932191 *)
{$EXTERNALSYM AMQP_BASIC_CANCEL_OK_METHOD}
(** basic.cancel-ok method fields *)
type
  begin
  	amqp_basic_cancel_ok_t_ = record
		consumer_tag: amqp_bytes_t;	 (**< consumer-tag *)
	end;
	amqp_basic_cancel_ok_t = amqp_basic_cancel_ok_t_;
	{$EXTERNALSYM amqp_basic_cancel_ok_t}

const AMQP_BASIC_PUBLISH_METHOD = ((amqp_method_number_t) $003C0028);	(**< basic.publish method id @internal 60, 40; 3932200 *)
{$EXTERNALSYM AMQP_BASIC_PUBLISH_METHOD}
(** basic.publish method fields *)
type
  begin
  	amqp_basic_publish_t_ = record
		ticket: uint16_t;	           (**< ticket *)
		exchange: amqp_bytes_t;	     (**< exchange *)
		routing_key: amqp_bytes_t;	 (**< routing-key *)
		mandatory: amqp_boolean_t;	 (**< mandatory *)
		immediate: amqp_boolean_t;	 (**< immediate *)
	end;
	amqp_basic_publish_t = amqp_basic_publish_t_;
	{$EXTERNALSYM amqp_basic_publish_t}

const AMQP_BASIC_RETURN_METHOD = ((amqp_method_number_t) $003C0032);	(**< basic.Result:= method id @internal 60, 50; 3932210 *)
{$EXTERNALSYM AMQP_BASIC_RETURN_METHOD}
(** basic.return method fields *)
type
  begin
  	amqp_basic_return_t_ = record
		reply_code: uint16_t;	        (**< reply-code *)
		reply_text: amqp_bytes_t;	    (**< reply-text *)
		exchange: amqp_bytes_t;	      (**< exchange *)
		routing_key: amqp_bytes_t;	  (**< routing-key *)
	end;
	amqp_basic_return_t = amqp_basic_return_t_;
	{$EXTERNALSYM amqp_basic_return_t}

const AMQP_BASIC_DELIVER_METHOD = ((amqp_method_number_t) $003C003C);	(**< basic.deliver method id @internal 60, 60; 3932220 *)
{$EXTERNALSYM AMQP_BASIC_DELIVER_METHOD}
(** basic.deliver method fields *)
type
  begin
  	amqp_basic_deliver_t_ = record
		consumer_tag: amqp_bytes_t;	     (**< consumer-tag *)
		delivery_tag: uint64_t;	         (**< delivery-tag *)
		redelivered: amqp_boolean_t;	   (**< redelivered *)
		exchange: amqp_bytes_t;	         (**< exchange *)
		routing_key: amqp_bytes_t;	     (**< routing-key *)
	end;
	amqp_basic_deliver_t = amqp_basic_deliver_t_;
	{$EXTERNALSYM amqp_basic_deliver_t}

const AMQP_BASIC_GET_METHOD = ((amqp_method_number_t) $003C0046);	(**< basic.get method id @internal 60, 70; 3932230 *)
{$EXTERNALSYM AMQP_BASIC_GET_METHOD}
(** basic.get method fields *)
type
  begin
  	amqp_basic_get_t_ = record
		ticket: uint16_t;	       (**< ticket *)
		queue: amqp_bytes_t;	   (**< queue *)
    no_ack: amqp_boolean_t;	 (**< no-ack *)
	end;
	amqp_basic_get_t = amqp_basic_get_t_;
	{$EXTERNALSYM amqp_basic_get_t}

const AMQP_BASIC_GET_OK_METHOD = ((amqp_method_number_t) $003C0047);	(**< basic.get-ok method id @internal 60, 71; 3932231 *)
{$EXTERNALSYM AMQP_BASIC_GET_OK_METHOD}
(** basic.get-ok method fields *)
type
  begin
  	amqp_basic_get_ok_t_ = record
		delivery_tag: uint64_t;	        (**< delivery-tag *)
		redelivered: amqp_boolean_t;	  (**< redelivered *)
		exchange: amqp_bytes_t;	        (**< exchange *)
		routing_key: amqp_bytes_t;	    (**< routing-key *)
		message_count: uint32_t;	      (**< message-count *)
	end;
	amqp_basic_get_ok_t = amqp_basic_get_ok_t_;
	{$EXTERNALSYM amqp_basic_get_ok_t}

const AMQP_BASIC_GET_EMPTY_METHOD = ((amqp_method_number_t) $003C0048);	(**< basic.get-empty method id @internal 60, 72; 3932232 *)
{$EXTERNALSYM AMQP_BASIC_GET_EMPTY_METHOD}
(** basic.get-empty method fields *)
type
  begin
  	amqp_basic_get_empty_t_ = record
		cluster_id: amqp_bytes_t;	 (**< cluster-id *)
	end;
	amqp_basic_get_empty_t = amqp_basic_get_empty_t_;
	{$EXTERNALSYM amqp_basic_get_empty_t}

const AMQP_BASIC_ACK_METHOD = ((amqp_method_number_t) $003C0050);	(**< basic.ack method id @internal 60, 80; 3932240 *)
{$EXTERNALSYM AMQP_BASIC_ACK_METHOD}
(** basic.ack method fields *)
type
  begin
  	amqp_basic_ack_t_ = record
		delivery_tag: uint64_t;	    (**< delivery-tag *)
		multiple: amqp_boolean_t;	  (**< multiple *)
	end;
	amqp_basic_ack_t = amqp_basic_ack_t_;
	{$EXTERNALSYM amqp_basic_ack_t}

const AMQP_BASIC_REJECT_METHOD = ((amqp_method_number_t) $003C005A);	(**< basic.reject method id @internal 60, 90; 3932250 *)
{$EXTERNALSYM AMQP_BASIC_REJECT_METHOD}
(** basic.reject method fields *)
type
  begin
  	amqp_basic_reject_t_ = record
		delivery_tag: uint64_t;	    (**< delivery-tag *)
		requeue: amqp_boolean_t;	  (**< requeue *)
	end;
	amqp_basic_reject_t = amqp_basic_reject_t_;
	{$EXTERNALSYM amqp_basic_reject_t}

const AMQP_BASIC_RECOVER_ASYNC_METHOD = ((amqp_method_number_t) $003C0064);	(**< basic.recover-async method id @internal 60, 100; 3932260 *)
{$EXTERNALSYM AMQP_BASIC_RECOVER_ASYNC_METHOD}
(** basic.recover-async method fields *)
type
  begin
  	amqp_basic_recover_async_t_ = record
		requeue: amqp_boolean_t;	 (**< requeue *)
	end;
	amqp_basic_recover_async_t = amqp_basic_recover_async_t_;
	{$EXTERNALSYM amqp_basic_recover_async_t}

const AMQP_BASIC_RECOVER_METHOD = ((amqp_method_number_t) $003C006E);	(**< basic.recover method id @internal 60, 110; 3932270 *)
{$EXTERNALSYM AMQP_BASIC_RECOVER_METHOD}
(** basic.recover method fields *)
type
  begin
  	amqp_basic_recover_t_ = record
		requeue: amqp_boolean_t;	 (**< requeue *)
	end;
	amqp_basic_recover_t = amqp_basic_recover_t_;
	{$EXTERNALSYM amqp_basic_recover_t}

const AMQP_BASIC_RECOVER_OK_METHOD = ((amqp_method_number_t) $003C006F);	(**< basic.recover-ok method id @internal 60, 111; 3932271 *)
{$EXTERNALSYM AMQP_BASIC_RECOVER_OK_METHOD}
(** basic.recover-ok method fields *)
type
  begin
  	amqp_basic_recover_ok_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_basic_recover_ok_t = amqp_basic_recover_ok_t_;
	{$EXTERNALSYM amqp_basic_recover_ok_t}

const AMQP_BASIC_NACK_METHOD = ((amqp_method_number_t) $003C0078);	(**< basic.nack method id @internal 60, 120; 3932280 *)
{$EXTERNALSYM AMQP_BASIC_NACK_METHOD}
(** basic.nack method fields *)
type
  begin
  	amqp_basic_nack_t_ = record
		delivery_tag: uint64_t;	    (**< delivery-tag *)
		multiple: amqp_boolean_t;	  (**< multiple *)
		requeue: amqp_boolean_t;	  (**< requeue *)
	end;
	amqp_basic_nack_t = amqp_basic_nack_t_;
	{$EXTERNALSYM amqp_basic_nack_t}

const AMQP_TX_SELECT_METHOD = ((amqp_method_number_t) $005A000A);	(**< tx.select method id @internal 90, 10; 5898250 *)
{$EXTERNALSYM AMQP_TX_SELECT_METHOD}
(** tx.select method fields *)
type
  begin
  	amqp_tx_select_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_tx_select_t = amqp_tx_select_t_;
	{$EXTERNALSYM amqp_tx_select_t}

const AMQP_TX_SELECT_OK_METHOD = ((amqp_method_number_t) $005A000B);	(**< tx.select-ok method id @internal 90, 11; 5898251 *)
{$EXTERNALSYM AMQP_TX_SELECT_OK_METHOD}
(** tx.select-ok method fields *)
type
  begin
  	amqp_tx_select_ok_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_tx_select_ok_t = amqp_tx_select_ok_t_;
	{$EXTERNALSYM amqp_tx_select_ok_t}

const AMQP_TX_COMMIT_METHOD = ((amqp_method_number_t) $005A0014);	(**< tx.commit method id @internal 90, 20; 5898260 *)
{$EXTERNALSYM AMQP_TX_COMMIT_METHOD}
(** tx.commit method fields *)
type
  begin
  	amqp_tx_commit_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_tx_commit_t = amqp_tx_commit_t_;
	{$EXTERNALSYM amqp_tx_commit_t}

const AMQP_TX_COMMIT_OK_METHOD = ((amqp_method_number_t) $005A0015);	(**< tx.commit-ok method id @internal 90, 21; 5898261 *)
{$EXTERNALSYM AMQP_TX_COMMIT_OK_METHOD}
(** tx.commit-ok method fields *)
type
  begin
  	amqp_tx_commit_ok_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_tx_commit_ok_t = amqp_tx_commit_ok_t_;
	{$EXTERNALSYM amqp_tx_commit_ok_t}

const AMQP_TX_ROLLBACK_METHOD = ((amqp_method_number_t) $005A001E);	(**< tx.rollback method id @internal 90, 30; 5898270 *)
{$EXTERNALSYM AMQP_TX_ROLLBACK_METHOD}
(** tx.rollback method fields *)
type
  begin
  	amqp_tx_rollback_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_tx_rollback_t = amqp_tx_rollback_t_;
	{$EXTERNALSYM amqp_tx_rollback_t}

const AMQP_TX_ROLLBACK_OK_METHOD = ((amqp_method_number_t) $005A001F);	(**< tx.rollback-ok method id @internal 90, 31; 5898271 *)
{$EXTERNALSYM AMQP_TX_ROLLBACK_OK_METHOD}
(** tx.rollback-ok method fields *)
type
  begin
  	amqp_tx_rollback_ok_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_tx_rollback_ok_t = amqp_tx_rollback_ok_t_;
	{$EXTERNALSYM amqp_tx_rollback_ok_t}

const AMQP_CONFIRM_SELECT_METHOD = ((amqp_method_number_t) $0055000A);	(**< confirm.select method id @internal 85, 10; 5570570 *)
{$EXTERNALSYM AMQP_CONFIRM_SELECT_METHOD}
(** confirm.select method fields *)
type
  begin
  	amqp_confirm_select_t_ = record
		nowait: amqp_boolean_t;	 (**< nowait *)
	end;
	amqp_confirm_select_t = amqp_confirm_select_t_;
	{$EXTERNALSYM amqp_confirm_select_t}

const AMQP_CONFIRM_SELECT_OK_METHOD = ((amqp_method_number_t) $0055000B);	(**< confirm.select-ok method id @internal 85, 11; 5570571 *)
{$EXTERNALSYM AMQP_CONFIRM_SELECT_OK_METHOD}
(** confirm.select-ok method fields *)
type
  begin
  	amqp_confirm_select_ok_t_ = record
		dummy: Pointer;	 (**< Dummy field to avoid empty struct *)
	end;
	amqp_confirm_select_ok_t = amqp_confirm_select_ok_t_;
	{$EXTERNALSYM amqp_confirm_select_ok_t}

(* Class property records. *)
const AMQP_CONNECTION_CLASS = ($000A);	(**< connection class id @internal 10 *)
{$EXTERNALSYM AMQP_CONNECTION_CLASS}
(** connection class properties *)
type
  begin
  	amqp_connection_properties_t_ = record
		_flags: amqp_flags_t;	  (**< bit-mask of set fields *)
		dummy: Pointer;	        (**< Dummy field to avoid empty struct *)
	end;
	amqp_connection_properties_t = amqp_connection_properties_t_;
	{$EXTERNALSYM amqp_connection_properties_t}

const AMQP_CHANNEL_CLASS = ($0014);	(**< channel class id @internal 20 *)
{$EXTERNALSYM AMQP_CHANNEL_CLASS}
(** channel class properties *)
type
  begin
	  amqp_channel_properties_t_ = record
		_flags: amqp_flags_t;	  (**< bit-mask of set fields *)
		dummy: Pointer;	        (**< Dummy field to avoid empty struct *)
	end;
	amqp_channel_properties_t = amqp_channel_properties_t_;
	{$EXTERNALSYM amqp_channel_properties_t}

const AMQP_ACCESS_CLASS = ($001E);	(**< access class id @internal 30 *)
{$EXTERNALSYM AMQP_ACCESS_CLASS}
(** access class properties *)
type
  begin
  	amqp_access_properties_t_ = record
		_flags: amqp_flags_t;	  (**< bit-mask of set fields *)
		dummy: Pointer;	        (**< Dummy field to avoid empty struct *)
	end;
	amqp_access_properties_t = amqp_access_properties_t_;
	{$EXTERNALSYM amqp_access_properties_t}

const AMQP_EXCHANGE_CLASS = ($0028);	(**< exchange class id @internal 40 *)
{$EXTERNALSYM AMQP_EXCHANGE_CLASS}
(** exchange class properties *)
type
  begin
	  amqp_exchange_properties_t_ = record
		_flags: amqp_flags_t;	  (**< bit-mask of set fields *)
		dummy: Pointer;	        (**< Dummy field to avoid empty struct *)
	end;
	amqp_exchange_properties_t = amqp_exchange_properties_t_;
	{$EXTERNALSYM amqp_exchange_properties_t}

const AMQP_QUEUE_CLASS = ($0032);	(**< queue class id @internal 50 *)
{$EXTERNALSYM AMQP_QUEUE_CLASS}
(** queue class properties *)
type
  begin
  	amqp_queue_properties_t_ = record
		_flags: amqp_flags_t;	  (**< bit-mask of set fields *)
		dummy: Pointer;	        (**< Dummy field to avoid empty struct *)
	end;
	amqp_queue_properties_t = amqp_queue_properties_t_;
	{$EXTERNALSYM amqp_queue_properties_t}

const AMQP_BASIC_CLASS = ($003C);	                      (**< basic class id @internal 60 *)
const AMQP_BASIC_CONTENT_TYPE_FLAG = (1 shl 15);      	(**< basic.content-aType property flag *)
const AMQP_BASIC_CONTENT_ENCODING_FLAG = (1 shl 14);	  (**< basic.content-encoding property flag *)
const AMQP_BASIC_HEADERS_FLAG = (1 shl 13);           	(**< basic.headers property flag *)
const AMQP_BASIC_DELIVERY_MODE_FLAG = (1 shl 12);	      (**< basic.delivery-mode property flag *)
const AMQP_BASIC_PRIORITY_FLAG = (1 shl 11);	          (**< basic.priority property flag *)
const AMQP_BASIC_CORRELATION_ID_FLAG = (1 shl 10);    	(**< basic.correlation-id property flag *)
const AMQP_BASIC_REPLY_TO_FLAG = (1 shl 9);	            (**< basic.reply-to property flag *)
const AMQP_BASIC_EXPIRATION_FLAG = (1 shl 8);	          (**< basic.expiration property flag *)
const AMQP_BASIC_MESSAGE_ID_FLAG = (1 shl 7);	          (**< basic.message-id property flag *)
const AMQP_BASIC_TIMESTAMP_FLAG = (1 shl 6);	          (**< basic.timestamp property flag *)
const AMQP_BASIC_TYPE_FLAG = (1 shl 5);	                (**< basic.aType property flag *)
const AMQP_BASIC_USER_ID_FLAG = (1 shl 4);	            (**< basic.user-id property flag *)
const AMQP_BASIC_APP_ID_FLAG = (1 shl 3);	              (**< basic.app-id property flag *)
const AMQP_BASIC_CLUSTER_ID_FLAG = (1 shl 2);	          (**< basic.cluster-id property flag *)

(** basic class properties *)

type
  begin
	  amqp_basic_properties_t_ = record
		_flags: amqp_flags_t;	            (**< bit-mask of set fields *)
		content_type: amqp_bytes_t;	      (**< content-aType *)
		content_encoding: amqp_bytes_t;	  (**< content-encoding *)
		headers: amqp_table_t;	          (**< headers *)
		delivery_mode: uint8_t;	          (**< delivery-mode *)
		priority: uint8_t;	              (**< priority *)
		correlation_id: amqp_bytes_t;	    (**< correlation-id *)
		reply_to: amqp_bytes_t;	          (**< reply-to *)
		expiration: amqp_bytes_t;	        (**< expiration *)
		message_id: amqp_bytes_t;	        (**< message-id *)
		timestamp: uint64_t;	            (**< timestamp *)
		aType: amqp_bytes_t;	            (**< aType *)
		user_id: amqp_bytes_t;	          (**< user-id *)
		app_id: amqp_bytes_t;	            (**< app-id *)
		cluster_id: amqp_bytes_t;	        (**< cluster-id *)
	end;
	amqp_basic_properties_t = amqp_basic_properties_t_;
	{$EXTERNALSYM amqp_basic_properties_t}

const AMQP_TX_CLASS = ($005A);	(**< tx class id @internal 90 *)
{$EXTERNALSYM AMQP_TX_CLASS}
(** tx class properties *)
type
	begin
    amqp_tx_properties_t_ = record
		_flags: amqp_flags_t;	 (**< bit-mask of set fields *)
		dummy: Pointer;	       (**< Dummy field to avoid empty struct *)
	end;
	amqp_tx_properties_t = amqp_tx_properties_t_;
	{$EXTERNALSYM amqp_tx_properties_t}

const AMQP_CONFIRM_CLASS = ($0055);	(**< confirm class id @internal 85 *)
{$EXTERNALSYM AMQP_CONFIRM_CLASS}
(** confirm class properties *)
type
  begin
	  amqp_confirm_properties_t_ = record
		_flags: amqp_flags_t;	  (**< bit-mask of set fields *)
		dummy: Pointer;	        (**< Dummy field to avoid empty struct *)
	end;
	amqp_confirm_properties_t = amqp_confirm_properties_t_;
	{$EXTERNALSYM amqp_confirm_properties_t}

(* API functions for methods *)

(**
 * amqp_channel_open
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @returns amqp_channel_open_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_channel_open_ok_t *
AMQP_CALL amqp_channel_open(amqp_connection_state_t state, amqp_channel_t channel);
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
AMQP_CALL amqp_channel_flow(amqp_connection_state_t state, amqp_channel_t channel, amqp_boolean_t active);
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
AMQP_CALL amqp_exchange_declare(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t exchange, amqp_bytes_t aType, amqp_boolean_t passive, amqp_boolean_t durable, amqp_boolean_t auto_delete, amqp_boolean_t internal, amqp_table_t arguments);
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
AMQP_CALL amqp_exchange_delete(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t exchange, amqp_boolean_t if_unused) then ;
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
AMQP_CALL amqp_exchange_bind(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t destination, amqp_bytes_t source, amqp_bytes_t routing_key, amqp_table_t arguments);
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
AMQP_CALL amqp_exchange_unbind(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t destination, amqp_bytes_t source, amqp_bytes_t routing_key, amqp_table_t arguments);
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
AMQP_CALL amqp_queue_declare(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t queue, amqp_boolean_t passive, amqp_boolean_t durable, amqp_boolean_t exclusive, amqp_boolean_t auto_delete, amqp_table_t arguments);
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
AMQP_CALL amqp_queue_bind(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t queue, amqp_bytes_t exchange, amqp_bytes_t routing_key, amqp_table_t arguments);
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
AMQP_CALL amqp_queue_purge(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t queue);
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
AMQP_CALL amqp_queue_delete(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t queue, amqp_boolean_t if_unused, amqp_boolean_t if_empty) then ;
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
AMQP_CALL amqp_queue_unbind(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t queue, amqp_bytes_t exchange, amqp_bytes_t routing_key, amqp_table_t arguments);
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
AMQP_CALL amqp_basic_qos(amqp_connection_state_t state, amqp_channel_t channel, uint32_t prefetch_size, uint16_t prefetch_count, amqp_boolean_t global);
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
AMQP_CALL amqp_basic_consume(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t queue, amqp_bytes_t consumer_tag, amqp_boolean_t no_local, amqp_boolean_t no_ack, amqp_boolean_t exclusive, amqp_table_t arguments);
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
AMQP_CALL amqp_basic_cancel(amqp_connection_state_t state, amqp_channel_t channel, amqp_bytes_t consumer_tag);
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
AMQP_CALL amqp_basic_recover(amqp_connection_state_t state, amqp_channel_t channel, amqp_boolean_t requeue);
(**
 * amqp_tx_select
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @returns amqp_tx_select_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_tx_select_ok_t *
AMQP_CALL amqp_tx_select(amqp_connection_state_t state, amqp_channel_t channel);
(**
 * amqp_tx_commit
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @returns amqp_tx_commit_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_tx_commit_ok_t *
AMQP_CALL amqp_tx_commit(amqp_connection_state_t state, amqp_channel_t channel);
(**
 * amqp_tx_rollback
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @returns amqp_tx_rollback_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_tx_rollback_ok_t *
AMQP_CALL amqp_tx_rollback(amqp_connection_state_t state, amqp_channel_t channel);
(**
 * amqp_confirm_select
 *
 * @param [in] state connection state
 * @param [in] channel the channel to do the RPC on
 * @returns amqp_confirm_select_ok_t
 *)
AMQP_PUBLIC_FUNCTION
amqp_confirm_select_ok_t *
AMQP_CALL amqp_confirm_select(amqp_connection_state_t state, amqp_channel_t channel);

AMQP_END_DECLS

{$endif}	(* AMQP_FRAMING_H *)

implementation

end.

