library amqp;

(* vim:set ft=c ts=2 sw=2 sts=2 et cindent: *)
(** \file *)
(*
 * ***** aBegin LICENSE BLOCK *****
 * Version: MIT
 *
 * Portions created by Alan Antonuk are Copyright (c) 2012-2014
 * Alan Antonuk. All Rights Reserved.
 *
 * Portions created by VMware are Copyright (c) 2007-2012 VMware, Inc.
 * All Rights Reserved.
 *
 * Portions created by Tony Garnock-Jones are Copyright (c) 2009-2010
 * VMware, Inc. and Tony Garnock-Jones. All Rights Reserved.
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

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  amqp_api in 'amqp_api.pas',
  amqp_connection in 'amqp_connection.pas',
  amqp_consumer in 'amqp_consumer.pas',
  amqp_framing_c in 'amqp_framing_c.pas',
  amqp_framing_h in 'amqp_framing_h.pas',
  amqp_hostcheck_c in 'amqp_hostcheck_c.pas',
  amqp_hostcheck_h in 'amqp_hostcheck_h.pas',
  amqp_mem in 'amqp_mem.pas',
  amqp_openssl in 'amqp_openssl.pas',
  amqp_openssl_hostname_validation_c in 'amqp_openssl_hostname_validation_c.pas',
  amqp_openssl_hostname_validation_h in 'amqp_openssl_hostname_validation_h.pas',
  amqp_private in 'amqp_private.pas',
  amqp_socket_c in 'amqp_socket_c.pas',
  amqp_socket_h in 'amqp_socket_h.pas',
  amqp_ssl_socket in 'amqp_ssl_socket.pas',
  amqp_table_c in 'amqp_table_c.pas',
  amqp_table_h in 'amqp_table_h.pas',
  amqp_tcp_socket_c in 'amqp_tcp_socket_c.pas',
  amqp_tcp_socket_h in 'amqp_tcp_socket_h.pas',
  amqp_time_c in 'amqp_time_c.pas',
  amqp_time_h in 'amqp_time_h.pas',
  amqp_url in 'amqp_url.pas',
  amqp_h in 'amqp_h.pas',
  stdint in 'stdint.pas',
  config in 'config.pas',
  threads in 'threads.pas',
  threads_h in 'threads_h.pas';

{$R *.res}

{$define AMQP_H}

(** \cond HIDE_FROM_DOXYGEN *)

{$ifdef __cplusplus}
{$define AMQP_BEGIN_DECLS}
const AMQP_END_DECLS = end;
{$else}
{$define AMQP_BEGIN_DECLS}
{$define AMQP_END_DECLS}
{$endif}

{$if Defined(_WIN32)) and (_WIN32) defined and  defined(_MSC_VER)}
{$HPPEMIT '# if defined(AMQP_BUILD) && !defined(AMQP_STATIC)'}
{$HPPEMIT '#  define AMQP_PUBLIC_FUNCTION __declspec(dllexport)'}
{$HPPEMIT '#  define AMQP_PUBLIC_VARIABLE __declspec(dllexport) extern'}
{$HPPEMIT '# else'}
{$HPPEMIT '#  define AMQP_PUBLIC_FUNCTION'}
{$HPPEMIT '#  if !defined(AMQP_STATIC)'}
{$HPPEMIT '#   define AMQP_PUBLIC_VARIABLE __declspec(dllimport) extern'}
{$HPPEMIT '#  else'}
{$HPPEMIT '#   define AMQP_PUBLIC_VARIABLE extern'}
{$HPPEMIT '#  endif'}
{$HPPEMIT '# endif'}
{$HPPEMIT '# define AMQP_CALL __cdecl'}

(*
 * \internal
 * Important API decorators:
 *  AMQP_PUBLIC_FUNCTION - a public API function
 *  AMQP_PUBLIC_VARIABLE - a public API external variable
 *  AMQP_CALL - calling convension (used on Win32)
 *)

{$HPPEMIT '#elif defined(_WIN32) && defined(__BORLANDC__)'}
{$HPPEMIT '# if defined(AMQP_BUILD) && !defined(AMQP_STATIC)'}
{$HPPEMIT '#  define AMQP_PUBLIC_FUNCTION __declspec(dllexport)'}
{$HPPEMIT '#  define AMQP_PUBLIC_VARIABLE __declspec(dllexport) extern'}
{$HPPEMIT '# else'}
{$HPPEMIT '#  define AMQP_PUBLIC_FUNCTION'}
{$HPPEMIT '#  if !defined(AMQP_STATIC)'}
{$HPPEMIT '#   define AMQP_PUBLIC_VARIABLE __declspec(dllimport) extern'}
{$HPPEMIT '#  else'}
{$HPPEMIT '#   define AMQP_PUBLIC_VARIABLE extern'}
{$HPPEMIT '#  endif'}
{$HPPEMIT '# endif'}
{$HPPEMIT '# define AMQP_CALL __cdecl'}

{$HPPEMIT '#elif defined(_WIN32) && defined(__MINGW32__)'}
{$HPPEMIT '# if defined(AMQP_BUILD) && !defined(AMQP_STATIC)'}
{$HPPEMIT '#  define AMQP_PUBLIC_FUNCTION __declspec(dllexport)'}
{$HPPEMIT '#  define AMQP_PUBLIC_VARIABLE __declspec(dllexport) extern'}
{$HPPEMIT '# else'}
{$HPPEMIT '#  define AMQP_PUBLIC_FUNCTION'}
{$HPPEMIT '#  if !defined(AMQP_STATIC)'}
{$HPPEMIT '#   define AMQP_PUBLIC_VARIABLE __declspec(dllimport) extern'}
{$HPPEMIT '#  else'}
{$HPPEMIT '#   define AMQP_PUBLIC_VARIABLE extern'}
{$HPPEMIT '#  endif'}
{$HPPEMIT '# endif'}
{$HPPEMIT '# define AMQP_CALL __cdecl'}

{$HPPEMIT '#elif defined(_WIN32) && defined(__CYGWIN__)'}
{$HPPEMIT '# if defined(AMQP_BUILD) && !defined(AMQP_STATIC)'}
{$HPPEMIT '#  define AMQP_PUBLIC_FUNCTION __declspec(dllexport)'}
{$HPPEMIT '#  define AMQP_PUBLIC_VARIABLE __declspec(dllexport)'}
{$HPPEMIT '# else'}
{$HPPEMIT '#  define AMQP_PUBLIC_FUNCTION'}
{$HPPEMIT '#  if !defined(AMQP_STATIC)'}
{$HPPEMIT '#   define AMQP_PUBLIC_VARIABLE __declspec(dllimport) extern'}
{$HPPEMIT '#  else'}
{$HPPEMIT '#   define AMQP_PUBLIC_VARIABLE extern'}
{$HPPEMIT '#  endif'}
{$HPPEMIT '# endif'}
{$HPPEMIT '# define AMQP_CALL __cdecl'}

begin HPPEMIT '#elif defined(__GNUC__) && __GNUC__ >= 4'}
begin HPPEMIT '# define AMQP_PUBLIC_FUNCTION'}
  __attribute__ ((visibility ('default')))
begin HPPEMIT '# define AMQP_PUBLIC_VARIABLE'}
  __attribute__ ((visibility ('default'))) extern
begin HPPEMIT '# define AMQP_CALL'}
begin else end;
begin HPPEMIT '# define AMQP_PUBLIC_FUNCTION'}
begin HPPEMIT '# define AMQP_PUBLIC_VARIABLE extern'}
begin HPPEMIT '# define AMQP_CALL'}
begin endif end;

begin if Defined(__GNUC__) and (__GNUC__ __GNUC__ > 3 or := 3  and  __GNUC_MINOR__ >= 1) end;
begin HPPEMIT '# define AMQP_DEPRECATED(aFunction)'}
  aFunction __attribute__ ((__deprecated__))
begin HPPEMIT '#elif defined(_MSC_VER)'}
begin HPPEMIT '# define AMQP_DEPRECATED(aFunction)'}
  __declspec(deprecated) aFunction
begin else end;
begin HPPEMIT '# define AMQP_DEPRECATED(aFunction)'}
begin end
if end;

{$ifdef _W64}
{$if Defined(__midl)) and (__midl)  not defined and  (defined(_X86_) or defined(_M_IX86))  and  _MSC_VER >= 1300}
const _W64 __w64
{$else}
{$define _W64}
{$endif}
{$endif}

{$ifdef _MSC_VER}
{$ifdef _WIN64}
type
	ssize_t = Int64;

	{$EXTERNALSYM ssize_t}
	{$else}
type
	Integer ssize_t = _W64;

	{$EXTERNALSYM Integer ssize_t}
	{$endif}
{$endif}

{$if Defined(_WIN32)) and (_WIN32) defined and  defined(__MINGW32__)}
{$HPPEMIT '#include <sys/types.h>'}
{$endif}
  (** \endcond *)
{$HPPEMIT '#include <stddef.h>'}
{$HPPEMIT '#include <stdint.h>'}

 timeval;

AMQP_BEGIN_DECLS

(**
 * \def AMQP_VERSION_MAJOR
 *
 * Major library version number compile-time constant
 *
 * The major version is incremented when backwards incompatible API changes
 * are made.
 *
 * \sa AMQP_VERSION, AMQP_VERSION_STRING
 *
 * \since v0.4.0
 *)

(**
 * \def AMQP_VERSION_MINOR
 *
 * Minor library version number compile-time constant
 *
 * The minor version is incremented when new APIs are added. Existing APIs
 * are left alone.
 *
 * \sa AMQP_VERSION, AMQP_VERSION_STRING
 *
 * \since v0.4.0
 *)

(**
 * \def AMQP_VERSION_PATCH
 *
 * Patch library version number compile-time constant
 *
 * The patch version is incremented when library code changes, but the API
 * is not changed.
 *
 * \sa AMQP_VERSION, AMQP_VERSION_STRING
 *
 * \since v0.4.0
 *)

