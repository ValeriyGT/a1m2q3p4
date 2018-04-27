unit stdint;

{$I AlGun.inc}

interface

uses
	Windows, Messages, SysUtils, Classes;

// ISO C9x  compliant stdint.h for Microsoft Visual Studio
// Based on ISO/IEC 9899:TC2 Committee draft (May 6, 2005) WG14/N1124
//
//  Copyright (c) 2006-2008 Alexander Chemeris
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
//   1. Redistributions of source code must retain the above copyright notice,
//      this list of conditions and the following disclaimer.
//
//   2. Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//   3. The name of the author may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
// EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
///////////////////////////////////////////////////////////////////////////////

{$ifndef _MSC_VER}	// [
{$HPPEMIT '#error 'Use this header only with Microsoft Visual C++ compilers!''}
{$endif}	// _MSC_VER ]

{$ifndef _MSC_STDINT_H_}	// [
{$define _MSC_STDINT_H_}

{$if Defined(_MSC_VER) and (_MSC_VER > 1000)}
{$HPPEMIT '#pragma once'}
{$endif}

{$HPPEMIT '#include <limits.h>'}

// For Visual Studio 6 in C++ mode and for many Visual Studio versions when
// compiling for ARM we should wrap <wchar.h> include with 'extern "C++" {}'
// or compiler give many errors like this:
//   error C2733: second C linkage of overloaded function 'wmemchr' not allowed
{$ifdef __cplusplus}
//extern "C" {
{$endif}
{$HPPEMIT '#  include <wchar.h>'}
{$ifdef __cplusplus}
 end;
{$endif}

// Define _W64 macros to mark types changing their size, like intptr_t.
{$ifndef _W64}
{$HPPEMIT '#  if !defined(__midl) && (defined(_X86_) || defined(_M_IX86)) && _MSC_VER >= 1300'}
{$HPPEMIT '#     define _W64 __w64'}
{$HPPEMIT '#  else'}
{$HPPEMIT '#     define _W64'}
{$HPPEMIT '#  endif'}
{$endif}


// 7.18.1 Integer types

// 7.18.1.1 Exact-width integer types

// Visual Studio 6 and Embedded Visual C++ 4 doesn't
// realize that, e.g. char has the same size as __int8
// so we give up on __intX for them.
{$if Defined(_MSC_VER) and (_MSC_VER < 1300)}
   type
	int8_t = ShortInt;

	{$EXTERNALSYM int8_t}
	type
	int16_t = SmallInt;

	{$EXTERNALSYM int16_t}
	  type
	int32_t = Integer;

	{$EXTERNALSYM int32_t}
	type
	uint8_t = Byte;

	{$EXTERNALSYM uint8_t}
	  type
	uint16_t = Word;

	{$EXTERNALSYM uint16_t}
	type
	uint32_t = Cardinal;

	{$EXTERNALSYM uint32_t}
	$else}
   type
	int8_t = ShortInt;

	{$EXTERNALSYM int8_t}
	type
	int16_t = SmallInt;

	{$EXTERNALSYM int16_t}
	  type
	int32_t = Integer;

	{$EXTERNALSYM int32_t}
	type
	uint8_t = Byte;

	{$EXTERNALSYM uint8_t}
	  type
	uint16_t = Word;

	{$EXTERNALSYM uint16_t}
	type
	uint32_t = Cardinal;

	{$EXTERNALSYM uint32_t}
	$endif}
type
	int64_t = Int64;

	{$EXTERNALSYM int64_t}
	type
	uint64_t = Int64;

	{$EXTERNALSYM uint64_t}

// 7.18.1.2 Minimum-width integer types
type
	int_least8_t = int8_t;

	{$EXTERNALSYM int_least8_t}
	type
	int_least16_t = int16_t;

	{$EXTERNALSYM int_least16_t}
	ype int32_t   int_least32_t;
type
	int_least64_t = int64_t;

	{$EXTERNALSYM int_least64_t}
	type
	uint_least8_t = uint8_t;

	{$EXTERNALSYM uint_least8_t}
	ype uint16_t  uint_least16_t;
