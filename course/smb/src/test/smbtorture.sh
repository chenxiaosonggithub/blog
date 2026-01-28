smbtorture_path=/root/code/samba-smbtorture/
script_path="$(realpath "${BASH_SOURCE[0]}")"
script_dir="$(dirname "${script_path}")"
. ${script_dir}/common.sh

if [ $# -ne 1 ]; then
	echo "Usage: bash $0 <ip>"
	exit 1
fi
smb_server_ip=$1

result_file=${script_dir}/"smbtorture-result.txt"
result_log_file=${script_dir}/"smbtorture-result-log.txt"
> ${result_file}
> ${result_log_file}

do_test()
{
	local test_item=$1
	local date_time=`date +"%F %T"`
	cd ${smbtorture_path}
	echo "starting run smbtorture $test_item at $date_time" >> ${result_log_file}  2>&1
	./bin/smbtorture //${smb_server_ip}/cifsd-test3/ -U${smb_username}%${smb_password} ${test_item} >> ${result_log_file}  2>&1
	result=$?
	if [[ ${result} == 0 ]]; then
		echo "${test_item} success" >> ${result_file}
	else
		echo "${test_item} fail" >> ${result_file}
	fi
	date_time=`date +"%F %T"`
	echo "finished run smbtorture $test_item at $date_time" >> ${result_log_file}  2>&1
}

mk_mnt_dir
start_ksmbd

# smb2 connect test
do_test smb2.connect
sudo rm -rf /mnt/test3/*
# smb2 read test
do_test smb2.read.eof
sudo rm -rf /mnt/test3/*
do_test smb2.read.position
sudo rm -rf /mnt/test3/*
do_test smb2.read.dir
sudo rm -rf /mnt/test3/*
do_test smb2.read.access
sudo rm -rf /mnt/test3/*
# smb2 scan test
do_test smb2.scan.scan
sudo rm -rf /mnt/test3/*
do_test smb2.scan.getinfo
sudo rm -rf /mnt/test3/*
do_test smb2.scan.setinfo
sudo rm -rf /mnt/test3/*
do_test smb2.scan.find
sudo rm -rf /mnt/test3/*
# smb2 dir test
do_test smb2.dir.find
sudo rm -rf /mnt/test3/*
do_test smb2.dir.fixed
sudo rm -rf /mnt/test3/*
##do_test smb2.dir.one
##sudo rm -rf /mnt/test3/*
do_test smb2.dir.many
sudo rm -rf /mnt/test3/*
do_test smb2.dir.modify
sudo rm -rf /mnt/test3/*
do_test smb2.dir.sorted
sudo rm -rf /mnt/test3/*
do_test smb2.dir.file-index
sudo rm -rf /mnt/test3/*
do_test smb2.dir.large-files
sudo rm -rf /mnt/test3/*
# smb2 rename test
do_test smb2.rename.simple
sudo rm -rf /mnt/test3/*
do_test smb2.rename.simple_nodelete
sudo rm -rf /mnt/test3/*
do_test smb2.rename.no_sharing
sudo rm -rf /mnt/test3/*
do_test smb2.rename.share_delete_and_delete_access
sudo rm -rf /mnt/test3/*
do_test smb2.rename.no_share_delete_but_delete_access
sudo rm -rf /mnt/test3/*
do_test smb2.rename.share_delete_no_delete_access
sudo rm -rf /mnt/test3/*
do_test smb2.rename.msword
sudo rm -rf /mnt/test3/*
# - do_test smb2.rename.rename_dir_openfile
# - sudo rm -rf /mnt/test3/*
do_test smb2.rename.rename_dir_bench
sudo rm -rf /mnt/test3/*
# smb2 maxfid test
do_test smb2.maxfid
sudo rm -rf /mnt/test3/*
# smb2 sharemode test
do_test smb2.sharemode.sharemode-access
sudo rm -rf /mnt/test3/*
do_test smb2.sharemode.access-sharemode
sudo rm -rf /mnt/test3/*
# smb2 compound test
do_test smb2.compound.related1
sudo rm -rf /mnt/test3/*
do_test smb2.compound.related2
sudo rm -rf /mnt/test3/*
do_test smb2.compound.related3
sudo rm -rf /mnt/test3/*
do_test smb2.compound.unrelated1
sudo rm -rf /mnt/test3/*
do_test smb2.compound.invalid1
sudo rm -rf /mnt/test3/*
do_test smb2.compound.invalid2
sudo rm -rf /mnt/test3/*
do_test smb2.compound.invalid3
sudo rm -rf /mnt/test3/*
# - do_test smb2.compound.interim1 #fail
# - sudo rm -rf /mnt/test3/*
do_test smb2.compound.interim2
sudo rm -rf /mnt/test3/*
do_test smb2.compound.compound-break
sudo rm -rf /mnt/test3/*
do_test smb2.compound.compound-padding
sudo rm -rf /mnt/test3/*
# smb2 streams test
do_test smb2.streams.dir
do_test smb2.streams.io
do_test smb2.streams.sharemodes
do_test smb2.streams.names
do_test smb2.streams.names2
do_test smb2.streams.names3
do_test smb2.streams.rename
do_test smb2.streams.rename2
do_test smb2.streams.create-disposition
##do_test smb2.streams.attributes
# - do_test smb2.streams.delete
do_test smb2.streams.zero-byte
do_test smb2.streams.basefile-rename-with-open-stream
sudo rm -rf /mnt/test3/*
# smb2 create test
##do_test smb2.create.gentest
##do_test smb2.create.blob
do_test smb2.create.open
do_test smb2.create.brlocked
do_test smb2.create.multi
do_test smb2.create.delete
do_test smb2.create.leading-slash
do_test smb2.create.impersonation
do_test smb2.create.dir-alloc-size
do_test smb2.create.aclfile
sudo rm -rf /mnt/test3/*
do_test smb2.create.acldir
sudo rm -rf /mnt/test3/*
do_test smb2.create.nulldacl
sudo rm -rf /mnt/test3/*
# smb2 delete-on-close test
do_test smb2.delete-on-close-perms.OVERWRITE_IF
sudo rm -rf /mnt/test3/*
do_test "smb2.delete-on-close-perms.OVERWRITE_IF Existing"
sudo rm -rf /mnt/test3/*
do_test smb2.delete-on-close-perms.CREATE
sudo rm -rf /mnt/test3/*
do_test "smb2.delete-on-close-perms.CREATE Existing"
sudo rm -rf /mnt/test3/*
do_test smb2.delete-on-close-perms.CREATE_IF
sudo rm -rf /mnt/test3/*
do_test "smb2.delete-on-close-perms.CREATE_IF Existing"
sudo rm -rf /mnt/test3/*
do_test smb2.delete-on-close-perms.FIND_and_set_DOC
sudo rm -rf /mnt/test3/*
# smb2 oplock test
do_test smb2.oplock.exclusive1
do_test smb2.oplock.exclusive2
do_test smb2.oplock.exclusive3
do_test smb2.oplock.exclusive4
do_test smb2.oplock.exclusive5
do_test smb2.oplock.exclusive6
do_test smb2.oplock.exclusive9
do_test smb2.oplock.batch1
do_test smb2.oplock.batch2
do_test smb2.oplock.batch3
do_test smb2.oplock.batch4
do_test smb2.oplock.batch5
do_test smb2.oplock.batch6
do_test smb2.oplock.batch7
do_test smb2.oplock.batch8
do_test smb2.oplock.batch9
do_test smb2.oplock.batch9a
do_test smb2.oplock.batch10
do_test smb2.oplock.batch11
do_test smb2.oplock.batch12
do_test smb2.oplock.batch13
do_test smb2.oplock.batch14
do_test smb2.oplock.batch15
do_test smb2.oplock.batch16
do_test smb2.oplock.batch19
do_test smb2.oplock.batch20
do_test smb2.oplock.batch21
do_test smb2.oplock.batch22a
do_test smb2.oplock.batch23
do_test smb2.oplock.batch24
do_test smb2.oplock.batch25
do_test smb2.oplock.batch26 #fail
# - do_test smb2.oplock.stream1 #fail
do_test smb2.oplock.doc
do_test smb2.oplock.brl1
sudo rm -rf /mnt/test3/*
do_test smb2.oplock.brl2
sudo rm -rf /mnt/test3/*
do_test smb2.oplock.brl3
sudo rm -rf /mnt/test3/*
do_test smb2.oplock.levelii500
sudo rm -rf /mnt/test3/*
do_test smb2.oplock.levelii501
sudo rm -rf /mnt/test3/*
do_test smb2.oplock.levelii502
#sudo rm -rf /mnt/test3/*
# smb2 session test
do_test smb2.session.reconnect1
do_test smb2.session.reconnect2
do_test smb2.session.reauth1
do_test smb2.session.reauth2
do_test smb2.session.reauth3
do_test smb2.session.reauth4
# smb2 lock test
do_test smb2.lock.valid-request
do_test smb2.lock.rw-shared
do_test smb2.lock.rw-exclusive
do_test smb2.lock.auto-unlock
do_test smb2.lock.async
do_test smb2.lock.cancel
do_test smb2.lock.cancel-tdis
do_test smb2.lock.cancel-logoff
do_test smb2.lock.zerobytelength
do_test smb2.lock.zerobyteread
do_test smb2.lock.unlock
do_test smb2.lock.multiple-unlock
do_test smb2.lock.stacking
do_test smb2.lock.contend
do_test smb2.lock.context
do_test smb2.lock.truncate
# smb2 leases test
do_test smb2.lease.request
do_test smb2.lease.nobreakself
do_test smb2.lease.statopen
do_test smb2.lease.statopen2
do_test smb2.lease.statopen3
do_test smb2.lease.upgrade
do_test smb2.lease.upgrade2
do_test smb2.lease.upgrade3
do_test smb2.lease.break
do_test smb2.lease.oplock
do_test smb2.lease.multibreak
do_test smb2.lease.breaking1
do_test smb2.lease.breaking2
do_test smb2.lease.breaking3
#do_test smb2.lease.breaking4
do_test smb2.lease.breaking5
do_test smb2.lease.breaking6
do_test smb2.lease.lock1
do_test smb2.lease.complex1
do_test smb2.lease.timeout
#do_test smb2.lease.unlink
do_test smb2.lease.v2_request_parent
do_test smb2.lease.v2_request
do_test smb2.lease.v2_epoch1
do_test smb2.lease.v2_epoch2
do_test smb2.lease.v2_epoch3
do_test smb2.lease.v2_complex2
do_test smb2.lease.v2_rename
# smb2 acls test
do_test smb2.acls.CREATOR
sudo rm -rf /mnt/test3/*
do_test smb2.acls.GENERIC
sudo rm -rf /mnt/test3/*
do_test smb2.acls.OWNER
sudo rm -rf /mnt/test3/*
do_test smb2.acls.INHERITANCE
sudo rm -rf /mnt/test3/*
do_test smb2.acls.INHERITFLAGS
sudo rm -rf /mnt/test3/*
do_test smb2.acls.DYNAMIC
# smb2 credits test
do_test smb2.credits.session_setup_credits_granted
do_test smb2.credits.single_req_credits_granted
do_test smb2.credits.skipped_mid
# smb2 durable handle test
do_test smb2.durable-open.open-oplock
do_test smb2.durable-open.open-lease
do_test smb2.durable-open.reopen1
do_test smb2.durable-open.reopen1a
do_test smb2.durable-open.reopen1a-lease
do_test smb2.durable-open.reopen2
do_test smb2.durable-open.reopen2a
do_test smb2.durable-open.reopen2-lease
do_test smb2.durable-open.reopen2-lease-v2
do_test smb2.durable-open.reopen3
do_test smb2.durable-open.reopen4
do_test smb2.durable-open.delete_on_close2
do_test smb2.durable-open.file-position
do_test smb2.durable-open.lease
do_test smb2.durable-open.alloc-size
do_test smb2.durable-open.read-only
do_test smb2.durable-v2-open.create-blob
do_test smb2.durable-v2-open.open-oplock
do_test smb2.durable-v2-open.open-lease
do_test smb2.durable-v2-open.reopen1
do_test smb2.durable-v2-open.reopen1a
do_test smb2.durable-v2-open.reopen1a-lease
do_test smb2.durable-v2-open.reopen2
do_test smb2.durable-v2-open.reopen2b
do_test smb2.durable-v2-open.reopen2c
do_test smb2.durable-v2-open.reopen2-lease
do_test smb2.durable-v2-open.reopen2-lease-v2
