#!/bin/sh
# 同步 Git 钩子到 .git/hooks 目录

echo "🔄 同步企业级 Git 钩子..."

# 复制钩子文件
cp git-hooks/pre-commit .git/hooks/
cp git-hooks/commit-msg .git/hooks/

# 设置可执行权限
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg

echo "✅ Git 钩子同步完成！"