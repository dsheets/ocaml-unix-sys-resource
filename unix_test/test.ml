(*
 * Copyright (c) 2016 David Sheets <dsheets@docker.com>
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

module Rlimit = struct

  let test_get_set_nofile () =
    let open Sys_resource.Resource in
    let nofile = NOFILE in
    let target = Limit.Limit 128 in
    let (soft, hard) = Sys_resource_unix.getrlimit nofile in
    let soft = Limit.min soft target in
    let hard = Limit.min hard target in
    Sys_resource_unix.setrlimit nofile ~soft ~hard;
    match (soft, hard), Sys_resource_unix.getrlimit nofile with
    | (Limit.Limit soft, Limit.Limit hard), (Limit.Limit s, Limit.Limit h) ->
      Alcotest.(check int) "setrlimit soft" soft s;
      Alcotest.(check int) "setrlimit hard" hard h
    | _, (s, h) ->
      Alcotest.fail
        ("Some nofile rlimit not set: "
         ^Limit.to_string soft^" "
         ^Limit.to_string hard^" "
         ^Limit.to_string s   ^" "
         ^Limit.to_string h)

  let tests = [
    "get-set-nofile", `Quick, test_get_set_nofile;
  ]
end

let tests = [
  "rlimit", Rlimit.tests;
]

let () = Alcotest.run "Sys_resource_unix" tests
