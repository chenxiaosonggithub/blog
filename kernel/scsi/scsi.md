[toc]

# delete after mounting

[host-id, channel-id, target-id, lun-id]
```shell
lsscsi
echo "asdf" > /sys/class/scsi_device/0:0:0:0/device # echo any char
echo "- - -" > /sys/class/scsi_host/host0 # channel-id, target-id, lun-id
```
