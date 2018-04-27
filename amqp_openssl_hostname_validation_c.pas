unit amqp_openssl_hostname_validation_c;

interface

uses
	Windows, Messages, SysUtils, Classes, amqp_openssl_hostname_validation_h, amqp_hostcheck_h;


(* vim:set ft=c ts=2 sw=2 sts=2 et cindent: *)
(*
 * Copyright (C) 2012, iSEC Partners.
 * Copyright (C) 2015 Alan Antonuk.
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


(* Originally from:
 * https://github.com/iSECPartners/ssl-conservatory
 * https://wiki.openssl.org/index.php/Hostname_validation
 *)

{$HPPEMIT '#include <openssl/x509v3.h>'}
{$HPPEMIT '#include <openssl/ssl.h>'}


const HOSTNAME_MAX_SIZE = 255;
{$EXTERNALSYM HOSTNAME_MAX_SIZE}

(**
* Tries to find a match for hostname in the certificate's Common Name field.
*
* Returns AMQP_HVR_MATCH_FOUND if a match was found.
* Returns AMQP_HVR_MATCH_NOT_FOUND if no matches were found.
* Returns AMQP_HVR_MALFORMED_CERTIFICATE if the Common Name had a NUL character embedded in it.
* Returns AMQP_HVR_ERROR if the Common Name could not be extracted.
*)
 amqp_hostname_validation_result amqp_matches_common_name(
     PChar hostname, const X509 = *server_cert)
begin
  Integer common_name_loc := -1;
  X509_NAME_ENTRY *common_name_entry := 0;
  ASN1_STRING *common_name_asn1 := 0;
  PChar common_name_str := 0;;

  //
{$EXTERNALSYM X509}/ Find the position of the CN field in the Subject field of the certificate
  common_name_loc = X509_NAME_get_index_by_NID(
      X509_get_subject_name((X509 )server_cert), NID_commonName, -1);
  if (common_name_loc < 0) then
  begin
    Result:= AMQP_HVR_ERROR;
  end;

  // Extract the CN field
  common_name_entry = X509_NAME_get_entry(
      X509_get_subject_name((X509 )server_cert), common_name_loc);
  if (common_name_entry = 0) then
   begin
    Result:= AMQP_HVR_ERROR;
   end;

  // Convert the CN field to a C string
  common_name_asn1 := X509_NAME_ENTRY_get_data(common_name_entry);
  if (common_name_asn1 = 0) then
  begin
    Result:= AMQP_HVR_ERROR;
  end;
  common_name_str := (char )ASN1_STRING_data(common_name_asn1);

  // Make sure there isn't an embedded NUL character in the CN
  if ((size_t)ASN1_STRING_length(common_name_asn1) <> strlen(common_name_str)) then
   begin
    Result:= AMQP_HVR_MALFORMED_CERTIFICATE;
   end;

  // Compare expected hostname with the CN
  if (amqp_hostcheck(common_name_str, hostname) = AMQP_HCR_MATCH) then
   begin
    Result:= AMQP_HVR_MATCH_FOUND;
   end;
   else
   begin
    Result:= AMQP_HVR_MATCH_NOT_FOUND;
   end;
end;

(**
* Tries to find a match for hostname in the certificate's Subject Alternative
* Name extension.
*
* Returns AMQP_HVR_MATCH_FOUND if a match was found.
* Returns AMQP_HVR_MATCH_NOT_FOUND if no matches were found.
* Returns AMQP_HVR_MALFORMED_CERTIFICATE if any of the hostnames had a NUL
* character embedded in it.
* Returns AMQP_HVR_NO_SAN_PRESENT if the SAN extension was not present in the
* certificate.
*)
 amqp_hostname_validation_result amqp_matches_subject_alternative_name(
     PChar hostname, const X509 = *server_cert)
begin
  amqp_hostname_validation_result aResult := AMQP_HVR_MATCH_NOT_FOUND;
  Integer i;
  Integer san_names_nb := -1;
  STACK_OF(GENERAL_NAME) *san_names := 0;;


  {$EXTERNALSYM X509}/ Try to extract the names within the SAN extension from the certificate
  san_names =
      X509_get_ext_d2i((X509 )server_cert, NID_subject_alt_name, 0, 0);
  if (san_names = 0) then
  begin
    Result:= AMQP_HVR_NO_SAN_PRESENT;
  end;
  san_names_nb := sk_GENERAL_NAME_num(san_names);

  // Check each name within the extension
  for (i := 0; i < san_names_nb; i++)
  begin
     GENERAL_NAME *current_name := sk_GENERAL_NAME_value(san_names, i);

    if (current_name^.aType = GEN_DNS) then
     begin
      // Current name is a DNS name, let's check it
      PChar dns_name := (char )ASN1_STRING_data(current_name^.d.dNSName);

      // Make sure there isn't an embedded NUL character in the DNS name
      if ((size_t)ASN1_STRING_length(current_name^.d.dNSName) then   <>
          strlen(dns_name))
       begin
        aResult := AMQP_HVR_MALFORMED_CERTIFICATE;
        break;
       end;
       else
       begin   // Compare expected hostname with the DNS name
        if (amqp_hostcheck(dns_name, hostname) = AMQP_HCR_MATCH) then
        begin
          aResult := AMQP_HVR_MATCH_FOUND;
          break;
         end;
       end;
     end;
   end;
  sk_GENERAL_NAME_pop_free(san_names, GENERAL_NAME_free);

  Result:= aResult;
 end;

(**
* Validates the server's identity by looking for the expected hostname in the
* server's certificate. As described in RFC 6125, it first tries to find a match
* in the Subject Alternative Name extension. If the extension is not present in
* the certificate, it checks the Common Name instead.
*
* Returns AMQP_HVR_MATCH_FOUND if a match was found.
* Returns AMQP_HVR_MATCH_NOT_FOUND if no matches were found.
* Returns AMQP_HVR_MALFORMED_CERTIFICATE if any of the hostnames had a NUL
* character embedded in it.
* Returns AMQP_HVR_ERROR if there was an error.
*)
amqp_hostname_validation_result amqp_ssl_validate_hostname(
     PChar hostname, const X509 = *server_cert)

begin
  amqp_hostname_validation_result aResult;

  if ((hostname = 0) or (server_cert = 0)) then  Result:= AMQP_HVR_ERROR;;


  {$EXTERNALSYM X509}/ First try the Subject Alternative Names extension
  aResult := amqp_matches_subject_alternative_name(hostname, server_cert);
  if (aResult = AMQP_HVR_NO_SAN_PRESENT) then
  begin
    // Extension was not found: try the Common Name
    aResult := amqp_matches_common_name(hostname, server_cert);
  end;

  Result:= aResult;
 end;

implementation

end.
