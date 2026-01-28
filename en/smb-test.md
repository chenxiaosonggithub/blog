[Please refer to `namjaejeon/ksmbd/.github/workflows/c-cpp.yml`](https://github.com/namjaejeon/ksmbd/blob/master/.github/workflows/c-cpp.yml).

# kernel configs

Please refer to [syzbot Linux kernel configs](https://github.com/google/syzkaller/blob/master/docs/linux/kernel_configs.md).

You can directly use [`test-x86_64-config`](https://github.com/chenxiaosonggithub/tmp/blob/master/gnu-linux/kernel-config/test-x86_64-config).

# smb development environment

Install smb client tool software:
```sh
dnf install cifs-utils -y
```

[Please refer to KSMBD development environment](https://chenxiaosong.com/en/smb2-change-notify.html#ksmbd-dev-env).

Create some necessary directories:
```sh
sudo mkdir -p /tmp/test
sudo mkdir -p /tmp/test2
sudo mkdir -p /tmp/test3
sudo mkdir -m 777 -p /tmp/s_test
sudo mkdir -m 777 -p /tmp/s_test2
sudo mkdir -m 777 -p /tmp/s_test3
```

Create KSMBD config file [`~/smb-test/ksmbd.conf`](https://github.com/namjaejeon/cifsd-test-result/blob/master/testsuites/smb.conf):
```sh
[global]
	workgroup = DRIVER
	netbios name = CIFSSRV
	share:fake_fscaps = 0
	smb2 leases = yes
	durable handles = yes

[test]
	comment = content server share1
	path = /tmp/s_test
	writeable = yes
	vfs objects = acl_xattr

[test2]
	comment = content server share2
	path = /tmp/s_test2
	writeable = yes
	vfs objects = acl_xattr

[test3]
	comment = content server share3
	path = /tmp/s_test3
	writeable = yes
	vfs objects = acl_xattr streams_xattr
```

Add KSMBD user and start ksmbd:
```sh
ksmbd.adduser -P ~/smb-test/ksmbdpwd.db -a root -p 1
# ksmbd.adduser -P ~/smb-test/ksmbdpwd.db --delete root # delete user
sudo modprobe ksmbd
sudo systemctl stop smb
sudo systemctl stop smbd
sudo systemctl stop ksmbd
sudo ksmbd.mountd -n -C ~/smb-test/ksmbd.conf -P ~/smb-test/ksmbdpwd.db &
```

# xfstests {#xfstests}

[Please refer to xfstests-dev/README](https://git.kernel.org/pub/scm/fs/xfs/xfstests-dev.git/tree/README).

On Fedora, Install all necessary packages from standard repository:
```sh
sudo yum install -y acl attr automake bc dbench dump e2fsprogs fio gawk gcc \
        gdbm-devel git indent kernel-devel libacl-devel libaio-devel \
        libcap-devel libtool liburing-devel libuuid-devel lvm2 make psmisc \
        python3 quota sed sqlite udftools  xfsprogs
```

Build xfstests-dev:
```sh
git clone https://git.kernel.org/pub/scm/fs/xfs/xfstests-dev.git
cd xfstests-dev
make -j`nproc`
```

Create `local.config` in `xfstests-dev`:
```sh
smb_server_ip=192.168.53.210
smb_username=root
smb_password=1
smb_mount_options="-o username=${smb_username},password=${smb_password}"
export FSTYP=cifs
export TEST_FS_MOUNT_OPTS="${smb_mount_options}"
export TEST_DEV=//${smb_server_ip}/cifsd-test1
export TEST_DIR=/mnt/1
export MOUNT_OPTIONS="${smb_mount_options}"
export SCRATCH_DEV=//${smb_server_ip}/cifsd-test2
export SCRATCH_MNT=/mnt/2
```

We can use [`xfstests.sh`](https://github.com/chenxiaosonggithub/blog/blob/master/course/smb/src/test/xfstests.sh) to test.

# smbtorture {#smbtorture}

Build `smbtorture` from source:
```sh
git clone https://gitlab.com/samba-team/devel/samba.git
cd samba/bootstrap/generated-dists/fedora41/ # You can replace fedora41 with your own distribution
./bootstrap.sh # It may take some time to install the dependencies
cd ../../../
./configure --disable-cups --disable-iprint --without-ad-dc --without-ads --without-ldap --without-pam --with-shared-modules='!vfs_snapper'
make -j$((`nproc`+1)) bin/smbtorture
```

We can use [`smbtorture.sh`](https://github.com/chenxiaosonggithub/blog/blob/master/course/smb/src/test/smbtorture.sh) to test.

