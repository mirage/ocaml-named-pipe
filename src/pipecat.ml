open Lwt

let sigint_t, sigint_u = Lwt.task ()

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

open Cmdliner

let listen =
  let doc = "Act as a server rather than a client." in
  Arg.(value & flag & info [ "l"; "listen"] ~doc)

let path =
  Arg.(value & pos 0 string "\\\\.\\pipe\\mynamedpipe" & info ~docv:"PATH" ~doc:"Path to named pipe" [])

let echo =
  let doc = "Run a simple multithreaded echo server" in
  Arg.(value & flag & info ["echo"] ~doc)

let buffer_size = 4096

let client path =
  try
    Named_pipe_lwt.Client.openpipe path
    >>= fun p ->
    let fd = Named_pipe_lwt.Client.to_fd p in
    Printf.fprintf stderr "Connected\n%!";
    let ic = Lwt_io.of_fd ~mode:Lwt_io.input fd in
    let oc = Lwt_io.of_fd ~mode:Lwt_io.output fd in
    proxy buffer_size (ic, oc) (Lwt_io.stdin, Lwt_io.stdout)
    >>= fun () ->
    Lwt_unix.close fd
  with
  | Unix.Unix_error(Unix.ENOENT, _, _) ->
    Printf.fprintf stderr "Server not found (ENOENT)\n";
    Lwt.return ()

let with_connect p f =
  Lwt.catch (fun () ->
      Named_pipe_lwt.Server.connect p >>= f
    ) (fun e ->
      Printf.fprintf stderr "Failed to connect to client\n (%s)%!"
        (Printexc.to_string e);
      Lwt.return_unit)

let one_shot_server path =
  let p = Named_pipe_lwt.Server.create path in
  with_connect p (fun () ->
      Printf.fprintf stderr "Connected\n%!";
      let fd = Named_pipe_lwt.Server.to_fd p in
      let ic = Lwt_io.of_fd ~mode:Lwt_io.input fd in
      let oc = Lwt_io.of_fd ~mode:Lwt_io.output fd in
      proxy buffer_size (ic, oc) (Lwt_io.stdin, Lwt_io.stdout)
      >>= fun () ->
      Named_pipe_lwt.Server.flush p
      >>= fun () ->
      Named_pipe_lwt.Server.disconnect p;
      Named_pipe_lwt.Server.destroy p;
      Lwt.return ()
    )

let rec echo_server path =
  let p = Named_pipe_lwt.Server.create path in
  with_connect p (fun () ->
      Printf.fprintf stderr "Connected\n%!";
      let _ =
        let fd = Named_pipe_lwt.Server.to_fd p in
        let ic = Lwt_io.of_fd ~mode:Lwt_io.input fd in
        let oc = Lwt_io.of_fd ~mode:Lwt_io.output fd in
        proxy buffer_size (ic, oc) (ic, oc)
        >>= fun () ->
        Named_pipe_lwt.Server.flush p;
        >>= fun () ->
        Named_pipe_lwt.Server.disconnect p;
        Named_pipe_lwt.Server.destroy p;
        Printf.fprintf stderr "Disconnected\n%!";
        Lwt.return () in
      echo_server path
    )

let main listen echo path =
  let t = match listen, echo with
    | true, false -> one_shot_server path
    | true, true -> echo_server path
    | false, _ -> client path in
  Lwt_main.run t

let cmd =
  let doc = "Establish named pipe connections" in
  let man = [
    `S "DESCRIPTION";
    `P "Establish a connection to a server via a named pipe and transfer data over stdin/stdout, in a similar way to 'nc'";
    `S "EXAMPLES";
    `P "To listen to an incoming connection on path '\\\\.\\pipe\\pipecat':";
    `P "pipecat -l \\\\.\\pipe\\pipecat";
    `P "To connect:";
    `P "pipecat \\\\.\\pipe\\pipecat";
  ] in
  Term.(pure main $ listen $ echo $ path),
  Term.info "pipecat" ~version:"0.1" ~doc ~man

let () =
let (_: Lwt_unix.signal_handler_id) = Lwt_unix.on_signal Sys.sigint
  (fun (_: int) ->
    Lwt.wakeup_later sigint_u ();
  ) in
  match Term.eval cmd with `Error _ -> exit 1 | _ -> exit 0
