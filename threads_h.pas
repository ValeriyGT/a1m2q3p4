unit threads_h;

{$I AlGun.inc}

interface

uses
	Windows, Messages, SysUtils, Classes;


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

{$ifndef AMQP_THREAD_H}
{$define AMQP_THREAD_H}

{$ifndef WINVER}
{$HPPEMIT '# define WINVER 0x0502'}
{$endif}
{$ifndef WIN32_LEAN_AND_MEAN}
{$HPPEMIT '# define WIN32_LEAN_AND_MEAN'}
{$endif}
{$HPPEMIT '#include <Windows.h>'}

type
	pthread_mutex_t = ^CRITICAL_SECTION;

	{$EXTERNALSYM pthread_mutex_t}
	type
	pthread_once_t = Integer;

	{$EXTERNALSYM pthread_once_t}
	function pthread_self(): DWORD;

function pthread_mutex_init(var v1: pthread_mutex_t; attr: Pointer): Integer;
function pthread_mutex_lock(v1: pthread_mutex_t): Integer;
function pthread_mutex_unlock(v1: pthread_mutex_t): Integer;
{$endif}	(* AMQP_THREAD_H *)

implementation

end.

