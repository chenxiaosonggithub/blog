script_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
. $script_dir/common.sh

ssh_cmd="ssh -p $port $ssh_user@$address"
echo "$ssh_cmd"
$ssh_cmd

