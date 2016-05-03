open Lwt.Infix

let proxy buffer_size (ic, oc) (stdin, stdout) =
  let a_buffer = Bytes.create buffer_size in
  let b_buffer = Bytes.create buffer_size in
  let rec proxy buffer a b =
    Lwt_io.read_into a buffer 0 buffer_size
    >>= function
    | 0 -> Lwt.fail End_of_file
    | n ->
      Lwt_io.write_from_exactly b buffer 0 n
      >>= fun () ->
      proxy buffer a b in
  let (a: unit Lwt.t) = proxy a_buffer stdin oc in
  let (b: unit Lwt.t) = proxy b_buffer ic stdout in
  Lwt.catch
    (fun () -> Lwt.pick [a; b])
    (function End_of_file -> Lwt.return ()
     | e -> Lwt.fail e)

let rec echo_server path =
  let p = Named_pipe_lwt.Server.create path in
  Named_pipe_lwt.Server.connect p
  >>= function
  | false ->
    Printf.fprintf stderr "Failed to connect to client\n%!";
    Lwt.return ()
  | true ->
    Printf.fprintf stderr ".%!";
    let _ =
      let fd = Named_pipe_lwt.Server.to_fd p in
      let ic = Lwt_io.of_unix_fd ~mode:Lwt_io.input fd in
      let oc = Lwt_io.of_unix_fd ~mode:Lwt_io.output fd in
      proxy 4096 (ic, oc) (ic, oc)
      >>= fun () ->
      Named_pipe_lwt.Server.flush p;
      >>= fun () ->
      Named_pipe_lwt.Server.disconnect p;
      Named_pipe_lwt.Server.destroy p;
      Lwt.return () in
    echo_server path

let test_server () =
  let path = "\\\\.\\pipe\\testpipes" in
  let _ = echo_server path in

  let client () =
    Named_pipe_lwt.Client.openpipe path
    >>= fun p ->
    let fd = Named_pipe_lwt.Client.to_fd p in
    let ic = Lwt_io.of_unix_fd ~close:Lwt.return ~mode:Lwt_io.input fd in
    let oc = Lwt_io.of_unix_fd ~close:Lwt.return ~mode:Lwt_io.output fd in
    Lwt_io.write_line oc "hello"
    >>= fun () ->
    Lwt_io.read_line ic
    >>= fun input ->
    if input <> "hello"
    then failwith (Printf.sprintf "expected hello, got [%s]" input);
    Unix.close fd;
    Lwt.return () in
  let rec mkints = function
    | 0 -> []
    | n -> n :: (mkints (n-1)) in
  let t = Lwt.join (List.map (fun _ -> client ()) (mkints 1000)) in
  Lwt_main.run t

let tests = [
  "server", [
    "connect 1000x to a server", `Quick, test_server;
  ]
]

let () = Alcotest.run "named-pipe" tests
