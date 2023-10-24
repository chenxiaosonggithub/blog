[toc]

# page 设成只读

```c
char *page_addr = page_address(page);
// aarch64
set_memory_ro(page_addr, 1);
set_memory_rw(page_addr, 1);
// x86
set_pages_ro(page, 1);
set_pages_rw(page, 1);
```