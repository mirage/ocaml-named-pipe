open Cmdliner

let listen =
  let doc = "Act as a server rather than a client." in
  Arg.(value & flag & info [ "l"; "listen"] ~doc)

let path =
  Arg.(required & pos 1 (some string) (Some "\\\\.\\pipe\\pipecat") & info ~docv:"PATH" ~doc:"Path to named pipe" [])

let client path = failwith "unimplemented"

let server path =
  let p = Named_pipe.create path in
  match Named_pipe.connect p with
  | false ->
    Printf.fprintf stderr "Failed to connect to client\n%!";
    ()
  | true ->
    Printf.fprintf stderr "Connected\n%!";
    Named_pipe.flush p;
    Named_pipe.disconnect p;
    Named_pipe.destroy p

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
