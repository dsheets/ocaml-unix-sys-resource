ocaml-unix-sys-resource
=======================

[ocaml-unix-sys-resource](https://github.com/dsheets/ocaml-unix-sys-resource)
provides access to the features exposed in
[`sys/resource.h`][sys_resource.h] in a way that is not tied to the
implementation on the host system.

The [`Sys_resource`][sys_resource] module provides types and functions
for describing and working with rlimit resources and limits.

The [`Sys_resource_unix`][sys_resource_unix] module provides bindings to
functions that use the types in `Sys_resource`.

Currently, `getrlimit` and `setrlimit` and their corresponding flags are
bound.

[sys_resource.h]: http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/sys_resource.h.html
[sys_resource]: https://github.com/dsheets/ocaml-unix-sys-resource/blob/master/lib/sys_resource.mli
[sys_resource_host]: https://github.com/dsheets/ocaml-unix-sys-resource/blob/master/lib/sys_resource_host.mli
[sys_resource_unix]: https://github.com/dsheets/ocaml-unix-sys-resource/blob/master/unix/sys_resource_unix.mli
[lwt]: http://ocsigen.org/lwt/
