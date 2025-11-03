mount_info=$(mount | grep nfs | grep enfs_info)
echo "mount_info:${mount_info}"
localaddr=$(echo "$mount_info" | awk -F'localaddrs=' '{print $2}' | awk -F'[~,-]' '{print $1}')
echo "localaddr: ${localaddr}"
enfs_info=$(echo "$mount_info" | grep -o 'enfs_info=[^)]*' | sed 's/enfs_info=//')
echo "enfs_info: ${enfs_info}"
interface=$(ip -br addr show | grep "${localaddr}" | awk '{print $1}')
echo "interface: ${interface}"


