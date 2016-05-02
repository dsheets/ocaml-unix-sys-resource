(*
 * Copyright (c) 2016 David Sheets <sheets@alum.mit.edu>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

module Type = Unix_sys_resource_types.C(Unix_sys_resource_types_detected)
module C = Unix_sys_resource_bindings.C(Unix_sys_resource_generated)

let int_of_uint = Unsigned.UInt.to_int

module Resource = struct
  open Sys_resource.Resource

  let host =
    let defns = Type.Resource.({
      core   = int_of_uint rlimit_core;
      cpu    = int_of_uint rlimit_cpu;
      data   = int_of_uint rlimit_data;
      fsize  = int_of_uint rlimit_fsize;
      nofile = int_of_uint rlimit_nofile;
      stack  = int_of_uint rlimit_stack;
      as_    = int_of_uint rlimit_as;
    }) in
    Host.of_defns defns

end

let host = Sys_resource.Host.({
  resource = Resource.host;
})

type rlim = Sys_resource.Resource.Limit.t =
  | Limit of int
  | Infinity

module Rlimit = struct
  type t = {
    cur : rlim;
    max : rlim;
  }

  let infinity = { cur = Infinity; max = Infinity }

  let rlim_of_code uint =
    if uint = Type.Rlim.rlim_infinity
    then Infinity
    else Limit (int_of_uint uint)

  let code_of_rlim = function
    | Infinity -> Type.Rlim.rlim_infinity
    | Limit x -> Unsigned.UInt.of_int x

  let read rlimit = {
    cur = rlim_of_code (Ctypes.getf rlimit Type.Rlimit.rlim_cur);
    max = rlim_of_code (Ctypes.getf rlimit Type.Rlimit.rlim_max);
  }

  let write { cur; max } =
    let rlimit = Ctypes.make Type.Rlimit.t in
    Ctypes.setf rlimit Type.Rlimit.rlim_cur (code_of_rlim cur);
    Ctypes.setf rlimit Type.Rlimit.rlim_max (code_of_rlim max);
    rlimit

  let typ = Ctypes.view ~read ~write Type.Rlimit.t

  let coerce_ptr_to_struct_ptr = Ctypes.(coerce (ptr typ) (ptr Type.Rlimit.t))
end

let getrlimit resource =
  let label = Sys_resource.Resource.to_string resource in
  let host = Resource.host in
  Errno_unix.raise_on_errno ~call:"getrlimit" ~label (fun () ->
    let resource = Sys_resource.Resource.to_code ~host resource in
    let rlimit_ptr =
      Rlimit.(coerce_ptr_to_struct_ptr (Ctypes.allocate typ infinity))
    in
    if C.getrlimit resource rlimit_ptr <> 0
    then None
    else
      let rlimit =
        Ctypes.(!@ (coerce (ptr Type.Rlimit.t) (ptr Rlimit.typ) rlimit_ptr))
      in
      Some Rlimit.(rlimit.cur, rlimit.max)
  )

let setrlimit resource ~soft ~hard =
  let label = Sys_resource.Resource.to_string resource in
  let host = Resource.host in
  Errno_unix.raise_on_errno ~call:"setrlimit" ~label (fun () ->
    let resource = Sys_resource.Resource.to_code ~host resource in
    let rlimit = Rlimit.({ cur = soft; max = hard }) in
    let rlimit_ptr =
      Rlimit.coerce_ptr_to_struct_ptr (Ctypes.allocate Rlimit.typ rlimit)
    in
    if C.setrlimit resource rlimit_ptr <> 0 then None else Some ()
  )
