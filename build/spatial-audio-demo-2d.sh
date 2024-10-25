#!/bin/sh
echo -ne '\033c\033]0;spatial-audio-demo-2d\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/spatial-audio-demo-2d.x86_64" "$@"
