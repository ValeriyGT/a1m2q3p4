unit config;

{$I AlGun.inc}

interface

uses
	Windows, Messages, SysUtils, Classes;

(* vim:set ft=c ts=2 sw=2 sts=2 et cindent: *)
{$ifndef CONFIG_H}
{$define CONFIG_H}

{$ifndef __cplusplus}
{$HPPEMIT '# define  $begin C_INLINE_KEYWORD end;'}
{$endif}

{$HPPEMIT '#cmakedefine HAVE_HTONLL'}

{$HPPEMIT '#cmakedefine HAVE_SELECT'}

{$HPPEMIT '#cmakedefine HAVE_POLL'}

const AMQ_PLATFORM = '@CMAKE_SYSTEM@'

{$endif};	(* CONFIG_H *)
{$EXTERNALSYM AMQ_PLATFORM})

implementation

end.

