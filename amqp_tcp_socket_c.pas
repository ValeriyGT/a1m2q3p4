unit amqp_tcp_socket_c;

interface

uses
	Windows, Messages, SysUtils, Classes, config, amqp_private, amqp_tcp_socket_h;


(* vim:set ft=c ts=2 sw=2 sts=2 et cindent: *)
(*
 * Copyright 2012-2013 Michael Steinert
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

{$ifdef HAVE_CONFIG_H}
{$endif}

{$HPPEMIT '#include <errno.h>'}
{$ifdef _WIN32}
{$HPPEMIT '# ifndef WIN32_LEAN_AND_MEAN'}
{$HPPEMIT '#  define WIN32_LEAN_AND_MEAN'}
{$HPPEMIT '# endif'}
{$HPPEMIT '# include <WinSock2.h>'}
{$else}
{$HPPEMIT '# include <sys/socket.h>'}
{$HPPEMIT '# include <netinet/in.h>'}
{$HPPEMIT '# include <netinet/tcp.h>'}
{$endif}
{$HPPEMIT '#include <stdio.h>'}
{$HPPEMIT '#include <stdlib.h>'}

type
	= record amqp_tcp_socket_t
begin
   struct amqp_socket_class_t *klass;
  Integer sockfd;
  Integer internal_error;
  Integer state;
end;amqp_tcp_socket_t


 ssize_t
amqp_tcp_socket_send(procedure *base,  void *buf, size_t len, Integer flags)
begin
  type
	 amqp_tcp_socket_t *self := (struct amqp_tcp_socket_t )base = record
end;
  ssize_t res;
  Integer flagz := 0;

  if (-1 = self^.sockfd) then
  begin
    Result:= AMQP_STATUS_SOCKET_CLOSED;
  end;

{$ifdef MSG_NOSIGNAL}
  flagz:= mod or MSG_NOSIGNAL;
{$endif}

{$ifdef MSG_MORE}
  if (flags and AMQP_SF_MORE) then
  begin
    flagz:= mod or MSG_MORE;
  end;
  (* Cygwin defines TCP_NOPUSH, but trying to use it will return not
   * implemented. Disable it here. *)
{$HPPEMIT '#elif defined(TCP_NOPUSH) && !defined(__CYGWIN__)'}
  if (flags and AMQP_SF_MORE and  not (self^.state and AMQP_SF_MORE)) then
  begin
    Integer one := 1;
    res := setsockopt(self^.sockfd, IPPROTO_TCP, TCP_NOPUSH, @one, SizeOf(one));
    if (0 <> res) then
    begin
      self^.internal_error := res;
      Result:= AMQP_STATUS_SOCKET_ERROR;
    end;
    self^.state:= mod or AMQP_SF_MORE;
   end;
    else if ( not (flags and AMQP_SF_MORE) and self^.state and AMQP_SF_MORE) then
    begin
   Integer zero := 0;
   res := setsockopt(self^.sockfd, IPPROTO_TCP, TCP_NOPUSH, @zero, SizeOf(@zero));
   if (0 <> res) then
   begin
     self^.internal_error := res;
     res := AMQP_STATUS_SOCKET_ERROR;
    end;
    else
    begin
     self^.state:= mod and ~AMQP_SF_MORE;
    end;
   end;
{$endif}

start:
{$ifdef _WIN32}
  res := send(self^.sockfd, buf, (Integer)len, flagz);
{$else}
  res := send(self^.sockfd, buf, len, flagz);
{$endif}

  if (res < 0) then
begin
    self^.internal_error := amqp_os_socket_error();
    case (self^.internal_error)
    begin  of
       EINTR:
        goto start;
      {$ifdef _WIN32}
       WSAEWOULDBLOCK:
      {$else}
       EWOULDBLOCK:
      {$endif}
      {$if Defined(EAGAIN)) and (EAGAIN) defined and  EAGAIN <> EWOULDBLOCK}
       EAGAIN:
      {$endif}
        res := AMQP_PRIVATE_STATUS_SOCKET_NEEDWRITE;
        break;
      default:
        res := AMQP_STATUS_SOCKET_ERROR;
    end;
   end;
   else
   begin
    self^.internal_error := 0;
   end;

  Result:= res;
end;

 ssize_t
amqp_tcp_socket_recv(procedure *base, void *buf, size_t len, Integer flags)
begin
  type
	 amqp_tcp_socket_t *self := (struct amqp_tcp_socket_t )base = record
