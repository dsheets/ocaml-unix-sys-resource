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

open Ctypes

module C(F: Cstubs.Types.TYPE) = struct

  module Resource = struct
    let rlimit_core   = F.(constant "RLIMIT_CORE" uint)
    let rlimit_cpu    = F.(constant "RLIMIT_CPU" uint)
    let rlimit_data   = F.(constant "RLIMIT_DATA" uint)
    let rlimit_fsize  = F.(constant "RLIMIT_FSIZE" uint)
    let rlimit_nofile = F.(constant "RLIMIT_NOFILE" uint)
    let rlimit_stack  = F.(constant "RLIMIT_STACK" uint)
    let rlimit_as     = F.(constant "RLIMIT_AS" uint)
  end

  module Rlim = struct
    let t = F.(typedef uint) "rlim_t"
    
    let rlim_infinity = F.(constant "RLIM_INFINITY" t)
  end

  module Rlimit = struct    
    type t

    let lift = F.lift_typ
    let uint_t = lift uint

    let t : t structure F.typ = lift (structure "rlimit")
    let ( -:* ) s x = F.field t s x
    let rlim_cur = "rlim_cur"       -:* Rlim.t
    let rlim_max = "rlim_max"       -:* Rlim.t
    let () = F.seal t
  end

end
