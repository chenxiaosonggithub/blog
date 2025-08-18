array=(
# 在这里继续添加
ae72360a5e6b
9ef9b8c08d76
18e360871c3f
)

revert_enfs() {
	local element_count="${#array[@]}" #
	local count_per_line=1
	for ((index=0; index<${element_count}; index=$((index + ${count_per_line})))); do
		local commit=${array[${index}]}
		git revert ${commit} --no-edit
	done
}

revert_enfs

