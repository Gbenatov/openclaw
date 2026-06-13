#!/usr/bin/env bash
set -euo pipefail

# OpenClaw installer — https://openclaw.ai
# Usage: curl -fsSL https://openclaw.ai/install.sh | bash
# Docs:  https://docs.openclaw.ai/install/installer

OPENCLAW_PACKAGE="${OPENCLAW_INSTALL_PACKAGE:-openclaw}"
OPENCLAW_VERSION="${OPENCLAW_VERSION:-${CLAWDBOT_VERSION:-latest}}"
OPENCLAW_BETA="${OPENCLAW_BETA:-${CLAWDBOT_BETA:-0}}"
OPENCLAW_INSTALL_METHOD="${OPENCLAW_INSTALL_METHOD:-${CLAWDBOT_INSTALL_METHOD:-}}"
OPENCLAW_GIT_DIR="${OPENCLAW_GIT_DIR:-${CLAWDBOT_GIT_DIR:-$HOME/openclaw}}"
OPENCLAW_GIT_UPDATE="${OPENCLAW_GIT_UPDATE:-1}"
OPENCLAW_NO_PROMPT="${OPENCLAW_NO_PROMPT:-0}"
OPENCLAW_NO_ONBOARD="${OPENCLAW_NO_ONBOARD:-${CLAWDBOT_NO_ONBOARD:-0}}"
OPENCLAW_DRY_RUN="${OPENCLAW_DRY_RUN:-0}"
OPENCLAW_VERBOSE="${OPENCLAW_VERBOSE:-0}"
OPENCLAW_NPM_LOGLEVEL="${OPENCLAW_NPM_LOGLEVEL:-error}"
export SHARP_IGNORE_GLOBAL_LIBVIPS="${SHARP_IGNORE_GLOBAL_LIBVIPS:-1}"

_ONBOARD_EXPLICIT=0

# --- Argument parsing ---

_show_help() {
  cat <<'EOF'
OpenClaw installer

Usage: curl -fsSL https://openclaw.ai/install.sh | bash [-s --] [OPTIONS]

Options:
  --install-method npm|git  Install method (default: npm). Alias: --method
  --npm                     Shortcut for npm method
  --git, --github           Shortcut for git method
  --version <ver>           npm version or dist-tag (default: latest)
  --beta                    Use beta dist-tag if available, else latest
  --git-dir <path>          Checkout directory (default: ~/openclaw). Alias: --dir
  --no-git-update           Skip git pull for existing checkout
  --no-prompt               Disable prompts
  --no-onboard              Skip onboarding
  --onboard                 Force onboarding
  --dry-run                 Print actions without applying changes
  --verbose                 Enable debug output (set -x)
  --help, -h                Show this help

Environment variables:
  OPENCLAW_INSTALL_METHOD=npm|git
  OPENCLAW_VERSION=<ver>             npm version or dist-tag (default: latest)
  OPENCLAW_BETA=0|1                  Use beta dist-tag if available
  OPENCLAW_GIT_DIR=<path>            Checkout directory (default: ~/openclaw)
  OPENCLAW_GIT_UPDATE=0|1            Toggle git pull on existing checkout (default: 1)
  OPENCLAW_NO_PROMPT=1               Disable prompts
  OPENCLAW_NO_ONBOARD=1              Skip onboarding
  OPENCLAW_DRY_RUN=1                 Dry run mode
  OPENCLAW_VERBOSE=1                 Debug mode
  OPENCLAW_NPM_LOGLEVEL=<level>      npm log level (default: error)
  SHARP_IGNORE_GLOBAL_LIBVIPS=0|1    Control sharp/libvips behaviour (default: 1)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install-method|--method) OPENCLAW_INSTALL_METHOD="$2"; shift 2 ;;
    --npm)                     OPENCLAW_INSTALL_METHOD="npm"; shift ;;
    --git|--github)            OPENCLAW_INSTALL_METHOD="git"; shift ;;
    --version)                 OPENCLAW_VERSION="$2"; shift 2 ;;
    --beta)                    OPENCLAW_BETA=1; shift ;;
    --git-dir|--dir)           OPENCLAW_GIT_DIR="$2"; shift 2 ;;
    --no-git-update)           OPENCLAW_GIT_UPDATE=0; shift ;;
    --no-prompt)               OPENCLAW_NO_PROMPT=1; shift ;;
    --no-onboard)              OPENCLAW_NO_ONBOARD=1; _ONBOARD_EXPLICIT=1; shift ;;
    --onboard)                 OPENCLAW_NO_ONBOARD=0; _ONBOARD_EXPLICIT=1; shift ;;
    --dry-run)                 OPENCLAW_DRY_RUN=1; shift ;;
    --verbose)                 OPENCLAW_VERBOSE=1; shift ;;
    --help|-h)                 _show_help; exit 0 ;;
    *) echo "Unknown option: $1" >&2; _show_help >&2; exit 1 ;;
  esac
