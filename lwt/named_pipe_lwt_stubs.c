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

extern void named_pipe_not_available();

struct job_connect {
  struct lwt_unix_job job;
  HANDLE h;
  BOOL result;
};

static void worker_connect(struct job_connect *job)
{
#ifdef WIN32
  job->result = ConnectNamedPipe(job->h, NULL)?TRUE:(GetLastError() == ERROR_PIPE_CONNECTED);
#endif
}

static value result_connect(struct job_connect *job)
{
  CAMLparam0 ();
#ifndef WIN32
  named_pipe_not_available();
#endif
  CAMLreturn(Val_bool((job->result == TRUE)?1:0));
}

CAMLprim
value named_pipe_lwt_connect_job(value handle)
{
  CAMLparam1(handle);
  LWT_UNIX_INIT_JOB(job, connect, 0);
  job->h = (HANDLE)Handle_val(handle);
  job->result = FALSE;
  CAMLreturn(lwt_unix_alloc_job(&(job->job)));
}

struct job_flush {
  struct lwt_unix_job job;
  HANDLE h;
};

static void worker_flush(struct job_flush *job)
{
#ifdef WIN32
  FlushFileBuffers(job->h);
#endif
}

static value result_flush(struct job_flush *job)
{
  CAMLparam0 ();
  #ifndef WIN32
    named_pipe_not_available();
  #endif
  CAMLreturn(Val_int(0));
}

CAMLprim
value named_pipe_lwt_flush_job(value handle)
{
  CAMLparam1(handle);
  LWT_UNIX_INIT_JOB(job, flush, 0);
  job->h = (HANDLE)Handle_val(handle);
  CAMLreturn(lwt_unix_alloc_job(&(job->job)));
}

struct job_wait {
  struct lwt_unix_job job;
  char *path;
  DWORD ms;
  BOOL result;
};

static void worker_wait(struct job_wait *job)
{
#ifdef WIN32
  job->result = WaitNamedPipe(job->path, job->ms);
#endif
  free(job->path);
}

static value result_wait(struct job_wait *job)
{
  CAMLparam0 ();
#ifndef WIN32
  named_pipe_not_available();
#endif
  CAMLreturn(Val_bool((job->result == TRUE)?1:0));
}

CAMLprim
value named_pipe_lwt_wait_job(value path, value ms)
{
  CAMLparam2(path, ms);
  LWT_UNIX_INIT_JOB(job, wait, 0);
  job->path = strdup(String_val(path));
  job->ms = Int_val(ms);
  job->result = FALSE;
  CAMLreturn(lwt_unix_alloc_job(&(job->job)));
}

