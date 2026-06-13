#!/usr/bin/env bash
set -euo pipefail

# OpenClaw CLI installer — local prefix, no root required
# Usage: curl -fsSL https://openclaw.ai/install-cli.sh | bash
# Docs:  https://docs.openclaw.ai/install/installer#install-clish

OPENCLAW_PREFIX="${OPENCLAW_PREFIX:-$HOME/.openclaw}"
OPENCLAW_VERSION="${OPENCLAW_VERSION:-${CLAWDBOT_VERSION:-latest}}"
OPENCLAW_NODE_VERSION="${OPENCLAW_NODE_VERSION:-22.22.0}"
OPENCLAW_NO_ONBOARD="${OPENCLAW_NO_ONBOARD:-${CLAWDBOT_NO_ONBOARD:-1}}"
OPENCLAW_NPM_LOGLEVEL="${OPENCLAW_NPM_LOGLEVEL:-error}"
export SHARP_IGNORE_GLOBAL_LIBVIPS="${SHARP_IGNORE_GLOBAL_LIBVIPS:-1}"

# Legacy cleanup path (used when removing old Peekaboo submodule checkout)
OPENCLAW_GIT_DIR="${OPENCLAW_GIT_DIR:-}"

_JSON_OUTPUT=0
_ONBOARD=0
_SET_NPM_PREFIX=0

# --- Argument parsing ---

_show_help() {
  cat <<'EOF'
OpenClaw CLI installer — local prefix, no root required

Usage: curl -fsSL https://openclaw.ai/install-cli.sh | bash [-s --] [OPTIONS]

Options:
  --prefix <path>       Install prefix (default: ~/.openclaw)
  --version <ver>       OpenClaw version or dist-tag (default: latest)
  --node-version <ver>  Node.js version to bundle (default: 22.22.0)
  --json                Emit NDJSON progress events
  --onboard             Run openclaw onboard after install
  --no-onboard          Skip onboarding (default)
  --set-npm-prefix      On Linux, set npm prefix to ~/.npm-global
  --help, -h            Show this help

Environment variables:
  OPENCLAW_PREFIX=<path>
  OPENCLAW_VERSION=<ver>
  OPENCLAW_NODE_VERSION=<ver>
  OPENCLAW_NO_ONBOARD=1
  OPENCLAW_NPM_LOGLEVEL=error|warn|notice
  SHARP_IGNORE_GLOBAL_LIBVIPS=0|1   (default: 1)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)          OPENCLAW_PREFIX="$2"; shift 2 ;;
    --version)         OPENCLAW_VERSION="$2"; shift 2 ;;
    --node-version)    OPENCLAW_NODE_VERSION="$2"; shift 2 ;;
    --json)            _JSON_OUTPUT=1; shift ;;
    --onboard)         _ONBOARD=1; OPENCLAW_NO_ONBOARD=0; shift ;;
    --no-onboard)      OPENCLAW_NO_ONBOARD=1; _ONBOARD=0; shift ;;
    --set-npm-prefix)  _SET_NPM_PREFIX=1; shift ;;
    --help|-h)         _show_help; exit 0 ;;
    *) echo "Unknown option: $1" >&2; _show_help >&2; exit 1 ;;
  esac
done

# --- Utilities ---

_has_cmd() { command -v "$1" >/dev/null 2>&1; }

_emit() {
  local _event="$1"
  shift
  if [[ "$_JSON_OUTPUT" == "1" ]]; then
    local _msg="$*"
    printf '{"event":"%s","message":"%s"}\n' "$_event" "${_msg//\"/\\\"}"
  else
    echo "==> $*"
  fi
}

# --- Platform detection ---

_OS=""
_ARCH=""

