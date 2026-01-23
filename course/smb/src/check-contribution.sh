TARGET_FILE=$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../contribution.md
# echo $TARGET_FILE

find_missing() {
	git log --format="%h %s" --grep=chenxiaosong fs/smb/ | while IFS= read -r full_commit; do
		subject=$(echo "$full_commit" | cut -d' ' -f2-)
		commit_id=$(echo "$full_commit" | cut -d' ' -f1)
		# echo $commit_id $subject
		if grep -Fq "$subject" "$TARGET_FILE"; then
			: # echo "[FOUND] $subject"
		else
			echo "[MISSING] - [$full_commit](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=$commit_id)"
		fi
	done
}

delete_commit_id() {
	git log --format="%h %s" --grep=chenxiaosong fs/smb/ | while IFS= read -r full_commit; do
		subject=$(echo "$full_commit" | cut -d' ' -f2-)
		# echo $subject
		sed -i "s|$full_commit|$subject|g" $TARGET_FILE
	done
}

add_commit_id() {
	git log --format="%h %s" --grep=chenxiaosong fs/smb/ | while IFS= read -r full_commit; do
		subject=$(echo "$full_commit" | cut -d' ' -f2-)
		# echo $subject
		sed -i "s|\[$subject\]|[$full_commit]|g" $TARGET_FILE
	done
}

# delete_commit_id
# add_commit_id
find_missing

