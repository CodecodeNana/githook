/**
 * ESlint 入口文件
 */
const { ESLint } = require("eslint");
var aaa = 1;
// 核心配置：仅用内置规则，声明 jQuery 全局变量
const ESLINT_CONFIG = {
  env: {
    browser: true // 浏览器环境（window/document 等全局变量）
  },
  parserOptions: {
    ecmaVersion: 5 // 适配原生 ES5 语法
  },
  globals: {
    // 声明 jQuery 相关全局变量，解决 $/jQuery 未定义报错
    jQuery: "readonly",
    $: "readonly"
  },
  rules: {
  }
};

// 创建 ESLint 实例（禁用外部插件，仅用内置规则）
const eslint = new ESLint({
  baseConfig: ESLINT_CONFIG,
  useEslintrc: true, // 仍支持外部配置覆盖
  fix: false,
  ignore: false
});

// 核心校验逻辑
async function lintFiles(files) {
  try {
    const results = await eslint.lintFiles(files);
    let hasError = false;

    // 输出错误信息
    results.forEach(result => {
      if (result.errorCount > 0 || result.warningCount > 0) {
        hasError = true;
        console.log(`\n❌ 校验失败 → ${result.filePath}`);
        result.messages.forEach(msg => {
          const type = msg.severity === 2 ? "错误" : "警告";
          console.log(`  第${msg.line}行第${msg.column}列 [${type}]：${msg.message}`);
        });
      }
    });

    if (hasError) {
      process.exit(1);
    } else {
      console.log("\n✅ 所有文件 ESLint 校验通过！");
      process.exit(0);
    }
  } catch (err) {
    console.error("❌ ESLint 执行失败：", err.message);
    process.exit(1);
  }
}

// 入口：接收命令行传入的文件列表
const files = process.argv.slice(2);
if (files.length === 0) {
  console.error("❌ 错误：请传入要校验的 JS 文件路径");
  process.exit(1);
}

lintFiles(files);