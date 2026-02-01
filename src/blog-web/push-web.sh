. ~/.top-path
code_path=${MY_CODE_TOP_PATH}
user_name=chenxiaosonggithub
github_io_repo=${code_path}/${user_name}.github.io/
# 导入其他脚本
. ${code_path}/blog/src/blog-web/common-lib.sh
. ~/.set_proxy.sh 1

comm_create_params "false"

is_new_repo=false
if [ $# -ge 1 ]; then
	is_new_repo=$1
fi
echo "new github.io repo: ${is_new_repo}"
if [[ ! -d "${github_io_repo}" ]]; then
	echo "${github_io_repo} not exist, set is_new_repo=true"
	is_new_repo=true
fi

bash ${code_path}/blog/src/blog-web/create-html.sh false this-arg-is-useless ${github_io_repo}
cp ${code_path}/blog/src/blog-web/github-io-404.html ${github_io_repo}/404.html
cp ${code_path}/blog/src/blog-web/github-io-README.md ${github_io_repo}/README.md
echo "chenxiaosong.com" > ${github_io_repo}/CNAME
ls_array=( # index.html有内容的路径，需要生成ls.html
	""
	"en"
)
comm_generate_index "${github_io_repo}" "" "${github_io_repo}" ls_array[@]

sudo chown -R $USER:$USER ${github_io_repo}
cd ${github_io_repo}
if [[ "${is_new_repo}" == true ]]; then
	rm .git -rf
	git init
else
	git remote remove github
fi
git remote add github git@github.com:${user_name}/${user_name}.github.io.git
if [[ "${is_new_repo}" == false ]]; then
	git fetch github
	git reset github/master
fi
git add .
git commit -s -m "chenxiaosong.com"
git branch -m master # 确保分支名为master
git push github master -f

# others blog
# bash ${code_path}/private-blog/others-blog/push-github.sh "${is_new_repo}"
