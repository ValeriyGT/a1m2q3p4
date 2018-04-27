unit amqp_hostcheck_h;

interface

uses
	Windows, Messages, SysUtils, Classes;


(* vim:set ft=c ts=2 sw=2 sts=2 et cindent: *)
{$ifndef librabbitmq_amqp_hostcheck_h}
{$define librabbitmq_amqp_hostcheck_h}

(*
 * Copyright 1996-2014 Daniel Stenberg <daniel@haxx.se>.
 * Copyright 2014 Michael Steinert
 *
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF THIRD PARTY RIGHTS.
 *  NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER  AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM,  OF OR  CONNECTION WITH THE SOFTWARE OR THE
 * USE OR OTHER DEALINGS  THE SOFTWARE.
 *
 * Except as contained in this notice, the name of a copyright holder shall
 * not be used in advertising or otherwise to promote the sale, use or other
 * dealings in this Software without prior written authorization of the
 * copyright holder.
 *)

const AMQP_HCR_NO_MATCH = 0;
const AMQP_HCR_MATCH = 1;

type
	amqp_hostcheck_result = AMQP_HCR_NO_MATCH..AMQP_HCR_MATCH;
	{$EXTERNALSYM amqp_hostcheck_result}


(**
 * Determine whether hostname matches match_pattern.
 *
 * match_pattern may include wildcards.
 *
 * Match is performed based on the rules set forth in RFC6125 section 6.4.3.
 * http://tools.ietf.org/html/rfc6125#section-6.4.3
 *
 * param match_pattern RFC6125 compliant pattern
 * param hostname to match against
 * returns AMQP_HCR_MATCH if its a match, AMQP_HCR_NO_MATCH otherwise.
 *)
function amqp_hostcheck(
	match_pattern: PChar;
	hostname: PChar): amqp_hostcheck_result;

{$endif}

implementation

end.

