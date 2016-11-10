open Ocamlbuild_plugin

let incl pkg =
  run_and_read ("opam config var " ^ pkg ^ ":lib")
  |> String.trim
  |> Printf.sprintf "-I '%s'"

let incl_lwt =
  let s = incl "lwt" in
  Printf.printf "Adding cclib(%s)\n%!" s;
  s

let () = Ocb_stubblr.dispatchv [
    Ocb_stubblr.cclib incl_lwt;
    Ocb_stubblr.init;
  ]
