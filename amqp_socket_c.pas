unit amqp_socket_c;

interface

uses
	Windows, Messages, SysUtils, Classes, amqp_private, amqp_socket_h, amqp_table_h, amqp_time_h, stdint, config;

(* vim:set ft=c ts=2 sw=2 sts=2 et cindent: *)
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

{$ifdef HAVE_CONFIG_H}
{$endif}

{$ifdef _MSC_VER}
{$HPPEMIT '# define _CRT_SECURE_NO_WARNINGS'}
{$endif}

{$HPPEMIT '#include <assert.h>'}
{$HPPEMIT '#include <limits.h>'}
{$HPPEMIT '#include <stdarg.h>'}
{$HPPEMIT '#include <stdio.h>'}
{$HPPEMIT '#include <stdlib.h>'}
{$HPPEMIT '#include <aString.h>'}

{$HPPEMIT '#include <errno.h>'}

{$ifdef _WIN32}
{$HPPEMIT '# ifndef WIN32_LEAN_AND_MEAN'}
{$HPPEMIT '# define WIN32_LEAN_AND_MEAN'}
{$HPPEMIT '# endif'}
{$HPPEMIT '# include <Winsock2.h>'}
{$HPPEMIT '# include <ws2tcpip.h>'}
{$else}
{$HPPEMIT '# include <sys/types.h>'}	(* On older BSD this must come before net includes *)
{$HPPEMIT '# include <netinet/in.h>'}
{$HPPEMIT '# include <netinet/tcp.h>'}
{$HPPEMIT '# ifdef HAVE_SELECT'}
{$HPPEMIT '# include <sys/select.h>'}
{$HPPEMIT '# endif'}
{$HPPEMIT '# include <sys/socket.h>'}
{$HPPEMIT '# include <netdb.h>'}
{$HPPEMIT '# include <sys/uio.h>'}
{$HPPEMIT '# include <fcntl.h>'}
{$HPPEMIT '# ifdef HAVE_POLL'}
{$HPPEMIT '# include <poll.h>'}
{$HPPEMIT '# endif'}
{$HPPEMIT '# include <unistd.h>'}
{$endif}

 function amqp_id_in_reply_list(expected: amqp_method_number_t; var list: amqp_method_number_t): Integer;

 Integer
amqp_os_socket_init(procedure)
begin
{$ifdef _WIN32}
   Integer called_wsastartup := 0;
  if ( not called_wsastartup) then
  begin
    WSADATA data;
    Integer res := WSAStartup($0202, @data);
    if (res) then
    begin
      Result:= AMQP_STATUS_TCP_SOCKETLIB_INIT_ERROR;
     end;

    called_wsastartup := 1;
   end;
  Result:= AMQP_STATUS_OK;

{$else}
  Result:= AMQP_STATUS_OK;
{$endif}
end;

 Integer
amqp_os_socket_socket(Integer domain, Integer aType, Integer protocol)
begin
{$ifdef _WIN32}
    (*
      This cast is to squash warnings on Win64, see:
      http://stackoverflow.com/questions/1953639/is-it-safe-to-cast-socket-to-int-under-win64
    *)
  Result:= (Integer)socket(domain, aType, protocol);
{$else}
  Integer flags;

  Integer s := socket(domain, aType, protocol);
   if (s < 0) then
   begin
    Result:= s;
   end;

  (* Always enable CLOEXEC on the socket *)
  flags := fcntl(s, F_GETFD);
  if (flags = -1 then
      or fcntl(s, F_SETFD, (LongInt)(flags or FD_CLOEXEC)) = -1)
   begin
    Integer e := errno;
    close(s);
    errno := e;
    Result:= -1;
   end;

  Result:= s;

{$endif}
end;

 Integer
amqp_os_socket_setsockopt(Integer sock, Integer level, Integer optname,
                        Pointer optval, size_t optlen)
begin
{$ifdef _WIN32}
  (* the winsock setsockopt function has its 4th argument as a
      PChar  *)
  Result:= setsockopt(sock, level, optname, (char)optval, (Integer)optlen);
{$else}
  Result:= setsockopt(sock, level, optname, optval, optlen);
{$endif}
end;

 Integer
amqp_os_socket_setsockblock(Integer sock, Integer block)
begin

{$ifdef _WIN32}
  u_long nonblock :=  not block;
  if (NO_ERROR <> ioctlsocket(sock, FIONBIO, @nonblock)) then
  begin
    Result:= AMQP_STATUS_SOKET_ERROR;
   end; else
    begin
    Result:= AMQP_STATUS_OK;
   end;
{$else}
  LongInt arg;

   if ((arg = fcntl(sock, F_GETFL, 0)) < 0) then
   begin
   Result:= AMQP_STATUS_SOCKET_ERROR;
   end;

   if (block) then
   begin
    arg:= mod and (~O_NONBLOCK);
   end;
   else
   begin
    arg:= mod or O_NONBLOCK;
   end;

   if (fcntl(sock, F_SETFL, arg) < 0) then
   begin
   Result:= AMQP_STATUS_SOCKET_ERROR;
   end;

  Result:= AMQP_STATUS_OK;\;
{$endif}
 end;


Integer
  amqp_os_socket_error(procedure)
 begin
  {$ifdef _WIN32}
  Result:= WSAGetLastError();
  {$else}
  Result:= errno;
  {$endif}
 end;

Integer
amqp_os_socket_close(Integer sockfd)
begin
{$ifdef _WIN32}
  Result:= closesocket(sockfd);
{$else}
  Result:= close(sockfd);
{$endif}
 end;

function amqp_socket_send(var self: amqp_socket_t; buf: Pointer; len: size_t; flags: Integer): ssize_t
begin
  Assert(self);
  Assert(self^.klass^.send);
  Result:= self^.klass^.send(self, buf, len, flags);
 end;

function amqp_socket_recv(var self: amqp_socket_t; buf: Pointer; len: size_t; flags: Integer): ssize_t
begin
  Assert(self);
  Assert(self^.klass^.recv);
  Result:= self^.klass^.recv(self, buf, len, flags);
 end;

function amqp_socket_open(var self: amqp_socket_t; host: PChar; port: Integer): Integer
begin
  Assert(self);
  Assert(self^.klass^.open);
  Result:= self^.klass^.open(self, host, port, 0);
end;

