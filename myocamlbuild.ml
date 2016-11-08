open Ocamlbuild_plugin

let incl pkg =
  run_and_read ("opam config var " ^ pkg ^ ":lib")
  |> String.trim
  |> fun d -> "-I " ^ d

let () = Ocb_stubblr.dispatchv [
    Ocb_stubblr.cclib (incl "lwt");
    Ocb_stubblr.init;
  ]
