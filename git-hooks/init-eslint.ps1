<#
.SYNOPSIS
一键初始化 ESLint 独立校验环境（无 Node.js 依赖）
.DESCRIPTION
适用于原生 JS + jQuery 项目，自动配置 Git 提交钩子和 ESLint 二进制文件
#>

# 解决中文乱码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

# ========== 配置项 ==========
$PROJECT_ROOT = $PWD.Path
$TOOLS_DIR = Join-Path -Path $PROJECT_ROOT -ChildPath "git-tools"
$HOOK_SRC = Join-Path -Path $TOOLS_DIR -ChildPath "pre-commit"
$HOOK_DEST = Join-Path -Path $PROJECT_ROOT -ChildPath ".git/hooks/pre-commit"
$ZIP_FILE = Join-Path -Path $PROJECT_ROOT -ChildPath "git-tools.zip"

# ========== 步骤 1：解压工具包 ==========
try {
  if (Test-Path $ZIP_FILE) {
    Write-Host "📦 正在解压 ESLint 工具包..." -ForegroundColor Cyan
    if (Test-Path $TOOLS_DIR) {
      Remove-Item -Path $TOOLS_DIR -Recurse -Force
    }
    Expand-Archive -Path $ZIP_FILE -DestinationPath $TOOLS_DIR -Force
    Write-Host "✅ 工具包解压完成：$TOOLS_DIR" -ForegroundColor Green
  } else {
    Write-Host "⚠️  未找到 git-tools.zip，跳过解压（请确认工具包已放入项目根目录）" -ForegroundColor Yellow
  }
} catch {
  Write-Host "❌ 解压工具包失败：$($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

# ========== 步骤 2：配置 Git 钩子 ==========
try {
  Write-Host "🔧 正在配置 Git pre-commit 钩子..." -ForegroundColor Cyan
  
  # 确保 hooks 目录存在
  $HOOK_DIR = Split-Path -Path $HOOK_DEST -Parent
  if (-not (Test-Path $HOOK_DIR)) {
    New-Item -Path $HOOK_DIR -ItemType Directory | Out-Null
  }

  # 复制钩子文件
  if (Test-Path $HOOK_SRC) {
    Copy-Item -Path $HOOK_SRC -Destination $HOOK_DEST -Force
  } else {
    # 若未找到源文件，直接写入钩子内容（兜底）
    $HOOK_CONTENT = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/你的仓库/pre-commit" -UseBasicParsing).Content
    Set-Content -Path $HOOK_DEST -Value $HOOK_CONTENT -Encoding UTF8
  }

  # 赋予执行权限（调用 Git Bash 的 chmod）
  git bash -c "chmod +x '$HOOK_DEST'" 2>/dev/null
  
  Write-Host "✅ Git 钩子配置完成：$HOOK_DEST" -ForegroundColor Green
} catch {
  Write-Host "❌ 配置 Git 钩子失败：$($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

# ========== 步骤 3：验证配置 ==========
try {
  Write-Host "✅ 正在验证 ESLint 配置..." -ForegroundColor Cyan
  $OS_TYPE = if ($Env:OS -eq "Windows_NT") { "win" } elseif ($Env:OSTYPE -eq "darwin") { "mac" } else { "linux" }
  $ESLINT_EXE = Join-Path -Path $TOOLS_DIR -ChildPath "bin/$OS_TYPE/eslint.exe"
  
  if (Test-Path $ESLINT_EXE) {
    Write-Host "✅ ESLint 二进制文件验证通过：$ESLINT_EXE" -ForegroundColor Green
  } else {
    Write-Host "⚠️  ESLint 二进制文件未找到，可能需要手动放入：$ESLINT_EXE" -ForegroundColor Yellow
  }
} catch {
  Write-Host "❌ 验证配置失败：$($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

# ========== 完成提示 ==========
Write-Host "`n🎉 ESLint 独立校验环境初始化完成！" -ForegroundColor Green
Write-Host "📝 使用说明：" -ForegroundColor Cyan
Write-Host "   1. 修改 JS 文件后执行 git add 文件名.js"
Write-Host "   2. 执行 git commit 时会自动触发 ESLint 校验"
Write-Host "   3. 校验失败则提交终止，修复后重新提交即可"
Write-Host "`n按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")