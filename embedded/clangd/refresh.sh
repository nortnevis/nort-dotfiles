#!/usr/bin/env bash
# Rebuild a devtool recipe and publish its compile_commands.json for clangd.
#
# Usage:
#   ~/extraSpace/embedded/clangd/refresh.sh            # bmcweb (default)
#   ~/extraSpace/embedded/clangd/refresh.sh bmcweb
#
# Environment overrides:
#   OPENBMC_DIR      OpenBMC checkout (default: ~/extraSpace/embedded/openbmc)
#   OPENBMC_MACHINE  build directory (default: romulus)
# `setup` (and bitbake's environment scripts) reference unset variables such as
# ZSH_NAME, so do not enable `set -u` here.
set -eo pipefail

OPENBMC_DIR="${OPENBMC_DIR:-$HOME/extraSpace/embedded/openbmc}"
OPENBMC_MACHINE="${OPENBMC_MACHINE:-romulus}"
RECIPE="${1:-bmcweb}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$OPENBMC_DIR"
# shellcheck disable=SC1091
. setup "$OPENBMC_MACHINE"

devtool build "$RECIPE"
python3 "$SCRIPT_DIR/gen_compile_db.py" --openbmc "$OPENBMC_DIR" --recipe "$RECIPE"
