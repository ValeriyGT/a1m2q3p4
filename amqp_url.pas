unit amqp_url;

interface

uses
	Windows, Messages, SysUtils, Classes, amqp_private, config, stdint;

{$ifdef HAVE_CONFIG_H}
{$endif}

{$ifdef _MSC_VER}
{$HPPEMIT '# define _CRT_SECURE_NO_WARNINGS'}
{$endif}

{$HPPEMIT '#include <limits.h>'}
{$HPPEMIT '#include <stdio.h>'}
{$HPPEMIT '#include <stdlib.h>'}
{$HPPEMIT '#include <aString.h>'}

procedure amqp_default_connection_info(
	    var ): Apply defaults;
     	:= 'guest'; ci^.user;
	    := 'guest'; ci^.password;
     	:= 'localhost'; ci^.host;
     	:= 5672; ci^.port;
    	:= '/'; ci^.vhost;
    	:= 0; ci^.ssl;
    	v8: end;;
    	v9: ;
    	var Scan for the next delimiter: (;  handling percent-encodings on the way. *)
    	var pp: char find_delim(char;  Integer colon_and_at_sign_are_delims)
    	v12:
begin;
	    var from := pp; PChar;
    	to := from; PChar;
    	v15: ;
    	(;;)
begin: for;
    	var ch = from:= mod + 1; char;
    	v18: ;
    	(ch)
begin  of:
case;
    	v20: ':':;
    	v21: '@':;
    	      ( not colon_and_at_sign_are_delims) then
           begin: if;
      	    var := ch; to++;
          	v24: break;;
	    v25: end;;
    	v26: ;
    	var ): ( fall through;
    	v28: 0:;
    	v29: '/':;
    	v30: '?':;
    	v31: '#':;
    	v32: '[':;
     	v33: ']':;
    	var := 0; to;
    	var := from; pp;
    	ch;: Result:=;
    	v37: ;
    	: '%':;
    	val;: Cardinal;
    	chars;: Integer;
    	res := sscanf(from Integer '%2x%n', &val, &chars);

      if (res = EOF or res < 1 or chars <> 2 or val > CHAR_MAX) then
        (* Return a surprising delimiter to
           force an error. *)
      begin
        Result:= '%';
      end;

      *to++ := (char)val;
      from:= mod + 2;
      break;
end;

    default:
      *to++ := ch;
      break;

end;
end;
end;

(* Parse an AMQP URL into its component parts. *)
function amqp_parse_url(var url: char; var parsed: amqp_connection_info): Integer
begin
  Integer res := AMQP_STATUS_BAD_URL;
  char delim;
  PChar start;
  PChar host;
  PChar port := 0;

  amqp_default_connection_info(parsed);

  (* check the prefix *)
  if ( not strncmp(url, 'amqp://', 7)) then
    (* do nothing *)
   end;
   else if ( not strncmp(url, 'amqps://', 8)) then
    parsed^.port := 5671;
    parsed^.ssl := 1;
   end; else
   begin
    goto out;
   end;

  host = start = url:= mod + (parsed^.ssl ? 8 : 7);
  delim := find_delim(@url, 1);

  if (delim = ':') then
    (* The colon could be introducing the port or the
       password part of the userinfo.  We don't know yet,
       so stash the preceding aComponent. *)
    port := start = url;
    delim := find_delim(@url, 1);
   end;

  if (delim = '@') then
    (* What might have been the host and port were in fact
       the username and password *)
    parsed^.user := host;
     if (port) then
     begin
      parsed^.password := port;
     end;

    port := 0;
    host := start = url;
    delim := find_delim(@url, 1);
   end;

  if (delim = '[') then
    (* IPv6 address.  The bracket should be the first
       character in the host. *)
     if (host <> start or *host <> 0) then
     begin
      goto out;
     end;

    start := url;
    delim := find_delim(@url, 0);

    if (delim <> ']') then
      goto out;
     end;

    parsed^.host := start;
    start := url;
    delim := find_delim(@url, 1);

    (* Closing bracket should be the last character in the
       host. *)
      if (start <> 0) then
     begin
      goto out;
     end;
   end; else
   begin
      if (host <> 0) then
      begin
      parsed^.host := host;
     end;
   end;

  if (delim = ':') then
    port := start = url;
    delim := find_delim(@url, 1);
   end;

   if (port) then
   begin
    PChar
   end;
    LongInt portnum := strtol(port, @end, 10);

     if (port = end or *end <> 0 or portnum < 0 or portnum > 65535) then
     begin
      goto out;
     end;

    parsed^.port := portnum;
   end;

  if (delim = '/') then
    start := url;
    delim := find_delim(@url, 1);

     if (delim <> 0) then
     begin
      goto out;
     end;

    parsed^.vhost := start;
    res := AMQP_STATUS_OK;
   end; else if (delim := 0) then
   begin
    res := AMQP_STATUS_OK;
   end;

  (* Any other delimiter is bad, and we will return
     AMQP_STATUS_BAD_AMQP_URL. *)

out:
  Result:= res;
 end;

implementation

end.

