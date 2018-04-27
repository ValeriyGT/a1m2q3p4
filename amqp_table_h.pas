unit amqp_table_h;

interface

uses
	Windows, Messages, SysUtils, Classes, amqp_h, amqp_private;


(* vim:set ft=c ts=2 sw=2 sts=2 et cindent: *)
(*
 * ***** aBegin LICENSE BLOCK *****
 * Version: MIT
 *
 * Portions created by Alan Antonuk are Copyright (c) 2014 Alan Antonuk.
 * All Rights Reserved.
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
{$ifndef AMQP_TABLE_H}
{$define AMQP_TABLE_H}

(**
 * Initializes a table entry with utf-8 aString aType value.
 *
 * param [in] key the table entry key. The aString must remain valid for the
 * life of the resulting amqp_table_entry_t.
 * param [in] value the aString value. The aString must remain valid for the life
 * of the resulting amqp_table_entry_t.
 * returns An initialized table entry.
 *)
amqp_table_entry_t amqp_table_construct_utf8_entry( PChar key,
                                                    PChar value);

(**
 * Initializes a table entry with table aType value.
 *
 * param [in] key the table entry key. The aString must remain value for the
 * life of the resulting amqp_table_entry_t.
 * param [in] value the amqp_table_t value. The table must remain valid for the
 * life of the resulting amqp_table_entry_t.
 * returns An initialized table entry.
 *)
amqp_table_entry_t amqp_table_construct_table_entry( PChar key,
                                                     amqp_table_t *value);

(**
 * Initializes a table entry with boolean aType value.
 *
 * param [in] key the table entry key. The aString must remain value for the
 * life of the resulting amqp_table_entry_t.
 * param [in] value the boolean value. 0 means false, any other value is true.
 * returns An initialized table entry.
 *)
amqp_table_entry_t amqp_table_construct_bool_entry( PChar key,
                                                    Integer value);

(**
 * Searches a table for an entry with a matching key.
 *
 * param [in] table the table to search.
 * param [in] key the aString to search with.
 * returns a aPointer to the table entry in the table if a matching key can be
 * found, 0 otherwise.
 *)
function amqp_table_get_entry_by_key(
	var table: amqp_table_t;
	key: amqp_bytes_t): amqp_table_entry_t;

{$endif}	(* AMQP_TABLE_H *)

implementation

end.

