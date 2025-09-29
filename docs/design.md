# AUR Builder Design Document

## 1. 项目概述

### 1.1 目的

aur-builder 是一个工具，旨在使用 GitHub Actions 在 CI/CD 环境中自动编译 Arch User Repository (AUR) 软件包，并将其打包成可由 pacman 包管理器直接安装的 .tar.gz 格式安装包。该工具简化了 AUR 包的构建和分发过程，适用于 Arch Linux 用户或希望在非 Arch 环境中分发 AUR 软件的开发者。

### 1.2 范围

- **核心功能**：从 AUR 仓库克隆指定软件包，执行构建（使用 makepkg），并将构建结果打包成 .tar.gz 文件。
- **平台**：依赖 GitHub Actions 的 Linux 运行环境（例如 ubuntu-latest）。
- **输出**：一个 .tar.gz 文件，包含构建好的 PKG 文件，可通过 `pacman -U` 安装。
- **限制**：不处理依赖解析（假设 Actions 环境中已预装 Arch 构建工具）；不支持交互式构建；专注于自动化构建，不包括手动干预。

### 1.3 目标用户

- Arch Linux 开发者：快速构建和分发 AUR 包。
- CI/CD 集成者：将 AUR 构建集成到 GitHub 项目中。
- 分发者：生成便携式安装包以分享软件。

## 2. 架构设计

### 2.1 高层架构

项目采用模块化设计，遵循开闭原则（对扩展开放，对修改封闭）。核心组件包括：

- **GitHub Actions 工作流**：入口点，触发构建过程。
- **构建脚本**：Bash 脚本（或 Python，如果需要更复杂逻辑），处理 AUR 克隆、构建和打包。
- **配置管理**：通过 workflow YAML 和环境变量管理输入参数（如 AUR 包名、版本）。
- **输出管理**：Artifacts 上传 .tar.gz 文件，便于下载。

架构图（文本表示）：

```
GitHub Repository
    |
    +-- .github/workflows/build-aur.yml (Workflow)
    |       |
    |       +-- Trigger: Manual/Dispatch/Push
    |       |
    |       +-- Jobs: Setup -> Build -> Package -> Upload
    |
    +-- scripts/build-aur.sh (Build Script)
    |       |
    |       +-- Clone AUR
    |       +-- makepkg
    |       +-- tar.gz Packaging
    |
    +-- docs/ (Documentation)
    +-- README.md (User Guide)
```

### 2.2 模块分解

- **输入模块**：workflow inputs（如 `package_name`, `version`），通过 GitHub API 或手动 dispatch 提供。
- **环境准备模块**：安装 Arch 构建工具（pacman, makepkg, git）。
- **构建模块**：克隆 AUR repo，运行 makepkg -si（非交互模式）。
- **打包模块**：将生成的 .pkg.tar.zst 文件压缩成 .tar.gz。
- **验证模块**：可选，运行基本校验（如文件完整性、签名验证）。
- **输出模块**：上传 artifacts 到 GitHub Releases 或 Actions。

### 2.3 依赖管理

- **系统依赖**：Arch Linux 工具链（在 Actions 中通过脚本安装）。
- **外部工具**：git, curl（用于克隆 AUR），makepkg。
- **无第三方库**：优先使用原生 Bash，避免引入额外依赖以保持轻量。

## 3. 组件详述

### 3.1 GitHub Actions 工作流 (.github/workflows/build-aur.yml)

- **触发器**：
  - `workflow_dispatch`：手动触发，支持 inputs（如 package_name: string, version: string）。
  - 可选：`push` 到特定分支，自动构建。
- **Jobs**：
  1. **setup**：Checkout 代码，安装 Arch 工具（使用 PKGBUILD 或 AUR helper 如 yay，但优先手动安装以控制）。
     - 命令示例：`sudo pacman -Syu --noconfirm base-devel git`（在 Arch 容器中）。
  2. **build**：运行构建脚本。
  3. **package**：生成 .tar.gz。
  4. **upload**：使用 `actions/upload-artifact` 或 `gh release` 上传。
- **环境**：使用自托管 runner 或 ubuntu-latest + Arch 安装脚本。
- **安全性**：使用 GITHUB_TOKEN 限制权限；避免 root 构建。

