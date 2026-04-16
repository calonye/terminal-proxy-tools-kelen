 
 
# ==================== 全功能终端代理配置 (v4.0.0 by Kelen+Gemini) - 开始 ====================
#
# @description: 一个强大、安全且注释详尽的终端代理管理脚本。
#               v4.0.0 在保留原有 proxy_on / proxy_off / proxy_status 使用方式不变的前提下，
#               新增了“多本地局域网绕过”能力：环境变量与 SSH 双层同时生效。
# @author:      Kelen+Gemini
# @version:     4.0.0 (多局域网绕过版)
#
# --- 使用方法 ---
#
# 请选择以下任意一种方式进行安装：
#
# 方式一 (推荐，更整洁): 保存为独立文件
#
#   1. 将本代码块 (从“开始”到“结束”) 的所有内容，保存到一个新文件中，路径为:
#      ~/.proxy.sh
#
#   2. 在您的 Shell 配置文件 (如 ~/.bashrc 或 ~/.zshrc) 的末尾，仅添加下面这一行来加载它:
#      source ~/.proxy.sh
#
#   3. 这种方式能让您的主配置文件 (`~/.bashrc`) 保持干净，未来管理起来也更方便。
#
# 方式二 (直接): 粘贴到主配置文件
#
#   1. 将本代码块 (从“开始”到“结束”) 的所有内容，直接复制并粘贴到您的 Shell 配置文件
#      (如 ~/.bashrc 或 ~/.zshrc) 的末尾。
#
# --- 后续通用步骤 (两种方式都需要) ---
#
#   1. 【重要】根据您的实际情况，仔细阅读并修改脚本中的【配置区】。
#   2. 保存文件后，重启终端，或运行 `source ~/.bashrc` (或 `source ~/.zshrc`) 使配置立即生效。
#   3. 现在您可以使用以下命令：proxy_on, proxy_off, proxy_status
#
# --- 命令列表 ---
#
#   proxy_on     - 开启所有代理 (包括自动配置 SSH)
#   proxy_off    - 关闭所有代理 (包括自动清理 SSH 配置)
#   proxy_status - 查看当前所有代理的状态
#
 
# --- 【配置区】 ---
#
# 这是您唯一需要根据自己情况修改的区域。
# 请仔细阅读每一项的注释，并填写您的代理客户端提供的正确信息。
# =======================================================================================
 
# 1. 代理服务器的主机地址 (IP Address / Hostname)
#
#    说明：这是您的代理程序正在监听的地址。
#    - 如果代理软件运行在您自己的电脑上（绝大多数情况），此值应为 `127.0.0.1`，代表“本机”。
#    - 如果您使用的是局域网内的另一台电脑作为代理服务器，请填写那台电脑的局域网IP (如 `192.168.1.100`)。
#    - 通常情况下，您【不需要】修改此值。
#
PROXY_HOST="127.0.0.1"
 
# 2. HTTP/HTTPS 代理端口 (HTTP/HTTPS Proxy Port)
#
#    说明：这是您的代理软件为 HTTP 和 HTTPS 协议提供的端口号。
#          此端口用于绝大多数网页浏览、API请求、文件下载等。
#    常见值：
#      - Clash for Windows / ClashX / Clash Verge: 7890
#      - V2RayN / Qv2ray: 10809
#      - Shadowsocks-Windows (较新版本): 10808
#      - 您脚本中原有的值: 1087
#    操作：请在您的代理软件的设置中找到“HTTP 代理端口”或类似选项，并将其填入下方。
#
PROXY_HTTP_PORT="1087"
 
# 3. SOCKS5 代理端口 (SOCKS5 Proxy Port)
#
#    说明：这是您的代理软件为 SOCKS5 协议提供的端口号。
#          SOCKS5 是一种更底层的代理协议，常用于需要更高灵活性的场景，例如 SSH 连接、FTP、游戏等。
#    常见值：
#      - Clash for Windows / ClashX / Clash Verge: 7891 (也可能是 7890，取决于混合端口设置)
#      - V2RayN / Qv2ray: 10808
#      - Shadowsocks 客户端: 1080
#      - 您脚本中原有的值: 1080
#    操作：请在您的代理软件的设置中找到“SOCKS5 代理端口”或类似选项，并将其填入下方。
#
PROXY_SOCKS_PORT="1080"
 
# 4. 不走代理的地址列表 (No Proxy List)
#
#    说明：在此处列出的地址将【不会】通过代理服务器，而是直接连接。
#          这对于访问本地服务、公司内网、或某些不兼容代理的网站至关重要。
#    格式：
#      - 多个地址用英文逗号 `,` 分隔。
#      - 可以使用 IP 地址 (`192.168.1.1`)、域名 (`internal.company.com`)、
#        CIDR 地址块 (`10.0.0.0/8`) 或域名后缀 (`.local`)。
#    操作：默认值已包含所有标准私有网络地址，通常已足够。如果您有特殊的内网域名或地址，
#          可以将其添加到列表末尾。例如: `...,.mycompany.intranet,192.168.50.0/24`
#
NO_PROXY="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.local"

