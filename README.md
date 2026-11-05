<div align="center">

# Terminal_Proxy_Tools_Kelen

**一条命令开关终端代理：Shell 环境变量、Git、SSH 与 `sudo apt` 同步生效，局域网目标自动直连。**

[![Release](https://img.shields.io/github/v/release/calonye/terminal-proxy-tools-kelen?label=release)](https://github.com/calonye/terminal-proxy-tools-kelen/releases/latest)
[![License](https://img.shields.io/github/license/calonye/terminal-proxy-tools-kelen?label=license)](./LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20zsh-4EAA25)](#环境要求)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)](#环境要求)

中文 | [English](./README.en.md)

[快速开始](#快速开始) · [下载最新版本](https://github.com/calonye/terminal-proxy-tools-kelen/releases/latest) · [更新日志](./CHANGELOG.md)

</div>

一份面向 `bash` 和 `zsh` 的终端代理管理脚本，用来统一管理 Shell 环境变量、Git 代理和 SSH 代理，支持局域网绕过，并让 Ubuntu / Debian 上的 `sudo apt` 也能走代理。

- 当前版本：`v4.2.0`
- 最后更新：`2026-11-04`

## 为什么用它

- 不想分别手改 Shell、Git、SSH 的代理配置
- 需要一键开启、关闭并检查当前代理状态
- 需要让局域网目标直连，避免 HTTP 能直连但 SSH 仍误走代理

## 功能

- `proxy_on / proxy_off / proxy_status`
- 同步管理 `http_proxy / https_proxy / all_proxy`
- 同步写入和清理 Git 全局代理
- 同步写入和清理 `~/.ssh/config` 中由脚本托管的代理区块
- 支持多本地局域网绕过
- 当前终端的 `sudo apt` / `sudo apt-get` 自动保留代理变量
- 启用前探测 `git` 与 `nc`
- 分层显示环境变量、Git、SSH、APT 代理传递的当前状态

## 快速开始

任选一种方式获取脚本。

**从 Release 下载**（无需克隆仓库）：

```sh
ver=v4.2.0
curl -LO "https://github.com/calonye/terminal-proxy-tools-kelen/releases/download/${ver}/terminal-proxy-tools-kelen-${ver}.tar.gz"
tar -xzf "terminal-proxy-tools-kelen-${ver}.tar.gz"
cp "terminal-proxy-tools-kelen-${ver}/Sources/.proxy.sh" ~/.proxy.sh
```

Release 页面同时提供 `.zip` 压缩包和 `SHA256SUMS` 校验文件。

**或者，在仓库根目录执行：**

```sh
cp ./Sources/.proxy.sh ~/.proxy.sh
```

> 升级提示：如果 `~/.proxy.sh` 已存在，复制会覆盖你在顶部配置区填写的代理地址和端口。请先备份（如 `cp ~/.proxy.sh ~/.proxy.sh.bak`），复制后再把配置区改回原值。

如果你使用 `zsh`：

```sh
echo 'source ~/.proxy.sh' >> ~/.zshrc
source ~/.zshrc
```

如果你使用 `bash`：

```sh
echo 'source ~/.proxy.sh' >> ~/.bashrc
source ~/.bashrc
```

加载后即可使用：

```sh
proxy_on
proxy_status
proxy_off
```

## 配置

安装后直接修改 `~/.proxy.sh` 顶部配置区，通常只需要关注：

- `PROXY_HOST`
- `PROXY_HTTP_PORT`
- `PROXY_SOCKS_PORT`
- `NO_PROXY`
- `SSH_BYPASS_EXTRA_PATTERNS`

### NO_PROXY

用于控制环境变量层的绕过目标，默认值包含常见本机与私网范围：

```sh
NO_PROXY="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.local"
```

适合写入：

- 本机地址
- 私网网段
- 局域网域名
- 本地域名后缀

### SSH_BYPASS_EXTRA_PATTERNS

用于补充 SSH 层的直连目标。因为 SSH `Host` 规则不支持 CIDR，更细粒度的局域网主机或模式建议写在这里：

```sh
SSH_BYPASS_EXTRA_PATTERNS=(
    "gitlab.lan"
    "nas.local"
    "192.168.50.*"
)
```

## 它会改什么

执行 `proxy_on` 后，脚本会同时处理三层：

- 当前 Shell 的 `http_proxy / https_proxy / all_proxy`
- Git 全局 `http.proxy / https.proxy`
- `~/.ssh/config` 中由脚本托管的 SSH 代理区块

在装有 `apt` / `apt-get` 的系统上，还会为**当前终端**启用 `sudo apt` 代理传递（见下节）。

执行 `proxy_off` 后，会反向清理这些配置，并保留 `~/.ssh/config.bak` 备份。

## 在 Ubuntu / Debian 上使用 `sudo apt`

`sudo` 默认会清除代理环境变量，所以以前即使执行了 `proxy_on`，`sudo apt-get install ...` 仍会直连。从 `v4.2.0` 起，开启代理后可以直接输入：

```sh
proxy_on
sudo apt-get update
sudo apt-get install -y <软件包>
```

脚本会在当前终端安装一个 `sudo` 包装：只有以 `apt` / `apt-get` 开头的命令会额外带上 `--preserve-env=http_proxy,https_proxy,no_proxy`，其他 `sudo` 命令原样执行。`proxy_off` 时撤销该包装。

使用边界：

- 只作用于执行过 `proxy_on` 的当前终端；新开的终端、脚本中的 `sudo` 不受影响。
- 只识别 `sudo apt ...` 与 `sudo apt-get ...`；`sudo -n apt-get`、`sudo /usr/bin/apt-get` 等写法按原样执行，不会自动带代理。
- 如果你已经定义了 `sudo` 别名或函数（例如 `alias sudo='sudo '`），脚本不会覆盖，只会提示；`proxy_status` 会显示为关闭。
- 若系统的 sudo 策略不允许保留环境变量，`sudo` 会直接报错，不会自动退回直连。
- 系统 APT 配置中已有的代理（如 `/etc/apt/apt.conf.d/` 中的 `Acquire::http::Proxy`）优先于环境变量。可用 `apt-config dump | grep -i proxy` 查看。
- APT 对 `no_proxy` 只做主机名后缀匹配，不认识 `192.168.0.0/16` 这类 CIDR；内网软件源请写具体主机名或 IP。
- 系统级软件商店、容器镜像拉取等由后台服务下载的工具，不读取终端环境变量，需要按其自身方式配置代理。

## 环境要求

- `bash` 或 `zsh`
- `git`：用于写入和清理 Git 全局代理
- `nc`（netcat）：用于 SSH 代理转发
- `sudo` 与 `apt` / `apt-get`（可选）：用于 APT 代理传递；`sudo` 需支持 `--preserve-env=变量列表`

如果缺少 `git` 或 `nc`，脚本会跳过对应层，并在状态输出中明确提示；未安装 `apt` / `apt-get` 时跳过 APT 代理传递。

## 版本与发布

- 版本变更见 [`CHANGELOG.md`](./CHANGELOG.md)
- 当前脚本源码位于 [`Sources/.proxy.sh`](./Sources/.proxy.sh)

## 许可证

本项目采用 [MIT License](./LICENSE)。
