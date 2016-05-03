
module Server = struct
  type t = Unix.file_descr
  let to_fd x = x

  external create: string -> t = "stub_named_pipe_create"

  external connect: t -> bool = "stub_named_pipe_connect"

  external flush: t -> unit = "stub_named_pipe_flush"

  external disconnect: t -> unit = "stub_named_pipe_disconnect"

  external destroy: t -> unit = "stub_named_pipe_destroy"
end

module Client = struct
  type t = Unix.file_descr
  let to_fd x = x

  exception Pipe_busy

  (* TODO: if this fails with ERROR_PIPE_BUSY then call wait *)
  let openpipe path =
    try
      Unix.openfile path [ Unix.O_RDWR ] 0
    with Unix.Unix_error(Unix.EUNKNOWNERR -231, _, _) ->
      (* ERROR_PIPE_BUSY *)
      raise Pipe_busy
    | e -> raise e

  external wait: string -> int -> bool = "stub_named_pipe_wait"
end