(**
 * \def AMQP_VERSION_IS_RELEASE
 *
 * Version constant set to 1 for tagged release, 0 otherwise
 *
 * NOTE: versions that are not tagged releases are not guaranteed to be API/ABI
 * compatible with older releases, and may change commit-to-commit.
 *
 * \sa AMQP_VERSION, AMQP_VERSION_STRING
 *
 * \since v0.4.0
 */
/*
 * Developer note: when changing these, be sure to update SOVERSION constants
 *  in CMakeLists.txt and configure.ac
 *)

const AMQP_VERSION_MAJOR 0
const AMQP_VERSION_MINOR 8
const AMQP_VERSION_PATCH 0
const AMQP_VERSION_IS_RELEASE 1

(**
 * \def AMQP_VERSION_CODE
 *
 * Helper macro to geneate a packed version code suitable for
 * comparison with AMQP_VERSION.
 *
 * \sa amqp_version_number() AMQP_VERSION_MAJOR, AMQP_VERSION_MINOR,
 *     AMQP_VERSION_PATCH, AMQP_VERSION_IS_RELEASE, AMQP_VERSION
 *
 * \since v0.6.1
 *)

const AMQP_VERSION_CODE(major, minor, patch, release)
    ((major shl 24) or

     (minor shl 16) or

     (patch shl 8)  or

     (release))

 (**
 * \def AMQP_VERSION
 *
 * Packed version number
 *
 * AMQP_VERSION is a 4-byte unsigned integer with the most significant byte
 * set to AMQP_VERSION_MAJOR, the second most significant byte set to
 * AMQP_VERSION_MINOR, third most significant byte set to AMQP_VERSION_PATCH,
 * and the lowest byte set to AMQP_VERSION_IS_RELEASE.
 *
 * For example version 2.3.4 which is released version would be encoded as
 * 0x02030401
 *
 * \sa amqp_version_number() AMQP_VERSION_MAJOR, AMQP_VERSION_MINOR,
 *     AMQP_VERSION_PATCH, AMQP_VERSION_IS_RELEASE, AMQP_VERSION_CODE
 *
 * \since v0.4.0
 *)

const AMQP_VERSION AMQP_VERSION_CODE(AMQP_VERSION_MAJOR,
                                       AMQP_VERSION_MINOR,

                                       AMQP_VERSION_PATCH,

                                       AMQP_VERSION_IS_RELEASE)

 (** \cond HIDE_FROM_DOXYGEN *)
const AMQ_STRINGIFY(s) AMQ_STRINGIFY_HELPER(s)
const AMQ_STRINGIFY_HELPER(s) #s

const AMQ_VERSION_STRING AMQ_STRINGIFY(AMQP_VERSION_MAJOR) '.'
                            AMQ_STRINGIFY(AMQP_VERSION_MINOR) '.'

                            AMQ_STRINGIFY(AMQP_VERSION_PATCH)
 (** \endcond *)

(**
 * \def AMQP_VERSION_STRING
 *
 * Version string compile-time constant
 *
 * Non-released versions of the library will have "-pre" appended to the
 * version string
 *
 * \sa amqp_version()
 *
 * \since v0.4.0
 *)
{$ifdef AMQP_VERSION_IS_RELEASE}
{$HPPEMIT '# define AMQP_VERSION_STRING AMQ_VERSION_STRING'}
{$else}
{$HPPEMIT '# define AMQP_VERSION_STRING AMQ_VERSION_STRING '-pre''}
{$endif}


(**
 * Returns the rabbitmq-c version as a packed integer.
 *
 * See \ref AMQP_VERSION
 *
 * \return packed 32-bit integer representing version of library at runtime
 *
 * \sa AMQP_VERSION, amqp_version()
 *
 * \since v0.4.0
 *)

AMQP_PUBLIC_FUNCTION
uint32_t
AMQP_CALL amqp_version_number(procedure);
 (**
 * Returns the rabbitmq-c version as a string.
 *
 * See \ref AMQP_VERSION_STRING
 *
 * \return a statically allocated string describing the version of rabbitmq-c.
 *
 * \sa amqp_version_number(), AMQP_VERSION_STRING, AMQP_VERSION
 *
 * \since v0.1
 *)
AMQP_PUBLIC_FUNCTION
PChar
AMQP_CALL amqp_version();

(**
 * \def AMQP_DEFAULT_FRAME_SIZE
 *
 * Default frame size (128Kb)
 *
 * \sa amqp_login(), amqp_login_with_properties()
 *
 * \since v0.4.0
 *)
const AMQP_DEFAULT_FRAME_SIZE 131072

 (**
 * \def AMQP_DEFAULT_MAX_CHANNELS
 *
 * Default maximum number of channels (0, no limit)
 *
 * \sa amqp_login(), amqp_login_with_properties()
 *
 * \since v0.4.0
 *)
const AMQP_DEFAULT_MAX_CHANNELS 0
(**
 * \def AMQP_DEFAULT_HEARTBEAT
 *
 * Default heartbeat interval (0, heartbeat disabled)
 *
 * \sa amqp_login(), amqp_login_with_properties()
 *
 * \since v0.4.0
 *)
const AMQP_DEFAULT_HEARTBEAT 0

(**
 * boolean type 0 = false, true otherwise
 *
 * \since v0.1
 *)
type
	amqp_boolean_t = Integer;
 (**
 * Method number
 *
 * \since v0.1
 *)
	{$EXTERNALSYM amqp_boolean_t}


type
	amqp_method_number_t = uint32_t;
  (**
 * Bitmask for flags
 *
 * \since v0.1
 *)
	{$EXTERNALSYM amqp_method_number_t}


type
	amqp_flags_t = uint32_t;
   (**
 * Channel type
 *
 * \since v0.1
 *)
	{$EXTERNALSYM amqp_flags_t}


type
	amqp_channel_t = uint16_t;
     (**
 * Buffer descriptor
 *
 * \since v0.1
 *)
	{$EXTERNALSYM amqp_channel_t}


type;
{$EXTERNALSYM AMQP_END_DECLS}

	amqp_bytes_t_ = record
		len: size_t;	(**< length of the buffer in bytes *)
		bytes: Pointer;	 (**< pointer to the beginning of the buffer *)
	end;
	amqp_bytes_t = amqp_bytes_t_;
	{$EXTERNALSYM amqp_bytes_t}
    (**
 * Decimal data type
 *
 * \since v0.1
 *)


type
	amqp_decimal_t_ = record
		decimals: uint8_t; (**< the location of the decimal point *)
		value: uint32_t;	 (**< the value before the decimal point is applied *)
	end;
	amqp_decimal_t = amqp_decimal_t_;
	{$EXTERNALSYM amqp_decimal_t}
  (**
 * AMQP field table
 *
 * An AMQP field table is a set of key-value pairs.
 * A key is a UTF-8 encoded string up to 128 bytes long, and are not null
 * terminated.
 * A value can be one of several different datatypes. \sa amqp_field_value_kind_t
 *
 * \sa amqp_table_entry_t
 *
 * \since v0.1
 *)

type
	amqp_table_t_ = record
		num_entries: Integer;	 (**< length of entries array *)
		entries: ^ amqp_table_entry_t_;	 (**< an array of table entries *)
	end;
	amqp_table_t = amqp_table_t_;
	{$EXTERNALSYM amqp_table_t}

  (**
 * An AMQP Field Array
 *
 * A repeated set of field values, all must be of the same type
 *
 * \since v0.1
 *)

type
	amqp_array_t_ = record
		num_entries: Integer;	            (**< Number of entries in the table *)
		entries: ^ amqp_field_value_t_;	  (**< linked list of field values *)
	end;
	amqp_array_t = amqp_array_t_;
	{$EXTERNALSYM amqp_array_t}

 (*
  0-9   0-9-1   Qpid/Rabbit  Type               Remarks
---------------------------------------------------------------------------
        t       t            Boolean
        b       b            Signed 8-bit
        B                    Unsigned 8-bit
        U       s            Signed 16-bit      (A1)
        u                    Unsigned 16-bit
  I     I       I            Signed 32-bit
        i                    Unsigned 32-bit
        L       l            Signed 64-bit      (B)
        l                    Unsigned 64-bit
        f       f            32-bit float
        d       d            64-bit float
  D     D       D            Decimal
        s                    Short string       (A2)
  S     S       S            Long string
        A                    Nested Array
  T     T       T            Timestamp (u64)
  F     F       F            Nested Table
  V     V       V            Void
                x            Byte array

Remarks:

 A1, A2: Notice how the types **CONFLICT** here. In Qpid and Rabbit,
         's' means a signed 16-bit integer; in 0-9-1, it means a
          short string.

 B: Notice how the signednesses **CONFLICT** here. In Qpid and Rabbit,
    'l' means a signed 64-bit integer; in 0-9-1, it means an unsigned
    64-bit integer.

I'm going with the Qpid/Rabbit types, where there's a conflict, and
the 0-9-1 types otherwise. 0-8 is a subset of 0-9, which is a subset
of the other two, so this will work for both 0-8 and 0-9-1 branches of
the code.
*)

(**
 * A field table value
 *
 * \since v0.1
 *)

type
	amqp_field_value_t_ = record
		kind: uint8_t;	                 (**< the type of the entry /sa amqp_field_value_kind_t *)
  	case Integer of
			0:(boolean: amqp_boolean_t);   (**< boolean type AMQP_FIELD_KIND_BOOLEAN *)
			1:(i8: int8_t);                (**< int8_t type AMQP_FIELD_KIND_I8 *)
			2:(u8: uint8_t);               (**< uint8_t type AMQP_FIELD_KIND_U8 *)
			3:(i16: int16_t);              (**< int16_t type AMQP_FIELD_KIND_I16 *)
			4:(u16: uint16_t);             (**< uint16_t type AMQP_FIELD_KIND_U16 *)
			5:(i32: int32_t);              (**< int32_t type AMQP_FIELD_KIND_I32 *)
			6:(u32: uint32_t);             (**< uint32_t type AMQP_FIELD_KIND_U32 *)
			7:(i64: int64_t);              (**< int64_t type AMQP_FIELD_KIND_I64 *)
			8:(u64: uint64_t);             (**< uint64_t type AMQP_FIELD_KIND_U64, AMQP_FIELD_KIND_TIMESTAMP *)
			9:(f32: Single);               (**< float type AMQP_FIELD_KIND_F32 *)
			10:(f64: Double);              (**< double type AMQP_FIELD_KIND_F64 *)
			11:(decimal: amqp_decimal_t);  (**< amqp_decimal_t AMQP_FIELD_KIND_DECIMAL *)
			12:(bytes: amqp_bytes_t);      (**< amqp_bytes_t type AMQP_FIELD_KIND_UTF8, AMQP_FIELD_KIND_BYTES *)
			13:(table: amqp_table_t);      (**< amqp_table_t type AMQP_FIELD_KIND_TABLE *)
			14:(aArray: amqp_array_t);     (**< amqp_array_t type AMQP_FIELD_KIND_ARRAY *)
	end;
	value = amqp_field_value_t_;       (**< a union of the value *)
	{$EXTERNALSYM value}

 end; amqp_field_value_t;

 (**
 * An entry in a field-table
 *
 * \sa amqp_table_encode(), amqp_table_decode(), amqp_table_clone()
 *
 * \since v0.1
 *)

type
	amqp_table_entry_t_ = record
		key: amqp_bytes_t;	(**< the table entry key. Its a null-terminated UTF-8 string,
                               * with a maximum size of 128 bytes *)
		value: amqp_field_value_t;	   (**< the table entry values *)
	end;
	amqp_table_entry_t = amqp_table_entry_t_;
	{$EXTERNALSYM amqp_table_entry_t}

  (**
 * Field value types
 *
 * \since v0.1
 *)
/
const AMQP_FIELD_KIND_BOOLEAN = 't';       (**< boolean type. 0 = false, 1 = true @see amqp_boolean_t *)
const AMQP_FIELD_KIND_I8 = 'b';            (**< 8-bit signed integer, datatype: int8_t *)
const AMQP_FIELD_KIND_U8 = 'B';            (**< 8-bit unsigned integer, datatype: uint8_t *)
const AMQP_FIELD_KIND_I16 = 's';           (**< 16-bit signed integer, datatype: int16_t *)
const AMQP_FIELD_KIND_U16 = 'u';           (**< 16-bit unsigned integer, datatype: uint16_t *)
const AMQP_FIELD_KIND_I32 = 'I';           (**< 32-bit signed integer, datatype: int32_t *)
const AMQP_FIELD_KIND_U32 = 'i';           (**< 32-bit unsigned integer, datatype: uint32_t *)
const AMQP_FIELD_KIND_I64 = 'l';           (**< 64-bit signed integer, datatype: int64_t *)
const AMQP_FIELD_KIND_U64 = 'L';           (**< 64-bit unsigned integer, datatype: uint64_t *)
const AMQP_FIELD_KIND_F32 = 'f';           (**< single-precision floating point value, datatype: float *)
const AMQP_FIELD_KIND_F64 = 'd';           (**< double-precision floating point value, datatype: double *)
const AMQP_FIELD_KIND_DECIMAL = 'D';       (**< amqp-decimal value, datatype: amqp_decimal_t *)
const AMQP_FIELD_KIND_UTF8 = 'S';          (**< UTF-8 null-terminated character string, datatype: amqp_bytes_t *)
const AMQP_FIELD_KIND_ARRAY = 'A';         (**< field array (repeated values of another datatype. datatype: amqp_array_t *)
const AMQP_FIELD_KIND_TIMESTAMP = 'T';     (**< 64-bit timestamp. datatype uint64_t *)
const AMQP_FIELD_KIND_TABLE = 'F';         (**< field table. encapsulates a table inside a table entry. datatype: amqp_table_t *)
const AMQP_FIELD_KIND_VOID = 'V';          (**< empty entry *)
const AMQP_FIELD_KIND_BYTES = 'x';         (**< unformatted byte string, datatype: amqp_bytes_t *)

type
	amqp_field_value_kind_t = AMQP_FIELD_KIND_BOOLEAN..AMQP_FIELD_KIND_BYTES;
  (**
 * A list of allocation blocks
 *
 * \since v0.1
 *)
	{$EXTERNALSYM amqp_field_value_kind_t}



type
	amqp_pool_blocklist_t_ = record
		num_blocks: Integer;	  (**< Number of blocks in the block list *)
		blocklist: ^Pointer;	  (**< Array of memory blocks *)
	end;
	amqp_pool_blocklist_t = amqp_pool_blocklist_t_;
	{$EXTERNALSYM amqp_pool_blocklist_t}

     (**
 * A memory pool
 *
 * \since v0.1
 *)

type
	amqp_pool_t_ = record
		pagesize: size_t;	    (**< the size of the page in bytes.
                               *  allocations less than or equal to this size are
                               *    allocated in the pages block list
                               *  allocations greater than this are allocated in their
                               *   own block in the large_blocks block list *)

		pages: amqp_pool_blocklist_t;	        (**< blocks that are the size of pagesize *)

		large_blocks: amqp_pool_blocklist_t;  (**< allocations larger than the pagesize *)
		next_page: Integer;	                  (**< an index to the next unused page block *)
		alloc_block: PChar;	                  (**< pointer to the current allocation block *)
		alloc_used: size_t;	                  (**< number of bytes in the current allocation block that has been used *)
	end;
	amqp_pool_t = amqp_pool_t_;
	{$EXTERNALSYM amqp_pool_t}

   (**
 * An amqp method
 *
 * \since v0.1
 *)

type
	amqp_method_t_ = record
		id: amqp_method_number_t;	(**< the method id number *)
		decoded: Pointer;	   (**< pointer to the decoded method,
                                 *    cast to the appropriate type to use *)
	end;
	amqp_method_t = amqp_method_t_;
	{$EXTERNALSYM amqp_method_t}

 (**
 * An AMQP frame
 *
 * \since v0.1
 *)

type
	amqp_frame_t_ = record
		frame_type: uint8_t; (**< frame type. The types:
                             * - AMQP_FRAME_METHOD - use the method union member
                             * - AMQP_FRAME_HEADER - use the properties union member
                             * - AMQP_FRAME_BODY - use the body_fragment union member
                             *)
		channel: amqp_channel_t;	(**< the channel the frame was received on *)
  	case Integer of
			0:(method: amqp_method_t);  (**< a method, use if frame_type == AMQP_FRAME_METHOD *)
			1:(

			);
			2:(class_id: uint16_t);     (**< the class for the properties *)
			3:(body_size: uint64_t);    (**< size of the body in bytes *)
			4:(decoded: Pointer);       (**< the decoded properties *)
			5:(raw: amqp_bytes_t);      (**< amqp-encoded properties structure *)
	end;
	properties = amqp_frame_t_;     (**< message header, a.k.a., properties,
                                  use if frame_type == AMQP_FRAME_HEADER *)
	{$EXTERNALSYM properties}


    amqp_bytes_t body_fragment;         (**< a body fragment, use if frame_type == AMQP_FRAME_BODY *)
    type
      	= record begin
      uint8_t transport_high;           (**< @internal first byte of handshake *)
      uint8_t transport_low;            (**< @internal second byte of handshake *)
      uint8_t protocol_version_major;   (**< @internal third byte of handshake *)
      uint8_t protocol_version_minor;   (**< @internal fourth byte of handshake *)
     end; protocol_header;              (**< Used only when doing the initial handshake with the broker,
                                don't use otherwise *)

   end; payload;                        (**< the payload of the frame *)
 end; amqp_frame_t;

 (**
 * Response type
 *
 * \since v0.1
 *)
const AMQP_RESPONSE_NONE = 0;              (**< the library got an EOF from the socket *)
const AMQP_RESPONSE_NORMAL	= 1;           (**< response normal, the RPC completed successfully *)
const AMQP_RESPONSE_LIBRARY_EXCEPTION	= 2; (**< library error, an error occurred in the library, examine the library_error *)
const AMQP_RESPONSE_SERVER_EXCEPTION	= 3; (**< server exception, the broker returned an error, check replay *)

(**
 * Reply from a RPC method on the broker
 *
 * \since v0.1
 *)

type	AMQP_RESPONSE_NONE..AMQP_RESPONSE_SERVER_EXCEPTION
amqp_response_type_const
amqp_response_type_enum
reply_type	= 0;
                                        (**< the reply type:
                                         * - AMQP_RESPONSE_NORMAL - the RPC completed successfully
                                         * - AMQP_RESPONSE_SERVER_EXCEPTION - the broker returned
                                         *     an exception, check the reply field
                                         * - AMQP_RESPONSE_LIBRARY_EXCEPTION - the library
                                         *    encountered an error, check the library_error field
                                         *)
const amqp_method_t reply	= 1;          (**< in case of AMQP_RESPONSE_SERVER_EXCEPTION this
                                         * field will be set to the method returned from the broker *)
const Integer library_error	= 2;        (**< in case of AMQP_RESPONSE_LIBRARY_EXCEPTION this
                                         *    field will be set to an error code. An error
                                         *     string can be retrieved using amqp_error_string *)
const end	= 3; amqp_rpc_reply_t;

(**
 * SASL method type
 *
 * \since v0.1
 *)

const const AMQP_SASL_METHOD_UNDEFINED = -1;     (**< Invalid SASL method *)
const const AMQP_SASL_METHOD_PLAIN = 0;          (**< the PLAIN SASL method for authentication to the broker *)
const const AMQP_SASL_METHOD_EXTERNAL = 1;       (**< the EXTERNAL SASL method for authentication to the broker *)
const type	AMQP_SASL_METHOD_UNDEFINED..AMQP_SASL_METHOD_EXTERNAL	amqp_sasl_method_enum	= 4;
const type	= 5;

(**
 * connection state object
 *
 * \since v0.1
 *)

type
	amqp_connection_state_t = ^t  amqp_connection_state_t_;
  (**
 * Socket object
 *
 * \since v0.4.0
 *)
const type	= 6;
type
	amqp_socket_t_ amqp_socket_t = t;
  (**
 * Status codes
 *
 * \since v0.4.0
 *)
 (* NOTE: When updating this enum, update the strings in librabbitmq/amqp_api.c *)
const const AMQP_STATUS_OK =                         $0;              (**< Operation successful *)
const const AMQP_STATUS_NO_MEMORY =                 -$0001;           (**< Memory allocation
                                                         failed *)
const const AMQP_STATUS_BAD_AMQP_DATA =             -$0002;           (**< Incorrect or corrupt
                                                        data was received from
                                                        the broker. This is a
                                                        protocol error. *)
const const AMQP_STATUS_UNKNOWN_CLASS =             -$0003;           (**< An unknown AMQP class
                                                        was received. This is
                                                        a protocol error. *)
const const AMQP_STATUS_UNKNOWN_METHOD =            -$0004;           (**< An unknown AMQP method
                                                        was received. This is
                                                        a protocol error. *)
const const AMQP_STATUS_HOSTNAME_RESOLUTION_FAILED= -$0005;           (**< Unable to resolve the
                                                    * hostname *)
const const AMQP_STATUS_INCOMPATIBLE_AMQP_VERSION = -$0006;           (**< The broker advertised
                                                        an incompaible AMQP
                                                        version *)
const const AMQP_STATUS_CONNECTION_CLOSED =         -$0007;           (**< The connection to the
                                                        broker has been closed
                                                        *)
const const AMQP_STATUS_BAD_URL =                   -$0008;           (**< malformed AMQP URL *)

const const AMQP_STATUS_SOCKET_ERROR =              -$0009;           (**< A socket error
                                                        occurred *)
const const AMQP_STATUS_INVALID_PARAMETER =         -$000A;           (**< An invalid parameter
                                                        was passed into the
                                                        function *)
const const AMQP_STATUS_TABLE_TOO_BIG =             -$000B;           (**< The amqp_table_t object
                                                        cannot be serialized
                                                        because the output
                                                        buffer is too small *)
const const AMQP_STATUS_WRONG_METHOD =              -$000C;            (**< The wrong method was
                                                        received *)
const const AMQP_STATUS_TIMEOUT =                   -$000D;            (**< Operation timed out *)

const const AMQP_STATUS_TIMER_FAILURE =             -$000E;            (**< The underlying system
                                                        timer facility failed *)
const const AMQP_STATUS_HEARTBEAT_TIMEOUT =         -$000F;            (**< Timed out waiting for
                                                        heartbeat *)
const const AMQP_STATUS_UNEXPECTED_STATE =          -$0010;            (**< Unexpected protocol
                                                        state *)
const const AMQP_STATUS_SOCKET_CLOSED =             -$0011;            (**< Underlying socket is
                                                        closed *)
const const AMQP_STATUS_SOCKET_INUSE =              -$0012;            (**< Underlying socket is
                                                        already open *)
const const AMQP_STATUS_BROKER_UNSUPPORTED_SASL_METHOD = -$0013;       (**< Broker does not
                                                          support the requested
                                                          SASL mechanism *)
const const AMQP_STATUS_UNSUPPORTED =               -$0014;            (**< Parameter is unsupported
                                                     in this version *)
const const _AMQP_STATUS_NEXT_VALUE =               -$0015;            (**< Internal value *)

const const AMQP_STATUS_TCP_ERROR =                 -$0100;            (**< A generic TCP error
                                                        occurred *)
const const AMQP_STATUS_TCP_SOCKETLIB_INIT_ERROR =  -$0101;            (**< An error occurred trying
                                                        to initialize the
                                                        socket library*)
const const _AMQP_STATUS_TCP_NEXT_VALUE =           -$0102;            (**< Internal value *)

const const AMQP_STATUS_SSL_ERROR =                 -$0200;            (**< A generic SSL error
                                                        occurred. *)
const const AMQP_STATUS_SSL_HOSTNAME_VERIFY_FAILED= -$0201;            (**< SSL validation of
                                                        hostname against
                                                        peer certificate
                                                        failed *)
const const AMQP_STATUS_SSL_PEER_VERIFY_FAILED =    -$0202;            (**< SSL validation of peer
                                                        certificate failed. *)
const const AMQP_STATUS_SSL_CONNECTION_FAILED =     -$0203;            (**< SSL handshake failed. *)

const const _AMQP_STATUS_SSL_NEXT_VALUE =           -$0204;            (**< Internal value *)

(**
 * AMQP delivery modes.
 * Use these values for the #amqp_basic_properties_t::delivery_mode field.
 *
 * \since v0.5
 *)

const type	AMQP_STATUS_OK.._AMQP_STATUS_SSL_NEXT_VALUE	amqp_status_enum	= 7;
const const AMQP_DELIVERY_NONPERSISTENT = 1;  (**< Non-persistent message *)
const const AMQP_DELIVERY_PERSISTENT = 2;     (**< Persistent message *)
const type	AMQP_DELIVERY_NONPERSISTENT..AMQP_DELIVERY_PERSISTENT	amqp_delivery_mode_enum	= 8;
const AMQP_END_DECLS	= 9;
(**
 * Empty bytes structure
 *
 * \since v0.2
 *)
{$HPPEMIT '#include <amqp_framing.h>'};
const AMQP_BEGIN_DECLS	= 10;
const AMQP_PUBLIC_VARIABLE  amqp_bytes_t amqp_empty_bytes	= 11;
(**
 * Empty table structure
 *
 * \since v0.2
 *)
const AMQP_PUBLIC_VARIABLE  amqp_table_t amqp_empty_table	= 12;
(**
 * Empty table array structure
 *
 * \since v0.2
 *)
const AMQP_PUBLIC_VARIABLE  amqp_array_t amqp_empty_array	= 13;
(* Compatibility macros for the above, to avoid the need to update
   code written against earlier versions of librabbitmq. *)

(**
 * \def AMQP_EMPTY_BYTES
 *
 * Deprecated, use \ref amqp_empty_bytes instead
 *
 * \deprecated use \ref amqp_empty_bytes instead
 *
 * \since v0.1
 *)
const const AMQP_EMPTY_BYTES = amqp_empty_bytes;
(**
 * \def AMQP_EMPTY_TABLE
 *
 * Deprecated, use \ref amqp_empty_table instead
 *
 * \deprecated use \ref amqp_empty_table instead
 *
 * \since v0.1
 *)
const const AMQP_EMPTY_TABLE amqp_empty_table	= 14;
(**
 * \def AMQP_EMPTY_ARRAY
 *
 * Deprecated, use \ref amqp_empty_array instead
 *
 * \deprecated use \ref amqp_empty_array instead
 *
 * \since v0.1
 *)
const const AMQP_EMPTY_ARRAY amqp_empty_array	= 15;
(**
 * Initializes an amqp_pool_t memory allocation pool for use
 *
 * Readies an allocation pool for use. An amqp_pool_t
 * must be initialized before use
 *
 * \param [in] pool the amqp_pool_t structure to initialize.
 *              Calling this function on a pool a pool that has
 *              already been initialized will result in undefined
 *              behavior
 * \param [in] pagesize the unit size that the pool will allocate
 *              memory chunks in. Anything allocated against the pool
 *              with a requested size will be carved out of a block
 *              this size. Allocations larger than this will be
 *              allocated individually
 *
 * \sa recycle_amqp_pool(), empty_amqp_pool(), amqp_pool_alloc(),
 *     amqp_pool_alloc_bytes(), amqp_pool_t
 *
 * \since v0.1
 *)
const AMQP_PUBLIC_FUNCTION	= 16;
const procedure	= 17; const AMQP_CALL init_amqp_pool(
(**
 * Recycles an amqp_pool_t memory allocation pool
 *
 * Recycles the space allocate by the pool
 *
 * This invalidates all allocations made against the pool before this call is
 * made, any use of any allocations made before recycle_amqp_pool() is called
 * will result in undefined behavior.
 *
 * Note: this may or may not release memory, to force memory to be released
 * call empty_amqp_pool().
 *
 * \param [in] pool the amqp_pool_t to recycle
 *
 * \sa recycle_amqp_pool(), empty_amqp_pool(), amqp_pool_alloc(),
 *      amqp_pool_alloc_bytes()
 *
 * \since v0.1
 *
 *)
	v1: amqp_pool_t;;
	v2: ;
	pool}: {$EXTERNALSYM;}
	v4: ;
	v5: ;
	amqp_rpc_reply_t_;: type;
	v7: amqp_rpc_reply_t_;;
	v8: ;
	v9: ;
	v10: AMQP_PUBLIC_FUNCTION;
	v11: procedure;
	recycle_amqp_function (var pool: amqp_pool_t): pool; AMQP_CALL;
  (**
 * Empties an amqp memory pool
 *
 * Releases all memory associated with an allocation pool
 *
 * \param [in] pool the amqp_pool_t to empty
 *
 * \since v0.1
 *)
	v13: ;
	v14: ;
	v15: AMQP_PUBLIC_FUNCTION;
	v16: Pointer;
	amqp_function _alloc(var pool: amqp_pool_t; amount: size_t): pool; AMQP_CALL;
  (**
 * Allocates a block of memory from an amqp_pool_t memory pool
 *
 * Memory will be aligned on a 8-byte boundary. If a 0-length allocation is
 * requested, a NULL pointer will be returned.
 *
 * \param [in] pool the allocation pool to allocate the memory from
 * \param [in] amount the size of the allocation in bytes.
 * \return a pointer to the memory block, or NULL if the allocation cannot
 *          be satisfied.
 *
 * \sa init_amqp_pool(), recycle_amqp_pool(), empty_amqp_pool(),
 *     amqp_pool_alloc_bytes()
 *
 * \since v0.1
 *)
	v18: ;
	v19: ;
	v20: AMQP_PUBLIC_FUNCTION;
	v21: procedure;
	amqp_function _alloc_bytes(var pool: amqp_pool_t; amount: size_t; var output: amqp_bytes_t): pool; AMQP_CALL;
  (**
 * Allocates a block of memory from an amqp_pool_t to an amqp_bytes_t
 *
 * Memory will be aligned on a 8-byte boundary. If a 0-length allocation is
 * requested, output.bytes = NULL.
 *
 * \param [in] pool the allocation pool to allocate the memory from
 * \param [in] amount the size of the allocation in bytes
 * \param [in] output the location to store the pointer. On success
 *              output.bytes will be set to the beginning of the buffer
 *              output.len will be set to amount
 *              On error output.bytes will be set to NULL and output.len
 *              set to 0
 *
 * \sa init_amqp_pool(), recycle_amqp_pool(), empty_amqp_pool(),
 *     amqp_pool_alloc()
 *
 * \since v0.1
 *)
	v23: ;
	v24: ;
	v25: AMQP_PUBLIC_FUNCTION;
	v26: amqp_bytes_t;
	var amqp_cstring_bytes(char  cstr: AMQP_CALL);

(**
 * Wraps a c string in an amqp_bytes_t
 *
 * Takes a string, calculates its length and creates an
 * amqp_bytes_t that points to it. The string is not duplicated.
 *
 * For a given input cstr, The amqp_bytes_t output.bytes is the
 * same as cstr, output.len is the length of the string not including
 * the \0 terminator
 *
 * This function uses strlen() internally so cstr must be properly
 * terminated
 *
 * \param [in] cstr the c string to wrap
 * \return an amqp_bytes_t that describes the string
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
amqp_bytes_t
AMQP_CALL amqp_bytes_malloc_dup(amqp_bytes_t src);
(**
 * Duplicates an amqp_bytes_t buffer.
 *
 * The buffer is cloned and the contents copied.
 *
 * The memory associated with the output is allocated
 * with amqp_bytes_malloc() and should be freed with
 * amqp_bytes_free()
 *
 * \param [in] src
 * \return a clone of the src
 *
 * \sa amqp_bytes_free(), amqp_bytes_malloc()
 *
 * \since v0.1
 *)


(**
 * Allocates a amqp_bytes_t buffer
 *
 * Creates an amqp_bytes_t buffer of the specified amount, the buffer should be
 * freed using amqp_bytes_free()
 *
 * \param [in] amount the size of the buffer in bytes
 * \returns an amqp_bytes_t with amount bytes allocated.
 *           output.bytes will be set to NULL on error
 *
 * \sa amqp_bytes_free(), amqp_bytes_malloc_dup()
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
amqp_bytes_t
AMQP_CALL amqp_bytes_malloc(size_t amount);

 (**
 * Frees an amqp_bytes_t buffer
 *
 * Frees a buffer allocated with amqp_bytes_malloc() or amqp_bytes_malloc_dup()
 *
 * Calling amqp_bytes_free on buffers not allocated with one
 * of those two functions will result in undefined behavior
 *
 * \param [in] bytes the buffer to free
 *
 * \sa amqp_bytes_malloc(), amqp_bytes_malloc_dup()
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
procedure
AMQP_CALL amqp_bytes_free(bytes: amqp_bytes_t);

(**
 * Allocate and initialize a new amqp_connection_state_t object
 *
 * amqp_connection_state_t objects created with this function
 * should be freed with amqp_destroy_connection()
 *
 * \returns an opaque pointer on success, NULL or 0 on failure.
 *
 * \sa amqp_destroy_connection()
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
amqp_connection_state_t
AMQP_CALL amqp_new_connection(procedure);

(**
 * Get the underlying socket descriptor for the connection
 *
 * \warning Use the socket returned from this function carefully, incorrect use
 * of the socket outside of the library will lead to undefined behavior.
 * Additionally rabbitmq-c may use the socket differently version-to-version,
 * what may work in one version, may break in the next version. Be sure to
 * throughly test any applications that use the socket returned by this
 * function especially when using a newer version of rabbitmq-c
 *
 * \param [in] state the connection object
 * \returns the socket descriptor if one has been set, -1 otherwise
 *
 * \sa amqp_tcp_socket_new(), amqp_ssl_socket_new(), amqp_socket_open()
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_get_sockfd(amqp_connection_state_t state);


(**
 * Deprecated, use amqp_tcp_socket_new() or amqp_ssl_socket_new()
 *
 * \deprecated Use amqp_tcp_socket_new() or amqp_ssl_socket_new()
 *
 * Sets the socket descriptor associated with the connection. The socket
 * should be connected to a broker, and should not be read to or written from
 * before calling this function.  A socket descriptor can be created and opened
 * using amqp_open_socket()
 *
 * \param [in] state the connection object
 * \param [in] sockfd the socket
 *
 * \sa amqp_open_socket(), amqp_tcp_socket_new(), amqp_ssl_socket_new()
 *
 * \since v0.1
 *)

AMQP_DEPRECATED(
  AMQP_PUBLIC_FUNCTION
    procedure
AMQP_CALL amqp_set_sockfd(amqp_connection_state_t state, Integer sockfd)
);


(**
 * Tune client side parameters
 *
 * \warning This function may call abort() if the connection is in a certain
 *  state. As such it should probably not be called code outside the library.
 *  connection parameters should be specified when calling amqp_login() or
 *  amqp_login_with_properties()
 *
 * This function changes channel_max, frame_max, and heartbeat parameters, on
 * the client side only. It does not try to renegotiate these parameters with
 * the broker. Using this function will lead to unexpected results.
 *
 * \param [in] state the connection object
 * \param [in] channel_max the maximum number of channels.
 *              The largest this can be is 65535
 * \param [in] frame_max the maximum size of an frame.
 *              The smallest this can be is 4096
 *              The largest this can be is 2147483647
 *              Unless you know what you're doing the recommended
 *              size is 131072 or 128KB
 * \param [in] heartbeat the number of seconds between heartbeats
 *
 * \return AMQP_STATUS_OK on success, an amqp_status_enum value otherwise.
 *  Possible error codes include:
 *  - AMQP_STATUS_NO_MEMORY memory allocation failed.
 *  - AMQP_STATUS_TIMER_FAILURE the underlying system timer indicated it
 *    failed.
 *
 * \sa amqp_login(), amqp_login_with_properties()
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_tune_connection(amqp_connection_state_t state,
                               Integer channel_max,
                               Integer frame_max,
                               Integer heartbeat);
 (**
 * Get the maximum number of channels the connection can handle
 *
 * The maximum number of channels is set when connection negotiation takes
 * place in amqp_login() or amqp_login_with_properties().
 *
 * \param [in] state the connection object
 * \return the maximum number of channels. 0 if there is no limit
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_get_channel_max(amqp_connection_state_t state);

(**
 * Get the maximum size of an frame the connection can handle
 *
 * The maximum size of an frame is set when connection negotiation takes
 * place in amqp_login() or amqp_login_with_properties().
 *
 * \param [in] state the connection object
 * \return the maximum size of an frame.
 *
 * \since v0.6
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_get_frame_max(amqp_connection_state_t state);

(**
 * Get the number of seconds between heartbeats of the connection
 *
 * The number of seconds between heartbeats is set when connection
 * negotiation takes place in amqp_login() or amqp_login_with_properties().
 *
 * \param [in] state the connection object
 * \return the number of seconds between heartbeats.
 *
 * \since v0.6
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_get_heartbeat(amqp_connection_state_t state);

(**
 * Destroys an amqp_connection_state_t object
 *
 * Destroys a amqp_connection_state_t object that was created with
 * amqp_new_connection(). If the connection with the broker is open, it will be
 * implicitly closed with a reply code of 200 (success). Any memory that
 * would be freed with amqp_maybe_release_buffers() or
 * amqp_maybe_release_buffers_on_channel() will be freed, and use of that
 * memory will caused undefined behavior.
 *
 * \param [in] state the connection object
 * \return AMQP_STATUS_OK on success. amqp_status_enum value failure
 *
 * \sa amqp_new_connection()
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_destroy_connection(amqp_connection_state_t state);

(**
 * Process incoming data
 *
 * \warning This is a low-level function intended for those who want to
 *  have greater control over input and output over the socket from the
 *  broker. Correctly using this function requires in-depth knowledge of AMQP
 *  and rabbitmq-c.
 *
 * For a given buffer of data received from the broker, decode the first
 * frame in the buffer. If more than one frame is contained in the input buffer
 * the return value will be less than the received_data size, the caller should
 * adjust received_data buffer descriptor to point to the beginning of the
 * buffer + the return value.
 *
 * \param [in] state the connection object
 * \param [in] received_data a buffer of data received from the broker. The
 *  function will return the number of bytes of the buffer it used. The
 *  function copies these bytes to an internal buffer: this part of the buffer
 *  may be reused after this function successfully completes.
 * \param [in,out] decoded_frame caller should pass in a pointer to an
 *  amqp_frame_t struct. If there is enough data in received_data for a
 *  complete frame, decoded_frame->frame_type will be set to something OTHER
 *  than 0. decoded_frame may contain members pointing to memory owned by
 *  the state object. This memory can be recycled with amqp_maybe_release_buffers()
 *  or amqp_maybe_release_buffers_on_channel()
 * \return number of bytes consumed from received_data or 0 if a 0-length
 *  buffer was passed. A negative return value indicates failure. Possible errors:
 *  - AMQP_STATUS_NO_MEMORY failure in allocating memory. The library is likely in
 *    an indeterminate state making recovery unlikely. Client should note the error
 *    and terminate the application
 *  - AMQP_STATUS_BAD_AMQP_DATA bad AMQP data was received. The connection
 *    should be shutdown immediately
 *  - AMQP_STATUS_UNKNOWN_METHOD: an unknown method was received from the
 *    broker. This is likely a protocol error and the connection should be
 *    shutdown immediately
 *  - AMQP_STATUS_UNKNOWN_CLASS: a properties frame with an unknown class
 *    was received from the broker. This is likely a protocol error and the
 *    connection should be shutdown immediately
 *
 * \since v0.1
 *)
AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_handle_input(amqp_connection_state_t state,
                            amqp_bytes_t received_data,
                            amqp_frame_t *decoded_frame);

 (**
 * Check to see if connection memory can be released
 *
 * \deprecated This function is deprecated in favor of
 *  amqp_maybe_release_buffers() or amqp_maybe_release_buffers_on_channel()
 *
 * Checks the state of an amqp_connection_state_t object to see if
 * amqp_release_buffers() can be called successfully.
 *
 * \param [in] state the connection object
 * \returns TRUE if the buffers can be released FALSE otherwise
 *
 * \sa amqp_release_buffers() amqp_maybe_release_buffers()
 *  amqp_maybe_release_buffers_on_channel()
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
amqp_boolean_t
AMQP_CALL amqp_release_buffers_ok(amqp_connection_state_t state);

(**
 * Release amqp_connection_state_t owned memory
 *
 * \deprecated This function is deprecated in favor of
 *  amqp_maybe_release_buffers() or amqp_maybe_release_buffers_on_channel()
 *
 * \warning caller should ensure amqp_release_buffers_ok() returns true before
 *  calling this function. Failure to do so may result in abort() being called.
 *
 * Release memory owned by the amqp_connection_state_t for reuse by the
 * library. Use of any memory returned by the library before this function is
 * called will result in undefined behavior.
 *
 * \note internally rabbitmq-c tries to reuse memory when possible. As a result
 * its possible calling this function may not have a noticeable effect on
 * memory usage.
 *
 * \param [in] state the connection object
 *
 * \sa amqp_release_buffers_ok() amqp_maybe_release_buffers()
 *  amqp_maybe_release_buffers_on_channel()
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
procedure
AMQP_CALL amqp_release_buffers(state: amqp_connection_state_t);

(**
 * Release amqp_connection_state_t owned memory
 *
 * Release memory owned by the amqp_connection_state_t object related to any
 * channel, allowing reuse by the library. Use of any memory returned by the
 * library before this function is called with result in undefined behavior.
 *
 * \note internally rabbitmq-c tries to reuse memory when possible. As a result
 * its possible calling this function may not have a noticeable effect on
 * memory usage.
 *
 * \param [in] state the connection object
 *
 * \sa amqp_maybe_release_buffers_on_channel()
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
procedure
AMQP_CALL amqp_maybe_release_buffers(state: amqp_connection_state_t);

(**
 * Release amqp_connection_state_t owned memory related to a channel
 *
 * Release memory owned by the amqp_connection_state_t object related to the
 * specified channel, allowing reuse by the library. Use of any memory returned
 * the library for a specific channel will result in undefined behavior.
 *
 * \note internally rabbitmq-c tries to reuse memory when possible. As a result
 * its possible calling this function may not have a noticeable effect on
 * memory usage.
 *
 * \param [in] state the connection object
 * \param [in] channel the channel specifier for which memory should be
 *  released. Note that the library does not care about the state of the
 *  channel when calling this function
 *
 * \sa amqp_maybe_release_buffers()
 *
 * \since v0.4.0
 *)

AMQP_PUBLIC_FUNCTION
procedure
AMQP_CALL amqp_maybe_release_buffers_on_channel(state: amqp_connection_state_t; v2: ; channel: amqp_channel_t);

(**
 * Send a frame to the broker
 *
 * \param [in] state the connection object
 * \param [in] frame the frame to send to the broker
 * \return AMQP_STATUS_OK on success, an amqp_status_enum value on error.
 *  Possible error codes:
 *  - AMQP_STATUS_BAD_AMQP_DATA the serialized form of the method or
 *    properties was too large to fit in a single AMQP frame, or the
 *    method contains an invalid value. The frame was not sent.
 *  - AMQP_STATUS_TABLE_TOO_BIG the serialized form of an amqp_table_t is
 *    too large to fit in a single AMQP frame. Frame was not sent.
 *  - AMQP_STATUS_UNKNOWN_METHOD an invalid method type was passed in
 *  - AMQP_STATUS_UNKNOWN_CLASS an invalid properties type was passed in
 *  - AMQP_STATUS_TIMER_FAILURE system timer indicated failure. The frame
 *    was sent
 *  - AMQP_STATUS_SOCKET_ERROR
 *  - AMQP_STATUS_SSL_ERROR
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_send_frame(amqp_connection_state_t state, amqp_frame_t  *frame);

(**
 * Compare two table entries
 *
 * Works just like strcmp(), comparing two the table keys, datatype, then values
 *
 * \param [in] entry1 the entry on the left
 * \param [in] entry2 the entry on the right
 * \return 0 if entries are equal, 0 < if left is greater, 0 > if right is greater
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_table_entry_cmp(procedure  *entry1, Pointer entry2);

(**
 * Open a socket to a remote host
 *
 * \deprecated This function is deprecated in favor of amqp_socket_open()
 *
 * Looks up the hostname, then attempts to open a socket to the host using
 * the specified portnumber. It also sets various options on the socket to
 * improve performance and correctness.
 *
 * \param [in] hostname this can be a hostname or IP address.
 *              Both IPv4 and IPv6 are acceptable
 * \param [in] portnumber the port to connect on. RabbitMQ brokers
 *              listen on port 5672, and 5671 for SSL
 * \return a positive value indicates success and is the sockfd. A negative
 *  value (see amqp_status_enum)is returned on failure. Possible error codes:
 *  - AMQP_STATUS_TCP_SOCKETLIB_INIT_ERROR Initialization of underlying socket
 *    library failed.
 *  - AMQP_STATUS_HOSTNAME_RESOLUTION_FAILED hostname lookup failed.
 *  - AMQP_STATUS_SOCKET_ERROR a socket error occurred. errno or WSAGetLastError()
 *    may return more useful information.
 *
 * \note IPv6 support was added in v0.3
 *
 * \sa amqp_socket_open() amqp_set_sockfd()
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_open_socket(char  *hostname, Integer portnumber);

(**
 * Send initial AMQP header to the broker
 *
 * \warning this is a low level function intended for those who want to
 * interact with the broker at a very low level. Use of this function without
 * understanding what it does will result in AMQP protocol errors.
 *
 * This function sends the AMQP protocol header to the broker.
 *
 * \param [in] state the connection object
 * \return AMQP_STATUS_OK on success, a negative value on failure. Possible
 *  error codes:
 * - AMQP_STATUS_CONNECTION_CLOSED the connection to the broker was closed.
 * - AMQP_STATUS_SOCKET_ERROR a socket error occurred. It is likely the
 *   underlying socket has been closed. errno or WSAGetLastError() may provide
 *   further information.
 * - AMQP_STATUS_SSL_ERROR a SSL error occurred. The connection to the broker
 *   was closed.
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_send_header(amqp_connection_state_t state);

(**
 * Checks to see if there are any incoming frames ready to be read
 *
 * Checks to see if there are any amqp_frame_t objects buffered by the
 * amqp_connection_state_t object. Having one or more frames buffered means
 * that amqp_simple_wait_frame() or amqp_simple_wait_frame_noblock() will
 * return a frame without potentially blocking on a read() call.
 *
 * \param [in] state the connection object
 * \return TRUE if there are frames enqueued, FALSE otherwise
 *
 * \sa amqp_simple_wait_frame() amqp_simple_wait_frame_noblock()
 *  amqp_data_in_buffer()
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
amqp_boolean_t
AMQP_CALL amqp_frames_enqueued(amqp_connection_state_t state);

(**
 * Read a single amqp_frame_t
 *
 * Waits for the next amqp_frame_t frame to be read from the broker.
 * This function has the potential to block for a long time in the case of
 * waiting for a basic.deliver method frame from the broker.
 *
 * The library may buffer frames. When an amqp_connection_state_t object
 * has frames buffered calling amqp_simple_wait_frame() will return an
 * amqp_frame_t without entering a blocking read(). You can test to see if
 * an amqp_connection_state_t object has frames buffered by calling the
 * amqp_frames_enqueued() function.
 *
 * The library has a socket read buffer. When there is data in an
 * amqp_connection_state_t read buffer, amqp_simple_wait_frame() may return an
 * amqp_frame_t without entering a blocking read(). You can test to see if an
 * amqp_connection_state_t object has data in its read buffer by calling the
 * amqp_data_in_buffer() function.
 *
 * \param [in] state the connection object
 * \param [out] decoded_frame the frame
 * \return AMQP_STATUS_OK on success, an amqp_status_enum value
 *  is returned otherwise. Possible errors include:
 *  - AMQP_STATUS_NO_MEMORY failure in allocating memory. The library is likely in
 *    an indeterminate state making recovery unlikely. Client should note the error
 *    and terminate the application
 *  - AMQP_STATUS_BAD_AMQP_DATA bad AMQP data was received. The connection
 *    should be shutdown immediately
 *  - AMQP_STATUS_UNKNOWN_METHOD: an unknown method was received from the
 *    broker. This is likely a protocol error and the connection should be
 *    shutdown immediately
 *  - AMQP_STATUS_UNKNOWN_CLASS: a properties frame with an unknown class
 *    was received from the broker. This is likely a protocol error and the
 *    connection should be shutdown immediately
 *  - AMQP_STATUS_HEARTBEAT_TIMEOUT timed out while waiting for heartbeat
 *    from the broker. The connection has been closed.
 *  - AMQP_STATUS_TIMER_FAILURE system timer indicated failure.
 *  - AMQP_STATUS_SOCKET_ERROR a socket error occurred. The connection has
 *    been closed
 *  - AMQP_STATUS_SSL_ERROR a SSL socket error occurred. The connection has
 *    been closed.
 *
 * \sa amqp_simple_wait_frame_noblock() amqp_frames_enqueued()
 *  amqp_data_in_buffer()
 *
 * \note as of v0.4.0 this function will no longer return heartbeat frames
 *  when enabled by specifying a non-zero heartbeat value in amqp_login().
 *  Heartbeating is handled internally by the library.
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_simple_wait_frame(amqp_connection_state_t state,
                                 amqp_frame_t *decoded_frame);


(**
 * Read a single amqp_frame_t with a timeout.
 *
 * Waits for the next amqp_frame_t frame to be read from the broker, up to
 * a timespan specified by tv. The function will return AMQP_STATUS_TIMEOUT
 * if the timeout is reached. The tv value is not modified by the function.
 *
 * If a 0 timeval is specified, the function behaves as if its non-blocking: it
 * will test to see if a frame can be read from the broker, and return immediately.
 *
 * If NULL is passed in for tv, the function will behave like
 * amqp_simple_wait_frame() and block until a frame is received from the broker
 *
 * The library may buffer frames.  When an amqp_connection_state_t object
 * has frames buffered calling amqp_simple_wait_frame_noblock() will return an
 * amqp_frame_t without entering a blocking read(). You can test to see if an
 * amqp_connection_state_t object has frames buffered by calling the
 * amqp_frames_enqueued() function.
 *
 * The library has a socket read buffer. When there is data in an
 * amqp_connection_state_t read buffer, amqp_simple_wait_frame_noblock() may return
 * an amqp_frame_t without entering a blocking read(). You can test to see if an
 * amqp_connection_state_t object has data in its read buffer by calling the
 * amqp_data_in_buffer() function.
 *
 * \note This function does not return heartbeat frames. When enabled, heartbeating
 *  is handed internally internally by the library
 *
 * \param [in,out] state the connection object
 * \param [out] decoded_frame the frame
 * \param [in] tv the maximum time to wait for a frame to be read. Setting
 * tv->tv_sec = 0 and tv->tv_usec = 0 will do a non-blocking read. Specifying
 * NULL for tv will make the function block until a frame is read.
 * \return AMQP_STATUS_OK on success. An amqp_status_enum value is returned
 *  otherwise. Possible errors include:
 *  - AMQP_STATUS_TIMEOUT the timeout was reached while waiting for a frame
 *    from the broker.
 *  - AMQP_STATUS_INVALID_PARAMETER the tv parameter contains an invalid value.
 *  - AMQP_STATUS_NO_MEMORY failure in allocating memory. The library is likely in
 *    an indeterminate state making recovery unlikely. Client should note the error
 *    and terminate the application
 *  - AMQP_STATUS_BAD_AMQP_DATA bad AMQP data was received. The connection
 *    should be shutdown immediately
 *  - AMQP_STATUS_UNKNOWN_METHOD: an unknown method was received from the
 *    broker. This is likely a protocol error and the connection should be
 *    shutdown immediately
 *  - AMQP_STATUS_UNKNOWN_CLASS: a properties frame with an unknown class
 *    was received from the broker. This is likely a protocol error and the
 *    connection should be shutdown immediately
 *  - AMQP_STATUS_HEARTBEAT_TIMEOUT timed out while waiting for heartbeat
 *    from the broker. The connection has been closed.
 *  - AMQP_STATUS_TIMER_FAILURE system timer indicated failure.
 *  - AMQP_STATUS_SOCKET_ERROR a socket error occurred. The connection has
 *    been closed
 *  - AMQP_STATUS_SSL_ERROR a SSL socket error occurred. The connection has
 *    been closed.
 *
 * \sa amqp_simple_wait_frame() amqp_frames_enqueued() amqp_data_in_buffer()
 *
 * \since v0.4.0
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_simple_wait_frame_noblock(amqp_connection_state_t state,
                                         amqp_frame_t *decoded_frame,
                                          timeval *tv);

(**
 * Waits for a specific method from the broker
 *
 * \warning You probably don't want to use this function. If this function
 *  doesn't receive exactly the frame requested it closes the whole connection.
 *
 * Waits for a single method on a channel from the broker.
 * If a frame is received that does not match expected_channel
 * or expected_method the program will abort
 *
 * \param [in] state the connection object
 * \param [in] expected_channel the channel that the method should be delivered on
 * \param [in] expected_method the method to wait for
 * \param [out] output the method
 * \returns AMQP_STATUS_OK on success. An amqp_status_enum value is returned
 *  otherwise. Possible errors include:
 *  - AMQP_STATUS_WRONG_METHOD a frame containing the wrong method, wrong frame
 *    type or wrong channel was received. The connection is closed.
 *  - AMQP_STATUS_NO_MEMORY failure in allocating memory. The library is likely in
 *    an indeterminate state making recovery unlikely. Client should note the error
 *    and terminate the application
 *  - AMQP_STATUS_BAD_AMQP_DATA bad AMQP data was received. The connection
 *    should be shutdown immediately
 *  - AMQP_STATUS_UNKNOWN_METHOD: an unknown method was received from the
 *    broker. This is likely a protocol error and the connection should be
 *    shutdown immediately
 *  - AMQP_STATUS_UNKNOWN_CLASS: a properties frame with an unknown class
 *    was received from the broker. This is likely a protocol error and the
 *    connection should be shutdown immediately
 *  - AMQP_STATUS_HEARTBEAT_TIMEOUT timed out while waiting for heartbeat
 *    from the broker. The connection has been closed.
 *  - AMQP_STATUS_TIMER_FAILURE system timer indicated failure.
 *  - AMQP_STATUS_SOCKET_ERROR a socket error occurred. The connection has
 *    been closed
 *  - AMQP_STATUS_SSL_ERROR a SSL socket error occurred. The connection has
 *    been closed.
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_simple_wait_method(amqp_connection_state_t state,
                                  amqp_channel_t expected_channel,
                                  amqp_method_number_t expected_method,
                                  amqp_method_t *output);

(**
 * Sends a method to the broker
 *
 * This is a thin wrapper around amqp_send_frame(), providing a way to send
 * a method to the broker on a specified channel.
 *
 * \param [in] state the connection object
 * \param [in] channel the channel object
 * \param [in] id the method number
 * \param [in] decoded the method object
 * \returns AMQP_STATUS_OK on success, an amqp_status_enum value otherwise.
 *  Possible errors include:
 *  - AMQP_STATUS_BAD_AMQP_DATA the serialized form of the method or
 *    properties was too large to fit in a single AMQP frame, or the
 *    method contains an invalid value. The frame was not sent.
 *  - AMQP_STATUS_TABLE_TOO_BIG the serialized form of an amqp_table_t is
 *    too large to fit in a single AMQP frame. Frame was not sent.
 *  - AMQP_STATUS_UNKNOWN_METHOD an invalid method type was passed in
 *  - AMQP_STATUS_UNKNOWN_CLASS an invalid properties type was passed in
 *  - AMQP_STATUS_TIMER_FAILURE system timer indicated failure. The frame
 *    was sent
 *  - AMQP_STATUS_SOCKET_ERROR
 *  - AMQP_STATUS_SSL_ERROR
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_send_method(amqp_connection_state_t state,
                           amqp_channel_t channel,
                           amqp_method_number_t id,
                           Pointer decoded);

 (*
 * Sends a method to the broker and waits for a method response
 *
 * \param [in] state the connection object
 * \param [in] channel the channel object
 * \param [in] request_id the method number of the request
 * \param [in] expected_reply_ids a 0 terminated array of expected response
 *             method numbers
 * \param [in] decoded_request_method the method to be sent to the broker
 * \return a amqp_rpc_reply_t:
 *  - r.reply_type == AMQP_RESPONSE_NORMAL. RPC completed successfully
 *  - r.reply_type == AMQP_RESPONSE_SERVER_EXCEPTION. The broker returned an
 *    exception:
 *    - If r.reply.id == AMQP_CHANNEL_CLOSE_METHOD a channel exception
 *      occurred, cast r.reply.decoded to amqp_channel_close_t* to see details
 *      of the exception. The client should amqp_send_method() a
 *      amqp_channel_close_ok_t. The channel must be re-opened before it
 *      can be used again. Any resources associated with the channel
 *      (auto-delete exchanges, auto-delete queues, consumers) are invalid
 *      and must be recreated before attempting to use them again.
 *    - If r.reply.id == AMQP_CONNECTION_CLOSE_METHOD a connection exception
 *      occurred, cast r.reply.decoded to amqp_connection_close_t* to see
 *      details of the exception. The client amqp_send_method() a
 *      amqp_connection_close_ok_t and disconnect from the broker.
 *  - r.reply_type == AMQP_RESPONSE_LIBRARY_EXCEPTION. An exception occurred
 *    within the library. Examine r.library_error and compare it against
 *    amqp_status_enum values to determine the error.
 *
 * \sa amqp_simple_rpc_decoded()
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
amqp_rpc_reply_t
AMQP_CALL amqp_simple_rpc(amqp_connection_state_t state,
                          amqp_channel_t channel,
                          amqp_method_number_t request_id,
                          amqp_method_number_t *expected_reply_ids,
                          Pointer decoded_request_method);

(**
 * Sends a method to the broker and waits for a method response
 *
 * \param [in] state the connection object
 * \param [in] channel the channel object
 * \param [in] request_id the method number of the request
 * \param [in] reply_id the method number expected in response
 * \param [in] decoded_request_method the request method
 * \return a pointer to the method returned from the broker, or NULL on error.
 *  On error amqp_get_rpc_reply() will return an amqp_rpc_reply_t with
 *  details on the error that occurred.
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Pointer
AMQP_CALL amqp_simple_rpc_decoded(amqp_connection_state_t state,
                                  amqp_channel_t channel,
                                  amqp_method_number_t request_id,
                                  amqp_method_number_t reply_id,
                                  Pointer decoded_request_method);

(**
 * Get the last global amqp_rpc_reply
 *
 * The API methods corresponding to most synchronous AMQP methods
 * return a pointer to the decoded method result.  Upon error, they
 * return NULL, and we need some way of discovering what, if anything,
 * went wrong. amqp_get_rpc_reply() returns the most recent
 * amqp_rpc_reply_t instance corresponding to such an API operation
 * for the given connection.
 *
 * Only use it for operations that do not themselves return
 * amqp_rpc_reply_t; operations that do return amqp_rpc_reply_t
 * generally do NOT update this per-connection-global amqp_rpc_reply_t
 * instance.
 *
 * \param [in] state the connection object
 * \return the most recent amqp_rpc_reply_t:
 *  - r.reply_type == AMQP_RESPONSE_NORMAL. RPC completed successfully
 *  - r.reply_type == AMQP_RESPONSE_SERVER_EXCEPTION. The broker returned an
 *    exception:
 *    - If r.reply.id == AMQP_CHANNEL_CLOSE_METHOD a channel exception
 *      occurred, cast r.reply.decoded to amqp_channel_close_t* to see details
 *      of the exception. The client should amqp_send_method() a
 *      amqp_channel_close_ok_t. The channel must be re-opened before it
 *      can be used again. Any resources associated with the channel
 *      (auto-delete exchanges, auto-delete queues, consumers) are invalid
 *      and must be recreated before attempting to use them again.
 *    - If r.reply.id == AMQP_CONNECTION_CLOSE_METHOD a connection exception
 *      occurred, cast r.reply.decoded to amqp_connection_close_t* to see
 *      details of the exception. The client amqp_send_method() a
 *      amqp_connection_close_ok_t and disconnect from the broker.
 *  - r.reply_type == AMQP_RESPONSE_LIBRARY_EXCEPTION. An exception occurred
 *    within the library. Examine r.library_error and compare it against
 *    amqp_status_enum values to determine the error.
 *
 * \sa amqp_simple_rpc_decoded()
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
amqp_rpc_reply_t
AMQP_CALL amqp_get_rpc_reply(amqp_connection_state_t state);

(**
 * Login to the broker
 *
 * After using amqp_open_socket and amqp_set_sockfd, call
 * amqp_login to complete connecting to the broker
 *
 * \param [in] state the connection object
 * \param [in] vhost the virtual host to connect to on the broker. The default
 *              on most brokers is "/"
 * \param [in] channel_max the limit for number of channels for the connection.
 *              0 means no limit, and is a good default (AMQP_DEFAULT_MAX_CHANNELS)
 *              Note that the maximum number of channels the protocol supports
 *              is 65535 (2^16, with the 0-channel reserved). The server can
 *              set a lower channel_max and then the client will use the lowest
 *              of the two
 * \param [in] frame_max the maximum size of an AMQP frame on the wire to
 *              request of the broker for this connection. 4096 is the minimum
 *              size, 2^31-1 is the maximum, a good default is 131072 (128KB), or
 *              AMQP_DEFAULT_FRAME_SIZE
 * \param [in] heartbeat the number of seconds between heartbeat frames to
 *              request of the broker. A value of 0 disables heartbeats.
 *              Note rabbitmq-c only has partial support for heartbeats, as of
 *              v0.4.0 they are only serviced during amqp_basic_publish() and
 *              amqp_simple_wait_frame()/amqp_simple_wait_frame_noblock()
 * \param [in] sasl_method the SASL method to authenticate with the broker.
 *              followed by the authentication information.
 *              For AMQP_SASL_METHOD_PLAIN, the AMQP_SASL_METHOD_PLAIN
 *              should be followed by two arguments in this order:
 *              const char* username, and const char* password.
 * \return amqp_rpc_reply_t indicating success or failure.
 *  - r.reply_type == AMQP_RESPONSE_NORMAL. Login completed successfully
 *  - r.reply_type == AMQP_RESPONSE_LIBRARY_EXCEPTION. In most cases errors
 *    from the broker when logging in will be represented by the broker closing
 *    the socket. In this case r.library_error will be set to
 *    AMQP_STATUS_CONNECTION_CLOSED. This error can represent a number of
 *    error conditions including: invalid vhost, authentication failure.
 *  - r.reply_type == AMQP_RESPONSE_SERVER_EXCEPTION. The broker returned an
 *    exception:
 *    - If r.reply.id == AMQP_CHANNEL_CLOSE_METHOD a channel exception
 *      occurred, cast r.reply.decoded to amqp_channel_close_t* to see details
 *      of the exception. The client should amqp_send_method() a
 *      amqp_channel_close_ok_t. The channel must be re-opened before it
 *      can be used again. Any resources associated with the channel
 *      (auto-delete exchanges, auto-delete queues, consumers) are invalid
 *      and must be recreated before attempting to use them again.
 *    - If r.reply.id == AMQP_CONNECTION_CLOSE_METHOD a connection exception
 *      occurred, cast r.reply.decoded to amqp_connection_close_t* to see
 *      details of the exception. The client amqp_send_method() a
 *      amqp_connection_close_ok_t and disconnect from the broker.
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
amqp_rpc_reply_t
AMQP_CALL amqp_login(amqp_connection_state_t state, PChar vhost,
                     Integer channel_max, Integer frame_max, Integer heartbeat,
                     amqp_sasl_method_const sasl_method	= 0; Args: array of const


(**
 * Login to the broker passing a properties table
 *
 * This function is similar to amqp_login() and differs in that it provides a
 * way to pass client properties to the broker. This is commonly used to
 * negotiate newer protocol features as they are supported by the broker.
 *
 * \param [in] state the connection object
 * \param [in] vhost the virtual host to connect to on the broker. The default
 *              on most brokers is "/"
 * \param [in] channel_max the limit for the number of channels for the connection.
 *             0 means no limit, and is a good default (AMQP_DEFAULT_MAX_CHANNELS)
 *             Note that the maximum number of channels the protocol supports
 *             is 65535 (2^16, with the 0-channel reserved). The server can
 *             set a lower channel_max and then the client will use the lowest
 *             of the two
 * \param [in] frame_max the maximum size of an AMQP frame ont he wire to
 *              request of the broker for this connection. 4096 is the minimum
 *              size, 2^31-1 is the maximum, a good default is 131072 (128KB), or
 *              AMQP_DEFAULT_FRAME_SIZE
 * \param [in] heartbeat the number of seconds between heartbeat frame to
 *             request of the broker. A value of 0 disables heartbeats.
 *             Note rabbitmq-c only has partial support for hearts, as of
 *             v0.4.0 heartbeats are only serviced during amqp_basic_publish(),
 *             and amqp_simple_wait_frame()/amqp_simple_wait_frame_noblock()
 * \param [in] properties a table of properties to send the broker.
 * \param [in] sasl_method the SASL method to authenticate with the broker
 *             followed by the authentication information.
 *             For AMQP_SASL_METHOD_PLAN, the AMQP_SASL_METHOD_PLAIN parameter
 *             should be followed by two arguments in this order:
 *             const char* username, and const char* password.
 * \return amqp_rpc_reply_t indicating success or failure.
 *  - r.reply_type == AMQP_RESPONSE_NORMAL. Login completed successfully
 *  - r.reply_type == AMQP_RESPONSE_LIBRARY_EXCEPTION. In most cases errors
 *    from the broker when logging in will be represented by the broker closing
 *    the socket. In this case r.library_error will be set to
 *    AMQP_STATUS_CONNECTION_CLOSED. This error can represent a number of
 *    error conditions including: invalid vhost, authentication failure.
 *  - r.reply_type == AMQP_RESPONSE_SERVER_EXCEPTION. The broker returned an
 *    exception:
 *    - If r.reply.id == AMQP_CHANNEL_CLOSE_METHOD a channel exception
 *      occurred, cast r.reply.decoded to amqp_channel_close_t* to see details
 *      of the exception. The client should amqp_send_method() a
 *      amqp_channel_close_ok_t. The channel must be re-opened before it
 *      can be used again. Any resources associated with the channel
 *      (auto-delete exchanges, auto-delete queues, consumers) are invalid
 *      and must be recreated before attempting to use them again.
 *    - If r.reply.id == AMQP_CONNECTION_CLOSE_METHOD a connection exception
 *      occurred, cast r.reply.decoded to amqp_connection_close_t* to see
 *      details of the exception. The client amqp_send_method() a
 *      amqp_connection_close_ok_t and disconnect from the broker.
 *
 * \since v0.4.0
 *)

AMQP_PUBLIC_FUNCTION
amqp_rpc_reply_t
AMQP_CALL amqp_login_with_function (state: amqp_connection_state_t; channel: amqp_channel_t; v3: ;
exchange: amqp_bytes_t; routing_key: amqp_bytes_t; v6: ;
 mandatory: amqp_boolean_t; immediate: amqp_boolean_t; v9: ;
 var properties: amqp_basic_properties_t_; v11: ; v12: ; body: amqp_bytes_t): properties;

 (**
 * Publish a message to the broker
 *
 * Publish a message on an exchange with a routing key.
 *
 * Note that at the AMQ protocol level basic.publish is an async method:
 * this means error conditions that occur on the broker (such as publishing to
 * a non-existent exchange) will not be reflected in the return value of this
 * function.
 *
 * \param [in] state the connection object
 * \param [in] channel the channel identifier
 * \param [in] exchange the exchange on the broker to publish to
 * \param [in] routing_key the routing key to use when publishing the message
 * \param [in] mandatory indicate to the broker that the message MUST be routed
 *              to a queue. If the broker cannot do this it should respond with
 *              a basic.return method.
 * \param [in] immediate indicate to the broker that the message MUST be delivered
 *              to a consumer immediately. If the broker cannot do this it should
 *              response with a basic.return method.
 * \param [in] properties the properties associated with the message
 * \param [in] body the message body
 * \return AMQP_STATUS_OK on success, amqp_status_enum value on failure. Note
 *         that basic.publish is an async method, the return value from this
 *         function only indicates that the message data was successfully
 *         transmitted to the broker. It does not indicate failures that occur
 *         on the broker, such as publishing to a non-existent exchange.
 *         Possible error values:
 *         - AMQP_STATUS_TIMER_FAILURE: system timer facility returned an error
 *           the message was not sent.
 *         - AMQP_STATUS_HEARTBEAT_TIMEOUT: connection timed out waiting for a
 *           heartbeat from the broker. The message was not sent.
 *         - AMQP_STATUS_NO_MEMORY: memory allocation failed. The message was
 *           not sent.
 *         - AMQP_STATUS_TABLE_TOO_BIG: a table in the properties was too large
 *           to fit in a single frame. Message was not sent.
 *         - AMQP_STATUS_CONNECTION_CLOSED: the connection was closed.
 *         - AMQP_STATUS_SSL_ERROR: a SSL error occurred.
 *         - AMQP_STATUS_TCP_ERROR: a TCP error occurred. errno or
 *           WSAGetLastError() may provide more information
 *
 * Note: this function does heartbeat processing as of v0.4.0
 *
 * \since v0.1
 *)

 (**
 * Closes an channel
 *
 * \param [in] state the connection object
 * \param [in] channel the channel identifier
 * \param [in] code the reason for closing the channel, AMQP_REPLY_SUCCESS is a good default
 * \return amqp_rpc_reply_t indicating success or failure
 *
 * \since v0.1
 *)
AMQP_PUBLIC_FUNCTION
amqp_rpc_reply_t
AMQP_CALL amqp_channel_close(amqp_connection_state_t state, amqp_channel_t channel,
                             Integer code);

 (**
 * Closes the entire connection
 *
 * Implicitly closes all channels and informs the broker the connection
 * is being closed, after receiving acknowldgement from the broker it closes
 * the socket.
 *
 * \param [in] state the connection object
 * \param [in] code the reason code for closing the connection. AMQP_REPLY_SUCCESS is a good default.
 * \return amqp_rpc_reply_t indicating the result
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
amqp_rpc_reply_t
AMQP_CALL amqp_connection_close(amqp_connection_state_t state, Integer code);

(**
 * Acknowledges a message
 *
 * Does a basic.ack on a received message
 *
 * \param [in] state the connection object
 * \param [in] channel the channel identifier
 * \param [in] delivery_tag the delivery tag of the message to be ack'd
 * \param [in] multiple if true, ack all messages up to this delivery tag, if
 *              false ack only this delivery tag
 * \return 0 on success,  0 > on failing to send the ack to the broker.
 *            this will not indicate failure if something goes wrong on the broker
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_basic_ack(amqp_connection_state_t state, amqp_channel_t channel,
                         uint64_t delivery_tag, amqp_boolean_t multiple);

(**
 * Do a basic.get
 *
 * Synchonously polls the broker for a message in a queue, and
 * retrieves the message if a message is in the queue.
 *
 * \param [in] state the connection object
 * \param [in] channel the channel identifier to use
 * \param [in] queue the queue name to retrieve from
 * \param [in] no_ack if true the message is automatically ack'ed
 *              if false amqp_basic_ack should be called once the message
 *              retrieved has been processed
 * \return amqp_rpc_reply indicating success or failure
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
amqp_rpc_reply_t
AMQP_CALL amqp_basic_get(amqp_connection_state_t state, amqp_channel_t channel,
                         amqp_bytes_t queue, amqp_boolean_t no_ack);

 (**
 * Do a basic.reject
 *
 * Actively reject a message that has been delivered
 *
 * \param [in] state the connection object
 * \param [in] channel the channel identifier
 * \param [in] delivery_tag the delivery tag of the message to reject
 * \param [in] requeue indicate to the broker whether it should requeue the
 *              message or just discard it.
 * \return 0 on success, 0 > on failing to send the reject method to the broker.
 *          This will not indicate failure if something goes wrong on the broker.
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_basic_reject(amqp_connection_state_t state, amqp_channel_t channel,
                            uint64_t delivery_tag, amqp_boolean_t requeue);

  (**
 * Do a basic.nack
 *
 * Actively reject a message, this has the same effect as amqp_basic_reject()
 * however, amqp_basic_nack() can negatively acknowledge multiple messages with
 * one call much like amqp_basic_ack() can acknowledge mutliple messages with
 * one call.
 *
 * \param [in] state the connection object
 * \param [in] channel the channel identifier
 * \param [in] delivery_tag the delivery tag of the message to reject
 * \param [in] multiple if set to 1 negatively acknowledge all unacknowledged
 *              messages on this channel.
 * \param [in] requeue indicate to the broker whether it should requeue the
 *              message or dead-letter it.
 * \return AMQP_STATUS_OK on success, an amqp_status_enum value otherwise.
 *
 * \since v0.5.0
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_basic_nack(amqp_connection_state_t state, amqp_channel_t channel,
                          uint64_t delivery_tag, amqp_boolean_t multiple,
                          amqp_boolean_t requeue);

(**
 * Check to see if there is data left in the receive buffer
 *
 * Can be used to see if there is data still in the buffer, if so
 * calling amqp_simple_wait_frame will not immediately enter a
 * blocking read.
 *
 * \param [in] state the connection object
 * \return true if there is data in the recieve buffer, false otherwise
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
amqp_boolean_t
AMQP_CALL amqp_data_in_buffer(amqp_connection_state_t state);

(**
 * Get the error string for the given error code.
 *
 * \deprecated This function has been deprecated in favor of
 *  \ref amqp_error_string2() which returns statically allocated
 *  string which do not need to be freed by the caller.
 *
 * The returned string resides on the heap; the caller is responsible
 * for freeing it.
 *
 * \param [in] err return error code
 * \return the error string
 *
 * \since v0.1
 *)

AMQP_DEPRECATED(
  AMQP_PUBLIC_FUNCTION
  PChar
  AMQP_CALL amqp_error_string(Integer err)
);

(**
 * Get the error string for the given error code.
 *
 * Get an error string associated with an error code. The string is statically
 * allocated and does not need to be freed
 *
 * \param [in] err the error code
 * \return the error string
 *
 * \since v0.4.0
 *)

AMQP_PUBLIC_FUNCTION
 PChar

AMQP_CALL amqp_error_string2(Integer err);

(**
 * Deserialize an amqp_table_t from AMQP wireformat
 *
 * This is an internal function and is not typically used by
 * client applications
 *
 * \param [in] encoded the buffer containing the serialized data
 * \param [in] pool memory pool used to allocate the table entries from
 * \param [in] output the amqp_table_t structure to fill in. Any existing
 *             entries will be erased
 * \param [in,out] offset The offset into the encoded buffer to start
 *                 reading the serialized table. It will be updated
 *                 by this function to end of the table
 * \return AMQP_STATUS_OK on success, an amqp_status_enum value on failure
 *  Possible error codes:
 *  - AMQP_STATUS_NO_MEMORY out of memory
 *  - AMQP_STATUS_BAD_AMQP_DATA invalid wireformat
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_decode_table(amqp_bytes_t encoded, amqp_pool_t *pool,
                            amqp_table_t *output, size_t *offset);


(**
 * Serializes an amqp_table_t to the AMQP wireformat
 *
 * This is an internal function and is not typically used by
 * client applications
 *
 * \param [in] encoded the buffer where to serialize the table to
 * \param [in] input the amqp_table_t to serialize
 * \param [in,out] offset The offset into the encoded buffer to start
 *                 writing the serialized table. It will be updated
 *                 by this function to where writing left off
 * \return AMQP_STATUS_OK on success, an amqp_status_enum value on failure
 *  Possible error codes:
 *  - AMQP_STATUS_TABLE_TOO_BIG the serialized form is too large for the
 *    buffer
 *  - AMQP_STATUS_BAD_AMQP_DATA invalid table
 *
 * \since v0.1
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_encode_table(amqp_bytes_t encoded, amqp_table_t *input, size_t *offset);

(**
 * Create a deep-copy of an amqp_table_t object
 *
 * Creates a deep-copy of an amqp_table_t object, using the provided pool
 * object to allocate the necessary memory. This memory can be freed later by
 * call recycle_amqp_pool(), or empty_amqp_pool()
 *
 * \param [in] original the table to copy
 * \param [in,out] clone the table to copy to
 * \param [in] pool the initialized memory pool to do allocations for the table
 *             from
 * \return AMQP_STATUS_OK on success, amqp_status_enum value on failure.
 *  Possible error values:
 *  - AMQP_STATUS_NO_MEMORY - memory allocation failure.
 *  - AMQP_STATUS_INVALID_PARAMETER - invalid table (e.g., no key name)
 *
 * \since v0.4.0
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_table_clone( amqp_table_t *original, amqp_table_t *clone, amqp_pool_t *pool);

(**
 * A message object
 *
 * \since v0.4.0
 *)

type;
{$EXTERNALSYM AMQP_EMPTY_BYTES}

	amqp_message_t_ = record
		properties: amqp_basic_properties_t;	(**< message properties *)
		body: amqp_bytes_t;	                  (**< message body *)
		pool: amqp_pool_t;	                  (**< pool used to allocate properties *)
	end;
	amqp_message_t = amqp_message_t_;
	{$EXTERNALSYM amqp_message_t}

(**
 * Reads the next message on a channel
 *
 * Reads a complete message (header + body) on a specified channel. This
 * function is intended to be used with amqp_basic_get() or when an
 * AMQP_BASIC_DELIVERY_METHOD method is received.
 *
 * \param [in,out] state the connection object
 * \param [in] channel the channel on which to read the message from
 * \param [in,out] message a pointer to a amqp_message_t object. Caller should
 *                 call amqp_message_destroy() when it is done using the
 *                 fields in the message object.  The caller is responsible for
 *                 allocating/destroying the amqp_message_t object itself.
 * \param [in] flags pass in 0. Currently unused.
 * \returns a amqp_rpc_reply_t object. ret.reply_type == AMQP_RESPONSE_NORMAL on success.
 *
 * \since v0.4.0
 *)

AMQP_PUBLIC_FUNCTION
amqp_rpc_reply_t
AMQP_CALL amqp_read_message(amqp_connection_state_t state,
                            amqp_channel_t channel,
                            amqp_message_t *message, Integer flags);

 (**
 * Frees memory associated with a amqp_message_t allocated in amqp_read_message
 *
 * \param [in] message
 *
 * \since v0.4.0
 *)

AMQP_PUBLIC_FUNCTION
procedure
AMQP_CALL amqp_destroy_message(var message: amqp_message_t);

(**
 * Envelope object
 *
 * \since v0.4.0
 *)

type
	amqp_envelope_t_ = record
		channel: amqp_channel_t;	       (**< channel message was delivered on *)
		consumer_tag: amqp_bytes_t;	     (**< the consumer tag the message was delivered to *)
		delivery_tag: uint64_t;	         (**< the messages delivery tag *)
		redelivered: amqp_boolean_t;	   (**< flag indicating whether this message is being redelivered *)
		exchange: amqp_bytes_t;	         (**< exchange this message was published to *)
		routing_key: amqp_bytes_t;	     (**< the routing key this message was published with *)
		message: amqp_message_t;	       (**< the message *)
	end;
	amqp_envelope_t = amqp_envelope_t_;
	{$EXTERNALSYM amqp_envelope_t}

 (**
 * Wait for and consume a message
 *
 * Waits for a basic.deliver method on any channel, upon receipt of
 * basic.deliver it reads that message, and returns. If any other method is
 * received before basic.deliver, this function will return an amqp_rpc_reply_t
 * with ret.reply_type == AMQP_RESPONSE_LIBRARY_EXCEPTION, and
 * ret.library_error == AMQP_STATUS_UNEXPECTED_FRAME. The caller should then
 * call amqp_simple_wait_frame() to read this frame and take appropriate action.
 *
 * This function should be used after starting a consumer with the
 * amqp_basic_consume() function
 *
 * \param [in,out] state the connection object
 * \param [in,out] envelope a pointer to a amqp_envelope_t object. Caller
 *                 should call #amqp_destroy_envelope() when it is done using
 *                 the fields in the envelope object. The caller is responsible
 *                 for allocating/destroying the amqp_envelope_t object itself.
 * \param [in] timeout a timeout to wait for a message delivery. Passing in
 *             NULL will result in blocking behavior.
 * \param [in] flags pass in 0. Currently unused.
 * \returns a amqp_rpc_reply_t object.  ret.reply_type == AMQP_RESPONSE_NORMAL
 *          on success. If ret.reply_type == AMQP_RESPONSE_LIBRARY_EXCEPTION, and
 *          ret.library_error == AMQP_STATUS_UNEXPECTED_FRAME, a frame other
 *          than AMQP_BASIC_DELIVER_METHOD was received, the caller should call
 *          amqp_simple_wait_frame() to read this frame and take appropriate
 *          action.
 *
 * \since v0.4.0
 *)

AMQP_PUBLIC_FUNCTION
amqp_rpc_reply_t
AMQP_CALL amqp_consume_message(amqp_connection_state_t state,
                               amqp_envelope_t *envelope,
                                timeval *timeout, Integer flags);

(**
 * Frees memory associated with a amqp_envelope_t allocated in amqp_consume_message()
 *
 * \param [in] envelope
 *
 * \since v0.4.0
 *)

AMQP_PUBLIC_FUNCTION
procedure
AMQP_CALL amqp_destroy_envelope(var envelope: amqp_envelope_t);

(**
 * Parameters used to connect to the RabbitMQ broker
 *
 * \since v0.2
 *)

type
	= record amqp_connection_info begin
  PChar user;                (**< the username to authenticate with the broker, default on most broker is 'guest' *)
  PChar password;            (**< the password to authenticate with the broker, default on most brokers is 'guest' *)
  PChar host;                (**< the hostname of the broker *)
  PChar vhost;               (**< the virtual host on the broker to connect to, a good default is "/" *)
  Integer port;              (**< the port that the broker is listening on, default on most brokers is 5672 *)
  amqp_boolean_t ssl;
end;amqp_connection_info

(**
 * Initialze an amqp_connection_info to default values
 *
 * The default values are:
 * - user: "guest"
 * - password: "guest"
 * - host: "localhost"
 * - vhost: "/"
 * - port: 5672
 *
 * \param [out] parsed the connection info to set defaults on
 *
 * \since v0.2
 *)

AMQP_PUBLIC_FUNCTION
procedure
AMQP_CALL amqp_default_connection_info(var parsed: amqp_connection_info);

(**
 * Parse a connection URL
 *
 * An amqp connection url takes the form:
 *
 * amqp://[$USERNAME[:$PASSWORD]\@]$HOST[:$PORT]/[$VHOST]
 *
 * Examples:
 *  amqp://guest:guest\@localhost:5672//
 *  amqp://guest:guest\@localhost/myvhost
 *
 *  Any missing parts of the URL will be set to the defaults specified in
 *  amqp_default_connection_info. For amqps: URLs the default port will be set
 *  to 5671 instead of 5672 for non-SSL URLs.
 *
 * \note This function modifies url parameter.
 *
 * \param [in] url URI to parse, note that this parameter is modified by the
 *             function.
 * \param [out] parsed the connection info gleaned from the URI. The char*
 *              members will point to parts of the url input parameter.
 *              Memory management will depend on how the url is allocated.
 * \returns AMQP_STATUS_OK on success, AMQP_STATUS_BAD_URL on failure
 *
 * \since v0.2
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL amqp_parse_url(char *url,  amqp_connection_info *parsed);

(* socket API */

/**
 * Open a socket connection.
 *
 * This function opens a socket connection returned from amqp_tcp_socket_new()
 * or amqp_ssl_socket_new(). This function should be called after setting
 * socket options and prior to assigning the socket to an AMQP connection with
 * amqp_set_socket().
 *
 * \param [in,out] self A socket object.
 * \param [in] host Connect to this host.
 * \param [in] port Connect on this remote port.
 *
 * \return AMQP_STATUS_OK on success, an amqp_status_enum on failure
 *
 * \since v0.4.0
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL
amqp_socket_open(amqp_socket_t *self,  PChar host, Integer port);

(**
 * Open a socket connection.
 *
 * This function opens a socket connection returned from amqp_tcp_socket_new()
 * or amqp_ssl_socket_new(). This function should be called after setting
 * socket options and prior to assigning the socket to an AMQP connection with
 * amqp_set_socket().
 *
 * \param [in,out] self A socket object.
 * \param [in] host Connect to this host.
 * \param [in] port Connect on this remote port.
 * \param [in] timeout Max allowed time to spent on opening. If NULL - run in blocking mode
 *
 * \return AMQP_STATUS_OK on success, an amqp_status_enum on failure.
 *
 * \since v0.4.0
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL
amqp_socket_open_noblock(amqp_socket_t *self,  PChar host, Integer port,  timeval *timeout);

(**
 * Get the socket descriptor in use by a socket object.
 *
 * Retrieve the underlying socket descriptor. This function can be used to
 * perform low-level socket operations that aren't supported by the socket
 * interface. Use with caution!
 *
 * \param [in,out] self A socket object.
 *
 * \return The underlying socket descriptor, or -1 if there is no socket descriptor
 *  associated with
 *  with
 *
 * \since v0.4.0
 *)

AMQP_PUBLIC_FUNCTION
Integer
AMQP_CALL
amqp_socket_get_sockfd(amqp_socket_t *self);

(**
 * Get the socket object associated with a amqp_connection_state_t
 *
 * \param [in] state the connection object to get the socket from
 * \return a pointer to the socket object, or NULL if one has not been assigned
 *
 * \since v0.4.0
 *)

AMQP_PUBLIC_FUNCTION
amqp_socket_t *
amqp_get_socket(amqp_connection_state_t state);

(**
 * Get the broker properties table
 *
 * \param [in] state the connection object
 * \return a pointer to an amqp_table_t containing the properties advertised
 *  by the broker on connection. The connection object owns the table, it
 *  should not be modified.
 *
 * \since v0.5.0
 *)

AMQP_PUBLIC_FUNCTION
amqp_table_t *
amqp_get_server_function (state: amqp_connection_state_t): properties;

 (**
 * Get the client properties table
 *
 * Get the properties that were passed to the broker on connection.
 *
 * \param [in] state the connection object
 * \return a pointer to an amqp_table_t containing the properties advertised
 *  by the client on connection. The connection object owns the table, it
 *  should not be modified.
 *
 * \since v0.7.0
 *)

AMQP_PUBLIC_FUNCTION
amqp_table_t *
amqp_get_client_function (state: amqp_connection_state_t): properties;

AMQP_END_DECLS


{$endif}

   (* AMQP_H *)



end.