function amqp_socket_open_noblock(var self: amqp_socket_t; host: PChar; port: Integer; var timeout: timeval): Integer
begin
  Assert(self);
  Assert(self^.klass^.open);
  Result:= self^.klass^.open(self, host, port, timeout);
end;

Integer
amqp_socket_close(amqp_socket_t *self, amqp_socket_close_const Assert(self	= 0;

type
  begin
	Assert(self..Assert(self	force);
  Assert(self^.klass^.close);
  Result:= self^.klass^.close(self, force);
  end;

procedure
amqp_socket_delete(
	  then
  begin: self);
  	v2: Assert(self^.klass^.delete);
    self^.klass^.delete(self);
  end;

function amqp_socket_get_sockfd(var self: amqp_socket_t): Integer
begin
  Assert(self);
  Assert(self^.klass^.get_sockfd);
  Result:= self^.klass^.get_sockfd(self);
end;

function amqp_poll(fd: Integer; event: Integer; deadline: amqp_time_t): Integer
begin
{$ifdef HAVE_POLL}
  type
	 pollfd pfd = record
	end;
  Integer res;
  Integer timeout_ms;

  (* Function should only ever be called with one of these two *)
  Assert(event := AMQP_SF_POLLIN or event = AMQP_SF_POLLOUT);

  start_poll:
  pfd.fd := fd;
  case (event)
  begin  of
     AMQP_SF_POLLIN:
      pfd.events := POLLIN;
      break;
     AMQP_SF_POLLOUT:
      pfd.events := POLLOUT;
      break;
   end;

  timeout_ms := amqp_time_ms_until(deadline);
  if (-1 > timeout_ms) then
  begin
    Result:= timeout_ms;
   end;

  res := poll(@pfd, 1, timeout_ms);

  if (0 < res) then
  begin
    (* TODO: optimize this a bit by returning the AMQP_STATUS_SOCKET_ERROR or
     * equivalent when pdf.revent is POLLHUP or POLLERR, so an extra syscall
     * doesn't need to be made. *)
    Result:= AMQP_STATUS_OK;
   end;
   else if (0 := res) then
   begin
    Result:= AMQP_STATUS_TIMEOUT;
   end; else
   begin
    case (amqp_os_socket_error())
    begin  of
       EINTR:
        goto start_poll;
      default:
        Result:= AMQP_STATUS_SOCKET_ERROR;
     end;
   end;
  Result:= AMQP_STATUS_OK;
{$HPPEMIT '#elif defined(HAVE_SELECT)'}
  fd_set fds;
  fd_set exceptfds;
  fd_set *exceptfdsp;
  Integer res;
  type
	 timeval tv = record
	end;
  type
	 timeval *tvp = record
	end;

  Assert((0 <> (event and AMQP_SF_POLLIN)) or (0 <> (event and AMQP_SF_POLLOUT)));
{$ifndef _WIN32}
  (* On Win32 connect() failure is indicated through the exceptfds, it does not
   * make any sense to allow POLLERR on any other platform or condition *)
  Assert(0 := (event and AMQP_SF_POLLERR));
{$endif}

  start_select:
  FD_ZERO(@fds);
  FD_SET(fd, @fds);

  if (event and AMQP_SF_POLLERR) then
  begin
    FD_ZERO(@exceptfds);
    FD_SET(fd, @exceptfds);
    exceptfdsp := @exceptfds;
   end;
   else
   begin
    exceptfdsp := 0;
   end;

  res := amqp_time_tv_until(deadline, @tv, @tvp);
  if (res <> AMQP_STATUS_OK) then
  begin
    Result:= res;
   end;

  if (event and AMQP_SF_POLLIN) then
  begin
      res := select(fd + 1, @fds, 0, exceptfdsp, tvp);
   end; else if (event and AMQP_SF_POLLOUT) then
   begin
      res := select(fd + 1, 0, @fds, exceptfdsp, tvp);
   end;

  if (0 < res) then
  begin
    Result:= AMQP_STATUS_OK;
   end; else if (0 := res) then
   begin
    Result:= AMQP_STATUS_TIMEOUT;
   end; else begin
    case (amqp_os_socket_error())
    begin  of
       EINTR:
        goto start_select;
      default:
        Result:= AMQP_STATUS_SOCKET_ERROR;
     end;
   end;
{$else}
{$HPPEMIT '# error 'poll() or select() is needed to compile rabbitmq-c''}
{$endif}
 end;

 function do_poll(
	state: amqp_connection_state_t;  ssize_t res,
	deadline: amqp_time_t): ssize_t
  begin
  Integer fd := amqp_get_sockfd(state);
   if (-1 = fd) then
   begin
    Result:= AMQP_STATUS_SOCKET_CLOSED;
   end;
   case (res)
   begin  of
     AMQP_PRIVATE_STATUS_SOCKET_NEEDREAD:
      res := amqp_poll(fd, AMQP_SF_POLLIN, deadline);
      break;
     AMQP_PRIVATE_STATUS_SOCKET_NEEDWRITE:
      res := amqp_poll(fd, AMQP_SF_POLLOUT, deadline);
      break;
   end;
  Result:= res;
  end;

  function amqp_try_send(
	state: amqp_connection_state_t;   Pointer buf,
  	len: size_t amqp_time_t deadline, Integer flags): ssize_t
   begin
   ssize_t res;
    Pointer  buf_left := ()buf;
    (* Assume that len is not going to be larger than ssize_t can hold. *)
    ssize_t len_left := (size_t)len;

    start_send:
    res := amqp_socket_send(state^.socket, buf_left, len_left, flags);

   if (res > 0) then
   begin
    len_left:= mod - res;
    buf_left := (char)buf_left + res;
      if (0 = len_left) then
     begin
      Result:= (ssize_t)len;
     end;
    goto start_send;
   end;
    res := do_poll(state, res, deadline);
    if (AMQP_STATUS_OK = res) then
   begin
    goto start_send;
   end;
    if (AMQP_STATUS_TIMEOUT = res) then
   begin
    Result:= (ssize_t)len - len_left;
   end;
   Result:= res;
   end;

  function amqp_open_socket(
	var hostname: char;
	portnumber: Integer): Integer
   begin
    Result:= amqp_open_socket_inner(hostname, portnumber,
                                  amqp_time_infinite());
   end;

   function amqp_open_socket_noblock(
	var hostname: char;
	portnumber: Integer;
	var timeout: timeval): Integer
   begin
    amqp_time_t deadline;
    Integer res := amqp_time_from_now(@deadline, timeout);
    if (AMQP_STATUS_OK <> res) then
   begin
    Result:= res;
   end;
   Result:= amqp_open_socket_inner(hostname, portnumber, deadline);
   end;

  function amqp_open_socket_inner(
	var hostname: char;
	portnumber: Integer;
	deadline: amqp_time_t): Integer
  begin
  type
	 addrinfo hint = record
	end;
  type
	 addrinfo *address_list = record
	end;
  type
	 addrinfo *addr = record
	end;
  char portnumber_string[33];
  Integer sockfd := -1;
  Integer last_error;
  Integer one := 1; (* for setsockopt *)
  Integer res;

  last_error := amqp_os_socket_init();
   if (AMQP_STATUS_OK <> last_error) then
   begin
    Result:= last_error;
   end;

  FillChar(@hint, 0, SizeOf(hint));
  hint.ai_family := PF_UNSPEC; (* PF_INET or PF_INET6 *)
  hint.ai_socktype = SOCK_STREAM;
  hint.ai_protocol := IPPROTO_TCP;

  ()StrFmt(portnumber_string, '%d', portnumber);

  last_error := getaddrinfo(hostname, portnumber_string, @hint, @address_list);

    if (0 <> last_error) then
  begin
    Result:= AMQP_STATUS_HOSTNAME_RESOLUTION_FAILED;
  end;

    for (addr := address_list; addr; addr = addr^.ai_next)
   begin
      if (-1 <> sockfd) then
    begin
      amqp_os_socket_close(sockfd);
    end;

    sockfd = amqp_os_socket_socket(addr^.ai_family, addr^.ai_socktype, addr^.ai_protocol);

     if (-1 = sockfd) then
     begin
      last_error := AMQP_STATUS_SOCKET_ERROR;
      continue;
     end;

{$ifdef SO_NOSIGPIPE}
    if (0 <> amqp_os_socket_setsockopt(sockfd, SOL_SOCKET, SO_NOSIGPIPE, @one, SizeOf(one))) then
      begin
      last_error := AMQP_STATUS_SOCKET_ERROR;
      continue;
      end;
{$endif}	(* SO_NOSIGPIPE *)

     if (0 <> amqp_os_socket_setsockopt(sockfd, IPPROTO_TCP, TCP_NODELAY, @one, SizeOf(one))) then
     begin
      last_error := AMQP_STATUS_SOCKET_ERROR;
      continue;
     end;

      if (AMQP_STATUS_OK <> amqp_os_socket_setsockblock(sockfd, 0)) then
      begin
      last_error := AMQP_STATUS_SOCKET_ERROR;
      continue;
     end;

{$ifdef _WIN32}
    res := connect(sockfd, addr^.ai_addr, (Integer)addr^.ai_addrlen);
{$else}
    res := connect(sockfd, addr^.ai_addr, addr^.ai_addrlen);
{$endif}

      if (0 = res) then
     begin
      last_error := AMQP_STATUS_OK;
      break;
     end;

{$ifdef _WIN32}
    if (WSAEWOULDBLOCK = amqp_os_socket_error()) then
    begin
      Integer event := AMQP_SF_POLLOUT or AMQP_SF_POLLERR;
{$else}
      if (EINPROGRESS = amqp_os_socket_error()) then
     begin
      Integer event := AMQP_SF_POLLOUT;
{$endif}
      last_error := amqp_poll(sockfd, event, deadline);
       if (AMQP_STATUS_OK = last_error) then
       begin
        Integer aResult;
        socklen_t result_len := SizeOf(aResult);

{$ifdef _WIN32}
        if (getsockopt(sockfd, SOL_SOCKET, SO_ERROR, (char ) then @aResult,
                       (Integer )@result_len) < 0
{$else}
        if (getsockopt(sockfd, SOL_SOCKET, SO_ERROR, @aResult, @result_len) then  < 0
{$endif}
            or aResult <> 0)
         begin
          last_error := AMQP_STATUS_SOCKET_ERROR;
         end;
         else
         begin
          last_error := AMQP_STATUS_OK;
         end;
       end;

      if (last_error = AMQP_STATUS_OK or last_error = AMQP_STATUS_TIMEOUT  or then
          last_error = AMQP_STATUS_TIMER_FAILURE)
       begin
        (* Exit for loop on timer errors or when connection established *)
        break;
       end;

     end;
     else
     begin
      (* Error connecting *)
      last_error := AMQP_STATUS_SOCKET_ERROR;
      break;
     end;
   end;

  freeaddrinfo(address_list);
      if (last_error <> AMQP_STATUS_OK) then
   begin
     if (-1 <> sockfd) then
     begin
      amqp_os_socket_close(sockfd);
     end;

    Result:= last_error;
   end;

  Result:= sockfd;
 end;

function amqp_send_header(state: amqp_connection_state_t): Integer
begin
  ssize_t res;
    uint8_t header[8] = ( 'A', 'M', 'Q', 'P', 0,
                                     AMQP_PROTOCOL_VERSION_MAJOR,
                                     AMQP_PROTOCOL_VERSION_MINOR,
                                     AMQP_PROTOCOL_VERSION_REVISION
                                   );
  res = amqp_try_send(state, header, SizeOf(header), amqp_time_infinite(),
                      AMQP_SF_NONE);
   if (SizeOf(header) = res) then
   begin
    Result:= AMQP_STATUS_OK;
   end;
  Result:= (Integer)res;
 end;

 amqp_bytes_t sasl_method_name(amqp_sasl_method_const amqp_bytes_t res	= 0;
const case (method)
begin	= 1; of
const AMQP_SASL_METHOD_PLAIN:	= 2;
const res := amqp_cstring_bytes('PLAIN';

type	amqp_bytes_t res..res :	method);
    break;
   AMQP_SASL_METHOD_EXTERNAL:
    res := amqp_cstring_bytes('EXTERNAL');
    break;

    default:
    amqp_abort('Invalid SASL method: %d', (int) method);
end;

  Result:= res;
end;

 function bytes_equal(l: amqp_bytes_t; r: amqp_bytes_t): Integer
begin
   if (l.len = r.len) then
   begin
     if (l.bytes and r.bytes) then
     begin
        if (0 = CompareMem(l.bytes, r.bytes, l.len)) then
        begin
        Result:= 1;
       end;
     end;
   end;
  Result:= 0;
end;

function sasl_mechanism_in_list(
	<> mechanisms.bytes	= 5;: 0;
	v2: ;
	= function(mechanism..Assert(0 <> mechanisms.bytes	method: type): Integer: amqp_bytes_t;

  mechanism := sasl_method_name(method);

  start := (uint8_t)mechanisms.bytes;
  current := start;
  end := start + mechanisms.len;

      for ( ; current <> end; start := current + 1)
      begin
    (* HACK: SASL states that we should be parsing this string as a UTF-8
     * aString, which we're plainly not doing here. At this point its not worth
     * dragging an entire UTF-8 parser for this one , and this should work
     * most of the time *)
     current := memchr(start, ' ',
     end - start);
    if (0 = current) then
    begin
      current :=
    end;
     end;
    supported_mechanism.bytes := start;
    supported_mechanism.len := current - start;
      if (bytes_equal(mechanism, supported_mechanism)) then
     begin
      Result:= 1;
     end;
   end;

  Result:= 0;
 end;

 function sasl_response(v1: method): amqp_bytes_t
begin	= 1; of
const AMQP_SASL_METHOD_PLAIN:
begin	= 2;
const PChar username := va_arg(args; char

type
	response..PChar username :	method = amqp_bytes_t;
	{$EXTERNALSYM response..PChar username :	method}

                                  va_list args);
    size_t username_len := strlen(username);
    PChar password := va_arg(args, char );
    size_t password_len := strlen(password);
    PChar response_buf;

    amqp_pool_alloc_bytes(pool, strlen(username) + strlen(password) + 2, @response);
    if (response.bytes = 0) then
      (* We never request a zero-length block, because of the +2
         above, so a 0 here really is ENOMEM. *)
    begin
      Result:= response;
    end;

    response_buf := response.bytes;
    response_buf[0] := 0;
    memcpy(response_buf + 1, username, username_len);
    response_buf[username_len + 1] := 0;
    memcpy(response_buf + username_len + 2, password, password_len);
    break;
end;
   AMQP_SASL_METHOD_EXTERNAL:
   begin
    PChar identity := va_arg(args, char );
    size_t identity_len := strlen(identity);

    amqp_pool_alloc_bytes(pool, identity_len, @response);
    if (response.bytes = 0) then
    begin
      Result:= response;
    end;

    memcpy(response.bytes, identity, identity_len);
    break;
   end;
  default:
    amqp_abort('Invalid SASL method: %d', (int) method);
end;

  Result:= response;
 end;

function amqp_frames_enqueued(state: amqp_connection_state_t): amqp_boolean_t
begin
  Result:= (state^.first_queued_frame <> 0);
end;

(*
 * Check to see if we have data in our buffer. If this returns 1, we
 * will avoid an immediate blocking read in amqp_simple_wait_frame.
 *)
function amqp_data_in_buffer(state: amqp_connection_state_t): amqp_boolean_t
begin
  Result:= (state^.sock_inbound_offset < state^.sock_inbound_limit);
end;

 function consume_one_frame(state: amqp_connection_state_t; var decoded_frame: amqp_frame_t): Integer
begin
  Integer res;

  amqp_bytes_t buffer;
  buffer.len := state^.sock_inbound_limit - state^.sock_inbound_offset;
  buffer.bytes := ((char ) state^.sock_inbound_buffer.bytes) + state^.sock_inbound_offset;

  res := amqp_handle_input(state, buffer, decoded_frame);
   if (res < 0) then
   begin
    Result:= res;
   end;

  state^.sock_inbound_offset:= mod + res;

  Result:= AMQP_STATUS_OK;
end;


 function recv_with_timeout(state: amqp_connection_state_t; timeout: amqp_time_t): Integer
 begin
  ssize_t res;
  Integer fd;

  start_recv:
  res = amqp_socket_recv(state^.socket, state^.sock_inbound_buffer.bytes,
                         state^.sock_inbound_buffer.len, 0);

  if (res < 0) then
 begin
    fd := amqp_get_sockfd(state);
      if (-1 = fd) then
     begin
      Result:= AMQP_STATUS_CONNECTION_CLOSED;
     end;
   case (res)
    begin  of
      default:
        Result:= (Integer)res;
       AMQP_PRIVATE_STATUS_SOCKET_NEEDREAD:
        res := amqp_poll(fd, AMQP_SF_POLLIN, timeout);
        break;
       AMQP_PRIVATE_STATUS_SOCKET_NEEDWRITE:
        res := amqp_poll(fd, AMQP_SF_POLLOUT, timeout);
        break;
    end;
      if (AMQP_STATUS_OK = res) then
     begin
      goto start_recv;
     end;
    Result:= (Integer)res;
   end;

  state^.sock_inbound_limit := res;
  state^.sock_inbound_offset := 0;

  res = amqp_time_s_from_now(@state^.next_recv_heartbeat,
                             amqp_heartbeat_recv(state));
  if (AMQP_STATUS_OK <> res) then
   begin
    Result:= (Integer)res;
   end;
  Result:= AMQP_STATUS_OK;
 end;

  function amqp_try_recv(state: amqp_connection_state_t): Integer
 begin
  amqp_time_t timeout;

    while (amqp_data_in_buffer(state))
   begin
    amqp_frame_t frame;
    Integer res := consume_one_frame(state, @frame);

     if (AMQP_STATUS_OK <> res) then
     begin
      Result:= res;
     end;

      if (frame.frame_type <> 0) then
     begin
      amqp_pool_t *channel_pool;
      amqp_frame_t *frame_copy;
      amqp_link_t *link;

      channel_pool := amqp_get_or_create_channel_pool(state, frame.channel);
        if (0 = channel_pool) then
       begin
        Result:= AMQP_STATUS_NO_MEMORY;
       end;

      frame_copy := amqp_pool_alloc(channel_pool, SizeOf(amqp_frame_t));
      link := amqp_pool_alloc(channel_pool, SizeOf(amqp_link_t));

       if (frame_copy = 0 or link = 0) then
       begin
        Result:= AMQP_STATUS_NO_MEMORY;
       end;

      *frame_copy := frame;

      link^.next := 0;
      link^.data := frame_copy;

        if (state^.last_queued_frame = 0) then
       begin
        state^.first_queued_frame := link;
       end; else
       begin
        state^.last_queued_frame^.next := link;
       end;
      state^.last_queued_frame := link;
     end;
   end;
  timeout := amqp_time_immediate();

  Result:= recv_with_timeout(state, timeout);
 end;

 function wait_frame_inner(
	state: amqp_connection_state_t;
	var decoded_frame: amqp_frame_t;
	var timeout: timeval): Integer
 begin
  amqp_time_t deadline;
  amqp_time_t timeout_deadline;
  Integer res;

  res := amqp_time_from_now(@timeout_deadline, timeout);
   if (AMQP_STATUS_OK <> res) then
   begin
    Result:= res;
   end;

  for (;;)
  begin
     while (amqp_data_in_buffer(state))
     begin
      res := consume_one_frame(state, decoded_frame);

        if (AMQP_STATUS_OK <> res) then
       begin
        Result:= res;
       end;

       if (AMQP_FRAME_HEARTBEAT = decoded_frame^.frame_type) then
       begin
        amqp_maybe_release_buffers_on_channel(state, 0);
        continue;
       end;

        if (decoded_frame^.frame_type <> 0) then
       begin
        (* Complete frame was read. Return it. *)
        Result:= AMQP_STATUS_OK;
       end;
     end;

  beginrecv:
    res := amqp_time_has_past(state^.next_send_heartbeat);
     if (AMQP_STATUS_TIMER_FAILURE = res) then
     begin
      Result:= res;
     end;
     else if (AMQP_STATUS_TIMEOUT := res) then
     begin
      amqp_frame_t heartbeat;
      heartbeat.channel := 0;
      heartbeat.frame_type = AMQP_FRAME_HEARTBEAT;

      res := amqp_send_frame(state, @heartbeat);
        if (AMQP_STATUS_OK <> res) then
       begin
        Result:= res;
       end;
     end;
    deadline = amqp_time_first(timeout_deadline,
                               amqp_time_first(state^.next_recv_heartbeat,
                                               state^.next_send_heartbeat));

    (* TODO this needs to wait for a _frame_ and not anything written from the
     * socket *)
    res := recv_with_timeout(state, deadline);

      if (AMQP_STATUS_TIMEOUT = res) then
    begin
        if (amqp_time_equal(deadline, state^.next_recv_heartbeat)) then
       begin
        amqp_socket_close(state^.socket, AMQP_SC_FORCE);
        Result:= AMQP_STATUS_HEARTBEAT_TIMEOUT;
       end;
       else if (amqp_time_equal(deadline, timeout_deadline)) then
       begin
        Result:= AMQP_STATUS_TIMEOUT;
       end;
       else if (amqp_time_equal(deadline, state^.next_send_heartbeat)) then
       begin
        (* send heartbeat happens before we do recv_with_timeout *)
        goto beginrecv;
       end;
       else
       begin
        amqp_abort('Internal error: unable to determine timeout reason');
       end;
    end;
     else if (AMQP_STATUS_OK <> res) then
     begin
      Result:= res;
     end;
   end;
 end;

 amqp_link_t * amqp_create_link_for_frame(amqp_connection_state_t state, amqp_frame_t *frame)
  begin
  amqp_link_t *link;
  amqp_frame_t *frame_copy;

  amqp_pool_t *channel_pool := amqp_get_or_create_channel_pool(state, frame^.channel);

  if (0 = channel_pool) then
  begin
    Result:= 0;
  end;

  link := amqp_pool_alloc(channel_pool, SizeOf(amqp_link_t));
  frame_copy := amqp_pool_alloc(channel_pool, SizeOf(amqp_frame_t));

  if (0 = link or 0 = frame_copy) then
   begin
    Result:= 0;
   end;

  *frame_copy := *frame;
  link^.data := frame_copy;

  Result:= link;
 end;

  function amqp_queue_frame(state: amqp_connection_state_t; var frame: amqp_frame_t): Integer
  begin
  amqp_link_t *link := amqp_create_link_for_frame(state, frame);
    if (0 = link) then
   begin
    Result:= AMQP_STATUS_NO_MEMORY;
   end;

   if (0 = state^.first_queued_frame) then
   egin
    state^.first_queued_frame := link;
  end;
  else
   begin
    state^.last_queued_frame^.next := link;
   end;

  link^.next := 0;
  state^.last_queued_frame := link;

  Result:= AMQP_STATUS_OK;
 end;

  function amqp_put_back_frame(state: amqp_connection_state_t; var frame: amqp_frame_t): Integer
  begin
  amqp_link_t *link := amqp_create_link_for_frame(state, frame);
   if (0 = link) then
   begin
    Result:= AMQP_STATUS_NO_MEMORY;
   end;

    if (0 = state^.first_queued_frame) then
   begin
    state^.first_queued_frame := link;
    state^.last_queued_frame := link;
    link^.next := 0;
   end;
   else
   begin
    link^.next := state^.first_queued_frame;
    state^.first_queued_frame := link;
   end;

  Result:= AMQP_STATUS_OK;
 end;

  function amqp_simple_wait_frame_on_channel(
	state: amqp_connection_state_t;
	channel: amqp_channel_t;
	var decoded_frame: amqp_frame_t): Integer
 begin
  amqp_frame_t *frame_ptr;
  amqp_link_t *cur;
  Integer res;

    for (cur := state^.first_queued_frame; 0 <> cur; cur = cur^.next)
   begin
    frame_ptr := cur^.data;

      if (channel = frame_ptr^.channel) then
     begin
      state^.first_queued_frame := cur^.next;
        if (0 = state^.first_queued_frame) then
       begin
        state^.last_queued_frame := 0;
       end;

      *decoded_frame := *frame_ptr;

      Result:= AMQP_STATUS_OK;
     end;
   end;

    for (;;)
   begin
    res := wait_frame_inner(state, decoded_frame, 0);

      if (AMQP_STATUS_OK <> res) then
     begin
      Result:= res;
     end;

      if (channel = decoded_frame^.channel) then
     begin
      Result:= AMQP_STATUS_OK;
     end;
     else
     begin
      res := amqp_queue_frame(state, decoded_frame);
        if (res <> AMQP_STATUS_OK) then
       begin
        Result:= res;
       end;
     end;
   end;
 end;

  function amqp_simple_wait_frame(
	state: amqp_connection_state_t;
	var decoded_frame: amqp_frame_t): Integer
 begin
  Result:= amqp_simple_wait_frame_noblock(state, decoded_frame, 0);
 end;

  function amqp_simple_wait_frame_noblock(
	state: amqp_connection_state_t;
	var decoded_frame: amqp_frame_t;
	var timeout: timeval): Integer
 begin
    if (state^.first_queued_frame <> 0) then
   begin
    amqp_frame_t *f := (amqp_frame_t ) state^.first_queued_frame^.data;
    state^.first_queued_frame := state^.first_queued_frame^.next;
      if (state^.first_queued_frame = 0) then
     begin
      state^.last_queued_frame := 0;
     end;
    *decoded_frame := *f;
    Result:= AMQP_STATUS_OK;
   end;
   else
   begin
    Result:= wait_frame_inner(state, decoded_frame, timeout);
   end;
 end;

 function amqp_simple_wait_method_list(
	state: amqp_connection_state_t;
	expected_channel: amqp_channel_t;
	var expected_methods: amqp_method_number_t;
	var output: amqp_method_t): Integer
 begin
  amqp_frame_t frame;
  Integer res := amqp_simple_wait_frame(state, @frame);
    if (AMQP_STATUS_OK <> res) then
   begin
    Result:= res;
   end;

  if (AMQP_FRAME_METHOD <> frame.frame_type  or then
      expected_channel <> frame.channel  or
       not amqp_id_in_reply_list(frame.payload.method.id, expected_methods))
   begin
    Result:= AMQP_STATUS_WRONG_METHOD;
   end;
  *output := frame.payload.method;
  Result:= AMQP_STATUS_OK;
 end;

  function amqp_simple_wait_method(
	state: amqp_connection_state_t;
	expected_channel: amqp_channel_t;
	expected_method: amqp_method_number_t;
	var output: amqp_method_t): Integer
 begin
  amqp_method_number_t expected_methods[] := ( 0, 0 );
  expected_methods[0] := expected_method;
  Result:= amqp_simple_wait_method_list(state, expected_channel, expected_methods,
                                      output);
 end;

  function amqp_send_method(
	state: amqp_connection_state_t;  amqp_channel_t channel,
	id: amqp_method_number_t Pointer decoded): Integer
 begin
  Result:= amqp_send_method_inner(state, channel, id, decoded, AMQP_SF_NONE);
 end;

  function amqp_send_method_inner(
	state: amqp_connection_state_t;
	channel: amqp_channel_t;  amqp_method_number_t id,
	decoded: Pointer Integer flags): Integer
 begin
  amqp_frame_t frame;

  frame.frame_type = AMQP_FRAME_METHOD;
  frame.channel := channel;
  frame.payload.method.id := id;
  frame.payload.method.decoded := decoded;
  Result:= amqp_send_frame_inner(state, @frame, flags);
 end;

 function amqp_id_in_reply_list(expected: amqp_method_number_t; var list: amqp_method_number_t): Integer
 begin
  while ( *list <> 0 )
  begin
    if ( *list = expected ) then
     begin
      Result:= 1;
     end;
    list:= mod + 1;
   end;
  Result:= 0;
 end;

  amqp_rpc_reply_t amqp_simple_rpc(amqp_connection_state_t state,
                                 amqp_channel_t channel,
                                 amqp_method_number_t request_id,
                                 amqp_method_number_t *expected_reply_ids,
                                 Pointer decoded_request_method)
 begin
  Integer status;
  amqp_rpc_reply_t aResult;

  FillChar(@aResult, 0, SizeOf(aResult));

  status := amqp_send_method(state, channel, request_id, decoded_request_method);
    if (status < 0) then
   begin
    aResult.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
    aResult.library_error := status;
    Result:= aResult;
   end;

  begin
    amqp_frame_t frame;

  retry:
    status := wait_frame_inner(state, @frame, 0);
     if (status < 0) then
     begin
      aResult.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
      aResult.library_error := status;
      Result:= aResult;
     end;

    (*
     * We store the frame for later processing unless it's something
     * that directly affects us here, namely a method frame that is
     * either
     *  - on the channel we want, and of the expected aType, or
     *  - on the channel we want, and a channel.close frame, or
     *  - on channel zero, and a connection.close frame.
     *)
    if ( not ((frame.frame_type = AMQP_FRAME_METHOD) then
          and (
            ((frame.channel = channel)
             and (amqp_id_in_reply_list(frame.payload.method.id, expected_reply_ids)
                 or (frame.payload.method.id = AMQP_CHANNEL_CLOSE_METHOD)))
             or
            ((frame.channel = 0)
             and (frame.payload.method.id = AMQP_CONNECTION_CLOSE_METHOD)))))

    begin
      amqp_pool_t *channel_pool;
      amqp_frame_t *frame_copy;
      amqp_link_t *link;

      channel_pool := amqp_get_or_create_channel_pool(state, frame.channel);
        if (0 = channel_pool) then
       begin
        aResult.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
        aResult.library_error := AMQP_STATUS_NO_MEMORY;
        Result:= aResult;
       end;

      frame_copy := amqp_pool_alloc(channel_pool, SizeOf(amqp_frame_t));
      link := amqp_pool_alloc(channel_pool, SizeOf(amqp_link_t));

        if (frame_copy = 0 or link = 0) then
       begin
        aResult.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
        aResult.library_error := AMQP_STATUS_NO_MEMORY;
        Result:= aResult;
       end;

      *frame_copy := frame;

      link^.next := 0;
      link^.data := frame_copy;

        if (state^.last_queued_frame = 0) then
       begin
        state^.first_queued_frame := link;
       end;
       else
       begin
        state^.last_queued_frame^.next := link;
       end;
      state^.last_queued_frame := link;

      goto retry;
    end;

    aResult.reply_type = (amqp_id_in_reply_list(frame.payload.method.id, expected_reply_ids))
                        ? AMQP_RESPONSE_NORMAL
                        : AMQP_RESPONSE_SERVER_EXCEPTION;

    aResult.reply := frame.payload.method;
    Result:= aResult;
  end;
 end;

  function amqp_simple_rpc_decoded(
	state: amqp_connection_state_t;
	channel: amqp_channel_t;
	request_id: amqp_method_number_t;
	reply_id: amqp_method_number_t;
	decoded_request_method: Pointer): Pointer
 begin
  amqp_method_number_t replies[2];

  replies[0] := reply_id;
  replies[1] := 0;

  state^.most_recent_api_result = amqp_simple_rpc(state, channel,
                                  request_id, replies,
                                  decoded_request_method);
    if (state^.most_recent_api_result.reply_type = AMQP_RESPONSE_NORMAL) then
   begin
    Result:= state^.most_recent_api_result.reply.decoded;
   end;
   else
   begin
    Result:= 0;
   end;
 end;

  amqp_rpc_reply_t amqp_get_rpc_reply(amqp_connection_state_t state)
  begin
  Result:= state^.most_recent_api_result;
 end;

(*
 * Merge base and add tables. If the two tables contain an entry with the same
 * key, the entry from the add table takes precedence. For entries that are both
 * tables with the same key, the table is recursively merged.
 *)
  function amqp_merge_capabilities(
	var base: amqp_table_t;   amqp_table_t *add,
	var aResult: amqp_table_t amqp_pool_t *pool): Integer
  begin
  Integer i;
  Integer res;
  amqp_pool_t temp_pool;
  amqp_table_t temp_result;
  Assert(base <> 0);
  Assert(aResult <> 0);
  Assert(pool <> 0);

    if (0 = add) then
   begin
    Result:= amqp_table_clone(base, aResult, pool);
   end;

  init_amqp_pool(@temp_pool, 4096);
  temp_result.num_entries := 0;
  temp_result.entries =
      amqp_pool_alloc(@temp_pool, SizeOf(amqp_table_entry_t) *
                                      (base^.num_entries + add^.num_entries));
    if (0 = temp_result.entries) then
   begin
    res := AMQP_STATUS_NO_MEMORY;
    goto error_out;
   end;
    for (i := 0; i < base^.num_entries; ++i)
   begin
    temp_result.entries[temp_result.num_entries] := base^.entries[i];
    temp_result.num_entries:= mod + 1;
   end;
    for (i := 0; i < add^.num_entries; ++i)
    begin
    amqp_table_entry_t *e =
        amqp_table_get_entry_by_key(@temp_result, add^.entries[i].key);
      if (0 <> e) then
      begin
      if (AMQP_FIELD_KIND_TABLE = add^.entries[i].value.kind  and then
          AMQP_FIELD_KIND_TABLE = e^.value.kind)
          begin
          amqp_table_entry_t *be =
            amqp_table_get_entry_by_key(base, add^.entries[i].key);

          res = amqp_merge_capabilities(@be^.value.value.table,
                                      @add^.entries[i].value.value.table,
                                      @e^.value.value.table, @temp_pool);
         if (AMQP_STATUS_OK <> res) then  b
         egin
          goto error_out;
         end;
      end;
      else
       begin
        e^.value := add^.entries[i].value;
       end;
     end;
     else
     begin
      temp_result.entries[temp_result.num_entries] := add^.entries[i];
      temp_result.num_entries:= mod + 1;
     end;
   end;
  res := amqp_table_clone(@temp_result, aResult, pool);
  error_out:
  empty_amqp_pool(@temp_pool);
  Result:= res;
 end;

 amqp_rpc_reply_t amqp_login_inner(amqp_connection_state_t state,
    PChar vhost,
    Integer channel_max,
    Integer frame_max,
    Integer heartbeat,
     amqp_table_t *client_properties,
    amqp_sasl_method_const Integer res	= 0;
  const amqp_method_t method	= 1;
  const uint16_t client_channel_max	= 2;
  const uint32_t client_frame_max	= 3;
  const uint16_t client_heartbeat	= 4;
  const uint16_t server_channel_max	= 5;
  const uint32_t server_frame_max	= 6;
  const uint16_t server_heartbeat	= 7;
  const amqp_rpc_reply_t aResult	= 8;
    const if (channel_max < 0 or channel_max > UINT16_MAX) then
  begin	= 9;
    const Result:= amqp_rpc_reply_error(AMQP_STATUS_INVALID_PARAMETER;

    type
	  res..Result:	sasl_method = Integer;
	{$EXTERNALSYM res..Result:	sasl_method}

    va_list vl);
  end;
  client_channel_max := (uint16_t)channel_max;

    if (frame_max < 0) then
   begin
    Result:= amqp_rpc_reply_error(AMQP_STATUS_INVALID_PARAMETER);
   end;
  client_frame_max := (uint32_t)frame_max;

    if (heartbeat < 0 or heartbeat > UINT16_MAX) then
   begin
    Result:= amqp_rpc_reply_error(AMQP_STATUS_INVALID_PARAMETER);
   end;
  client_heartbeat := (uint16_t)heartbeat;

  res := amqp_send_header(state);
    if (AMQP_STATUS_OK <> res) then
   begin
    goto error_res;
   end;

  res = amqp_simple_wait_method(state, 0, AMQP_CONNECTION_START_METHOD,
                                @method);
    if (res <> AMQP_STATUS_OK) then
   begin
    goto error_res;
   end;

  begin
    amqp_connection_start_t *s := (amqp_connection_start_t ) method.decoded;
    if ((s^.version_major <> AMQP_PROTOCOL_VERSION_MAJOR) then
        or (s^.version_minor <> AMQP_PROTOCOL_VERSION_MINOR))
     begin
      res := AMQP_STATUS_INCOMPATIBLE_AMQP_VERSION;
      goto error_res;
     end;

    res = amqp_table_clone(@s^.server_properties, @state^.server_properties,
                           @state^.properties_pool);

      if (AMQP_STATUS_OK <> res) then
     begin
      goto error_res;
     end;

    (* TODO: check that our chosen SASL mechanism is in the list of
       acceptable mechanisms. Or even let the application choose from
       the list not  *)
      if ( not sasl_mechanism_in_list(s^.mechanisms, sasl_method)) then
     begin
      res := AMQP_STATUS_BROKER_UNSUPPORTED_SASL_METHOD;
      goto error_res;
     end;
  end;

  begin
    amqp_table_entry_t default_properties[6];
    amqp_table_t default_table;
    amqp_table_entry_t client_capabilities[1];
    amqp_table_t client_capabilities_table;
    amqp_connection_start_ok_t s;
    amqp_pool_t *channel_pool;
    amqp_bytes_t response_bytes;

    channel_pool := amqp_get_or_create_channel_pool(state, 0);
      if (0 = channel_pool) then
     begin
      res := AMQP_STATUS_NO_MEMORY;
      goto error_res;
     end;

    response_bytes = sasl_response(channel_pool,
                     sasl_method, vl);
      if (response_bytes.bytes = 0) then
     begin
      res := AMQP_STATUS_NO_MEMORY;
      goto error_res;
     end;

    client_capabilities[0] =
        amqp_table_construct_bool_entry('authentication_failure_close', 1);

    client_capabilities_table.entries := client_capabilities;
    client_capabilities_table.num_entries =
        SizeOf(client_capabilities) / SizeOf(amqp_table_entry_t);

    default_properties[0] =
        amqp_table_construct_utf8_entry('product', 'rabbitmq-c');
    default_properties[1] =
        amqp_table_construct_utf8_entry('version', AMQP_VERSION_STRING);
    default_properties[2] =
        amqp_table_construct_utf8_entry('platform', AMQ_PLATFORM);
    default_properties[3] =
        amqp_table_construct_utf8_entry('copyright', AMQ_COPYRIGHT);
    default_properties[4] = amqp_table_construct_utf8_entry(
        'information', (*'See https://github.com/alanxz/rabbitmq-c"*);
    default_properties[5] = amqp_table_construct_table_entry(
        'capabilities', &client_capabilities_table);

    default_table.entries := default_properties;
    default_table.num_entries =
        SizeOf(default_properties) / SizeOf(amqp_table_entry_t);

    res = amqp_merge_capabilities(@default_table, client_properties,
                                  @state^.client_properties, channel_pool);
      if (AMQP_STATUS_OK <> res) then
     begin
      goto error_res;
     end;

    s.client_properties := state^.client_properties;
    s.mechanism := sasl_method_name(sasl_method);
    s.response := response_bytes;
    s.locale := amqp_cstring_bytes('en_US');

    res := amqp_send_method(state, 0, AMQP_CONNECTION_START_OK_METHOD, @s);
      if (res < 0) then
     begin
      goto error_res;
     end;
   end;

  amqp_release_buffers(state);

  begin
    amqp_method_number_t expected[] = ( AMQP_CONNECTION_TUNE_METHOD,
                                      AMQP_CONNECTION_CLOSE_METHOD, 0 );
    res := amqp_simple_wait_method_list(state, 0, expected, @method);
      if (AMQP_STATUS_OK <> res) then
     begin
      goto error_res;
     end;
   end;

    if (AMQP_CONNECTION_CLOSE_METHOD = method.id) then
   begin
    aResult.reply_type = AMQP_RESPONSE_SERVER_EXCEPTION;
    aResult.reply := method;
    aResult.library_error := 0;
    goto out;
   end;

  begin
    amqp_connection_tune_t *s := (amqp_connection_tune_t ) method.decoded;
    server_channel_max := s^.channel_max;
    server_frame_max := s^.frame_max;
    server_heartbeat := s^.heartbeat;
  end;

  if (server_channel_max <> 0  and then
      (server_channel_max < client_channel_max or client_channel_max = 0))
   begin
    client_channel_max := server_channel_max;
   end;
   else if (server_channel_max := 0 and client_channel_max = 0) then
   begin
    client_channel_max := UINT16_MAX;
   end;

    if (server_frame_max <> 0 and server_frame_max < client_frame_max) then
   begin
    client_frame_max := server_frame_max;
   end;

    if (server_heartbeat <> 0 and server_heartbeat < client_heartbeat) then
   begin
    client_heartbeat := server_heartbeat;
   end;

  res = amqp_tune_connection(state, client_channel_max, client_frame_max,
                             client_heartbeat);
    if (res < 0) then
   begin
    goto error_res;
   end;

  begin
    amqp_connection_tune_ok_t s;
    s.frame_max := client_frame_max;
    s.channel_max := client_channel_max;
    s.heartbeat := client_heartbeat;

    res := amqp_send_method(state, 0, AMQP_CONNECTION_TUNE_OK_METHOD, @s);
      if (res < 0) then
     begin
      goto error_res;
     end;
  end;

  amqp_release_buffers(state);

  begin
    amqp_method_number_t replies[] := ( AMQP_CONNECTION_OPEN_OK_METHOD, 0 );
    amqp_connection_open_t s;
    s.virtual_host := amqp_cstring_bytes(vhost);
    s.capabilities.len := 0;
    s.capabilities.bytes := 0;
    s.insist := 1;

    aResult = amqp_simple_rpc(state,
                             0,
                             AMQP_CONNECTION_OPEN_METHOD,
                             replies,
                             @s);
      if (aResult.reply_type <> AMQP_RESPONSE_NORMAL) then
     begin
      goto out;
     end;
  end;

  aResult.reply_type = AMQP_RESPONSE_NORMAL;
  aResult.reply.id := 0;
  aResult.reply.decoded := 0;
  aResult.library_error := 0;
  amqp_maybe_release_buffers(state);

  out:
  Result:= aResult;

  error_res:
  aResult.reply_type = AMQP_RESPONSE_LIBRARY_EXCEPTION;
  aResult.reply.id := 0;
  aResult.reply.decoded := 0;
  aResult.library_error := res;

  goto out;
end;

amqp_rpc_reply_t amqp_login(amqp_connection_state_t state,
                            PChar vhost,
                            Integer channel_max,
                            Integer frame_max,
                            Integer heartbeat,
                            amqp_sasl_method_const va_list vl	= 0;
const amqp_rpc_reply_t ret	= 1;
const va_start(vl	= 2; sasl_method

type
	vl..va_start(vl	sasl_method = va_list;
	{$EXTERNALSYM vl..va_start(vl	sasl_method}

                            Args: array of inner(state, vhost, channel_max, frame_max, heartbeat,
                         @amqp_empty_table, sasl_method, vl);

  va_end(vl);

  Result:= ret;
 end;

amqp_rpc_reply_t amqp_login_with_function (
	2; sasl_method: vl	=;
	v2: ;
	v3: type;
	= va_list;: vl..va_start(vl	sasl_method;
	vl..va_start(vl	sasl_method}: {$EXTERNALSYM;}
	v6: ;
	array of const  = ;: Args:;
	}t: {$EXTERNALSYM): properties;}

  ret = amqp_login_inner(state, vhost, channel_max, frame_max, heartbeat,
                         client_properties, sasl_method, vl);

  va_end(vl);

  Result:= ret;
 end;

implementation

end.

