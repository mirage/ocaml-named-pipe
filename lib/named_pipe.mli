
(** https://msdn.microsoft.com/en-us/library/windows/desktop/aa365588(v=vs.85).aspx *)

module Server: sig
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
end

(* https://msdn.microsoft.com/en-gb/library/windows/desktop/aa365592(v=vs.85).aspx *)

module Client: sig
  type t
  (** A connection to a named pipe server *)

  val openpipe: string -> t
  (** Connect to the named pipe server. This can fail if the server is busy *)

  val wait: string -> int -> bool
  (** [wait path ms] wait for up to [ms] milliseconds for the server to become
      available. *)
end