# 5. SSH 直连绕过规则 (SSH Bypass Patterns)
#
#    说明：环境变量层的 `NO_PROXY` 只能影响遵循代理环境变量的工具；SSH / git@... 这类连接
#          还需要在 `~/.ssh/config` 中显式声明“哪些目标直连”。
#    格式：
#      - 使用 SSH `Host` 规则支持的模式，多个条目写在数组中，每行一个。
#      - 支持精确主机名 (`gitlab.lan`)、IP (`192.168.1.10`)、
#        域名通配 (`*.local`) 和主机模式 (`192.168.50.*`)。
#    自动继承：
#      - 脚本会自动把 `NO_PROXY` 里“能安全转换”的条目同步为 SSH 直连规则。
#      - 对于无法直接转换的 CIDR（例如更细粒度的 `/25`、`/27`），请在这里补一个对应模式。
#    操作：如果您新增了某个局域网 Git / SSH 主机，请优先把它写到这里。
#
SSH_BYPASS_EXTRA_PATTERNS=(
    # "gitlab.lan"
    # "nas.local"
    # "192.168.50.*"
)
 
# =======================================================================================
# --- 配置区结束 --- 您通常无需修改下方的任何内容。
# =======================================================================================
 
# --- 【内部核心函数】 ---
#
# 这个区域包含了实现 SSH 配置自动化的核心逻辑。
# 这些函数被设计为在后台工作，由 `proxy_on` 和 `proxy_off` 调用，用户无需直接接触。
# 其设计的核心原则是：【安全】、【精确】和【可逆】。
# =======================================================================================
 
# 定义用于SSH配置块的开始和结束标记。
SSH_PROXY_MARKER_START="# PROXY_SCRIPT_MANAGED_START (由Kelen+Gemini脚本自动管理)"
SSH_PROXY_MARKER_END="# PROXY_SCRIPT_MANAGED_END (由Kelen+Gemini脚本自动管理)"

function _proxy_split_csv_to_lines() {
    local csv="$1"
    printf '%s' "$csv" | tr ',' '\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

function _proxy_join_csv() {
    local first=1
    local item
    for item in "$@"; do
        [ -z "$item" ] && continue
        if [ "$first" -eq 1 ]; then
            printf '%s' "$item"
            first=0
        else
            printf ',%s' "$item"
        fi
    done
}

function _proxy_no_proxy_entries() {
    _proxy_split_csv_to_lines "$NO_PROXY" | sed '/^$/d'
}

function _proxy_is_ipv4() {
    case "$1" in
        *[!0-9.]* | *.*.*.*.* | .* | *.) return 1 ;;
    esac

    local old_ifs="$IFS"
    IFS=.
    set -- $1
    IFS="$old_ifs"
    [ "$#" -eq 4 ] || return 1

    local octet
    for octet in "$@"; do
        case "$octet" in
            '' | *[!0-9]*) return 1 ;;
        esac
        [ "$octet" -ge 0 ] && [ "$octet" -le 255 ] || return 1
    done
}

function _proxy_cidr_to_ssh_patterns() {
    local cidr="$1"
    local ip="${cidr%/*}"
    local prefix="${cidr#*/}"

    _proxy_is_ipv4 "$ip" || return 1

    local old_ifs="$IFS"
    IFS=.
    set -- $ip
    IFS="$old_ifs"

    case "$prefix" in
        32)
            printf '%s\n' "$ip"
            ;;
        24)
            printf '%s.%s.%s.*\n' "$1" "$2" "$3"
            ;;
        16)
            printf '%s.%s.*\n' "$1" "$2"
            ;;
        8)
            printf '%s.*\n' "$1"
            ;;
        12)
            if [ "$1" = "172" ] && [ "$2" = "16" ]; then
                local second
                for second in $(seq 16 31); do
                    printf '172.%s.*\n' "$second"
                done
            else
                return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