done

if [[ -n "$OPENCLAW_INSTALL_METHOD" ]] && \
   [[ "$OPENCLAW_INSTALL_METHOD" != "npm" ]] && \
   [[ "$OPENCLAW_INSTALL_METHOD" != "git" ]]; then
  echo "Error: --install-method must be 'npm' or 'git'" >&2
  exit 2
fi

[[ "$OPENCLAW_VERBOSE" == "1" ]] && set -x

# --- Utilities ---

_is_dry_run() { [[ "$OPENCLAW_DRY_RUN" == "1" ]]; }
_has_cmd()    { command -v "$1" >/dev/null 2>&1; }

_run_or_dry() {
  if _is_dry_run; then
    echo "[dry-run]" "$@"
  else
    "$@"
  fi
}

_maybe_sudo() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]] && _has_cmd sudo; then
    sudo "$@"
  else
    "$@"
  fi
}

# --- OS detection ---

_OS=""
_IS_WSL=0

_detect_os() {
  case "$(uname -s)" in
    Darwin) _OS="macos" ;;
    Linux)
      _OS="linux"
      if grep -qiE "microsoft|WSL" /proc/version 2>/dev/null; then
        _IS_WSL=1
      fi
      ;;
    *)
      echo "Unsupported OS: $(uname -s). Use install.ps1 on Windows." >&2
      exit 1
      ;;
  esac
}

# --- Linux package manager ---

_LINUX_PKG_MGR=""

_detect_linux_pkg_mgr() {
  [[ -n "$_LINUX_PKG_MGR" ]] && return
  if _has_cmd apt-get;  then _LINUX_PKG_MGR="apt"
  elif _has_cmd dnf;    then _LINUX_PKG_MGR="dnf"
  elif _has_cmd yum;    then _LINUX_PKG_MGR="yum"
  fi
}

# --- Node.js ---

_node_major() {
  node -e 'process.stdout.write(process.versions.node.split(".")[0])' 2>/dev/null || echo "0"
}

_install_node_macos() {
  if ! _has_cmd brew; then
    echo "==> Installing Homebrew..."
    _run_or_dry /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    for _brew_path in /opt/homebrew/bin /usr/local/bin; do
      if [[ -x "$_brew_path/brew" ]]; then
        eval "$("$_brew_path/brew" shellenv)"
        break
      fi
    done
  fi
  _run_or_dry brew install node@22
  local _node_prefix
  _node_prefix="$(brew --prefix node@22 2>/dev/null || true)"
  [[ -n "$_node_prefix" && -d "$_node_prefix/bin" ]] && export PATH="$_node_prefix/bin:$PATH"
}

_install_node_linux() {
  _detect_linux_pkg_mgr
  case "$_LINUX_PKG_MGR" in
    apt)
      echo "==> Installing Node.js 22 via NodeSource (apt)..."
      _maybe_sudo bash -c "curl -fsSL https://deb.nodesource.com/setup_22.x | bash -"
      _maybe_sudo apt-get install -y nodejs
      ;;
    dnf)
      echo "==> Installing Node.js 22 via NodeSource (dnf)..."
      _maybe_sudo bash -c "curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -"
      _maybe_sudo dnf install -y nodejs
      ;;
    yum)
      echo "==> Installing Node.js 22 via NodeSource (yum)..."
      _maybe_sudo bash -c "curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -"
      _maybe_sudo yum install -y nodejs
      ;;
    *)
      echo "No supported package manager found (apt/dnf/yum). Install Node.js 22+ manually." >&2
      exit 1
      ;;
  esac
}

