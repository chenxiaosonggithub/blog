kernel_contrib_file=$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../contribution.md
smb_contrib_file=$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../smb/contribution.md
# echo $kernel_contrib_file $smb_contrib_file

find_missing() {
	local full_commit=$1
	local subject=$(echo "$full_commit" | cut -d' ' -f2-)
	local commit_id=$(echo "$full_commit" | cut -d' ' -f1)
	# echo $commit_id $subject
	if grep -Fq "$subject" "$kernel_contrib_file"; then
		# echo "[FOUND] $subject"
		return
	fi
	if grep -Fq "$subject" "$smb_contrib_file"; then
		# echo "[FOUND] $subject"
		return
	fi

	echo "[MISSING] - [$full_commit](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=$commit_id)"
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
	# delete_commit_id $full_commit
	# add_commit_id $full_commit
	find_missing "$full_commit"
done

