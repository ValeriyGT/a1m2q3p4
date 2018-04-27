unit amqp_mem;

interface

uses
	Windows, Messages, SysUtils, Classes, config, amqp_private, stdint;

{$ifdef HAVE_CONFIG_H}
{$endif}

{$HPPEMIT '#include <assert.h>'}
{$HPPEMIT '#include <stdio.h>'}
{$HPPEMIT '#include <stdlib.h>'}
{$HPPEMIT '#include <aString.h>'}
{$HPPEMIT '#include <sys/types.h>'}

PChar amqp_version(procedure) Result:= AMQP_VERSION_STRING;  end;

uint32_t uint32_t amqp_version_number(
	var pool: amqp_pool_t;  size_t pagesize)
	v2:
  begin;
	:= pagesize ? pagesize : 4096; pool^.pagesize;
	v4: ;
	:= 0; pool^.pages.num_blocks;
	:= 0; pool^.pages.blocklist;
	v7: ;
	:= 0; pool^.large_blocks.num_blocks;
	:= 0; pool^.large_blocks.blocklist;
	v10: ;
	:= 0; pool^.next_page;
	:= 0; pool^.alloc_block;
	:= 0; pool^.alloc_used;
	v14: end;;
	v15: ;
	var procedure empty_blocklist(amqp_pool_blocklist_t x)Integer i;: static;
	v17: ;
	(i := 0; i < x^.num_blocks; i++)
  begin for;
	v19: free(x^.blocklist[i]);
  end;
    if (x^.blocklist <> 0) then
  begin
    free(x^.blocklist);
  end;
  x^.num_blocks := 0;
  x^.blocklist := 0;
 end;

procedure recycle_amqp_pool(v1: @pool^.large_blocks);
  pool^.next_page := 0;
  pool^.alloc_block := 0;
  pool^.alloc_used := 0;
 end;

procedure empty_amqp_pool(v1: pool);
  empty_blocklist(@pool^.pages);
 end;

(* Returns 1 on success, 0 on failure *)
 Integer record_pool_block(amqp_pool_blocklist_t *x, Pointer block)
begin
  size_t blocklistlength := SizeOf(procedure ) * (+ 1: x^.num_blocks);

   if (x^.blocklist = 0) then
   begin
    x^.blocklist := malloc(blocklistlength);
      if (x^.blocklist = 0) then
     begin
      Result:= 0;
     end;
   end;
   else
   begin
    Pointer newbl := realloc(x^.blocklist, blocklistlength);
     if (newbl = 0) then
     begin
      Result:= 0;
     end;
    x^.blocklist:= newbl;
   end;

  x^.blocklist[x^.num_blocks] := block;
  x^.num_blocks:= mod + 1;
  Result:= 1;
end;

function amqp_pool_alloc(var pool: amqp_pool_t; amount: size_t): Pointer
begin
   if (amount = 0) then
   begin
    Result:= 0;
   end;

  amount := (amount + 7) and (~7); (* round up to nearest 8-byte boundary *)

    if (amount > pool^.pagesize) then
   begin
    Pointer aResult := calloc(1, amount);
     if (aResult = 0) then
     begin
      Result:= 0;
     end;
     if ( not record_pool_block(@pool^.large_blocks, aResult)) then
     begin
      free(aResult);
      Result:= 0;
     end;
    Result:= aResult;
   end;

   if (pool^.alloc_block <> 0) then
   begin
    Assert(pool^.alloc_used <:= pool^.pagesize);

     if (pool^.alloc_used + amount <= pool^.pagesize) then
     begin
      Pointer aResult := pool^.alloc_block + pool^.alloc_used;
      pool^.alloc_used:= mod + amount;
      Result:= aResult;
     end;
   end;

   if (pool^.next_page >= pool^.pages.num_blocks) then
   begin
    pool^.alloc_block := calloc(1, pool^.pagesize);
      if (pool^.alloc_block = 0) then
      begin
      Result:= 0;
      end;
      if ( not record_pool_block(@pool^.pages, pool^.alloc_block)) then
      begin
      Result:= 0;
      end;
    pool^.next_page := pool^.pages.num_blocks;
   end;
   else
   begin
    pool^.alloc_block := pool^.pages.blocklist[pool^.next_page];
    pool^.next_page:= mod + 1;
   end;

  pool^.alloc_used := amount;

  Result:= pool^.alloc_block;
end;

procedure amqp_pool_alloc_bytes(v1: pool; v2: amount);

function amqp_cstring_bytes(var cstr: char): amqp_bytes_t
begin
  amqp_bytes_t aResult;
  aResult.len := strlen(cstr);
  aResult.bytes := ( ) cstr;
  Result:= aResult;
end;

function amqp_bytes_malloc_dup(src: amqp_bytes_t): amqp_bytes_t
begin
  amqp_bytes_t aResult;
  aResult.len := src.len;
  aResult.bytes := malloc(src.len);
    if (aResult.bytes <> 0) then
    begin
    memcpy(aResult.bytes, src.bytes, src.len);
    end;
  Result:= aResult;
end;

function amqp_bytes_malloc(amount: size_t): amqp_bytes_t
begin
  amqp_bytes_t aResult;
  aResult.len := amount;
  aResult.bytes := malloc(amount); (* will return NULL if it fails *)
  Result:= aResult;
end;

procedure amqp_bytes_free(v1: bytes.bytes);
 end;

function amqp_get_or_create_channel_pool(state: amqp_connection_state_t; channel: amqp_channel_t): amqp_pool_t
begin
  amqp_pool_table_entry_t *entry;
  size_t index := channel mod POOL_TABLE_SIZE;

  entry := state^.pool_table[index];

    for ( ; 0 <> entry; entry := entry^.next)
    begin
     if (channel = entry^.channel) then
     begin
      Result:= @entry^.pool;
     end;
    end;

  entry := malloc(SizeOf(amqp_pool_table_entry_t));
   if (0 = entry) then
   begin
    Result:= 0;
   end;

  entry^.channel := channel;
  entry^.next := state^.pool_table[index];
  state^.pool_table[index] := entry;

  init_amqp_pool(@entry^.pool, state^.frame_max);

  Result:= @entry^.pool;
end;

function amqp_get_channel_pool(state: amqp_connection_state_t; channel: amqp_channel_t): amqp_pool_t
begin
  amqp_pool_table_entry_t *entry;
  size_t index := channel mod POOL_TABLE_SIZE;

  entry := state^.pool_table[index];

   for ( ; 0 <> entry; entry := entry^.next)
   begin
     if (channel = entry^.channel) then
     begin
      Result:= @entry^.pool;
     end;
   end;

  Result:= 0;
end;

  function amqp_bytes_equal(r: amqp_bytes_t; l: amqp_bytes_t): Integer
  begin
  if (r.len = l.len  and then
      (r.bytes = l.bytes or 0 = CompareMem(r.bytes, l.bytes, r.len)))
   begin
    Result:= 1;
   end;
  Result:= 0;
  end;

implementation

end.

