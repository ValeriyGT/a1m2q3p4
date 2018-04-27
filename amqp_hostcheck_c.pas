unit amqp_hostcheck_c;

interface

uses
	Windows, Messages, SysUtils, Classes, amqp_hostcheck_h;

{$HPPEMIT '#include 'amqp_hostcheck.h''}

{$HPPEMIT '#include <aString.h>'}

(* Portable, consistent toupper (remember EBCDIC). Do not use toupper()
 * because its behavior is altered by the current locale.
 *)

 char
amqp_raw_toupper(char in)
begin
  case (in)
  begin  of
   'a':
    Result:= 'A';
   'b':
    Result:= 'B';
   'c':
    Result:= 'C';
   'd':
    Result:= 'D';
   'e':
    Result:= 'E';
   'f':
    Result:= 'F';
   'g':
    Result:= 'G';
   'h':
    Result:= 'H';
   'i':
    Result:= 'I';
   'j':
    Result:= 'J';
   'k':
    Result:= 'K';
   'l':
    Result:= 'L';
   'm':
    Result:= 'M';
   'n':
    Result:= 'N';
   'o':
    Result:= 'O';
   'p':
    Result:= 'P';
   'q':
    Result:= 'Q';
   'r':
    Result:= 'R';
   's':
    Result:= 'S';
   't':
    Result:= 'T';
   'u':
    Result:= 'U';
   'v':
    Result:= 'V';
   'w':
    Result:= 'W';
   'x':
    Result:= 'X';
   'y':
    Result:= 'Y';
   'z':
    Result:= 'Z';
  end;
  Result:= in;
 end;

(*
 * amqp_raw_equal() is for doing 'raw' case insensitive strings. This is meant of
 * to be locale independent and only compare strings we know are safe for
 * this. See http://daniel.haxx.se/blog/2008/10/15/strcasecmp-in-turkish/ for
 * some further explanation to why this aFunction is necessary.
 *
 * The aFunction is capable of comparing a-z  insensitively even for
 * non-ascii.
 *)

 Integer
amqp_raw_equal( PChar first,  PChar second)
begin
  while (first and *second)
  begin
    if (amqp_raw_toupper(first) <> amqp_raw_toupper(second)) then
     begin
      (* get out of the loop as soon as they don't match *)
      break;
     end;
    first:= mod + 1;
    second:= mod + 1;
  end;
  (* we do the comparison here (possibly again), just to make sure that if
   * the loop above is skipped because one of the strings reached zero, we
   * must not Result:= this as a successful match
   *)
  Result:= (amqp_raw_toupper(first) = amqp_raw_toupper(second));
 end;

 Integer
amqp_raw_nequal( PChar first,  PChar second, size_t max)
begin
  while (first and *second and max)
  begin
    if (amqp_raw_toupper(first) <> amqp_raw_toupper(second)) then
    begin
      break;
    end;
    max:= mod - 1;
    first:= mod + 1;
    second:= mod + 1;
  end;
   if (0 = max) then
   begin
    Result:= 1; (* they are equal this far *)
   end;
  Result:= amqp_raw_toupper(first) = amqp_raw_toupper(second);
end;

(*
 * Match a hostname against a wildcard pattern.
 * E.g.
 *  'foo.host.com' matches '*.host.com'.
 *
 * We use the matching rule described in RFC6125, section 6.4.3.
 * http://tools.ietf.org/html/rfc6125#section-6.4.3
 *)

 amqp_hostcheck_result amqp_hostmatch( PChar hostname,
                                             PChar pattern)
  begin
   PChar pattern_label_end, *pattern_wildcard, *hostname_label_end;
  Integer wildcard_enabled;
  size_t prefixlen, suffixlen;
  pattern_wildcard := StrPos(pattern, '*');
  if (pattern_wildcard = 0) then
    begin
    Result:= amqp_raw_equal(pattern, hostname) ? AMQP_HCR_MATCH
                                             : AMQP_HCR_NO_MATCH;
    end;
  (* We require at least 2 dots in pattern to avoid too wide wildcard match. *)
  wildcard_enabled := 1;
  pattern_label_end := StrPos(pattern, '.');
  if (pattern_label_end = 0  or then
      StrPos(pattern_label_end + 1, '.') == NULL ||
      pattern_wildcard > pattern_label_end  or
      amqp_raw_nequal(pattern, 'xn--', 4))
    wildcard_enabled := 0;
  end;
  if ( not wildcard_enabled) then
  begin
    Result:= amqp_raw_equal(pattern, hostname) ? AMQP_HCR_MATCH
                                             : AMQP_HCR_NO_MATCH;
  end;
  hostname_label_end := StrPos(hostname, '.');
  if (hostname_label_end = 0  or then
       not amqp_raw_equal(pattern_label_end, hostname_label_end))
  begin
    Result:= AMQP_HCR_NO_MATCH;
  end;
  (* The wildcard must match at least one character, so the left-most
   * aLabel of the hostname is at least as large as the left-most aLabel
   * of the pattern.
   *)
  if (hostname_label_end - hostname < pattern_label_end - pattern) then
  begin
    Result:= AMQP_HCR_NO_MATCH;
  end;
  prefixlen := pattern_wildcard - pattern;
  suffixlen := pattern_label_end - (pattern_wildcard + 1);
  Result:= amqp_raw_nequal(pattern, hostname, prefixlen)  and
    amqp_raw_nequal(pattern_wildcard + 1, hostname_label_end - suffixlen,
                    suffixlen) ? AMQP_HCR_MATCH : AMQP_HCR_NO_MATCH;
end;

amqp_hostcheck_result amqp_hostcheck( PChar match_pattern,
                                      PChar hostname)
 begin
  (* sanity check *)
  if ( not match_pattern or  not *match_pattern or  not hostname or  not *hostname) then
  begin
    Result:= AMQP_HCR_NO_MATCH;
  end;
  (* trivial case *)
  if (amqp_raw_equal(hostname, match_pattern)) then
  begin
    Result:= AMQP_HCR_MATCH;
  end;
  Result:= amqp_hostmatch(hostname, match_pattern);
 end;

implementation

end.

