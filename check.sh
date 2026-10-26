#!/usr/bin/env bash
# quick syntax sanity check for the repo
set -e
bash -n keep-awake-mode install.sh uninstall.sh
python3 -c "import json; json.load(open('plasmoid/vansh.keepawake.battery/metadata.json'))" && echo "metadata.json valid JSON"
echo "OK"