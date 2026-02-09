docker_name=workspace-fedora
image_name=workspace-fedora:latest
if [ -f "${docker_name}.tar" ]; then
    echo "请将${docker_name}.tar重命名再运行此脚本"
    exit 1
fi
echo "正在运行的容器:"
docker ps -a # 查看容器
echo -e "\n停止容器${docker_name}..."
docker stop ${docker_name} # 停止容器
echo -e "\n导出容器${docker_name}..."
docker export ${docker_name} > ${docker_name}.tar # 导出容器
echo -e "\n删除容器${docker_name}..."
docker rm ${docker_name} # 删除容器
echo -e "\n请确认容器${docker_name}是否删除成功:"
docker ps -a # 查看容器是否删除成功
echo -e "\n删除镜像${image_name}..."
docker image rm ${image_name} # 删除镜像
echo -e "\n请确认镜像${image_name}是否删除成功:"
docker image ls # 查看镜像是否删除成功
echo -e "\n导入镜像${image_name}..."
cat ${docker_name}.tar | docker import - ${image_name} # 导入镜像
echo -e "\n请确认镜像${image_name}是否导入成功:"
docker image ls # 查看镜像是否导入成功
echo -e "\n查看image的创建时间:"
docker inspect workspace-ubuntu:24.04 | grep Created
mv ${docker_name}.tar ${docker_name}.tar-$(uname -s)-$(uname -m)-$(date +"%Y%m%d-%H%M%S")
