# Terminal_Proxy_Tools_Kelen

这个仓库只承载可发布的终端代理脚本本体与版本资产，不包含工作空间级的需求、设计研发文档。

- 文档类型：仓库入口文档
- 当前版本：`v4.1.0`
- 最后更新：`2026-04-16`

## 快速判断

- 想一键开关终端代理 → 用它
- 想让内网 HTTP 和 SSH 同时绕过代理 → 用它
- 想保留脚本快照、版本日志和源码资产分层 → 这个仓库已经按这个方向整理

## 项目定位

- 目标：提供一份可直接 `source` 的终端代理脚本
- 仓库源码入口：[`Sources/.proxy.sh`](./Sources/.proxy.sh)
- 推荐安装后入口：`~/.proxy.sh`
- 当前主线版本：`v4.1.0`
- 源码目录：[`Sources/`](./Sources/)
- 历史版本快照目录：[`history/版本快照/`](./history/版本快照/)
- 版本日志：[`CHANGELOG.md`](./CHANGELOG.md)

## 当前能力

- 一键开启和关闭终端代理：`proxy_on / proxy_off`
- 查看当前环境、Git、SSH 代理状态：`proxy_status`
- 自动写入和清理 Git 全局代理
- 自动写入和清理 `~/.ssh/config` 中由脚本托管的代理区块
- 支持多本地局域网绕过
- 启用前探测 `git` / `nc` 依赖，避免误报成功
- 分层输出环境变量、Git、SSH 当前状态
- 同时兼容 `bash` 与 `zsh`

## 仓库结构

```text
.
├── .gitignore
├── CHANGELOG.md
├── LICENSE
├── README.md
├── Sources/
│   └── .proxy.sh
└── history/
    └── 版本快照/
        ├── .proxy.v3.8.0.sh
        ├── .proxy.v4.0.0.sh
        └── .proxy.v4.1.0.sh
```

## 快速开始

推荐方式：复制脚本到家目录

```sh
cp /绝对路径/仓库根目录/Sources/.proxy.sh ~/.proxy.sh
echo 'source ~/.proxy.sh' >> ~/.zshrc
source ~/.zshrc
```

加载后可直接使用：

```sh
proxy_on
proxy_status
proxy_off
```

## 配置项

推荐安装后，请在 `~/.proxy.sh` 顶部维护配置；仓库源码对应文件为 [`Sources/.proxy.sh`](./Sources/.proxy.sh)。当前主要维护这几项：

- `PROXY_HOST`
- `PROXY_HTTP_PORT`
- `PROXY_SOCKS_PORT`
- `NO_PROXY`
- `SSH_BYPASS_EXTRA_PATTERNS`

### `NO_PROXY`

用于控制环境变量层的绕过目标，默认已经包含：

```sh
NO_PROXY="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.local"
```

适合写入：

- 本机地址
- 私网网段
- 局域网域名
- 本地域名后缀

### `SSH_BYPASS_EXTRA_PATTERNS`

用于控制 SSH 层的额外直连目标。因为 SSH `Host` 规则不支持 CIDR，所以更细粒度的网段或局域网主机建议在这里补充：

```sh
SSH_BYPASS_EXTRA_PATTERNS=(
    "gitlab.lan"
    "nas.local"
    "192.168.50.*"
)
```

## 工作方式

执行 `proxy_on` 后，脚本会同时处理三层：

- 当前 Shell 的 `http_proxy / https_proxy / all_proxy`
- Git 全局 `http.proxy / https.proxy`
- `~/.ssh/config` 中由脚本托管的 SSH 代理区块

执行 `proxy_off` 后，会反向清理这三层配置，并保留 `~/.ssh/config.bak` 备份。

## 环境前提

- 建议本机已安装 `git`，否则脚本会跳过 Git 代理写入与清理
- 若需要 SSH 代理，请确保系统存在 `nc`（netcat），否则脚本会跳过 SSH 代理区块写入
- `proxy_status` 会直接显示这两个依赖是否可用

## v4.1.0 重点

`v4.1.0` 在 `v4.0.0` 的基础上补了三件事：

- 启用前探测 `git` 与 `nc`
- Git / SSH 写入失败时不再误报成功
- `proxy_status` 改成更明确的分层状态输出

## v4.0.0 重点

`v4.0.0` 的核心不是单纯把 `NO_PROXY` 变长，而是把“局域网绕过”同时落实到：

- 环境变量层
- SSH 层

这样可以避免：

- `curl 192.168.x.x` 直连
- 但 `ssh 192.168.x.x` 仍然走代理

这种只修一半的情况。

## 版本资产边界

- `README.md`：项目入口、使用方式、结构导航
- `CHANGELOG.md`：版本日志
- `LICENSE`：仓库许可说明
- `Sources/`：当前主线源码目录
- `history/`：历史版本快照与归档资产目录
- `.gitignore`：仓库运行残留与系统垃圾文件过滤

这六类资产分开维护，不交叉替代。

## 上传边界

- 只上传项目本体文件，不上传系统垃圾文件、编辑器临时文件、备份残留
- 历史版本快照统一归档到 `history/`，不再与当前主线源码并列混放
- 需求与设计研发文档在工作空间层管理，不纳入本仓库

## 许可

本项目采用 `MIT` 许可证发布。保留版权声明，允许免费使用、修改、分发与商用，具体条款见 [LICENSE](./LICENSE)。
