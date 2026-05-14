smb_username=root
smb_password=1

script_path="$(realpath "${BASH_SOURCE[0]}")"
script_dir="$(dirname "${script_path}")"

init_mnt_dir()
{
	sudo mkdir -p /tmp/test
	sudo mkdir -p /tmp/test2
	sudo mkdir -p /tmp/test3

	sudo mkdir -m 777 -p /tmp/s_test
	sudo mkdir -m 777 -p /tmp/s_test2
	sudo mkdir -m 777 -p /tmp/s_test3

	sudo systemctl stop ksmbd
	sudo systemctl stop smb
	sudo systemctl stop smbd

	sudo umount /tmp/test
	sudo umount /tmp/test2
	sudo umount /tmp/test3
	sudo umount /tmp/s_test
	sudo umount /tmp/s_test2
	sudo umount /tmp/s_test3

	sudo mkfs.ext4 -F /dev/sda
	sudo mkfs.ext4 -F /dev/sdb
	sudo mkfs.ext4 -F /dev/sdc
	sudo mount /dev/sda /tmp/s_test
	sudo mount /dev/sdb /tmp/s_test2
	sudo mount /dev/sdc /tmp/s_test3
}

start_ksmbd()
{
	init_mnt_dir

	# sudo ksmbd.mountd -n -C ./smb.conf -P ./ksmbdpwd.db &
	cp ${script_dir}/ksmbd.conf /usr/local/etc/ksmbd/ksmbd.conf
	ksmbd.adduser --delete root # delete user
	ksmbd.adduser --add root -p 1
	sudo systemctl start ksmbd
}

start_samba()
{
	init_mnt_dir

	cp ${script_dir}/smb.conf /etc/samba/smb.conf # dnf或apt安装的samba
	cp ${script_dir}/smb.conf /usr/local/samba/etc/smb.conf # 源码安装的samba
	pdbedit -x -u root # delete user
	printf "1\n1\n" | pdbedit -a -u root
	systemctl daemon-reload
	systemctl restart smb.service
}

