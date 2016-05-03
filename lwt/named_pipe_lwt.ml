open Lwt.Infix

module Server = struct
  type t = Unix.file_descr
  let to_fd x = x

  external create: string -> t = "stub_named_pipe_create"

  external connect: t -> bool Lwt.t = "named_pipe_lwt_connect_job"

  external flush: t -> unit Lwt.t = "named_pipe_lwt_flush_job"

  external disconnect: t -> unit = "stub_named_pipe_disconnect"

  external destroy: t -> unit = "stub_named_pipe_destroy"
end

module Client = struct
  type t = Unix.file_descr
  let to_fd x = x

  external wait: string -> int -> bool Lwt.t = "named_pipe_lwt_wait_job"

  let rec openpipe path =
    try
      let fd = Unix.openfile path [ Unix.O_RDWR ] 0 in
      Lwt.return fd
    with Unix.Unix_error(Unix.EUNKNOWNERR -231, _, _) ->
      (* ERROR_PIPE_BUSY *)
      wait path 1000
      >>= fun _ ->
      openpipe path
    | e -> raise e

end
