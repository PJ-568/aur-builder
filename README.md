# AUR Builder

> [ENGLISH](README.en.md) | 简体中文

aur-builder 旨在用 GitHub Actions 编译 AUR 软件为能被 pacman 包管理器安装的 .pkg.tar.zst 安装包格式。

## 项目概述

该工具自动化从 AUR 克隆指定软件包、使用 makepkg 构建，并将结果打包成 .tar.gz 文件，便于分发和安装。适用于 Arch Linux 用户或开发者在 CI/CD 中集成 AUR 构建。

### 特性

- 支持手动触发构建（workflow_dispatch）。
- 可指定包名、版本和架构。
- 在 Arch Linux 容器中运行，确保兼容性。
- 输出可直接通过 `pacman -U` 安装的 PKG 文件。
- 自动上传 artifact，便于下载。

### 先决条件

- GitHub 账户和仓库（fork 此项目）。
- 基本了解 Arch Linux 和 AUR。
- 目标系统需安装 pacman 以使用输出包。

## 使用指南

### 步骤 1: Fork 仓库

1. 访问 [GitHub 仓库](https://github.com/your-username/aur-builder)（替换为你的 fork）。
2. 点击 "Fork" 创建副本。

### 步骤 2: 触发构建

1. 在仓库页面，转到 **Actions** 标签。
2. 选择 **Build AUR Package** workflow。
3. 点击 **Run workflow**。
4. 在输入表单中填写：
   - **package_name**：AUR 包名（必需，例如 `yay`）。
   - **version**：版本或 git 标签/分支（可选，默认 `latest`）。
   - **arch**：目标架构（可选，默认 `x86_64`）。
5. 点击 **Run workflow** 开始构建。

### 步骤 3: 下载和安装

1. 构建完成后，转到 **Actions** > 选择运行 > **Artifacts**。
2. 下载 `aur-package-{package_name}-{version}.tar.gz`。
3. 解压文件：`tar -xzf aur-package-*.tar.gz`。
4. 安装包：`sudo pacman -U *.pkg.tar.zst`。

### 示例

构建 `yay` 包：

- package_name: `yay`
- version: `latest`（或具体标签如 `v12.0.5`）
- arch: `x86_64`

输出文件：`yay-latest.tar.gz`，包含 `yay-12.0.5-1-x86_64.pkg.tar.zst`。

## 自定义和扩展

- **修改脚本**：编辑 [scripts/build-aur.sh](scripts/build-aur.sh) 以添加自定义逻辑（如预构建钩子）。
- **工作流调整**：修改 [.github/workflows/build-aur.yml](.github/workflows/build-aur.yml) 以支持自动触发或多包构建。
- **缓存**：未来可添加 actions/cache 以加速重复构建。

## 故障排除

- **构建失败**：检查 Actions 日志。常见问题包括依赖缺失（确保容器有 base-devel）或 AUR 仓库不可达。
- **无 PKG 文件**：makepkg 可能因签名或依赖失败。查看脚本输出。
- **权限错误**：确保在 Arch 环境中运行，非 root 用户构建。
- **版本不存在**：确认 git checkout 的标签/分支有效。

如果问题持续，检查 [docs/design.md](docs/design.md) 或提交 issue。

## 贡献

1. Fork 仓库。
2. 创建分支：`git checkout -b feature/new-feature`。
3. 提交更改：`git commit -m "【新增】添加新功能"`（遵循提交规范）。
4. Push 分支：`git push origin feature/new-feature`。
5. 提交 Pull Request。

欢迎贡献脚本改进、测试或文档更新！

## 许可

MIT License。详见 LICENSE 文件。

## 相关资源

- [AUR 官网](https://aur.archlinux.org/)
- [makepkg 手册](https://man.archlinux.org/man/makepkg.8)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
