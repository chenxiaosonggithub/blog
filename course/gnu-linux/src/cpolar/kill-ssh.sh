ps | awk '$NF ~ /\/usr\/bin\/ssh$/ {print $1}' | xargs -r kill
