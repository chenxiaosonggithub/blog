script_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

bash "$script_dir/aorus-ssh.sh" "$1"
	
