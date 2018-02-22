#!/usr/bin/env bash

set -eou pipefail

DSI_DIR="$HOME/Projects/dsi"
MONGO_DIR="$HOME/Projects/mongo"
EVG="$HOME/bin/evergreen"
PROJECT="sys-perf"
TASKS="linkbench_WT"
VARIANTS="linux-standalone"

tmp_file="/tmp/patchme-$$.txt"

pushd "$MONGO_DIR" >/dev/null
    mongo_commit="$(git rev-parse HEAD)"
popd >/dev/null
pushd "$DSI_DIR" >/dev/null
    dsi_commit="$(git rev-parse HEAD)"
popd >/dev/null

# create patch
pushd "$MONGO_DIR" >/dev/null
    $EVG patch -p "$PROJECT" -t "$TASKS" -v "$VARIANTS" -y | tee "$tmp_file"
    evg_id="$(    cat "$tmp_file" | grep ID    | awk '{ print $3; }' )"
    evg_build="$( cat "$tmp_file" | grep Build | awk '{ print $3; }' )"
popd >/dev/null

# set-module
pushd "$DSI_DIR" >/dev/null
    $EVG set-module -m dsi -i "$evg_id" -y
popd >/dev/null

{
    echo ""
    echo ": [Build]($evg_build) [Results]("
    echo ": EVG ID: $evg_id"
    echo ": Mongo Commit: $mongo_commit"
    echo ": DSI Commit: $dsi_commit"
    echo ""
}

rm "$tmp_file"
