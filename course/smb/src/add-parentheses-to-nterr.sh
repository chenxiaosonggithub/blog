sed -i '/|/s/ 0x/ (0x/' fs/smb/client/nterr.h
sed -i '/|/ { /.*\*\/$/! s/$/)/ }' fs/smb/client/nterr.h
sed -i '/|/ s/[[:space:]]*\/\*/) &/' fs/smb/client/nterr.h
