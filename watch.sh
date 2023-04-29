#!/bin/bash

set -o nounset

while true; do
  rm -f z_rake_flag

  rake build
  if [ -e z_rake_flag ]; then
    echo "flag exist ... yes"
    if [ $? -eq 0 ]; then
      ./beep.sh ok
    else
      ./beep.sh ng
    fi
  else
    echo "flag exist ... no"
  fi

  sleep 3
done
