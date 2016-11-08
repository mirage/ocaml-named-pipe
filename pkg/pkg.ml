#!/usr/bin/env ocaml
#use "topfind"
#require "topkg"
#require "ocb-stubblr.topkg"
open Topkg

let opam =
  let nolint = ["ocb-stubblr"] in
  Pkg.opam_file ~lint_deps_excluding:(Some nolint) "opam"

let build = Pkg.build ~cmd:Ocb_stubblr_topkg.cmd ()

let () =
  Pkg.describe ~opams:[opam] ~build "named-pipe" @@ fun c ->
  Ok [
    Pkg.mllib "lib/named_pipe.mllib";
    Pkg.clib  "lib/libnamed_pipe.clib";
    Pkg.mllib "lwt/named_pipe_lwt.mllib";
    Pkg.clib  "lwt/libnamed_pipe_lwt.clib";
    Pkg.bin   "src/pipecat";
    Pkg.test~dir:"lib_test" "lib_test/test";
  ]