end;
  ssize_t ret;
  if (-1 = self^.sockfd) then
  begin
    Result:= AMQP_STATUS_SOCKET_CLOSED;
  end;

start:
{$ifdef _WIN32}
  ret := recv(self^.sockfd, buf, (Integer)len, flags);
{$else}
  ret := recv(self^.sockfd, buf, len, flags);
{$endif}

  if (0 > ret) then
 begin
    self^.internal_error := amqp_os_socket_error();
    case (self^.internal_error)
    begin  of
       EINTR:
        goto start;
      {$ifdef _WIN32}
       WSAEWOULDBLOCK:
      {$else}
       EWOULDBLOCK:
      {$endif}
      {$if Defined(EAGAIN)) and (EAGAIN) defined and  EAGAIN <> EWOULDBLOCK}
       EAGAIN:
      {$endif}
        ret := AMQP_PRIVATE_STATUS_SOCKET_NEEDREAD;
        break;
      default:
        ret := AMQP_STATUS_SOCKET_ERROR;
    end;
   end;
   else if (0 := ret) then
   begin
    ret := AMQP_STATUS_CONNECTION_CLOSED;
   end;

  Result:= ret;
 end;

 Integer
amqp_tcp_socket_open(procedure *base,  PChar host, Integer port,  timeval *timeout)
begin
  type
	 amqp_tcp_socket_t *self := (struct amqp_tcp_socket_t )base = record
end;
  if (-1 <> self^.sockfd) then
  begin
    Result:= AMQP_STATUS_SOCKET_INUSE;
  end;
  self^.sockfd := amqp_open_socket_noblock(host, port, timeout);
  if (0 > self^.sockfd) then
  begin
    Integer err := self^.sockfd;
    self^.sockfd := -1;
    Result:= err;
  end;
  Result:= AMQP_STATUS_OK;
 end;

 Integer
amqp_tcp_socket_close(procedure *base, AMQP_UNUSED amqp_socket_close_ AMQP_STATUS_SOCKET_ERROR; const;
	end	= 2;: const;
	self^.sockfd := -1; const;
	Result:= AMQP_STATUS_OK; const;
	end	= 3;: const;
	Integer	= 4;: const;
	var amqp_tcp_socket_get_sockfd(procedure base)	= 5;: const;
	begin	= 6;: const;
	type: const;
	var amqp_tcp_socket_t self := (struct amqp_tcp_socket_t )base = record struct;
	Result:= self^.sockfd;
  end;t;
	end	= 7;: const;
	var static proceduretcp_socket_delete( base)	= 8;: const;
	begin	= 9;: const;
	type: const;
	var amqp_tcp_socket_t self := (struct amqp_tcp_socket_t )base = record struct;
	if (self) then  begin	= 10;: end;t;
	amqp_tcp_socket_close(self	= 11; AMQP_SC_NONE: const;
	v20: ;
	type: type;
	var self :..amqp_tcp_socket_close(self	force) = record amqp_tcp_socket_t;
	free(self: end;);
   end;
 end;

   amqp_socket_class_t amqp_tcp_socket_class = (
  amqp_tcp_socket_send, (* send *)
  amqp_tcp_socket_recv, (* recv *)
  amqp_tcp_socket_open, (* open *)
  amqp_tcp_socket_close, (* close *)
  amqp_tcp_socket_get_sockfd, (* get_sockfd *)
  amqp_tcp_socket_delete (* delete *)
);

amqp_socket_t *
amqp_tcp_socket_new(amqp_connection_state_t state)
begin
  type
	 amqp_tcp_socket_t *self := calloc(1, SizeOf(self)) = record
end;
  if ( not self) then
  begin
    Result:= 0;
  end;
  self^.klass := @amqp_tcp_socket_class;
  self^.sockfd := -1;

  amqp_set_socket(state, (amqp_socket_t )self);

  Result:= (amqp_socket_t )self;
 end;

procedure
amqp_tcp_socket_set_sockfd(
	<> @amqp_tcp_socket_class) then
  begin: base^.klass;
  is not of type amqp_tcp_socket_t': amqp_abort('<%p> base);
  end;
  self := (type
	 := (struct amqp_tcp_socket_t )base = record
	end;.sockfd := sockfd;
 end;

implementation

end.

