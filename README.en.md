<div align="center">

# Terminal_Proxy_Tools_Kelen

**Toggle your terminal proxy with one command — shell variables, Git, SSH and `sudo apt` stay in sync, while LAN targets connect directly.**

[![Release](https://img.shields.io/github/v/release/calonye/terminal-proxy-tools-kelen?label=release)](https://github.com/calonye/terminal-proxy-tools-kelen/releases/latest)
[![License](https://img.shields.io/github/license/calonye/terminal-proxy-tools-kelen?label=license)](./LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20zsh-4EAA25)](#requirements)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)](#requirements)

[中文](./README.md) | English

[Quick Start](#quick-start) · [Download latest release](https://github.com/calonye/terminal-proxy-tools-kelen/releases/latest) · [Changelog](./CHANGELOG.md)

</div>

A terminal proxy manager for `bash` and `zsh`. It manages shell environment variables, the Git proxy and the SSH proxy together, keeps LAN targets direct, and makes `sudo apt` on Ubuntu / Debian use the proxy as well.

- Current version: `v4.2.0`
- Last updated: `2026-11-04`

## Why use it

- No more editing shell, Git and SSH proxy settings separately
- Turn the proxy on or off and check its state with one command
- Keep LAN targets direct, so SSH does not go through the proxy while HTTP already connects directly

## Features

- `proxy_on / proxy_off / proxy_status`
- Manages `http_proxy / https_proxy / all_proxy` together
- Writes and clears the global Git proxy
- Writes and clears a script-managed proxy block in `~/.ssh/config`
- Bypasses multiple local networks
- `sudo apt` / `sudo apt-get` in the current terminal keep the proxy variables
- Checks for `git` and `nc` before enabling
- Shows the state of environment variables, Git, SSH and APT proxy pass-through separately

## Quick Start

Get the script in either of these ways.

**Download from a Release** (no clone needed):

```sh
ver=v4.2.0
curl -LO "https://github.com/calonye/terminal-proxy-tools-kelen/releases/download/${ver}/terminal-proxy-tools-kelen-${ver}.tar.gz"
tar -xzf "terminal-proxy-tools-kelen-${ver}.tar.gz"
cp "terminal-proxy-tools-kelen-${ver}/Sources/.proxy.sh" ~/.proxy.sh
```

The Release page also provides a `.zip` archive and a `SHA256SUMS` checksum file.

**Or, from the repository root:**

```sh
cp ./Sources/.proxy.sh ~/.proxy.sh
```

> Upgrading: if `~/.proxy.sh` already exists, copying overwrites the proxy host and ports in its configuration block. Back it up first (for example `cp ~/.proxy.sh ~/.proxy.sh.bak`) and restore your values after copying.

If you use `zsh`:

```sh
echo 'source ~/.proxy.sh' >> ~/.zshrc
source ~/.zshrc
```

If you use `bash`:

```sh
echo 'source ~/.proxy.sh' >> ~/.bashrc
source ~/.bashrc
```

Then use:

```sh
proxy_on
proxy_status
proxy_off
```

## Configuration

After installing, edit the configuration block at the top of `~/.proxy.sh`. Usually you only need:

- `PROXY_HOST`
- `PROXY_HTTP_PORT`
- `PROXY_SOCKS_PORT`
- `NO_PROXY`
- `SSH_BYPASS_EXTRA_PATTERNS`

### NO_PROXY

Targets that bypass the proxy at the environment-variable layer. The default covers common local and private ranges:

```sh
NO_PROXY="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.local"
```

Good candidates:

- Local addresses
- Private network ranges
- LAN host names
- Local domain suffixes

### SSH_BYPASS_EXTRA_PATTERNS

Extra direct-connect targets for the SSH layer. SSH `Host` rules do not support CIDR, so put finer-grained LAN hosts or patterns here:

```sh
SSH_BYPASS_EXTRA_PATTERNS=(
    "gitlab.lan"
    "nas.local"
    "192.168.50.*"
)
```

## What it changes

`proxy_on` handles three layers at once:

- `http_proxy / https_proxy / all_proxy` in the current shell
- Global Git `http.proxy / https.proxy`
- A script-managed SSH proxy block in `~/.ssh/config`

On systems with `apt` / `apt-get`, it also enables `sudo apt` proxy pass-through for the **current terminal** (see the next section).

`proxy_off` reverses these changes and keeps a backup at `~/.ssh/config.bak`.

## Using `sudo apt` on Ubuntu / Debian

`sudo` clears proxy environment variables by default, so `sudo apt-get install ...` used to connect directly even after `proxy_on`. Since `v4.2.0`, after enabling the proxy you can simply run:

```sh
proxy_on
sudo apt-get update
sudo apt-get install -y <package>
```

The script installs a `sudo` wrapper in the current terminal: only commands starting with `apt` / `apt-get` get `--preserve-env=http_proxy,https_proxy,no_proxy`; every other `sudo` command runs unchanged. `proxy_off` removes the wrapper.

Limits:

- Only the current terminal where `proxy_on` ran is affected; new terminals and `sudo` inside scripts are not.
- Only `sudo apt ...` and `sudo apt-get ...` are recognized; forms such as `sudo -n apt-get` or `sudo /usr/bin/apt-get` run unchanged, without the proxy variables.
- If you already have a `sudo` alias or function (for example `alias sudo='sudo '`), the script leaves it alone and shows a notice; `proxy_status` reports it as off.
- If the system sudo policy does not allow preserving environment variables, `sudo` reports an error instead of falling back to a direct connection.
- A proxy already set in the system APT configuration (such as `Acquire::http::Proxy` in `/etc/apt/apt.conf.d/`) takes precedence over environment variables. Check with `apt-config dump | grep -i proxy`.
- APT matches `no_proxy` by host-name suffix only and does not understand CIDR such as `192.168.0.0/16`; list LAN package mirrors by host name or IP.
- Tools that download through background services, such as system-level app stores or container image pulls, do not read terminal environment variables; configure their proxy in their own way.

## Requirements

- `bash` or `zsh`
- `git`: writes and clears the global Git proxy
- `nc` (netcat): forwards SSH through the proxy
- `sudo` and `apt` / `apt-get` (optional): APT proxy pass-through; `sudo` must support `--preserve-env=list`

If `git` or `nc` is missing, the script skips that layer and says so in the status output; without `apt` / `apt-get`, APT proxy pass-through is skipped.

## Versions and releases

- See [`CHANGELOG.md`](./CHANGELOG.md) for changes
- The script source is at [`Sources/.proxy.sh`](./Sources/.proxy.sh)

## License

This project is released under the [MIT License](./LICENSE).
