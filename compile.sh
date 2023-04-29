#!/bin/bash

# Dockerを利用してDXOpalアプリケーションを手軽に事前コンパイルする - Qiita
# https://qiita.com/sonota88/items/536c76d7383356592b92

. .env

IMG_NAME=dxopal-builder:1

cmd_build_image() {
  docker build -t $IMG_NAME .
}

cmd_compile() {
  local rbfile="$1"; shift

  local cmd=""
  cmd="${cmd}docker run --rm -i "
  cmd="${cmd}  -v$(pwd):/tmp/work "

  # コンテナ外の DXOpal を使う場合
  # cmd="${cmd}  -v/path/to/dxopal:/opt/dxopal "
  cmd="${cmd}  -v${DXOPAL_DIR}:/opt/dxopal "

  cmd="${cmd}  ${IMG_NAME} "
  cmd="${cmd}    opal --compile --no-opal --no-exit "
  cmd="${cmd}      --include /opt/dxopal/lib "
  cmd="${cmd}      --include . "
  cmd="${cmd}      $rbfile "

  $cmd # 組み立てたコマンドを実行
}

cmd="$1"; shift
case $cmd in
  build-image )
    cmd_build_image
;; compile )
    cmd_compile "$@"
;; * )
    echo "unknown command (${cmd})" >&2
    exit 1
    ;;
esac
