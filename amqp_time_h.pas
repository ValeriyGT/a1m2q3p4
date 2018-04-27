unit amqp_time_h;

interface

uses
  Windows, Messages, SysUtils, Classes, stdint;


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
{$ifndef AMQP_TIMER_H}
{$define AMQP_TIMER_H}

{$ifdef _WIN32}
{$HPPEMIT '# ifndef WINVER'}
{$HPPEMIT '#  define WINVER 0x0502'}
{$HPPEMIT '# endif'}
{$HPPEMIT '# ifndef WIN32_LEAN_AND_MEAN'}
{$HPPEMIT '#  define WIN32_LEAN_AND_MEAN'}
{$HPPEMIT '# endif'}
{$HPPEMIT '# include <Winsock2.h>'}
{$else}
{$HPPEMIT '# include <sys/time.h>'}
{$endif}

const AMQP_MS_PER_S = 1000;
{$EXTERNALSYM AMQP_MS_PER_S}
const AMQP_US_PER_MS = 1000;
{$EXTERNALSYM AMQP_US_PER_MS}
const AMQP_NS_PER_S = 1000000000;
{$EXTERNALSYM AMQP_NS_PER_S}
const AMQP_NS_PER_MS = 1000000;
{$EXTERNALSYM AMQP_NS_PER_MS}
const AMQP_NS_PER_US = 1000;
{$EXTERNALSYM AMQP_NS_PER_US}

(* This represents a point in time in reference to a monotonic clock.
 *
 * The internal representation is ns, relative to the monotonic clock.
 *
 * There are two 'special' values:
 * - 0: means 'this instant', its meant for polls with a 0-timeout, or
 *   non-blocking option
 * - UINT64_MAX: means 'at infinity', its mean for polls with an infinite
 *   timeout
 *)
type
	amqp_time_t_ = record
		time_point_ns: uint64_t;
	end;
	amqp_time_t = amqp_time_t_;
	{$EXTERNALSYM amqp_time_t}


(* Gets a monotonic timestamp. This will return 0 if the underlying call to the
 * system fails.
 *)
uint64_t amqp_get_monotonic_timestamp(procedure);
(* Get a amqp_time_t that is timeout from now.
 * If timeout is 0, an amqp_time_infinite() is created.
 * If timeout = (0, 0)), an amqp_time_immediate() is created.
 *
 * Returns AMQP_STATUS_OK on success.
 * AMQP_STATUS_INVALID_PARAMETER if timeout is invalid
 * AMQP_STATUS_TIMER_FAILURE if the underlying call to get the current timestamp
 * fails.
 *)
function amqp_time_from_now(var time: amqp_time_t; var timeval timeout: struct): Integer = record
	end;now.
 * If seconds <= 0, then amqp_time_infinite() is created.
 *
 * Returns AMQP_STATUS_OK on success.
 * AMQP_STATUS_TIMER_FAILURE if the underlying call to get the current timestamp
 * fails.
 *)
function amqp_time_s_from_now(var time: amqp_time_t; seconds: Integer): Integer;

(* Create an immediate amqp_time_t *)
function amqp_time_immediate(): amqp_time_t;

(* Create an infinite amqp_time_t *)
function amqp_time_infinite(): amqp_time_t;

(* Gets the number of ms until the amqp_time_t, suitable for the timeout
 * parameter in poll().
 *
 * -1 will be returned for amqp_time_infinite values.
 * 0 will be returned for amqp_time_immediate values.
 * AMQP_STATUS_TIMEOUT will be returned if time was in the past.
 * AMQP_STATUS_TIMER_FAILURE will be returned if the underlying call to get the
 * current timestamp fails.
 *)
function amqp_time_ms_until(time: amqp_time_t): Integer;

(* Gets a timeval filled in with the time until amqp_time_t. Suitable for the
 * parameter in select().
 *
 * The in parameter specifies a storage location for *out.
 * If time is an inf timeout, then *out = 0.
 * If time is a 0-timeout or the timer has expired, then *out := (0, 0 end;
 * Otherwise *out is set to the time left on the time.
 *
 * AMQP_STATUS_OK will be returned if successfully filled.
 * AMQP_STATUS_TIMER_FAILURE is returned when the underlying call to get the
 * current timestamp fails.
 *)
function amqp_time_tv_until(
	time: function;   timeval *in,
	v2: type;
	var out: timeval): amqp_time_t: Integer = record
	end;

(* Test whether current time is past the provided time.
 *
 * TODO: this isn't a great interface to use. Fix this.
 *
 * Return AMQP_STATUS_OK if time has not past
 * Return AMQP_STATUS_TIMEOUT if time has past
 * Return AMQP_STATUS_TIMER_FAILURE if the underlying call to get the current
 * timestamp fails.
 *)
function amqp_time_has_past(time: amqp_time_t): Integer;

(* Return the time value that happens first *)
function amqp_time_first(l: amqp_time_t; r: amqp_time_t): amqp_time_t;

function amqp_time_equal(l: amqp_time_t; r: amqp_time_t): Integer;
{$endif}	(* AMQP_TIMER_H *)

implementation

end.

