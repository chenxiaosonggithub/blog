[toc]

```shell
mount -t nfs -o vers=3 localhost:/tmp/s_test /mnt
```

```c
nfs_readahead
  page = readahead_page // get page to use
  readpage_async_filler
    nfs_create_request
      __nfs_create_request
        req->wb_page = page
  nfs_pageio_complete_read
    nfs_pageio_complete
      nfs_pageio_complete_mirror
        nfs_pageio_doio
          nfs_generic_pg_pgios
            hdr = nfs_pgio_header_alloc
            nfs_generic_pgio
              pg_array->pagevec
              pages = hdr->page_array.pagevec
              *pages++ = last_page = req->wb_page
              nfs_pgio_rpcsetup
                hdr->args.pages = hdr->page_array.pagevec
            nfs_initiate_pgio
              nfs_initiate_read // rw_initiate
                nfs3_proc_read_setup // read_setup
              rpc_execute

call_encode
  rpc_xdr_encode
    rpcauth_wrap_req
      rpcauth_wrap_req_encode
        nfs3_xdr_enc_read3args
          rpc_prepare_reply_pages
            xdr_inline_pages(&req->rq_rcv_buf, ...)
              xdr->pages = pages
  xprt_request_enqueue_receive
  xprt_request_enqueue_transmit
    xprt_request_prepare
      xs_stream_prepare_request
        xdr_alloc_bvec
          buf->bvec = kmalloc_array
          buf->bvec[i].bv_page = buf->pages[i]

rpc_create
  xprt_create_transport
    xs_setup_tcp
      INIT_WORK(..., xs_stream_data_receive_workfn)

xs_stream_data_receive_workfn
  xs_stream_data_receive
    xs_read_stream
      case RPC_REPLY:
      xs_read_stream_reply
        xs_read_stream_request
          xs_read_xdr_buf
            xs_read_bvec(..., buf->bvec, ...)
            xs_read_kvec
              xs_sock_recvmsg

kthread
  worker_thread
    process_one_work
      rpc_async_release
        rpc_free_task
          rpc_release_calldata
            nfs_pgio_release
              nfs_read_completion
                nfs_page_group_set_uptodate
                  SetPageUptodate

call_decode
  rpcauth_unwrap_resp
    rpcauth_unwrap_resp_decode
      nfs3_xdr_dec_read3res
        decode_read3resok
          xdr_read_pages

```

enable config `PAGE_EXTENSION`
```c
page_ext_init
  invoke_need_callbacks
    page_ext_ops // define a new page_ext_operations like page_idle_ops
```
