
(** https://msdn.microsoft.com/en-us/library/windows/desktop/aa365588(v=vs.85).aspx *)

module Server: sig
  type t
  (** A single named pipe capable of accepting one connection. *)

  val create: string -> t
  (** The server should create a named pipe at a particular path under \\.\pipe *)

  val connect: t -> bool
  (** Connect blocks until a client connects to this named pipe *)

  val to_fd: t -> Unix.file_descr

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

  exception Pipe_busy
  (** A pipe is busy if the server is not ready to accept more connections:
      perhaps it is still forking a thread for the previous one. A client
      should call the wait function to wait for a free slot. *)

  val openpipe: string -> t
  (** Connect to the named pipe server on the given path (e.g. \\.\pipe\foo).
      If the server isn't running then this raises Unix_error(Unix.ENOENT...).
      If the server isn't ready to accept a connection then this raises
      Pipe_busy, and the client should call [wait]. *)

  val to_fd: t -> Unix.file_descr

  val wait: string -> int -> bool
  (** [wait path ms] wait for up to [ms] milliseconds for the server to become
      available. Returns true if the server has a free slot: in this case
      the client should call [openpipe] again. Returns false if the server
      has shutdown. *)
end
