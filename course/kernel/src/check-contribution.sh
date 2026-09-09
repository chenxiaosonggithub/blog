. ~/.top-path
blog_path=${MY_CODE_TOP_PATH}/blog

kernel_contrib_file=${blog_path}/course/kernel/contribution.md
smb_contrib_file=${blog_path}/en/smb-contribution.md
# echo $kernel_contrib_file $smb_contrib_file

find_review_missing() {
	local full_commit=$1
	local subject=$2
	local commit_id=$3

	local review_tag=$(git show $commit_id | grep -E "Reviewed-by:[[:space:]]*ChenXiaoSong")
	local ack_tag=$(git show $commit_id | grep -E "Acked-by:[[:space:]]*ChenXiaoSong")

	if [ -z "$review_tag" ] && [ -z "$ack_tag" ]; then
		return 1
	fi

	local patch_link="[$full_commit](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=$commit_id)"
	if [ -n "$review_tag" ]; then
		echo "- Review: $patch_link"
		return 0
	fi
	if [ -n "$ack_tag" ]; then
		echo "- Ack: $patch_link"
		return 0
	fi
	return 1
}

find_missing() {
	local full_commit=$1
	local subject=$(echo "$full_commit" | cut -d' ' -f2-)
	local commit_id=$(echo "$full_commit" | cut -d' ' -f1)
	# echo $commit_id $subject

	if grep -Fq "$full_commit" "$kernel_contrib_file"; then
		# echo "[FOUND] $subject"
		return
	fi
	if grep -Fq "$full_commit" "$smb_contrib_file"; then
		# echo "[FOUND] $subject"
		return
	fi

	find_review_missing "$full_commit" "$subject" "$commit_id"
	if [ $? -eq 0 ]; then
		return
	fi

	echo "- [$full_commit](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=$commit_id)"
}

delete_commit_id() {
	local full_commit=$1
	local subject=$(echo "$full_commit" | cut -d' ' -f2-)
	# echo $subject
	sed -i "s|$full_commit|$subject|g" $kernel_contrib_file
	sed -i "s|$full_commit|$subject|g" $smb_contrib_file
}

add_commit_id() {
	local full_commit=$1
	local subject=$(echo "$full_commit" | cut -d' ' -f2-)
	# echo $subject
	sed -i "s|\[$subject\]|[$full_commit]|g" $kernel_contrib_file
	sed -i "s|\[$subject\]|[$full_commit]|g" $smb_contrib_file
}

git log --format="%h %s" --grep=chenxiaosong origin/master | while IFS= read -r full_commit; do
	# delete_commit_id "$full_commit"
	# add_commit_id "$full_commit"
	find_missing "$full_commit"
done

