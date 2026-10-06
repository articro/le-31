#!/bin/bash
# runat.sh <dbg> [args...] -> tests courts (audit, rig, m2, mvis, cam)
GODOT=/home/user/.cache/Godot_v4.3-stable_linux.x86_64
"$GODOT" --headless --path /home/user/hantise --dbg="$1" "${@:2}" 2>&1 \
 | grep -v "Parameter \"m\" is null" | grep -vE "^\s+at:" | grep -v "transparency_mode"
