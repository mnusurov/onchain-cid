#!/usr/bin/env bash
# Foundry FFI runs without shell profiles, so node may not be in PATH.
# Search common node version managers and install locations before giving up.
find_node_bin() {
    # NVM
    [ -d "$HOME/.nvm/versions/node" ] && \
        ls -d "$HOME/.nvm/versions/node"/*/bin 2>/dev/null | sort -V | tail -1 && return
    # fnm
    [ -d "$HOME/.fnm/node-versions" ] && \
        ls -d "$HOME/.fnm/node-versions"/*/installation/bin 2>/dev/null | sort -V | tail -1 && return
    # volta
    [ -f "$HOME/.volta/bin/node" ] && echo "$HOME/.volta/bin" && return
    # asdf
    [ -d "$HOME/.asdf/installs/nodejs" ] && \
        ls -d "$HOME/.asdf/installs/nodejs"/*/bin 2>/dev/null | sort -V | tail -1 && return
}

if ! command -v node &>/dev/null; then
    NODE_BIN=$(find_node_bin)
    [ -n "$NODE_BIN" ] && export PATH="$NODE_BIN:$PATH"
fi

exec node "$(dirname "$0")/decode-cid.js" "$@"
