(*
 * Copyright (c) 2016 Docker Inc
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

(**
For more information on Windows Named pipes please see:

https://msdn.microsoft.com/en-us/library/windows/desktop/aa365588(v=vs.85).aspx
*)

exception Not_available
(** Raised on platforms which don't support named pipes *)

module Server: sig
  type t
  (** A single named pipe capable of accepting one connection. *)

  val create: string -> t
  (** The server should create a named pipe at a particular path under \\.\pipe *)

  val connect: t -> bool Lwt.t
  (** Connect blocks until a client connects to this named pipe *)

  val to_fd: t -> Lwt_unix.file_descr

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

  val to_fd: t -> Lwt_unix.file_descr
end
