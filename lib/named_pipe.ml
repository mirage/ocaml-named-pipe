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

exception Not_available

module Server = struct
  type t = Unix.file_descr
  let to_fd x = x

  external create': string -> t = "stub_named_pipe_create"
  let create path =
    if Sys.os_type <> "Win32" then raise Not_available;
    create' path

  external connect': t -> bool = "stub_named_pipe_connect"
  let connect t =
    if Sys.os_type <> "Win32" then raise Not_available;
    connect' t

  external flush': t -> unit = "stub_named_pipe_flush"
  let flush t =
    if Sys.os_type <> "Win32" then raise Not_available;
    flush' t

  external disconnect': t -> unit = "stub_named_pipe_disconnect"
  let disconnect t =
    if Sys.os_type <> "Win32" then raise Not_available;
    disconnect' t

  external destroy': t -> unit = "stub_named_pipe_destroy"
  let destroy t =
    if Sys.os_type <> "Win32" then raise Not_available;
    destroy' t
end

module Client = struct
  type t = Unix.file_descr
  let to_fd x = x

  exception Pipe_busy

  (* TODO: if this fails with ERROR_PIPE_BUSY then call wait *)
  let openpipe path =
    if Sys.os_type <> "Win32" then raise Not_available;
    try
      Unix.openfile path [ Unix.O_RDWR ] 0
    with Unix.Unix_error(Unix.EUNKNOWNERR -231, _, _) ->
      (* ERROR_PIPE_BUSY *)
      raise Pipe_busy
    | e -> raise e

  external wait': string -> int -> bool = "stub_named_pipe_wait"

  let wait path ms =
    if Sys.os_type <> "Win32" then raise Not_available;
    wait' path ms
end
