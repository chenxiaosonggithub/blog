#!/bin/bash

# 检查参数
if [ $# -lt 1 ]; then
        echo "用法: bash $0 <要查找的字符串>"
        exit 1
fi
target_str=$1

src_file=MAINTAINERS
dst_file=grep-maintainer.txt

> ${dst_file}

readonly STATUS_INIT=0		# 未开始
readonly STATUS_BEGIN_EMPTY=1	# 匹配到开始的空行
readonly STATUS_TITLE=2		# 即将匹配标题行
readonly STATUS_TITLE_DONE=3	# 匹配完标题行
readonly STATUS_TARGET=4	# 匹配成功目标字符串
readonly STATUS_END_EMPTY=5	# 匹配到结束的空行

grep_maintainer() {
	local cached_line=()
	local status=$STATUS_INIT
	local title_line=""
	while IFS= read -r line; do
		if [[ "${line}" == "" ]]; then
			case $status in
			$STATUS_TARGET)
				echo "${title_line}" >> ${dst_file}
				echo >> ${dst_file}
				echo "\`\`\`" >> ${dst_file}
				printf '%s\n' "${cached_line[@]}" >> ${dst_file}
				echo "\`\`\`" >> ${dst_file}
				echo >> ${dst_file}
				;;& # 继续匹配后续模式
			*)
				# echo "empty line"
				status=$STATUS_BEGIN_EMPTY
				cached_line=()
				;;
			esac
		elif [[ "${line}" == *"${target_str}"* ]]; then
			echo "line: ${line}"
			status=$STATUS_TARGET
			title_line+=" ${line}"
			title_line=$(echo "${title_line}" | sed 's/M:\t/maintainer /')
			title_line=$(echo "${title_line}" | sed 's/R:\t/reviewer /')
			echo "final title_line: ${title_line}"
		fi

		case $status in
		$STATUS_BEGIN_EMPTY)
			status=$STATUS_TITLE
			;;
		$STATUS_TITLE)
			status=$STATUS_TITLE_DONE
			title_line="## ${line}"
			# echo "title_line: ${title_line}"
			;;
		*)
			cached_line+=("$line")
			;;
		esac
	done < "$src_file"
}

grep_maintainer

