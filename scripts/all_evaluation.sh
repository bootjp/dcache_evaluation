#!/usr/bin/env bash

set -ex

targets=(
    "coredns"
    "dcache"
    "forward"
    "redis"
)


if [ $# != 1 ]; then
  echo "require 1 args for data out put dir (not contains last slash)"
  exit 1;
fi

OUT_PATH=$1

for target in "${targets[@]}" ; do
  bash ./prepare_instance.sh "$target" "$OUT_PATH"
done