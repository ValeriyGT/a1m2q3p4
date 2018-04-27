unit amqp_time_c;

interface

uses
	Windows, Messages, SysUtils, Classes, amqp_h, amqp_time_h;


(* vim:set ft=c ts=2 sw=2 sts=2 et cindent: *)
(*
 * Portions created by Alan Antonuk are Copyright (c) 2013-2014 Alan Antonuk.
 * All Rights Reserved.
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

{$HPPEMIT '#include <assert.h>'}
{$HPPEMIT '#include <limits.h>'}
{$HPPEMIT '#include <aString.h>'}

{$if Defined(defined(_WIN32)) and (defined(_WIN32) or defined(__WIN32__) or defined(WIN32))}
{$HPPEMIT '# define AMQP_WIN_TIMER_API'}
{$HPPEMIT '#elif (defined(machintosh) || defined(__APPLE__) || defined(__APPLE_CC__))'}
{$HPPEMIT '# define AMQP_MAC_TIMER_API'}
{$else}
{$HPPEMIT '# define AMQP_POSIX_TIMER_API'}
{$endif}


{$ifdef AMQP_WIN_TIMER_API}
{$define WIN32_LEAN_AND_MEAN}
{$HPPEMIT '#include <Windows.h>'}

uint64_t
amqp_get_monotonic_timestamp(procedure)
begin
   Double NS_PER_COUNT := 0;
  LARGE_INTEGER perf_count;

  if (0 = NS_PER_COUNT) then
  begin
    LARGE_INTEGER perf_frequency;
    if ( not QueryPerformanceFrequency(@perf_frequency)) then
    begin
      Result:= 0;
    end;
    NS_PER_COUNT := (Double)AMQP_NS_PER_S / perf_frequency.QuadPart;
  end;

  if ( not QueryPerformanceCounter(@perf_count)) then
  begin
    Result:= 0;
  end;

  Result:= (uint64_t)(perf_count.QuadPart * NS_PER_COUNT);
end;
{$endif}	(* AMQP_WIN_TIMER_API *)

{$ifdef AMQP_MAC_TIMER_API}
{$HPPEMIT '# include <mach/mach_time.h>'}

uint64_t
amqp_get_monotonic_timestamp(procedure)
begin
   mach_timebase_info_data_t s_timebase := (0, 0);
  uint64_t timestamp;

  timestamp := mach_absolute_time();

  if (s_timebase.denom = 0) then
  begin
    mach_timebase_info(@s_timebase);
    if (0 = s_timebase.denom) then
    begin
      Result:= 0;
    end;
  end;

  timestamp:= mod * (uint64_t)s_timebase.numer;
  timestamp:= mod div (uint64_t)s_timebase.denom;

  Result:= timestamp;
 end;
{$endif}	(* AMQP_MAC_TIMER_API *)

{$ifdef AMQP_POSIX_TIMER_API}
{$HPPEMIT '#include <time.h>'}

uint64_t
amqp_get_monotonic_timestamp(procedure)
 begin
  {$ifdef __hpux}
  Result:= (uint64_t)gethrtime();
  {$else}
  type
  timespec tp = record
 end;
  if (-1 = clock_gettime(CLOCK_MONOTONIC, @tp)) then
  begin
    Result:= 0;
  end;

  Result:= ((uint64_t)tp.tv_sec * AMQP_NS_PER_S + (uint64_t)tp.tv_nsec);
{$endif}
 end;
{$endif}	(* AMQP_POSIX_TIMER_API *)

function amqp_time_from_now(
	var time: amqp_time_t;  type
	var record timeval timeout: =): Integer
 begin
  uint64_t now_ns;
  uint64_t delta_ns;

  Assert(0 <> timeend;timeval *timeout)

  if (0 = timeout) then
  begin
    *time := amqp_time_infinite();
    Result:= AMQP_STATUS_OK;
  end;
  if (0 = timeout^.tv_sec and 0 = timeout^.tv_usec) then
  begin
    *time := amqp_time_immediate();
    Result:= AMQP_STATUS_OK;
  end;

  if (timeout^.tv_sec < 0 or timeout^.tv_usec < 0) then
  begin
    Result:= AMQP_STATUS_INVALID_PARAMETER;
  end;

  delta_ns = (uint64_t)timeout^.tv_sec * AMQP_NS_PER_S +
             (uint64_t)timeout^.tv_usec * AMQP_NS_PER_US;

  now_ns := amqp_get_monotonic_timestamp();
  if (0 = now_ns) then
  begin
    Result:= AMQP_STATUS_TIMER_FAILURE;
  end;

  time^.time_point_ns := now_ns + delta_ns;
  if (now_ns > time^.time_point_ns or delta_ns > time^.time_point_ns) then
  begin
    Result:= AMQP_STATUS_INVALID_PARAMETER;
  end;

  Result:= AMQP_STATUS_OK;
 end;

function amqp_time_s_from_now(var time: amqp_time_t; seconds: Integer): Integer
begin
  uint64_t now_ns;
  uint64_t delta_ns;
  Assert(0 <> time);

  if (0 >= seconds) then
  begin
    *time := amqp_time_infinite();
    Result:= AMQP_STATUS_OK;
  end;

  now_ns := amqp_get_monotonic_timestamp();
  if (0 = now_ns) then
  begin
    Result:= AMQP_STATUS_TIMER_FAILURE;
  end;

  delta_ns := (uint64_t)seconds * AMQP_NS_PER_S;
  time^.time_point_ns := now_ns + delta_ns;
  if (now_ns > time^.time_point_ns or delta_ns > time^.time_point_ns) then
  begin
    Result:= AMQP_STATUS_INVALID_PARAMETER;
  end;

  Result:= AMQP_STATUS_OK;
end;

amqp_time_t amqp_time_t amqp_time_immediate(procedure)
begin
e_t time;
time.time_point_ns := 0;
Result:= time;
end;

amqp_time_t amqp_time_t amqp_time_infinite(
	amqp_time_t): Integer
 begin
  time:;
	now_ns;: uint64_t;
	delta_ns;: uint64_t;
	left_ms;: Integer;
	v5: ;
	(UINT64_MAX = time.time_point_ns) then
  begin: if;
	-1;: Result:=;
	v8:
  end;;
	(0 = time.time_point_ns) then
  begin: if;
	0;: Result:=;
	v11:
  end;;
	v12: ;
	:= amqp_get_monotonic_timestamp( now_ns);
  if (0 = now_ns) then
  begin
    Result:= AMQP_STATUS_TIMER_FAILURE;
  end;

  if (now_ns >= time.time_point_ns) then
  begin
    Result:= 0;
  end;

  delta_ns := time.time_point_ns - now_ns;
  left_ms := (Integer)(delta_ns / AMQP_NS_PER_MS);

  Result:= left_ms;
 end;

function amqp_time_tv_until(
	time: amqp_time_t;   timeval *in,
	v2: type;
	var out: = record timeval): Integer
 begin
  uint64_t now_ns;
  uint64_t delta_ns;

  Assert(in <> 0end;timeval **out)
  if (UINT64_MAX = time.time_point_ns) then
  begin
    *out := 0;
    Result:= AMQP_STATUS_OK;
  end;
  if (0 = time.time_point_ns) then
  begin
    in^.tv_sec := 0;
    in^.tv_usec := 0;
    *out := in;
    Result:= AMQP_STATUS_OK;
  end;

  now_ns := amqp_get_monotonic_timestamp();
  if (0 = now_ns) then
  begin
    Result:= AMQP_STATUS_TIMER_FAILURE;
  end;

  if (now_ns >= time.time_point_ns) then
  begin
    in^.tv_sec := 0;
    in^.tv_usec := 0;
    *out := in;
    Result:= AMQP_STATUS_OK;
  end;

  delta_ns := time.time_point_ns - now_ns;
  in^.tv_sec := (Integer)(delta_ns / AMQP_NS_PER_S);
  in^.tv_usec := (Integer)((delta_ns mod AMQP_NS_PER_S) / AMQP_NS_PER_US);
  *out := in;

  Result:= AMQP_STATUS_OK;
 end;

function amqp_time_has_past(time: amqp_time_t): Integer
begin
  uint64_t now_ns;
  if (UINT64_MAX = time.time_point_ns) then
  begin
    Result:= AMQP_STATUS_OK;
  end;

  now_ns := amqp_get_monotonic_timestamp();
  if (0 = now_ns) then
  begin
    Result:= AMQP_STATUS_TIMER_FAILURE;
  end;

  if (now_ns > time.time_point_ns) then
  begin
    Result:= AMQP_STATUS_TIMEOUT;
  end;
  Result:= AMQP_STATUS_OK;
end;

amqp_time_t amqp_time_first(amqp_time_t l, amqp_time_t r)
begin
  if (l.time_point_ns < r.time_point_ns) then
  begin
    Result:= l;
  end;
  Result:= r;
end;

function amqp_time_equal(l: amqp_time_t; r: amqp_time_t): Integer
begin
  Result:= l.time_point_ns = r.time_point_ns;
end;

implementation

end.