function _proxy_entry_to_ssh_patterns() {
    local entry="$1"
    [ -z "$entry" ] && return 1

    case "$entry" in
        .*)
            printf '*%s\n' "$entry"
            return 0
            ;;
        */*)
            _proxy_cidr_to_ssh_patterns "$entry"
            return $?
            ;;
        *'*'* | *'?'*)
            printf '%s\n' "$entry"
            return 0
            ;;
    esac

    if _proxy_is_ipv4 "$entry"; then
        printf '%s\n' "$entry"
        return 0
    fi

    case "$entry" in
        *:*)
            printf '%s\n' "$entry"
            ;;
        *)
            printf '%s\n' "$entry"
            ;;
    esac
}

function _proxy_default_ssh_patterns() {
    cat <<'EOF'
localhost
127.0.0.1
::1
10.*
192.168.*
172.16.*
172.17.*
172.18.*
172.19.*
172.20.*
172.21.*
172.22.*
172.23.*
172.24.*
172.25.*
172.26.*
172.27.*
172.28.*
172.29.*
172.30.*
172.31.*
*.local
EOF
}

function _proxy_collect_ssh_bypass_patterns() {
    _proxy_default_ssh_patterns

    local entry
    while IFS= read -r entry; do
        [ -z "$entry" ] && continue
        _proxy_entry_to_ssh_patterns "$entry" 2>/dev/null || true
    done <<EOF
$(_proxy_no_proxy_entries)
EOF

    local pattern
    for pattern in "${SSH_BYPASS_EXTRA_PATTERNS[@]}"; do
        [ -n "$pattern" ] && printf '%s\n' "$pattern"
    done
}

function _proxy_render_ssh_host_line() {
    local pattern_line=""
    local pattern

    while IFS= read -r pattern; do
        [ -z "$pattern" ] && continue
        case " $pattern_line " in
            *" $pattern "*) continue ;;
        esac
        if [ -z "$pattern_line" ]; then
            pattern_line="$pattern"
        else
            pattern_line="$pattern_line $pattern"
        fi
    done <<EOF
$(_proxy_collect_ssh_bypass_patterns)
EOF

    printf '%s' "$pattern_line"
}
 
# 函数: _proxy_ssh_on
# 目的: 安全地在 `~/.ssh/config` 文件中开启 SSH 代理。
function _proxy_ssh_on() {
    local ssh_bypass_host_line
    ssh_bypass_host_line="$(_proxy_render_ssh_host_line)"

    mkdir -p -m 700 ~/.ssh
    if ! grep -q "$SSH_PROXY_MARKER_START" ~/.ssh/config 2>/dev/null; then
        echo -e "  \033[34m[i]\033[0m 正在向 \`~/.ssh/config\` 添加代理配置..."
        {
            echo ""
            echo "$SSH_PROXY_MARKER_START"
            echo "Host ${ssh_bypass_host_line}"
            echo "    ProxyCommand none"
            echo ""
            echo "Host *"
            echo "    ProxyCommand nc -X 5 -x ${PROXY_HOST}:${PROXY_SOCKS_PORT} %h %p"
            echo "$SSH_PROXY_MARKER_END"
        } >> ~/.ssh/config
        chmod 600 ~/.ssh/config
        echo -e "  \033[32m[✓]\033[0m 已自动配置 SSH 代理，并为本地局域网目标启用直连规则。"
    else
        echo -e "  \033[34m[i]\033[0m 检测到 SSH 代理已配置，无需操作。"
    fi
}
 
# 函数: _proxy_ssh_off
# 目的: 精确地从 `~/.ssh/config` 文件中移除由本脚本添加的代理配置，实现可逆操作。
function _proxy_ssh_off() {
    if [ -f ~/.ssh/config ] && grep -q "$SSH_PROXY_MARKER_START" ~/.ssh/config; then
        echo -e "  \033[34m[i]\033[0m 正在从 \`~/.ssh/config\` 移除代理配置..."
        sed -i.bak "/${SSH_PROXY_MARKER_START}/,/${SSH_PROXY_MARKER_END}/d" ~/.ssh/config
        echo -e "  \033[33m[✓]\033[0m 已自动移除 SSH 代理配置。您的原始配置已备份至: ~/.ssh/config.bak"
    fi
}
 
# =======================================================================================
# --- 内部核心函数结束 ---
# =======================================================================================
 
# --- 【主要功能函数】 ---
#
# 这个区域定义了用户直接在命令行中调用的命令，如 `proxy_on`, `proxy_off`, `proxy_status`。
# 它们是整个脚本的“用户界面”，负责协调调用内部核心函数，并向用户提供清晰的操作反馈。
# =======================================================================================
 
# 函数: proxy_on
# 目的: 一键开启所有受支持的代理配置，为用户提供一个“准备就绪”的网络环境。
function proxy_on() {
    local effective_no_proxy

    echo -e "\033[1m开启所有终端代理...\033[0m"
 
    # --- 步骤 1: 配置环境变量 ---
    # `export` 命令将变量设置为当前 Shell 会话的环境变量，后续命令将继承它们。
    #
    # --- 关于大小写问题的深度解释 ---
    #
    # 历史与标准：
    #   - 【小写】 (`http_proxy`) 是最初由 W3C/CERN 在早期 Web 实践中非正式确立的，并被广泛采纳，
    #     是事实上的标准，绝大多数现代、遵循规范的工具（如 curl, wget, Python requests, Node.js axios）
    #     都优先使用小写版本。
    #   - 【大写】 (`HTTP_PROXY`) 源于一些早期 CGI 脚本的环境变量命名约定（所有 CGI 变量都用大写）。
    #     因此，一些较老的、或受 CGI 影响的程序可能会只认大写版本。
    #
    # 最佳实践：
    #   为了达到【最大兼容性】，最稳妥的做法是【同时设置大小写两个版本】。
    #   这样，无论一个程序是遵循现代标准还是古老约定，我们的代理配置都能被正确识别。
    #   本脚本正是遵循这一最佳实践。
    #
    effective_no_proxy="$(_proxy_join_csv $(_proxy_no_proxy_entries))"

    # 设置小写版本 (首选标准)
    export http_proxy="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
    export https_proxy="http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
    export all_proxy="socks5://${PROXY_HOST}:${PROXY_SOCKS_PORT}"
    export no_proxy="${effective_no_proxy}"
 
    # 设置大写版本 (为了兼容性)
    export HTTP_PROXY="${http_proxy}"
    export HTTPS_PROXY="${https_proxy}"
    export ALL_PROXY="${all_proxy}"
    export NO_PROXY="${effective_no_proxy}"
    echo -e "  \033[32m[✓]\033[0m 已配置环境变量 (影响 curl, wget, apt, pip, bun, pnpm 等大多数工具)"
    echo -e "  \033[34m[i]\033[0m 当前 NO_PROXY: ${effective_no_proxy}"
 
    # --- 步骤 2: 配置 Git 专属代理 ---
    # Git 有自己独立的配置系统。通过 `git config` 设置是更明确、更可靠的方式。
    # 影响范围：仅影响所有通过 `https://` 协议进行的 Git 网络操作（如 clone, pull, push）。
    git config --global http.proxy "http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
    git config --global https.proxy "http://${PROXY_HOST}:${PROXY_HTTP_PORT}"
    echo -e "  \033[32m[✓]\033[0m 已配置 Git 代理 (影响所有 https:// 协议的 Git 操作)"
 
    # --- 步骤 3: 自动配置 SSH 代理 ---
    # 调用内部核心函数 `_proxy_ssh_on`，来安全地、自动化地处理 `~/.ssh/config` 文件。
    # 影响范围：所有 `ssh` 命令、通过 `git@...` 协议的 Git 操作，以及 `scp`, `sftp`, `rsync` 等。
    _proxy_ssh_on
 
    # 所有步骤执行完毕，打印最终的成功信息，确认整个环境已配置完毕。
    echo -e "\n\033[32m[✓] 代理已全面开启。\033[0m"
}
 
# 函数: proxy_off
# 目的: 一键关闭所有由本脚本开启的代理配置，将网络环境恢复到原始状态。
function proxy_off() {
    echo -e "\033[1m关闭所有终端代理...\033[0m"
    # `unset` 命令会从当前 Shell 环境中彻底移除这些变量（大小写版本一并移除）。
    unset http_proxy https_proxy all_proxy no_proxy
    unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
    echo -e "  \033[33m[✓]\033[0m 已清除环境变量"
    git config --global --unset http.proxy
    git config --global --unset https.proxy
    echo -e "  \033[33m[✓]\033[0m 已清除 Git 代理"
    _proxy_ssh_off
    echo -e "\n\033[33m[✓] 代理已全面关闭。\033[0m"
}
 
# 函数: proxy_status
# 目的: 检查并报告当前各个组件的代理状态，让用户对当前环境一目了然。
function proxy_status() {
    local effective_no_proxy

    effective_no_proxy="$(_proxy_join_csv $(_proxy_no_proxy_entries))"

    echo -e "\033[1m--- 当前代理状态 ---\033[0m"
    if [ -n "$http_proxy" ]; then
        echo -e "环境变量: \033[32m开启\033[0m (HTTP: $http_proxy)"
    else
        echo -e "环境变量: \033[33m关闭\033[0m"
    fi
    echo "NO_PROXY 规划值: ${effective_no_proxy}"
    local git_proxy
    git_proxy=$(git config --global --get http.proxy)
    if [ -n "$git_proxy" ]; then
        echo -e "Git 代理: \033[32m开启\033[0m (HTTP: $git_proxy)"
    else
        echo -e "Git 代理: \033[33m关闭\033[0m"
    fi
    if grep -q "$SSH_PROXY_MARKER_START" ~/.ssh/config 2>/dev/null; then
         echo -e "SSH 代理: \033[32m开启\033[0m (由本脚本自动管理)"
         echo "SSH 局域网直连: $(_proxy_render_ssh_host_line)"
    else
         echo -e "SSH 代理: \033[33m关闭\033[0m (或由用户手动管理)"
    fi
    echo "--------------------"
}

# ===================== 全功能终端代理配置 (v4.0.0 by Kelen+Gemini) - 结束 =====================
 
