smb_username=root
smb_password=1

mk_mnt_dir()
{
	sudo mkdir -p /tmp/test
	sudo mkdir -p /tmp/test2
	sudo mkdir -p /tmp/test3
	sudo mkdir -m 777 -p /tmp/s_test
	sudo mkdir -m 777 -p /tmp/s_test2
	sudo mkdir -m 777 -p /tmp/s_test3
}

start_ksmbd()
{
	local script_path="$(realpath "${BASH_SOURCE[0]}")"
	local script_dir="$(dirname "${script_path}")"

	sudo systemctl stop ksmbd
	sudo systemctl stop smb
	sudo systemctl stop smbd

	sudo umount /tmp/test
	sudo umount /tmp/test2
	sudo umount /tmp/s_test
	sudo umount /tmp/s_test2
	sudo umount /tmp/s_test3
	sudo mkfs.ext4 -F /dev/sda
	sudo mkfs.ext4 -F /dev/sdb
	sudo mkfs.ext4 -F /dev/sdc
	sudo mount /dev/sda /tmp/s_test
	sudo mount /dev/sdb /tmp/s_test2
	sudo mount /dev/sdc /tmp/s_test3

	cp ${script_dir}/ksmbd.conf /usr/local/etc/ksmbd/ksmbd.conf
	ksmbd.adduser --delete root # delete user
	ksmbd.adduser --add root -p 1
	sudo systemctl start ksmbd
}


