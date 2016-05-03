OCaml bindings for named pipes
==============================

Named pipes are used on Windows for local (and remote) IPC. Where a Unix
system would use a Unix domain socket, a Windows system will probably used
a named pipe.

Example
-------

To build:
```
oasis setup
make
```

To run a server:
```
./_build/src/pipecat.native -l \\\\.\\pipe\\mynamedpipe
```

To run a client:
```
./_build/src/pipecat.native \\\\.\\pipe\\mynamedpipe
```

Notes
=====

Named pipes have a number of significant differences to Unix domain sockets
to be careful. These bindings attempt to disable remote connections and
disable security context impersonation but there may be other issues.

