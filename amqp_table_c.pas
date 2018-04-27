unit amqp_table_c;

interface

uses
	Windows, Messages, SysUtils, Classes, config, amqp_private_h, amqp_table_h, stdint;

(* vim:set ft=c ts=2 sw=2 sts=2 et cindent: *)
(*
 * ***** aBegin LICENSE BLOCK *****
 * Version: MIT
 *
 * Portions created by Alan Antonuk are Copyright (c) 2012-2013
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

{$HPPEMIT '#include <assert.h>'}
{$HPPEMIT '#include <stdio.h>'}
{$HPPEMIT '#include <stdlib.h>'}
{$HPPEMIT '#include <aString.h>'}

const INITIAL_ARRAY_SIZE = 16;
{$EXTERNALSYM INITIAL_ARRAY_SIZE}
const INITIAL_TABLE_SIZE = 16;
{$EXTERNALSYM INITIAL_TABLE_SIZE}

 function amqp_decode_field_function (
	encoded: amqp_bytes_t;
	var pool: amqp_pool_t;
	var entry: amqp_field_value_t;
	var offset: size_t): value: Integer;

 function amqp_encode_field_function (
	encoded: amqp_bytes_t;
	var entry: amqp_field_value_t;
	var offset: size_t): value: Integer;

(*---------------------------------------------------------------------------*)

 function amqp_decode_array(
	encoded: amqp_bytes_t;
	var pool: amqp_pool_t;
	var output: amqp_array_t;
	var offset: size_t): Integer
begin
  uint32_t arraysize;
  Integer num_entries := 0;
  Integer allocated_entries := INITIAL_ARRAY_SIZE;
  amqp_field_value_t *entries;
  size_t limit;
  Integer res;

  if ( not amqp_decode_32(encoded, offset, @arraysize)) then
  begin
    Result:= AMQP_STATUS_BAD_AMQP_DATA;
  end;

  entries := malloc(allocated_entries * SizeOf(amqp_field_value_t));
  if (entries = 0) then
  begin
    Result:= AMQP_STATUS_NO_MEMORY;
  end;

  limit := *offset + arraysize;
  while (offset < limit)
  begin
    if (num_entries >= allocated_entries) then
    begin
      Pointer newentries;
      allocated_entries := allocated_entries * 2;
      newentries := realloc(entries, allocated_entries * SizeOf(amqp_field_value_t));
      res := AMQP_STATUS_NO_MEMORY;
      if (newentries = 0) then
      begin
        goto out;
      end;

      entries := newentries;
    end;

    res = amqp_decode_field_value(encoded, pool, @entries[num_entries],
                                  offset);
    if (res < 0) then
    begin
      goto out;
    end;

    num_entries:= mod + 1;
  end;

  output^.num_entries := num_entries;
  output^.entries := amqp_pool_alloc(pool, num_entries * SizeOf(amqp_field_value_t));
  (* NULL is legitimate if we requested a zero-length block. *)
  if (output^.entries = 0) then
  begin
    if (num_entries = 0) then
    begin
      res := AMQP_STATUS_OK;
    end;
     else
     begin
      res := AMQP_STATUS_NO_MEMORY;
     end;
    goto out;
   end;

  memcpy(output^.entries, entries, num_entries * SizeOf(amqp_field_value_t));
  res := AMQP_STATUS_OK;

out:
  free(entries);
  Result:= res;
 end;

function amqp_decode_table(
	encoded: amqp_bytes_t;
	var pool: amqp_pool_t;
	var output: amqp_table_t;
	var offset: size_t): Integer
begin
  uint32_t tablesize;
  Integer num_entries := 0;
  amqp_table_entry_t *entries;
  Integer allocated_entries := INITIAL_TABLE_SIZE;
  size_t limit;
  Integer res;

  if ( not amqp_decode_32(encoded, offset, @tablesize)) then
  begin
    Result:= AMQP_STATUS_BAD_AMQP_DATA;
  end;

  entries := malloc(allocated_entries * SizeOf(amqp_table_entry_t));
  if (entries = 0) then
  begin
    Result:= AMQP_STATUS_NO_MEMORY;
  end;

  limit := *offset + tablesize;
  while (offset < limit)
  begin
    uint8_t keylen;

    res := AMQP_STATUS_BAD_AMQP_DATA;
    if ( not amqp_decode_8(encoded, offset, @keylen)) then
    begin
      goto out;
    end;

    if (num_entries >= allocated_entries) then
    begin
      Pointer newentries;
      allocated_entries := allocated_entries * 2;
      newentries := realloc(entries, allocated_entries * SizeOf(amqp_table_entry_t));
      res := AMQP_STATUS_NO_MEMORY;
      if (newentries = 0) then
      begin
        goto out;
      end;

      entries := newentries;
    end;

    res := AMQP_STATUS_BAD_AMQP_DATA;
    if ( not amqp_decode_bytes(encoded, offset, @entries[num_entries].key, keylen)) then
    begin
      goto out;
    end;

    res = amqp_decode_field_value(encoded, pool, @entries[num_entries].value,
                                  offset);
    if (res < 0) then
    begin
      goto out;
    end;

    num_entries:= mod + 1;
  end;

  output^.num_entries := num_entries;
  output^.entries := amqp_pool_alloc(pool, num_entries * SizeOf(amqp_table_entry_t));
  (* NULL is legitimate if we requested a zero-length block. *)
  if (output^.entries = 0) then
  begin
    if (num_entries = 0) then
    begin
      res := AMQP_STATUS_OK;
    end;
     else
     begin
      res := AMQP_STATUS_NO_MEMORY;
     end;
    goto out;
  end;

  memcpy(output^.entries, entries, num_entries * SizeOf(amqp_table_entry_t));
  res := AMQP_STATUS_OK;

out:
  free(entries);
  Result:= res;
end;

 function amqp_decode_field_function (
	encoded: amqp_bytes_t;
	var pool: amqp_pool_t;
	var entry: amqp_field_value_t;
	var offset: size_t): value: Integer
begin
  Integer res := AMQP_STATUS_BAD_AMQP_DATA;

  if ( not amqp_decode_8(encoded, offset, @entry^.kind)) then
  begin
    goto out;
  end;

const TRIVIAL_FIELD_DECODERif ( not amqp_decode_##bits(encoded, offset, @entry^.value.u##bits)) goto out; break;
{$EXTERNALSYM TRIVIAL_FIELD_DECODER}
const SIMPLE_FIELD_DECODER(bits, dest, how) begin  uint##bits##_t val; if ( not amqp_decode_##bits(encoded, offset, @val)) then  goto out; entry^.value.dest = how;  end; break

  case (entry^.kind)
  begin  of
   AMQP_FIELD_KIND_BOOLEAN:
    SIMPLE_FIELD_DECODER(8, boolean, val ? 1 : 0);

   AMQP_FIELD_KIND_I8:
    SIMPLE_FIELD_DECODER(8, i8, (int8_t)val);
   AMQP_FIELD_KIND_U8:
    TRIVIAL_FIELD_DECODER(8);

   AMQP_FIELD_KIND_I16:
    SIMPLE_FIELD_DECODER(16, i16, (int16_t)val);
   AMQP_FIELD_KIND_U16:
    TRIVIAL_FIELD_DECODER(16);

   AMQP_FIELD_KIND_I32:
    SIMPLE_FIELD_DECODER(32, i32, (int32_t)val);
   AMQP_FIELD_KIND_U32:
    TRIVIAL_FIELD_DECODER(32);

   AMQP_FIELD_KIND_I64:
    SIMPLE_FIELD_DECODER(64, i64, (int64_t)val);
   AMQP_FIELD_KIND_U64:
    TRIVIAL_FIELD_DECODER(64);

   AMQP_FIELD_KIND_F32:
    TRIVIAL_FIELD_DECODER(32);
    (* and by punning, f32 magically gets the right value...! *)

   AMQP_FIELD_KIND_F64:
    TRIVIAL_FIELD_DECODER(64);
    (* and by punning, f64 magically gets the right value...! *)

   AMQP_FIELD_KIND_DECIMAL:
    if ( not amqp_decode_8(encoded, offset, @entry^.value.decimal.decimals) then
        or  not amqp_decode_32(encoded, offset, @entry^.value.decimal.value))
    begin
      goto out;
    end;
    break;

   AMQP_FIELD_KIND_UTF8:
    (* AMQP_FIELD_KIND_UTF8 and AMQP_FIELD_KIND_BYTES have the
       same implementation, but different interpretations. *)
    (* fall through *)
   AMQP_FIELD_KIND_BYTES:
   begin
    uint32_t len;
    if ( not amqp_decode_32(encoded, offset, @len) then
        or  not amqp_decode_bytes(encoded, offset, @entry^.value.bytes, len))
    begin
      goto out;
    end;
    break;
   end;

   AMQP_FIELD_KIND_ARRAY:
    res := amqp_decode_array(encoded, pool, @(entry^.value.aArray), offset);
    goto out;

   AMQP_FIELD_KIND_TIMESTAMP:
    TRIVIAL_FIELD_DECODER(64);

   AMQP_FIELD_KIND_TABLE:
    res := amqp_decode_table(encoded, pool, @(entry^.value.table), offset);
    goto out;

   AMQP_FIELD_KIND_VOID:
    break;

  default:
    goto out;
  end;

  res := AMQP_STATUS_OK;

  out:
  Result:= res;
 end;

(*---------------------------------------------------------------------------*)

 function amqp_encode_array(
	encoded: amqp_bytes_t;
	var input: amqp_array_t;
	var offset: size_t): Integer
begin
  size_t start := *offset;
  Integer i, res;

  *offset:= mod + 4; (* size of the array gets filled in later on *)

  for (i := 0; i < input^.num_entries; i++)
  begin
    res := amqp_encode_field_value(encoded, @input^.entries[i], offset);
    if (res < 0) then
    begin
      goto out;
    end;
  end;

  if ( not amqp_encode_32(encoded, @start, (uint32_t)(offset - start - 4))) then
  begin
    res := AMQP_STATUS_TABLE_TOO_BIG;
    goto out;
  end;

  res := AMQP_STATUS_OK;

out:
  Result:= res;
end;

function amqp_encode_table(
	encoded: amqp_bytes_t;
	var input: amqp_table_t;
	var offset: size_t): Integer
begin
  size_t start := *offset;
  Integer i, res;

  *offset:= mod + 4; (* size of the table gets filled in later on *)

  for (i := 0; i < input^.num_entries; i++)
  begin
    if ( not amqp_encode_8(encoded, offset, (uint8_t)input^.entries[i].key.len)) then
    begin
      res := AMQP_STATUS_TABLE_TOO_BIG;
      goto out;
    end;

    if ( not amqp_encode_bytes(encoded, offset, input^.entries[i].key)) then
    begin
      res := AMQP_STATUS_TABLE_TOO_BIG;
      goto out;
    end;

    res := amqp_encode_field_value(encoded, @input^.entries[i].value, offset);
    if (res < 0) then
    begin
      goto out;
    end;
  end;

  if ( not amqp_encode_32(encoded, @start, (uint32_t)(offset - start - 4))) then
  begin
    res := AMQP_STATUS_TABLE_TOO_BIG;
    goto out;
  end;

  res := AMQP_STATUS_OK;

out:
  Result:= res;
end;

 function amqp_encode_field_function (
	encoded: amqp_bytes_t;
	var entry: amqp_field_value_t;
	var offset: size_t): value: Integer
begin
  Integer res := AMQP_STATUS_BAD_AMQP_DATA;

  if ( not amqp_encode_8(encoded, offset, entry^.kind)) then
  begin
    goto out;
  end;

const FIELD_ENCODERval) if ( not amqp_encode_##bits(encoded, offset, val)) then
                                  begin;
                                    {$EXTERNALSYM FIELD_ENCODER}
                                    res := AMQP_STATUS_TABLE_TOO_BIG;
                                    goto out;
                                  end;
                                  break

  case (entry^.kind)
  begin  of
   AMQP_FIELD_KIND_BOOLEAN:
    FIELD_ENCODER(8, entry^.value.boolean ? 1 : 0);

   AMQP_FIELD_KIND_I8:
    FIELD_ENCODER(8, entry^.value.i8);
   AMQP_FIELD_KIND_U8:
    FIELD_ENCODER(8, entry^.value.u8);

   AMQP_FIELD_KIND_I16:
    FIELD_ENCODER(16, entry^.value.i16);
   AMQP_FIELD_KIND_U16:
    FIELD_ENCODER(16, entry^.value.u16);

   AMQP_FIELD_KIND_I32:
    FIELD_ENCODER(32, entry^.value.i32);
   AMQP_FIELD_KIND_U32:
    FIELD_ENCODER(32, entry^.value.u32);

   AMQP_FIELD_KIND_I64:
    FIELD_ENCODER(64, entry^.value.i64);
   AMQP_FIELD_KIND_U64:
    FIELD_ENCODER(64, entry^.value.u64);

   AMQP_FIELD_KIND_F32:
    (* by punning, u32 magically gets the right value...! *)
    FIELD_ENCODER(32, entry^.value.u32);

   AMQP_FIELD_KIND_F64:
    (* by punning, u64 magically gets the right value...! *)
    FIELD_ENCODER(64, entry^.value.u64);

   AMQP_FIELD_KIND_DECIMAL:
    if ( not amqp_encode_8(encoded, offset, entry^.value.decimal.decimals) then
        or  not amqp_encode_32(encoded, offset, entry^.value.decimal.value))
    begin
      res := AMQP_STATUS_TABLE_TOO_BIG;
      goto out;
    end;
    break;

   AMQP_FIELD_KIND_UTF8:
    (* AMQP_FIELD_KIND_UTF8 and AMQP_FIELD_KIND_BYTES have the
       same implementation, but different interpretations. *)
    (* fall through *)
   AMQP_FIELD_KIND_BYTES:
    if ( not amqp_encode_32(encoded, offset, (uint32_t)entry^.value.bytes.len) then
        or  not amqp_encode_bytes(encoded, offset, entry^.value.bytes))
    begin
      res := AMQP_STATUS_TABLE_TOO_BIG;
      goto out;
    end;
    break;

   AMQP_FIELD_KIND_ARRAY:
    res := amqp_encode_array(encoded, @entry^.value.aArray, offset);
    goto out;

   AMQP_FIELD_KIND_TIMESTAMP:
    FIELD_ENCODER(64, entry^.value.u64);

   AMQP_FIELD_KIND_TABLE:
    res := amqp_encode_table(encoded, @entry^.value.table, offset);
    goto out;

   AMQP_FIELD_KIND_VOID:
    break;

  default:
    res := AMQP_STATUS_INVALID_PARAMETER;
    goto out;
   end;

  res := AMQP_STATUS_OK;

`out:
  Result:= res;
 end;

(*---------------------------------------------------------------------------*)

function Integer amqp_table_entry_cmp(var entry1: procedure; var entry2: void): Integer   amqp_table_entry_t  *p1 = (
	const ) entry2;: amqp_table_entry_t;
	v2: ;
	d;: Integer;
	minlen;: size_t;
	v5: ;
	:= p1^.key.len; minlen;
	(p2^.key.len < minlen) then  begin: if;
	:= p2^.key.len; minlen;
	v9: end;;
	v10: ;
	:= CompareMem(p1^.key.bytes d p2^.key.bytes, minlen);
  if (d <> 0) then  begin
    Result:= d;
   end;

  Result:= (Integer)p1^.key.len - (Integer)p2^.key.len;
end;

 Integer
amqp_field_function _clone(var original: amqp_field_value_t; var clone: amqp_field_value_t; var pool: amqp_pool_t): value
begin
  Integer i;
  Integer res;
  clone^.kind := original^.kind;

  case (clone^.kind)
  begin  of
     AMQP_FIELD_KIND_BOOLEAN:
      clone^.value.boolean := original^.value.boolean;
      break;

     AMQP_FIELD_KIND_I8:
      clone^.value.i8 := original^.value.i8;
      break;

     AMQP_FIELD_KIND_U8:
      clone^.value.u8 := original^.value.u8;
      break;

     AMQP_FIELD_KIND_I16:
      clone^.value.i16 := original^.value.i16;
      break;

     AMQP_FIELD_KIND_U16:
      clone^.value.u16 := original^.value.u16;
      break;

     AMQP_FIELD_KIND_I32:
      clone^.value.i32 := original^.value.i32;
      break;

     AMQP_FIELD_KIND_U32:
      clone^.value.u32 := original^.value.u32;
      break;

     AMQP_FIELD_KIND_I64:
      clone^.value.i64 := original^.value.i64;
      break;

     AMQP_FIELD_KIND_U64:
     AMQP_FIELD_KIND_TIMESTAMP:
      clone^.value.u64 := original^.value.u64;
      break;

     AMQP_FIELD_KIND_F32:
      clone^.value.f32 := original^.value.f32;
      break;

     AMQP_FIELD_KIND_F64:
      clone^.value.f64 := original^.value.f64;
      break;

     AMQP_FIELD_KIND_DECIMAL:
      clone^.value.decimal := original^.value.decimal;
      break;

     AMQP_FIELD_KIND_UTF8:
     AMQP_FIELD_KIND_BYTES:
      if (0 = original^.value.bytes.len) then
      begin
        clone^.value.bytes := amqp_empty_bytes;
       end;
       else
       begin
        amqp_pool_alloc_bytes(pool, original^.value.bytes.len, @clone^.value.bytes);
        if (0 = clone^.value.bytes.bytes) then
        begin
          Result:= AMQP_STATUS_NO_MEMORY;
        end;
        memcpy(clone^.value.bytes.bytes, original^.value.bytes.bytes, clone^.value.bytes.len);
       end;
      break;

     AMQP_FIELD_KIND_ARRAY:
      if (0 = original^.value.aArray.entries) then
      begin
        clone^.value.aArray := amqp_empty_array;
      end;
       else
       begin
        clone^.value.aArray.num_entries := original^.value.aArray.num_entries;
        clone^.value.aArray.entries := amqp_pool_alloc(pool, clone^.value.aArray.num_entries * SizeOf(amqp_field_value_t));
        if (0 = clone^.value.aArray.entries) then
        begin
          Result:= AMQP_STATUS_NO_MEMORY;
        end;

        for (i := 0; i < clone^.value.aArray.num_entries; ++i)
        begin
          res := amqp_field_value_clone(@original^.value.aArray.entries[i], @clone^.value.aArray.entries[i], pool);
          if (AMQP_STATUS_OK <> res) then
          begin
            Result:= res;
          end;
        end;
       end;
      break;

     AMQP_FIELD_KIND_TABLE:
      Result:= amqp_table_clone(@original^.value.table, @clone^.value.table, pool);

     AMQP_FIELD_KIND_VOID:
      break;

    default:
      Result:= AMQP_STATUS_INVALID_PARAMETER;
  end;

  Result:= AMQP_STATUS_OK;
 end;


 Integer
amqp_table_entry_clone( amqp_table_entry_t *original, amqp_table_entry_t *clone, amqp_pool_t *pool)
begin
  if (0 = original^.key.len) then
  begin
    Result:= AMQP_STATUS_INVALID_PARAMETER;
  end;

  amqp_pool_alloc_bytes(pool, original^.key.len, @clone^.key);
  if (0 = clone^.key.bytes) then
  begin
    Result:= AMQP_STATUS_NO_MEMORY;
  end;

  memcpy(clone^.key.bytes, original^.key.bytes, clone^.key.len);

  Result:= amqp_field_value_clone(@original^.value, @clone^.value, pool);
end;

function amqp_table_clone(var original: amqp_table_t; var clone: amqp_table_t; var pool: amqp_pool_t): Integer
begin
  Integer i;
  Integer res;
  clone^.num_entries := original^.num_entries;
  if (0 = clone^.num_entries) then
  begin
    *clone := amqp_empty_table;
    Result:= AMQP_STATUS_OK;
  end;

  clone^.entries := amqp_pool_alloc(pool, clone^.num_entries * SizeOf(amqp_table_entry_t));

  if (0 = clone^.entries) then
  begin
    Result:= AMQP_STATUS_NO_MEMORY;
  end;

  for (i := 0; i < clone^.num_entries; ++i)
  begin
    res := amqp_table_entry_clone(@original^.entries[i], @clone^.entries[i], pool);
    if (AMQP_STATUS_OK <> res) then
    begin
      goto error_out1;
    end;
  end;

  Result:= AMQP_STATUS_OK;

error_out1:
  Result:= res;
end;

amqp_table_entry_t amqp_table_construct_utf8_entry( PChar key,
                                                    PChar value)
begin
  amqp_table_entry_t ret;
  ret.key := amqp_cstring_bytes(key);
  ret.value.kind := AMQP_FIELD_KIND_UTF8;
  ret.value.value.bytes := amqp_cstring_bytes(value);
  Result:= ret;
end;

amqp_table_entry_t amqp_table_construct_table_entry( PChar key,
                                                     amqp_table_t *value)
begin
  amqp_table_entry_t ret;
  ret.key := amqp_cstring_bytes(key);
  ret.value.kind := AMQP_FIELD_KIND_TABLE;
  ret.value.value.table := *value;
  Result:= ret;
end;

amqp_table_entry_t amqp_table_construct_bool_entry( PChar key,
                                                    Integer value)
begin
  amqp_table_entry_t ret;
  ret.key := amqp_cstring_bytes(key);
  ret.value.kind := AMQP_FIELD_KIND_BOOLEAN;
  ret.value.value.boolean := value;
  Result:= ret;
end;

function amqp_table_get_entry_by_key(
	var table: amqp_table_t;
	key: amqp_bytes_t): amqp_table_entry_t
begin
  Integer i;
  Assert(table <> 0);
  for (i := 0; i < table^.num_entries; ++i)
  begin
    if (amqp_bytes_equal(table^.entries[i].key, key)) then
    begin
      Result:= @table^.entries[i];
    end;
  end;
  Result:= 0;
end;

implementation

end.

