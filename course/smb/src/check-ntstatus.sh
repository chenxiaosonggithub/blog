#!/bin/sh

smb2status_src_file="fs/smb/common/smb2status.h"
nterr_src_file="fs/smb/client/nterr.h"
dst_file="ntstatus_gen.h"
output_file=""

find_dst_file() {
	src_name=$1
	src_value=$2
	src_line=$3

	dst_line=$(grep "${src_name}[[:space:]]" "$dst_file")
	# echo "src_name=$src_name, src_value=$src_value, dst_line=$dst_line"
	if [ -z "$dst_line" ]; then
		echo "没找到 $src_name" >> $output_file
		echo "src_line: $src_line" >> $output_file
		echo >> $output_file
		return
	fi

	dst_value=$(echo "$dst_line" | awk -F'[()]' '{print $2}')
	# echo "dst_value=$dst_value"

	if [ $(( dst_value )) -ne $(( src_value )) ]; then
		echo "values differ $src_name, src_value: $src_value, dst_value: $dst_value" >> $output_file
		echo "src_line: $src_line" >> $output_file
		echo "dst_line: $dst_line" >> $output_file
		echo >> $output_file
	# else
	# 	echo "values match"
	fi
}

iter_src_file() {
	src_file=$1
	while IFS= read -r line; do
		case "$line" in "#define "*)
			name=$(echo "$line" | awk '{print $2}')
			value=$(echo "$line" | awk -F'[()]' '{print $2}')
			if [ -z "$value" ]; then
				value=$(echo "$line" | awk '{print $3}')
			fi
			find_dst_file "$name" "$value" "$line"
			;;
		esac
	done < "$src_file"
}

output_file="nterr-diff.txt"
> $output_file
iter_src_file $nterr_src_file

output_file="smb2status-diff.txt"
> $output_file
iter_src_file $smb2status_src_file

