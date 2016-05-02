
type t = Unix.file_descr

external create: string -> t = "stub_named_pipe_create"

external connect: t -> bool = "stub_named_pipe_connect"

external flush: t -> unit = "stub_named_pipe_flush"

external disconnect: t -> unit = "stub_named_pipe_disconnect"

external destroy: t -> unit = "stub_named_pipe_destroy"
