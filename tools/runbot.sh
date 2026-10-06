#!/bin/bash
# runbot.sh <dbg> <seed> [maxsec] -> lance Godot headless, coupe des que EVT WIN/CAUGHT apparait
dbg=$1; seed=${2:-1}; maxt=${3:-240}
GODOT=/home/user/.cache/Godot_v4.3-stable_linux.x86_64
log=/tmp/bot_${dbg}_${seed}.log; : > "$log"
"$GODOT" --headless --path /home/user/hantise --dbg="$dbg" --seed="$seed" > "$log" 2>&1 &
pid=$!
t0=$(date +%s)
while [ $(( $(date +%s) - t0 )) -lt "$maxt" ]; do
  grep -qE "EVT (WIN|CAUGHT)" "$log" 2>/dev/null && break
  kill -0 $pid 2>/dev/null || break
  sleep 0.3
done
kill -9 $pid 2>/dev/null; wait $pid 2>/dev/null
echo "--- bot=$dbg seed=$seed duree=$(( $(date +%s) - t0 ))s ---"
grep -E "EVT (WIN|CAUGHT)|SCRIPT ERROR|AUDIT" "$log" | head -4
