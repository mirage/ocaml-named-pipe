
(** https://msdn.microsoft.com/en-us/library/windows/desktop/aa365588(v=vs.85).aspx *)

module Server: sig
  type t
  (** A single named pipe capable of accepting one connection. *)

  val create: string -> t
  (** The server should create a named pipe at a particular path under \\.\pipe *)

  val connect: t -> bool Lwt.t
  (** Connect blocks until a client connects to this named pipe *)

  val to_fd: t -> Unix.file_descr

  val flush: t -> unit Lwt.t
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

  val openpipe: string -> t Lwt.t
  (** Connect to the named pipe server on the given path (e.g. \\.\pipe\foo).
      If the server isn't running then this raises Unix_error(Unix.ENOENT...).
      If the server is busy then this function blocks. *) 

  val to_fd: t -> Unix.file_descr
end
