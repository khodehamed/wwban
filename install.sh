#!/bin/bash
# curl -fsSL https://raw.githubusercontent.com/khodehamed/wwban/main/install.sh | sudo bash
set -e
REPO=https://github.com/khodehamed/wwban.git
if [ "$(id -u)" -ne 0 ]; then
  echo "با root اجرا کنید: curl -fsSL https://raw.githubusercontent.com/khodehamed/wwban/main/install.sh | sudo bash"
  exit 1
fi
here=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
if [ -n "$here" ] && [ -f "$here/wwban" ] && [ -f "$here/wwban-setup.sh" ]; then
  exec bash "$here/wwban" install
fi
export DEBIAN_FRONTEND=noninteractive
command -v git >/dev/null || apt-get install -y -o DPkg::Lock::Timeout=60 git
dir=/opt/wwban
rm -rf "$dir"
git clone --depth 1 "$REPO" "$dir"
exec bash "$dir/wwban" install