### 3.2 构建脚本 (scripts/build-aur.sh)

- **输入**：$1 = package_name, $2 = version（可选，默认 latest）。
- **步骤**：
  1. 克隆 AUR：`git clone https://aur.archlinux.org/$package_name.git`。
  2. cd 到目录：`cd $package_name`。
  3. 如果指定版本：`git checkout $version`。
  4. 构建：`makepkg -si --noconfirm`（安装依赖并构建）。
  5. 收集输出：`ls *.pkg.tar.zst`。
  6. 打包：`tar -czf ${package_name}-${version}.tar.gz *.pkg.tar.zst`。
- **错误处理**：使用 set -e；捕获 makepkg 失败并输出日志。
- **日志**：重定向输出到 Actions logs。

### 3.3 配置和自定义

- **workflow inputs**：
  - `package_name`：必需，AUR 包名。
  - `version`：可选，指定标签/分支。
  - `arch`：可选，构建架构（默认 x86_64）。
- **环境变量**：AUR_CACHE_DIR 用于缓存克隆。
- **扩展点**：钩子脚本（如 pre-build.sh）允许用户自定义。

## 4. 构建过程详解

### 4.1 流程图（文本）

```
Start
  |
  v
Receive Inputs (package_name, version)
  |
  v
Setup Environment (Install base-devel, git)
  |
  v
Clone AUR Repo: git clone https://aur.archlinux.org/$package_name.git
  |
  v
Checkout Version (if specified)
  |
  v
Run makepkg -si --noconfirm
  |          |
  | Success  | Fail
  v          v
Collect PKG files    Output Error & Exit
  |
  v
Package into .tar.gz: tar -czf output.tar.gz *.pkg.tar.*
  |
  v
Upload Artifact
  |
  v
End
```

### 4.2 关键挑战与解决方案

- **依赖安装**：AUR 包可能有复杂依赖。在 Actions 中预装常见依赖，或使用 chroot 环境（如 arch-chroot）。
- **构建时间**：AUR 构建可能耗时长；使用 matrix 策略并行不同包。
- **签名**：可选 gpg 签名 PKG 文件；需配置 GPG 在 Actions 中。
- **缓存**：使用 actions/cache 缓存 AUR 克隆和构建中间文件。
- **错误恢复**：如果 makepkg 失败，保留日志并通知。

### 4.3 输出格式

- **.tar.gz 内容**：
  - 根目录：构建好的 .pkg.tar.zst 文件（一个或多个，如果有 split packages）。
  - 可选：INSTALL 脚本或 README 说明 `pacman -U package.pkg.tar.zst`。
- **命名**：`${package_name}-${version}-${arch}.tar.gz`。
- **大小**：取决于包；Actions 有 10GB 限制。

## 5. 测试与验证

### 5.1 单元测试

- 测试脚本：使用 Bats（Bash 测试框架）验证克隆、makepkg 模拟。
- 示例：mock git clone 和 makepkg，检查输出文件。

### 5.2 集成测试

- 在 Actions 中运行端到端构建简单 AUR 包（如 hello-world）。
- 验证：解压 .tar.gz 并模拟 pacman 安装。

### 5.2 质量保障

- Lint：shellcheck 脚本。
- CI：每个 PR 运行测试工作流。

## 6. 部署与维护

### 6.1 部署

- 项目初始化：创建 .github/workflows/ 和 scripts/ 目录。
- 用户使用：Fork repo，dispatch workflow 指定包名。

### 6.2 维护

- 更新：监控 AUR 变化；定期更新 Arch 工具版本。
- 扩展：支持多包构建、自定义 PKGBUILD 覆盖。
- 文档：更新此 design.md 和 README。

### 6.3 风险与缓解

- **AUR 不可用**：fallback 到镜像或缓存。
- **构建失败**：提供详细日志；支持重试。
- **许可**：确保输出包遵守 AUR 许可。

## 7. 未来扩展

- 支持其他 AUR helpers（如 yay）。
- 集成 Docker/容器化构建。
- Web UI：通过 GitHub Pages 提供构建界面。
- 多架构支持：arm, i686 等。

此文档将随着项目演进更新。版本：1.0，日期：2025 年 9 月 29 日。
