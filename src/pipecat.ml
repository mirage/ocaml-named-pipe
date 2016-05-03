open Cmdliner

let listen =
  let doc = "Act as a server rather than a client." in
  Arg.(value & flag & info [ "l"; "listen"] ~doc)

let path =
  Arg.(required & pos 1 (some string) (Some "\\\\.\\pipe\\pipecat") & info ~docv:"PATH" ~doc:"Path to named pipe" [])

let rec client path =
  try
    let p = Named_pipe.Client.openpipe path in
    Printf.fprintf stderr "Connected\n%!";
    Unix.close p
  with e ->
    Printf.fprintf stderr "Caught error %s: waiting\n%!" (Printexc.to_string e);
    if not (Named_pipe.Client.wait path 1000)
    then Printf.fprintf stderr "Failed to wait for a free slot\n%!"
    else client path

let server path =
  let p = Named_pipe.Server.create path in
  match Named_pipe.Server.connect p with
  | false ->
    Printf.fprintf stderr "Failed to connect to client\n%!";
    ()
  | true ->
    Printf.fprintf stderr "Connected\n%!";
    Named_pipe.Server.flush p;
    Named_pipe.Server.disconnect p;
    Named_pipe.Server.destroy p

let main listen path = (if listen then server else client) path

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
  Term.(pure main $ listen $ path),
  Term.info "pipecat" ~version:"0.1" ~doc ~man

let () =
  match Term.eval cmd with `Error _ -> exit 1 | _ -> exit 0
