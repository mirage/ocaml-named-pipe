0.3 (2016-07-19)
- Add dependency on lwt.unix

0.2 (2016-05-06)
- Enable build on OCaml 3.12.1
- Code can now be built and linked on all platforms, but will raise a dynamic
  exception Named_pipe.Not_available if the functionality is not available on
  the current platform.

0.1 (2016-05-05)
- Initial release
