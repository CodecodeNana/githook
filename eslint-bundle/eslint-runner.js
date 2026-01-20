#!/usr/bin/env node
/**
 * ESLint 独立执行入口（适配原生 JS + jQuery）
 * 特性：1. 内置配置 2. 无外部依赖 3. 输出友好提示
 */
const { ESLint } = require("eslint");
const fs = require("fs");
const path = require("path");

// ====================== 配置区（可根据团队需求调整） ======================
const ESLINT_CONFIG = {
  env: {
    browser: true,    // 支持浏览器环境（window/document）
    es5: true,        // 适配 ES5（原生 JS/jQuery 项目）
    jquery: true      // 识别 jQuery 全局变量
  },
  globals: {
    jQuery: "readonly",
    $: "readonly",
    window: "readonly",
    document: "readonly",
    console: "readonly"
  },
  plugins: ["jquery"],
  rules: {
    // 基础语法规则
    "no-undef": "error",                // 禁止未定义变量
    "no-unused-vars": ["error", { "vars": "all", "args": "none" }], // 禁止未使用变量
    "semi": ["error", "always"],        // 强制分号结尾
    "quotes": ["error", "double"],      // 强制双引号
    "eqeqeq": ["error", "always"],      // 强制 === 而非 ==
    "curly": ["error", "all"],          // if/for 强制加花括号
    "no-trailing-spaces": "error",      // 禁止行尾空格
    "indent": ["error", 2],             // 缩进 2 个空格
    "max-len": ["error", { "code": 120 }], // 单行最大长度 120
    // jQuery 专属规则（避免常见坑）
    "jquery/no-global-ajax": "warn",    // 警告全局 ajax 使用
    "jquery/no-animate-toggle": "warn", // 警告 animate/toggle 混用
    "jquery/no-sizzle": "error"         // 禁止使用 Sizzle 选择器
  },
  parserOptions: {
    ecmaVersion: 5 // 适配 ES5 语法
  }
};

// ====================== 核心执行逻辑 ======================
async function runEslint() {
  // 1. 获取命令行传入的文件列表
  const files = process.argv.slice(2);
  if (files.length === 0) {
    console.error("\n❌ 错误：请传入要校验的 JS 文件路径");
    process.exit(1);
  }

  // 2. 验证文件是否存在
  const validFiles = [];
  for (const file of files) {
    if (fs.existsSync(file)) {
      validFiles.push(file);
    } else {
      console.warn(`⚠️  警告：文件不存在，跳过校验：${file}`);
    }
  }
  if (validFiles.length === 0) {
    console.log("\n✅ 无有效 JS 文件，跳过 ESLint 校验");
    process.exit(0);
  }

  // 3. 初始化 ESLint
  const eslint = new ESLint({
    overrideConfig: ESLINT_CONFIG,
    useEslintrc: false, // 禁用外部配置，保证独立可执行
    fix: false           // 关闭自动修复（如需自动修复改为 true）
  });

  // 4. 执行校验
  try {
    const results = await eslint.lintFiles(validFiles);
    const formatter = await eslint.loadFormatter("stylish"); // 友好的输出格式
    const resultText = formatter.format(results);

    // 输出校验结果
    if (resultText) {
      console.log("\n" + resultText);
    }

    // 统计错误数，决定退出码
    const errorCount = results.reduce((sum, res) => sum + res.errorCount, 0);
    if (errorCount > 0) {
      console.error(`\n❌ ESLint 校验失败：共 ${errorCount} 个错误`);
      process.exit(1);
    } else {
      console.log("\n✅ ESLint 校验通过！");
      process.exit(0);
    }
  } catch (err) {
    console.error("\n❌ ESLint 执行失败：", err.message);
    process.exit(1);
  }
}

// 启动校验
runEslint();