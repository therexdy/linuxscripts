#!/bin/bash
set -euo pipefail

for dir in */; do
    if [ -d "$dir" ]; then
        if git -C "$dir" rev-parse --is-bare-repository 2>/dev/null | grep -q "true"; then
            if git -C "$dir" config --get-all remote.origin.mirror | grep -q "true"; then
                git -C "$dir" remote update
            fi
        fi
    fi
done

