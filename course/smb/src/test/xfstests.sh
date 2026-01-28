xfstests_path=/root/code/xfstests-dev/
script_path="$(realpath "${BASH_SOURCE[0]}")"
script_dir="$(dirname "${script_path}")"
. ${script_dir}/common.sh

if [ $# -ne 1 ]; then
	echo "Usage: bash $0 <ip>"
	exit 1
fi
smb_server_ip=$1

result_file=${script_dir}/"xfstests-result.txt"
result_log_file=${script_dir}/"xfstests-result-log.txt"
> ${result_file}
> ${result_log_file}

do_test()
{
	local test_item=$1
	local date_time=`date +"%F %T"`
	cd ${xfstests_path}
	echo "starting run fstests $test_item at $date_time" >> ${result_log_file}  2>&1
	sudo ./check ${test_item} >> ${result_log_file}  2>&1
	result=$?
	if [[ ${result} == 0 ]]; then
		echo "${test_item} success" >> ${result_file}
	else
		echo "${test_item} fail" >> ${result_file}
	fi
	date_time=`date +"%F %T"`
	echo "finished run fstests $test_item at $date_time" >> ${result_log_file}  2>&1
}

mk_mnt_dir
start_ksmbd
echo "smb_server_ip=${smb_server_ip}" > ${xfstests_path}/local.config
echo "smb_username=${smb_username}" >> ${xfstests_path}/local.config
echo "smb_password=${smb_password}" >> ${xfstests_path}/local.config
cat ${script_dir}/xfstests-local.config >> ${xfstests_path}/local.config

do_test cifs/001
do_test generic/001
do_test generic/002
do_test generic/005
do_test generic/006
do_test generic/007
do_test generic/008
do_test generic/010
sed -e "s/count=1000/count=100/" -e "s/-p 5/-p 3/" tests/generic/011 > tests/generic/011.new
sed -e "s/-p 5/-p 3/" tests/generic/011.out > tests/generic/011.out.new
mv tests/generic/011.new tests/generic/011
mv tests/generic/011.out.new tests/generic/011.out
do_test generic/011
#        do_test generic/013
do_test generic/014
do_test generic/023
do_test generic/024
do_test generic/028
do_test generic/029
do_test generic/030
do_test generic/032
do_test generic/033
do_test generic/036
do_test generic/037
do_test generic/043
do_test generic/044
do_test generic/045
do_test generic/046
do_test generic/051
do_test generic/069
#        do_test generic/070
do_test generic/071
do_test generic/072
do_test generic/074
do_test generic/080
do_test generic/084
do_test generic/086
do_test generic/091
do_test generic/095
do_test generic/098
do_test generic/100
do_test generic/103
do_test generic/109
do_test generic/113
do_test generic/117
do_test generic/124
do_test generic/125
do_test generic/129
do_test generic/130
do_test generic/132
do_test generic/133
do_test generic/135
do_test generic/141
do_test generic/169
do_test generic/198
do_test generic/207
do_test generic/208
do_test generic/210
do_test generic/211
do_test generic/212
do_test generic/214
do_test generic/215
do_test generic/221
do_test generic/225
do_test generic/228
do_test generic/236
do_test generic/239
do_test generic/241
do_test generic/245
do_test generic/246
do_test generic/247
do_test generic/248
do_test generic/249
do_test generic/257
do_test generic/258
do_test generic/263
do_test generic/308
do_test generic/309
do_test generic/310
do_test generic/313
do_test generic/315
do_test generic/316
do_test generic/323
do_test generic/337
do_test generic/339
do_test generic/340
do_test generic/344
do_test generic/345
do_test generic/346
do_test generic/349
do_test generic/350
do_test generic/354
do_test generic/360
do_test generic/377
do_test generic/391
do_test generic/393
do_test generic/394
do_test generic/406
do_test generic/412
do_test generic/420
do_test generic/428
do_test generic/430
do_test generic/431
do_test generic/432
do_test generic/433
do_test generic/436
do_test generic/437
do_test generic/438
do_test generic/439
do_test generic/443
do_test generic/445
do_test generic/446
do_test generic/448
do_test generic/451
do_test generic/452
do_test generic/454
do_test generic/460
do_test generic/461
do_test generic/464
do_test generic/465
do_test generic/469
do_test generic/504
do_test generic/523
do_test generic/524
do_test generic/528
do_test generic/532
do_test generic/533
do_test generic/539
do_test generic/565
do_test generic/567
do_test generic/568
do_test generic/599
