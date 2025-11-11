smb_username=root
smb_password=1

start_ksmbd()
{
	local script_path="$(realpath "${BASH_SOURCE[0]}")"
	local script_dir="$(dirname "${script_path}")"

	sudo systemctl stop ksmbd
	sudo systemctl stop smb
	sudo systemctl stop smbd

	sudo mkdir -p /mnt/1
	sudo mkdir -p /mnt/2
	sudo mkdir -m 777 -p /mnt/test1
	sudo mkdir -m 777 -p /mnt/test2
	sudo mkdir -m 777 -p /mnt/test3
	sudo umount /mnt/1
	sudo umount /mnt/2
	sudo umount /mnt/test1
	sudo umount /mnt/test2
	sudo umount /mnt/test3
	sudo mkfs.ext4 -F /dev/sda
	sudo mkfs.ext4 -F /dev/sdb
	sudo mkfs.ext4 -F /dev/sdc
	sudo mount /dev/sda /mnt/test1
	sudo mount /dev/sdb /mnt/test2
	sudo mount /dev/sdc /mnt/test3

	cp ${script_dir}/ksmbd.conf /usr/local/etc/ksmbd/ksmbd.conf
	ksmbd.adduser --delete root # delete user
	ksmbd.adduser --add root -p 1
	sudo systemctl start ksmbd
}

read_server_ip()
{
	local script_path="$(realpath "${BASH_SOURCE[0]}")"
	local script_dir="$(dirname "${script_path}")"
	local smb_server_ip_file=${script_dir}/smb-server-ip.conf

	if [[ ! -f "${smb_server_ip_file}" ]]; then
		echo "Please create ${smb_server_ip_file}"
		return 1
	fi

	# read the ip from config file
	echo $(sed -n '/^[[:space:]]*$/!{p;q}' ${smb_server_ip_file})
	return 0
}

