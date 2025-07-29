. ~/.top-path
docker_name=workspace-ubuntu2404
image_name=workspace-ubuntu:24.04
host_dir=${MY_TOP_PATH}
container_dir=${MY_TOP_PATH}

echo "当前的容器:"
docker ps -a
echo -e "\n从镜像${image_name}启动容器${docker_name}..."
docker run -p 8888:8888 --name ${docker_name} --hostname ${docker_name} --privileged -itd -v ${host_dir}:${container_dir} -w ${container_dir} ${image_name} bash
echo -e "\n确认${docker_name}是否启动成功:"
docker ps -a
echo -e "\n请使用以下命令进入容器:"
echo "docker exec -it ${docker_name} bash"
