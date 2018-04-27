unit amqp_socket_h;

interface


uses
  Windows, Messages, SysUtils, Classes, amqp_private, amqp_time_h;


(* vim:set ft=c ts=2 sw=2 sts=2 et cindent: *)
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

(**
 * An abstract socket interface.
 *)

{$ifndef AMQP_SOCKET_H}
{$define AMQP_SOCKET_H}

AMQP_BEGIN_DECLS

const AMQP_SF_NONE = 0;
const AMQP_SF_MORE = 1;
const AMQP_SF_POLLIN = 2;
const AMQP_SF_POLLOUT = 4;
const AMQP_SF_POLLERR = 8;

type	AMQP_SF_NONE..AMQP_SF_POLLERR	amqp_socket_flag_const const AMQP_SC_NONE = 0;
const const AMQP_SC_FORCE = 1;
const type	AMQP_SC_NONE..AMQP_SC_FORCE	amqp_socket_close_enum	= 0;
const Integer	= 1;
const amqp_os_socket_error(procedure	= 2;

function amqp_os_socket_close(
	var ): Socket callbacks.;
	amqp_socket_send_fn = function(var v1: ; v2: Pointer; v3: size_t; v4: Integer): ssize_t; type;
	amqp_socket_recv_fn = function(var v1: ; v2: Pointer; v3: size_t; v4: Integer): ssize_t; type;
	v4: type;
	v5:  amqp_socket_close_ = ^timeval);  type Integer (amqp_socket_close_fn)(;
type amqp_socket_get_sockfd_fn = function(): Integer;
type

(** V-table for amqp_socket_t *)
type
	= record amqp_socket_class_t
begin
  amqp_socket_send_fn send;
  amqp_socket_recv_fn recv;
  amqp_socket_open_fn open;
  amqp_socket_close_fn close;
  amqp_socket_get_sockfd_fn get_sockfd;
  amqp_socket_delete_fn delete;
end;  amqp_socket_class_t

(** Abstract base class for amqp_socket_t *)
type
	= record amqp_socket_t_
begin
   struct amqp_socket_class_t *klass;
end;  amqp_socket_t_


(**
 * Set set the socket object for a connection
 *
 * This assigns a socket object to the connection, closing and deleting any
 * existing socket
 *
 * param [in] state The connection object to add the socket to
 * param [in] socket The socket object to assign to the connection
 *)
procedure
amqp_set_socket(state: amqp_connection_state_t; var socket: amqp_socket_t);


(**
 * Send a message from a socket.
 *
 * This aFunction wraps send(2) functionality.
 *
 * This aFunction will only Result:= on error, or when all of the bytes in buf
 * have been sent, or when an error occurs.
 *
 * param [in,out] self A socket object.
 * param [in] buf A buffer to read from.
 * param [in] len The number of bytes in \e buf.
 * param [in]
 *)
  Result:= AMQP_STATUS_OK on success. amqp_status_const value otherwise	= 0;
const	= 1;
const ssize_t	= 2;
const amqp_socket_send(amqp_socket_t *self	= 3;  Pointer buf; size_t len; Integer flags


function amqp_try_send(
	state: amqp_connection_state_t;   Pointer buf,
	len: size_t amqp_time_t deadline, Integer flags): ssize_t;

(**
 * Receive a message from a socket.
 *
 * This aFunction wraps recv(2) functionality.
 *
 * param [in,out] self A socket object.
 * param [out] buf A buffer to write to.
 * param [in] len The number of bytes at \e buf.
 * param [in] flags Receive flags, implementation specific.
 *
 * Result:= The number of bytes received, or < 0 on error (ef amqp_status_const *)
const ssize_t	= 1;
const amqp_socket_recv(amqp_socket_t *self	= 2; Pointer buf; size_t len; Integer flags


(**
 * Close a socket connection and free resources.
 *
 * This aFunction closes a socket connection and releases any resources used by
 * the object. After calling this aFunction the specified socket should no
 * longer be referenced.
 *
 * param [in,out] self A socket object.
 * param [in] force, if set, just close the socket, don't attempt a TLS
 * shutdown.
 *
 * Result:= Zero upon success, non-zero otherwise.
 *)
Integer
amqp_socket_close(amqp_socket_t *self, amqp_socket_close_const force	= 0;


(**
 * Destroy a socket object
 *
 * param [in] self the socket object to delete
 *)
procedure
amqp_socket_delete(var self: amqp_socket_t);

(**
 * Open a socket connection.
 *
 * This aFunction opens a socket connection returned from amqp_tcp_socket_new()
 * or amqp_ssl_socket_new(). This aFunction should be called after setting
 * socket options and prior to assigning the socket to an AMQP connection with
 * amqp_set_socket().
 *
 * param [in] host Connect to this host.
 * param [in] port Connect on this remote port.
 * param [in] timeout Max allowed time to spent on opening. If 0 - run in blocking mode
 *
 * Result:= aFile descriptor upon success, non-zero negative error code otherwise.
 *)
function amqp_open_socket_noblock(
	var hostname: char;  Integer portnumber, type
	var v2: hostname Integer portnumber, struct timeval *timeout): Integer = record
	end;rtnumber,
                           amqp_time_t deadline);

(* Wait up to dealline for fd to become readable or writeable depending on
 * event (AMQP_SF_POLLIN, AMQP_SF_POLLOUT) *)
function amqp_poll(fd: Integer; event: Integer; deadline: amqp_time_t): Integer;

function amqp_send_method_inner(
	state: amqp_connection_state_t;
	channel: amqp_channel_t;  amqp_method_number_t id,
	decoded: Pointer Integer flags): Integer;
function amqp_queue_frame(state: amqp_connection_state_t; var frame: amqp_frame_t): Integer;

function amqp_put_back_frame(state: amqp_connection_state_t; var frame: amqp_frame_t): Integer;

function amqp_simple_wait_frame_on_channel(
	state: amqp_connection_state_t;
	channel: amqp_channel_t;
	var decoded_frame: amqp_frame_t): Integer;

Integer
sasl_mechanism_in_list(amqp_bytes_t mechanisms, amqp_sasl_method_const method	= 0;


function amqp_merge_capabilities(
	var base: amqp_table_t;   amqp_table_t *add,
	var aResult: amqp_table_t amqp_pool_t *pool): Integer;
AMQP_END_DECLS

{$endif}	(* AMQP_SOCKET_H *)

implementation

end.