type
	uint_least32_t = uint32_t;

	{$EXTERNALSYM uint_least32_t}
	type
	uint_least64_t = uint64_t;

	{$EXTERNALSYM uint_least64_t}
	// 7.18.1.3 Fastest minimum-width integer types
type
	int_fast8_t = int8_t;

	{$EXTERNALSYM int_fast8_t}
	type
	int_fast16_t = int16_t;

	{$EXTERNALSYM int_fast16_t}
	ype int32_t   int_fast32_t;
type
	int_fast64_t = int64_t;

	{$EXTERNALSYM int_fast64_t}
	type
	uint_fast8_t = uint8_t;

	{$EXTERNALSYM uint_fast8_t}
	ype uint16_t  uint_fast16_t;
type
	uint_fast32_t = uint32_t;

	{$EXTERNALSYM uint_fast32_t}
	type
	uint_fast64_t = uint64_t;

	{$EXTERNALSYM uint_fast64_t}
	// 7.18.1.4 Integer types capable of holding object pointers
{$ifdef _WIN64}	// [
   type
	intptr_t = Int64;

	{$EXTERNALSYM intptr_t}
	type
	uintptr_t = Int64;

	{$EXTERNALSYM uintptr_t}
	$else}	// _WIN64 ][
   type
	Integer   intptr_t = _W64;

	{$EXTERNALSYM Integer   intptr_t}
	type
	Cardinal uintptr_t = _W64;

	{$EXTERNALSYM Cardinal uintptr_t}
	$endif}	// _WIN64 ]

// 7.18.1.5 Greatest-width integer types
type
	intmax_t = int64_t;

	{$EXTERNALSYM intmax_t}
	type
	uintmax_t = uint64_t;

	{$EXTERNALSYM uintmax_t}

// 7.18.2 Limits of specified-width integer types

{$if Defined(__cplusplus)) and (__cplusplus)  not defined or  defined(__STDC_LIMIT_MACROS)}	// [   See footnote 220 at page 257 and footnote 221 at page 259

// 7.18.2.1 Limits of exact-width integer types
const INT8_MIN = ((int8_t)_I8_MIN)
const INT8_MAX _I8_MAX
const INT16_MIN ((int16_t)_I16_MIN)
const INT16_MAX _I16_MAX
const INT32_MIN ((int32_t)_I32_MIN)
const INT32_MAX _I32_MAX
const INT64_MIN ((int64_t)_I64_MIN)
const INT64_MAX _I64_MAX
const UINT8_MAX _UI8_MAX
const UINT16_MAX _UI16_MAX
const UINT32_MAX _UI32_MAX
const UINT64_MAX _UI64_MAX;

//
{$EXTERNALSYM INT8_MIN}/ 7.18.2.2 Limits of minimum-width integer types
const INT_LEAST8_MIN = INT8_MIN
const INT_LEAST8_MAX INT8_MAX
const INT_LEAST16_MIN INT16_MIN
const INT_LEAST16_MAX INT16_MAX
const INT_LEAST32_MIN INT32_MIN
const INT_LEAST32_MAX INT32_MAX
const INT_LEAST64_MIN INT64_MIN
const INT_LEAST64_MAX INT64_MAX
const UINT_LEAST8_MAX UINT8_MAX
const UINT_LEAST16_MAX UINT16_MAX
const UINT_LEAST32_MAX UINT32_MAX
const UINT_LEAST64_MAX UINT64_MAX;

//
{$EXTERNALSYM INT_LEAST8_MIN}/ 7.18.2.3 Limits of fastest minimum-width integer types
const INT_FAST8_MIN = INT8_MIN
const INT_FAST8_MAX INT8_MAX
const INT_FAST16_MIN INT16_MIN
const INT_FAST16_MAX INT16_MAX
const INT_FAST32_MIN INT32_MIN
const INT_FAST32_MAX INT32_MAX
const INT_FAST64_MIN INT64_MIN
const INT_FAST64_MAX INT64_MAX
const UINT_FAST8_MAX UINT8_MAX
const UINT_FAST16_MAX UINT16_MAX
const UINT_FAST32_MAX UINT32_MAX
const UINT_FAST64_MAX UINT64_MAX;

