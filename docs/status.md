# 项目状态概览

## 当前阶段

- 核心实现阶段：构建脚本和 workflow 已激活；测试和缓存按计划进行。

## 已完成

- [x] 初始 AUR 构建脚本 (`scripts/build-aur.sh`) 实现：支持克隆、构建和打包。
- [x] GitHub Actions workflow (`.github/workflows/build-aur.yml`) 配置：使用 Arch 容器，非 root 用户构建。
- [x] 修复 gogs 包构建问题：处理 Bash glob 展开错误（tar 打包失败），预安装 Go 依赖。

## 进行中

- [-] 端到端测试：使用 bats 框架验证克隆、makepkg 和打包流程。
- [-] 缓存优化：集成 GitHub Actions 缓存以加速重复构建。

## 待办

- [ ] 文档更新：完善 README.md 中的使用指南和故障排除。
- [ ] 扩展支持：添加更多 AUR 包类型（如 split packages）的处理。
- [ ] CI 集成：自动化 lint（shellcheck）和测试（bats）步骤。
