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

module Resource = struct
  type t =
    | CORE
    | CPU
    | DATA
    | FSIZE
    | NOFILE
    | STACK
    | AS

  type defns = {
    core   : int;
    cpu    : int;
    data   : int;
    fsize  : int;
    nofile : int;
    stack  : int;
    as_    : int;
  }

  type index = (int, t) Hashtbl.t

  module Host = struct
    type t = defns * index

    let index_of_defns defns =
      let open Hashtbl in
      let h = create 10 in
      replace h defns.core   CORE;
      replace h defns.cpu    CPU;
      replace h defns.data   DATA;
      replace h defns.fsize  FSIZE;
      replace h defns.nofile NOFILE;
      replace h defns.stack  STACK;
      replace h defns.as_    AS;
      h

    let of_defns defns = (defns, index_of_defns defns)
    let to_defns (defns, _) = defns
  end

  let to_string = function
    | CORE   -> "CORE"
    | CPU    -> "CPU"
    | DATA   -> "DATA"
    | FSIZE  -> "FSIZE"
    | NOFILE -> "NOFILE"
    | STACK  -> "STACK"
    | AS     -> "AS"

  let to_code ~host = let (defns,_) = host in function
    | CORE   -> defns.core
    | CPU    -> defns.cpu
    | DATA   -> defns.data
    | FSIZE  -> defns.fsize
    | NOFILE -> defns.nofile
    | STACK  -> defns.stack
    | AS     -> defns.as_

  module Limit = struct
    type t = Limit of int | Infinity

    let compare x y = match x, y with
      | Infinity, Infinity ->  0
      | Limit _, Infinity  -> -1
      | Infinity, Limit _  ->  1
      | Limit x, Limit y   -> compare x y

    let min x y : t = if compare x y < 0 then x else y

    let to_string = function
      | Limit x -> string_of_int x
      | Infinity -> "infinity"
  end
end

module Host = struct
  type t = {
    resource : Resource.Host.t;
  }
end
