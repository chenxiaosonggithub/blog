# ps | awk '$NF ~ /\/usr\/bin\/ssh$/ {print $1}' | xargs -r kill # 不能用，第一列可能是S或O，不一定为空
ps | awk '$NF == "/usr/bin/ssh" {print ($1 ~ /^[0-9]+$/ ? $1 : $2)}' | xargs -r kill
