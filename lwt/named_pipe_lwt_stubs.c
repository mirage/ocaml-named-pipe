/*
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
 */

#include <stdint.h>
#include <string.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include <caml/bigarray.h>
#include <caml/threads.h>
#include <caml/unixsupport.h>
#include <caml/callback.h>

#include "lwt_unix.h"

#ifdef WIN32
#include <winsock2.h>
#include <wtypes.h>
#include <winbase.h>
#include <stdio.h>
#include <tchar.h>
#else
#define HANDLE void*
#define BOOL int
#define DWORD int
#define Handle_val(x) NULL
#define TRUE 1
#define FALSE 0
#endif

static void named_pipe_not_available()
{
  caml_failwith("Named pipes not available");
}

struct job_connect {
  struct lwt_unix_job job;
  HANDLE h;
  DWORD error_code;
};

static void worker_connect(struct job_connect *job)
{
#ifdef WIN32
  DWORD error;
  if (!ConnectNamedPipe(job->h, NULL)) {
    error = GetLastError();
    if (error != ERROR_PIPE_CONNECTED) {
      job->error_code = error;
    }
  }
#endif
}

static value result_connect(struct job_connect *job)
{
  CAMLparam0 ();
#ifdef WIN32
  DWORD error = job->error_code;
  if (error) {
    lwt_unix_free_job(&job->job);
    win32_maperr(error);
    uerror("connect", Nothing);
  }
#endif
  lwt_unix_free_job(&job->job);
#ifndef WIN32
  named_pipe_not_available();
#endif
  CAMLreturn(Val_unit);
}

CAMLprim
value named_pipe_lwt_connect_job(value handle)
{
  CAMLparam1(handle);
  LWT_UNIX_INIT_JOB(job, connect, 0);
  job->h = (HANDLE)Handle_val(handle);
  job->error_code = 0;
  CAMLreturn(lwt_unix_alloc_job(&(job->job)));
}

struct job_flush {
  struct lwt_unix_job job;
  HANDLE h;
  DWORD error_code;
};

static void worker_flush(struct job_flush *job)
{
#ifdef WIN32
  if (!FlushFileBuffers(job->h)) {
    job->error_code = GetLastError();
  }
#endif
}

static value result_flush(struct job_flush *job)
{
  CAMLparam0 ();
#ifdef WIN32
  DWORD error = job->error_code;
  if (error) {
    lwt_unix_free_job(&job->job);
    win32_maperr(error);
    uerror("flush", Nothing);
  }
#endif
  lwt_unix_free_job(&job->job);
#ifndef WIN32
  named_pipe_not_available();
#endif
  CAMLreturn(Val_unit);
}

CAMLprim
value named_pipe_lwt_flush_job(value handle)
{
  CAMLparam1(handle);
  LWT_UNIX_INIT_JOB(job, flush, 0);
  job->h = (HANDLE)Handle_val(handle);
  job->error_code = 0;
  CAMLreturn(lwt_unix_alloc_job(&(job->job)));
}

struct job_wait {
  struct lwt_unix_job job;
  char *path;
  DWORD ms;
  DWORD error_code;
};

static void worker_wait(struct job_wait *job)
{
#ifdef WIN32
  if (!WaitNamedPipe(job->path, job->ms)) {
    job->error_code = GetLastError();
  }
#endif
}

static value result_wait(struct job_wait *job)
{
  CAMLparam0 ();
#ifdef WIN32
  DWORD error = job->error_code;
  if (error) {
    free(job->path);
    lwt_unix_free_job(&job->job);
    win32_maperr(error);
    uerror("wait", Nothing);
  };
#endif
  lwt_unix_free_job(&job->job);
#ifndef WIN32
  named_pipe_not_available();
#endif
  CAMLreturn(Val_unit);
}

CAMLprim
value named_pipe_lwt_wait_job(value path, value ms)
{
  CAMLparam2(path, ms);
  LWT_UNIX_INIT_JOB(job, wait, 0);
  job->path = caml_strdup(String_val(path));
  job->ms = Int_val(ms);
  job->error_code = 0;
  CAMLreturn(lwt_unix_alloc_job(&(job->job)));
}
