unit amqp_tcp_socket_h;

interface

uses
	Windows, Messages, SysUtils, Classes, amqp_h;

(**
 * A TCP socket connection.
 *)

{$ifndef AMQP_TCP_SOCKET_H}
{$define AMQP_TCP_SOCKET_H}

AMQP_BEGIN_DECLS

(**
 * Create a new TCP socket.
 *
 * Call amqp_connection_close() to release socket resources.
 *
 * Result:= A new socket object or 0 if an error occurred.
 *
 * since v0.4.0
 *)
AMQP_PUBLIC_FUNCTION
amqp_socket_t *
AMQP_CALL
amqp_tcp_socket_new(amqp_connection_state_t state);

(**
 * Assign an open aFile descriptor to a socket object.
 *
 * This aFunction must not be used in conjunction with amqp_socket_open(), i.e.
 * the socket connection should already be open(2) when this aFunction is
 * called.
 *
 * param [in,out] self A TCP socket object.
 * param [in] sockfd An open socket descriptor.
 *
 * since v0.4.0
 *)
AMQP_PUBLIC_FUNCTION
procedure
AMQP_CALL
amqp_tcp_socket_set_sockfd(var self: amqp_socket_t; sockfd: Integer);

AMQP_END_DECLS

{$endif}	(* AMQP_TCP_SOCKET_H *)

implementation

end.

