open Lwt.Infix

module Server = struct
  type t = Unix.file_descr
  let to_fd x = x

  external create: string -> t = "stub_named_pipe_create"

  external connect_job: t -> bool Lwt_unix.job = "named_pipe_lwt_connect_job"

  let connect t = Lwt_unix.run_job (connect_job t)

  external flush_job: t -> unit Lwt_unix.job = "named_pipe_lwt_flush_job"

  let flush t = Lwt_unix.run_job (flush_job t)

  external disconnect: t -> unit = "stub_named_pipe_disconnect"

  external destroy: t -> unit = "stub_named_pipe_destroy"
end

module Client = struct
  type t = Unix.file_descr
  let to_fd x = x

  external wait_job: string -> int -> bool Lwt_unix.job = "named_pipe_lwt_wait_job"

  let wait path ms = Lwt_unix.run_job (wait_job path ms)

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