_ensure_node() {
  local _min_major=22
  if _has_cmd node && [[ "$(_node_major)" -ge "$_min_major" ]] 2>/dev/null; then
    echo "==> Node.js $(node --version) OK"
    return
  fi

  if _has_cmd node; then
    echo "==> Node.js $(node --version) too old (need >= ${_min_major}). Upgrading..."
  else
    echo "==> Node.js not found. Installing..."
  fi

  if _is_dry_run; then
    echo "[dry-run] would install Node.js ${_min_major}"
    return
  fi

  case "$_OS" in
    macos) _install_node_macos ;;
    linux) _install_node_linux ;;
  esac

  _has_cmd node || { echo "Node.js installation failed." >&2; exit 1; }
  echo "==> Node.js $(node --version) installed"
}

# --- Git ---

_install_git_macos() {
  if _has_cmd brew; then
    _run_or_dry brew install git
    return
  fi
  echo "Install Git: https://git-scm.com/download/mac" >&2
  exit 1
}

_install_git_linux() {
  _detect_linux_pkg_mgr
  case "$_LINUX_PKG_MGR" in
    apt) _maybe_sudo apt-get install -y --no-install-recommends git ;;
    dnf) _maybe_sudo dnf install -y git ;;
    yum) _maybe_sudo yum install -y git ;;
    *)
      echo "No supported package manager. Install git manually." >&2
      exit 1
      ;;
  esac
}

_ensure_git() {
  _has_cmd git && return
  echo "==> Git not found. Installing..."
  _is_dry_run && { echo "[dry-run] would install git"; return; }
  case "$_OS" in
    macos) _install_git_macos ;;
    linux) _install_git_linux ;;
  esac
}

# --- npm prefix ---

_configure_npm_prefix() {
  local _prefix
  _prefix="$(npm config get prefix 2>/dev/null || true)"
  [[ -z "$_prefix" ]] && return

  local _bin_dir="$_prefix/bin"
  if mkdir -p "$_bin_dir" 2>/dev/null && touch "$_bin_dir/.openclaw-write-test" 2>/dev/null; then
    rm -f "$_bin_dir/.openclaw-write-test"
    return
  fi

  local _new_prefix="$HOME/.npm-global"
  echo "==> npm prefix '${_prefix}' is not writable. Switching to ${_new_prefix}."

  if ! _is_dry_run; then
    mkdir -p "$_new_prefix/bin"
    npm config set prefix "$_new_prefix"
    local _export_line='export PATH="$HOME/.npm-global/bin:$PATH"'
    for _rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
      if [[ -f "$_rc" ]] && ! grep -qF '.npm-global/bin' "$_rc" 2>/dev/null; then
        echo "$_export_line" >> "$_rc"
      fi
    done
  else
    echo "[dry-run] would set npm prefix to $_new_prefix"
  fi

  export PATH="$HOME/.npm-global/bin:$PATH"
}

# --- Version resolution ---

_resolve_npm_tag() {
  if [[ "$OPENCLAW_BETA" == "1" ]]; then
    local _beta_ver
    _beta_ver="$(npm view "${OPENCLAW_PACKAGE}@beta" version 2>/dev/null || true)"
    if [[ -n "$_beta_ver" ]]; then
      echo "beta"
      return
    fi
    echo "==> Beta channel unavailable, falling back to latest." >&2
    echo "latest"
    return
  fi
  echo "$OPENCLAW_VERSION"
}

# --- Source checkout detection ---

_IS_CHECKOUT=0

_detect_source_checkout() {
  if [[ -f "$PWD/package.json" && -f "$PWD/pnpm-workspace.yaml" ]]; then
    if grep -q '"openclaw"' "$PWD/package.json" 2>/dev/null; then
      _IS_CHECKOUT=1
    fi
  fi
}

_prompt_checkout_method() {
  [[ "$_IS_CHECKOUT" == "0" || -n "$OPENCLAW_INSTALL_METHOD" ]] && return

  if [[ "$OPENCLAW_NO_PROMPT" == "1" ]] || ! [[ -t 0 ]]; then
    echo "==> Source checkout detected; no TTY or prompts disabled. Defaulting to npm." >&2
    OPENCLAW_INSTALL_METHOD="npm"
    return
  fi

  echo ""
  echo "OpenClaw source checkout detected in ${PWD}."
  echo "  1) Use this checkout  (git — builds from source)"
  echo "  2) Install from npm   (latest published release)"
  echo ""
  local _choice
  read -rp "Choose [1/2, default: 2]: " _choice
  case "$_choice" in
    1) OPENCLAW_INSTALL_METHOD="git"; OPENCLAW_GIT_DIR="$PWD" ;;
    *) OPENCLAW_INSTALL_METHOD="npm" ;;
  esac
}