//
{$EXTERNALSYM INT_FAST8_MIN}/ 7.18.2.4 Limits of integer types capable of holding object pointers
{$ifdef _WIN64}	// [
{$HPPEMIT '#  define INTPTR_MIN   INT64_MIN'}
{$HPPEMIT '#  define INTPTR_MAX   INT64_MAX'}
{$HPPEMIT '#  define UINTPTR_MAX  UINT64_MAX'}
{$else}	// _WIN64 ][
{$HPPEMIT '#  define INTPTR_MIN   INT32_MIN'}
{$HPPEMIT '#  define INTPTR_MAX   INT32_MAX'}
{$HPPEMIT '#  define UINTPTR_MAX  UINT32_MAX'}
{$endif}	// _WIN64 ]

// 7.18.2.5 Limits of greatest-width integer types
const INTMAX_MIN = INT64_MIN
const INTMAX_MAX INT64_MAX
const UINTMAX_MAX UINT64_MAX;

//
{$EXTERNALSYM INTMAX_MIN}/ 7.18.3 Limits of other integer types

{$ifdef _WIN64}	// [
{$HPPEMIT '#  define PTRDIFF_MIN  _I64_MIN'}
{$HPPEMIT '#  define PTRDIFF_MAX  _I64_MAX'}
{$else}	// _WIN64 ][
{$HPPEMIT '#  define PTRDIFF_MIN  _I32_MIN'}
{$HPPEMIT '#  define PTRDIFF_MAX  _I32_MAX'}
{$endif}	// _WIN64 ]

const SIG_ATOMIC_MIN = INT_MIN
const SIG_ATOMIC_MAX INT_MAX

{$ifndef SIZE_MAX};	//
{$EXTERNALSYM SIG_ATOMIC_MIN}/ [
{$HPPEMIT '#  ifdef _WIN64'}	// [
{$HPPEMIT '#     define SIZE_MAX  _UI64_MAX'}
{$HPPEMIT '#  else'}	// _WIN64 ][
{$HPPEMIT '#     define SIZE_MAX  _UI32_MAX'}
{$HPPEMIT '#  endif'}	// _WIN64 ]
{$endif}	// SIZE_MAX ]

// WCHAR_MIN and WCHAR_MAX are also defined in <wchar.h>
{$ifndef WCHAR_MIN}	// [
{$HPPEMIT '#  define WCHAR_MIN  0'}
{$endif}	// WCHAR_MIN ]
{$ifndef WCHAR_MAX}	// [
{$HPPEMIT '#  define WCHAR_MAX  _UI16_MAX'}
{$endif}	// WCHAR_MAX ]

const WINT_MIN = 0
const WINT_MAX _UI16_MAX

{$endif};	//
{$EXTERNALSYM WINT_MIN}/ __STDC_LIMIT_MACROS ]


// 7.18.4 Limits of other integer types

{$if Defined(__cplusplus)) and (__cplusplus)  not defined or  defined(__STDC_CONSTANT_MACROS)}	// [   See footnote 224 at page 260

// 7.18.4.1 Macros for minimum-width integer constants

const INT8_Cval##i8
const INT16_C(val) val##i16
const INT32_C(val) val##i32
const INT64_C(val) val##i64

const UINT8_C(val) val##ui8
const UINT16_C(val) val##ui16
const UINT32_C(val) val##ui32
const UINT64_C(val) val##ui64

/;
{$EXTERNALSYM INT8_C}/ 7.18.4.2 Macros for greatest-width integer constants
const INTMAX_C = INT64_C
const UINTMAX_C UINT64_C

{$endif};	//
{$EXTERNALSYM INTMAX_C}/ __STDC_CONSTANT_MACROS ]


{$endif}	// _MSC_STDINT_H_ ]

implementation
end.