_detect_platform() {
  case "$(uname -s)" in
    Darwin) _OS="darwin" ;;
    Linux)  _OS="linux" ;;
    *)
      echo "Unsupported OS: $(uname -s). Use install.ps1 on Windows." >&2
      exit 1
      ;;
  esac

  case "$(uname -m)" in
    arm64|aarch64) _ARCH="arm64" ;;
    x86_64|amd64)  _ARCH="x64" ;;
    *)
      echo "Unsupported architecture: $(uname -m)" >&2
      exit 1
      ;;
  esac
}

# --- Bundled Node.js ---

_NODE_BIN_DIR=""

_install_node_local() {
  local _ver="$OPENCLAW_NODE_VERSION"
  local _tools_dir="$OPENCLAW_PREFIX/tools"
  local _platform="${_OS}-${_ARCH}"
  local _node_name="node-v${_ver}-${_platform}"
  local _node_dir="$_tools_dir/$_node_name"
  local _archive="$_tools_dir/${_node_name}.tar.xz"
  local _base_url="https://nodejs.org/dist/v${_ver}"
  local _sha_file="$_tools_dir/SHASUMS256.txt"

  _emit "node-download" "Downloading Node.js v${_ver} (${_platform})..."

  mkdir -p "$_tools_dir"
  curl -fsSL "${_base_url}/${_node_name}.tar.xz" -o "$_archive"

  # Verify checksum
  if curl -fsSL "${_base_url}/SHASUMS256.txt" -o "$_sha_file" 2>/dev/null; then
    local _expected _actual
    _expected="$(grep " ${_node_name}.tar.xz$" "$_sha_file" 2>/dev/null | awk '{print $1}' || true)"
    if [[ -n "$_expected" ]]; then
      if _has_cmd shasum; then
        _actual="$(shasum -a 256 "$_archive" | awk '{print $1}')"
      elif _has_cmd sha256sum; then
        _actual="$(sha256sum "$_archive" | awk '{print $1}')"
      fi
      if [[ -n "${_actual:-}" && "$_actual" != "$_expected" ]]; then
        echo "Checksum mismatch for Node.js archive" >&2
        rm -f "$_archive" "$_sha_file"
        exit 1
      fi
    fi
    rm -f "$_sha_file"
  fi

  tar -xJf "$_archive" -C "$_tools_dir"
  rm -f "$_archive"

  _NODE_BIN_DIR="$_node_dir/bin"
  _emit "node-ready" "Node.js v${_ver} ready"
}

_ensure_node_local() {
  local _ver="$OPENCLAW_NODE_VERSION"
  local _node_dir="$OPENCLAW_PREFIX/tools/node-v${_ver}-${_OS}-${_ARCH}"

  if [[ -x "$_node_dir/bin/node" ]]; then
    _emit "node-cached" "Node.js v${_ver} already present"
    _NODE_BIN_DIR="$_node_dir/bin"
    return
  fi

  _install_node_local
}

# --- Git ---

_install_git_linux() {
  local _sudo=""
  [[ "${EUID:-$(id -u)}" -ne 0 ]] && _has_cmd sudo && _sudo="sudo"

  if _has_cmd apt-get;  then $_sudo apt-get install -y --no-install-recommends git
  elif _has_cmd dnf;    then $_sudo dnf install -y git
  elif _has_cmd yum;    then $_sudo yum install -y git
  else
    echo "No supported package manager. Install git manually." >&2
    exit 1
  fi
}

_ensure_git_cli() {
  _has_cmd git && return
  _emit "git-install" "Installing git..."
  case "$_OS" in
    darwin)
      _has_cmd brew && brew install git && return
      echo "Install Git: https://git-scm.com/download/mac" >&2
      exit 1
      ;;
    linux) _install_git_linux ;;
  esac
}

# --- npm prefix for --set-npm-prefix ---

