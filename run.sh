#!/bin/bash

set -o errexit

if [ "$1" = "test" ]; then
  ruby test/test_child_circuit.rb
  ruby test/test_tuden.rb
  exit 0
fi

bundle exec ruby gen_sound.rb \
  out=click.wav amp=0.05 msec=30 hz=1000

ruby preprocess.rb "$@" > data.rb

if [ "$BROWSER" = "1" ]; then
  bundle exec dxopal server
else
  bundle exec ruby main.rb
fi
