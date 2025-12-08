while IFS= read -r line; do
	if echo "$line" | grep -q "|"; then
		# Add "("
		line=$(echo "$line" | sed "s/ 0x/ (0x/")
		if [[ "$line" != *"*/" ]]; then
			# Add ")" if line does not end with a comment
			line=$(echo "$line" | sed "s/$/)/")
		else
			# Add ")" if line end with a comment
			line=$(echo "$line" | sed 's/[[:space:]]*\/\*/) &/')
		fi
	fi
	echo "$line"
done < fs/smb/client/nterr.h > fs/smb/client/nterr.h.tmp

mv fs/smb/client/nterr.h.tmp fs/smb/client/nterr.h