_configure_set_npm_prefix() {
  [[ "$_SET_NPM_PREFIX" != "1" || "$_OS" != "linux" ]] && return

  local _new_prefix="$HOME/.npm-global"
  _emit "npm-prefix" "Setting npm prefix to ${_new_prefix}"

  mkdir -p "$_new_prefix/bin"
  "$_NODE_BIN_DIR/npm" config set prefix "$_new_prefix"

  local _export_line='export PATH="$HOME/.npm-global/bin:$PATH"'
  for _rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [[ -f "$_rc" ]] && ! grep -qF '.npm-global/bin' "$_rc" 2>/dev/null; then
      echo "$_export_line" >> "$_rc"
    fi
  done

  export PATH="$_new_prefix/bin:$PATH"
}

# --- Install OpenClaw ---

_install_openclaw() {
  local _npm="$_NODE_BIN_DIR/npm"
  local _node="$_NODE_BIN_DIR/node"
  local _ver="$OPENCLAW_VERSION"

  export PATH="$_NODE_BIN_DIR:$PATH"

  # Determine the actual npm prefix to use
  local _npm_prefix
  if [[ "$_SET_NPM_PREFIX" == "1" && "$_OS" == "linux" ]]; then
    _configure_set_npm_prefix
    _npm_prefix="$HOME/.npm-global"
  else
    _npm_prefix="$OPENCLAW_PREFIX"
    mkdir -p "$_npm_prefix/bin"
    "$_npm" config set prefix "$_npm_prefix"
  fi

  _emit "openclaw-install" "Installing openclaw@${_ver} to ${_npm_prefix}..."

  "$_npm" install -g \
    --prefix "$_npm_prefix" \
    --loglevel "$OPENCLAW_NPM_LOGLEVEL" \
    "openclaw@${_ver}"

  # Write a wrapper that uses the bundled node explicitly, so it works regardless of PATH
  local _bin_dir="$_npm_prefix/bin"
  local _wrapper="$_bin_dir/openclaw"
  local _main

  # Locate the installed main entry point
  _main="$(find "$_npm_prefix/lib/node_modules/openclaw" \
    \( -name "openclaw.mjs" -o -name "index.js" \) \
    -maxdepth 2 2>/dev/null | head -1 || true)"

  if [[ -z "$_main" ]]; then
    _main="$_npm_prefix/lib/node_modules/openclaw/openclaw.mjs"
  fi

  cat > "$_wrapper" <<WRAPPER
#!/usr/bin/env bash
exec "${_node}" "${_main}" "\$@"
WRAPPER
  chmod +x "$_wrapper"

  export PATH="$_bin_dir:$PATH"
  _emit "openclaw-ready" "openclaw installed at ${_wrapper}"
}

# --- Legacy cleanup ---

_cleanup_legacy_git_dir() {
  [[ -z "$OPENCLAW_GIT_DIR" ]] && return
  local _submodule="$OPENCLAW_GIT_DIR/vendor/Peekaboo"
  if [[ -d "$_submodule" ]]; then
    _emit "legacy-cleanup" "Removing legacy Peekaboo submodule..."
    rm -rf "$_submodule"
    git -C "$OPENCLAW_GIT_DIR" rm --cached vendor/Peekaboo 2>/dev/null || true
  fi
}

# --- Post-install ---

_do_post_install_cli() {
  [[ "$_ONBOARD" != "1" ]] && return
  _has_cmd openclaw || return
  _emit "onboard" "Starting onboarding wizard..."
  openclaw onboard --install-daemon 2>/dev/null || true
}

# --- Main ---

_detect_platform
_cleanup_legacy_git_dir

_emit "start" "OpenClaw CLI installer (${_OS:-?}-${_ARCH:-?})"

mkdir -p "$OPENCLAW_PREFIX"
_ensure_node_local
_ensure_git_cli
_install_openclaw
_do_post_install_cli

# PATH hint
case ":${PATH:-}:" in
  *":$OPENCLAW_PREFIX/bin:"*) ;;
  *)
    echo ""
    echo "Add openclaw to your PATH:"
    echo "  export PATH=\"${OPENCLAW_PREFIX}/bin:\$PATH\""
    ;;
esac

_emit "done" "OpenClaw CLI installer complete"
