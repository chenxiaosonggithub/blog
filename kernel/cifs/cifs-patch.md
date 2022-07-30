[toc]

# 64c4a37ac04e cifs: potential buffer overflow in handling symlinks

```c
parse_mf_symlink
  sscanf(buf, "XSym\n%04u\n", &link_len) // link_len 可能会很大, 超过允许的最大长度 CIFS_MF_SYMLINK_LINK_MAXLEN ＝ 1024
```