code_path=/home/sonvhi/chenxiaosong/code/

input_file=${code_path}/blog/src/blog-web/github-io-404.html
origin_file=${code_path}/blog/src/blog-web/nginx-config
tmp_file=${origin_file}.tmp
full_file=${origin_file}.full

path_array=()

parse_line() {
	local line=$1
	local url

	if [[ "${line}" =~ path\ \=\=\=\ \"(\/[^\"]+)\" ]]; then
		path_array+=("${BASH_REMATCH[1]}")
	elif [[ "${line}" =~ window\.location\.href\ \=\ \"([^\"]+)\" ]]; then
		path_count="${#path_array[@]}"
		# echo "path_count: ${path_count}"
		if [[ path_count == 0 ]]; then
			continue
		fi
		url="${BASH_REMATCH[1]}"
		for path in "${path_array[@]}"; do
			echo "	location ${path} {" >> "${tmp_file}"
			echo "		rewrite ^${path}\$ ${url};" >> "${tmp_file}"
			echo "	}" >> "${tmp_file}"
		done
		path_array=()
		url=""
	fi
}

create_tmp_file() {
	# 清空输出文件
	> "${tmp_file}"
	# 处理每行路径
	while IFS= read -r line; do
		parse_line "${line}"
	done < "${input_file}"
}

create_full_file() {
	cp ${origin_file} ${full_file}
	# 在'# 404 begin'之后插入${tmp_file}整个文件
	sed -i -e '/# 404 begin/r '${tmp_file} ${full_file}
	rm ${tmp_file}
}

create_tmp_file
create_full_file