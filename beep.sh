#!/bin/bash

. .env

vol=5

cmd_beep_ok() {
  for i in 0 1; do
    (
      cd $BEEPGEN_DIR
      ./beep-cmd-example.sh f=440 l=50 v=${vol} i=tri
      ./beep-cmd-example.sh f=880 l=50 v=${vol} i=tri
    )
  done
}

cmd_beep_ng() {
  for i in 0 1 2 3; do
    (
      cd $BEEPGEN_DIR
      ./beep-cmd-example.sh f=1000 l=50 v=${vol} i=tri
      ./beep-cmd-example.sh f=100 l=50 v=${vol} i=tri
    )
  done
}

case $1 in
  ok)
    cmd_beep_ok
    ;;
  ng)
    cmd_beep_ng
    ;;
  *)
    echo "invalid command" >&2
    exit 1
    ;;
esac
