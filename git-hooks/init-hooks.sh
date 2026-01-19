# 执行：到tools目录下执行 ./init-hooks.sh 命令或bash init-hooks.sh 命令
# 初始化 Git 钩子：将项目 git-hooks 目录的钩子同步到 .git/hooks/

# 1. 检查 git-hooks 目录是否存在
if [ ! -d "../git-hooks" ]; then
  echo "❌ 错误：项目根目录未找到 git-hooks 目录！"
  exit 1
fi

# 2. 复制钩子文件到 .git/hooks/
cp ../git-hooks/* ../.git/hooks/

# 3. 赋予所有钩子文件可执行权限
chmod +x ../.git/hooks/*

echo "✔ Git 钩子初始化完成！所有钩子已生效。"
exit 0