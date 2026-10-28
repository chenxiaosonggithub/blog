. ~/.top-path
MY_ECHO_DEBUG=0

src_path=${MY_CODE_TOP_PATH}/blog

. ${src_path}/src/blog-web/common-lib.sh
. ${src_path}/src/blog-web/array.sh

if [ $# -lt 1 ]; then
	echo "用法: bash $0 <html目录> [是否替换IP] [局域网IP]"
	exit 1
fi
html_path=$1
is_replace_ip=${2:-false}
other_ip=$3

# 使用生成配置中的输出路径，兼容自定义HTML文件名。
add_common() {
	local ifile=$3
	local ofile=$4
	local course=$8
	local common_html=$9

	case "${ifile}" in
		course/${course}/${course}.md|\
		course/${course}/video.md|\
		course/${course}/common.md)
			return
			;;
		course/${course}/*.md) ;;
		*) return ;;
	esac

	local dst_file=${html_path}/${ofile}
	if [ ! -f "${dst_file}" ]; then
		return
	fi
	comm_echo "add ${common_html} to ${dst_file}"
	sed -i -e '/<\/nav>/r '"${common_html}" "${dst_file}"
}

create_full_course_html() {
	local course=$1
	local common_md=${src_path}/course/${course}/common.md
	local common_html=${html_path}/course/${course}/common.html

	mkdir -p "$(dirname "${common_html}")"
	# 与签名一样，由Markdown生成HTML后只保留正文片段。
	comm_create_sign "${common_md}" "${common_html}"
	if [[ ${is_replace_ip} == true ]]; then
		comm_file_replace_ip "${common_html}" "${other_ip}"
	fi
	comm_iterate_array add_common comm_array[@] "${src_path}" "${course}" "${common_html}"
}

create_full_course_html "kernel"
create_full_course_html "nfs"
create_full_course_html "smb"
create_full_course_html "algorithm"
create_full_course_html "godot"
create_full_course_html "gnu-linux"
create_full_course_html "harmony"
create_full_course_html "mptcp"