# --- npm install ---

_do_install_npm() {
  local _tag
  _tag="$(_resolve_npm_tag)"

  echo "==> Installing ${OPENCLAW_PACKAGE}@${_tag} via npm..."

  _configure_npm_prefix

  if _is_dry_run; then
    echo "[dry-run] SHARP_IGNORE_GLOBAL_LIBVIPS=${SHARP_IGNORE_GLOBAL_LIBVIPS} npm install -g --loglevel ${OPENCLAW_NPM_LOGLEVEL} ${OPENCLAW_PACKAGE}@${_tag}"
    return
  fi

  npm install -g --loglevel "$OPENCLAW_NPM_LOGLEVEL" "${OPENCLAW_PACKAGE}@${_tag}"

  local _npm_bin
  _npm_bin="$(npm config get prefix 2>/dev/null || true)/bin"
  [[ -d "$_npm_bin" ]] && export PATH="$_npm_bin:$PATH"
}

# --- git install ---

_do_install_git() {
  _ensure_git

  local _git_dir="$OPENCLAW_GIT_DIR"
  echo "==> Installing OpenClaw from source to ${_git_dir}..."

  if [[ -d "$_git_dir/.git" ]]; then
    if [[ "$OPENCLAW_GIT_UPDATE" == "1" ]]; then
      echo "==> Updating existing checkout..."
      _run_or_dry git -C "$_git_dir" pull --ff-only
    else
      echo "==> Skipping git pull (OPENCLAW_GIT_UPDATE=0)"
    fi
  else
    _run_or_dry git clone https://github.com/openclaw/openclaw.git "$_git_dir"
  fi

  if ! _is_dry_run; then
    (cd "$_git_dir" && pnpm install --frozen-lockfile)
    (cd "$_git_dir" && pnpm run build)
  else
    echo "[dry-run] would run pnpm install --frozen-lockfile && pnpm run build in $_git_dir"
  fi

  local _bin_dir="$HOME/.local/bin"
  local _wrapper="$_bin_dir/openclaw"
  echo "==> Writing wrapper to ${_wrapper}..."

  if ! _is_dry_run; then
    mkdir -p "$_bin_dir"
    printf '#!/usr/bin/env bash\nexec node "%s/openclaw.mjs" "$@"\n' "$_git_dir" > "$_wrapper"
    chmod +x "$_wrapper"
  else
    echo "[dry-run] would write wrapper to $_wrapper"
  fi

  export PATH="$_bin_dir:$PATH"
}

# --- Post-install ---

_do_post_install() {
  local _was_upgrade="$1"  # "1" if openclaw was already installed
  local _method="$2"

  if [[ "$_was_upgrade" == "1" || "$_method" == "git" ]]; then
    if _has_cmd openclaw; then
      echo "==> Running openclaw doctor..."
      openclaw doctor --non-interactive 2>/dev/null || true
    fi
  fi

  [[ "$OPENCLAW_NO_ONBOARD" == "1" ]] && return

  # Auto-onboard only on fresh npm installs with an interactive TTY
  if [[ "$_was_upgrade" == "0" ]] && [[ "$_method" == "npm" ]] && [[ -t 0 && -t 1 ]]; then
    if _has_cmd openclaw; then
      echo "==> Starting onboarding wizard..."
      openclaw onboard --install-daemon 2>/dev/null || true
    fi
  fi
}

# --- Main ---

_detect_os

echo "==> OpenClaw installer ($(uname -sm))"

_detect_source_checkout
_prompt_checkout_method

: "${OPENCLAW_INSTALL_METHOD:=npm}"
echo "==> Method: ${OPENCLAW_INSTALL_METHOD} | Version: ${OPENCLAW_VERSION}"

_ensure_node
_ensure_git

_WAS_UPGRADE=0
_has_cmd openclaw && _WAS_UPGRADE=1

case "$OPENCLAW_INSTALL_METHOD" in
  npm) _do_install_npm ;;
  git) _do_install_git ;;
  *)   echo "Unknown method: $OPENCLAW_INSTALL_METHOD" >&2; exit 2 ;;
esac

_do_post_install "$_WAS_UPGRADE" "$OPENCLAW_INSTALL_METHOD"

echo ""
echo "==> OpenClaw installed successfully!"
if _has_cmd openclaw; then
  openclaw --version
fi
