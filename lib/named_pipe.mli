
(** https://msdn.microsoft.com/en-us/library/windows/desktop/aa365588(v=vs.85).aspx *)

type t
(** A single named pipe capable of accepting one connection. *)

val create: string -> t
(** The server should create a named pipe at a particular path under \\.\pipe *)

val connect: t -> bool
(** Connect blocks until a client connects to this named pipe *)

val flush: t -> unit
(** Flushes outstanding write buffers, typically called before disconnect *)

val disconnect: t -> unit
(** Disconnects the connected client *)

val destroy: t -> unit
(** Removes the underlying OS resource *)
