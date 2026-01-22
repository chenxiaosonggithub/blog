#!/bin/sh

src_file="fs/smb/client/nterr.h"
dst_file="fs/smb/client/smb1maperror.c"

find_dst_file() {
	macro_name=$1

	dst_line=$(grep ", ${macro_name}\}" "$dst_file")
	if [ -z "$dst_line" ]; then
		echo "$macro_name "
	fi
}

echo "The following macros are not included in the ntstatus_to_dos_map array:"
while IFS= read -r line; do
	if [[ "$line" == "#define NT_"* && "$line" != "#define NT_ERROR"* ]]; then
		macro_name=$(echo "$line" | awk '{print $2}')
		find_dst_file "$macro_name"
	fi
done < "$src_file"
