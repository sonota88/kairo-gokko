#!/bin/bash

set -o errexit
set -o nounset

if [ "$1" = "test" ]; then
  ruby test/test_circuit.rb
  ruby test/test_tuden.rb
  exit 0
fi

bundle exec ruby gen_sound.rb \
  out=click.wav amp=0.05 msec=30 hz=1000

# bundle exec ruby gen_sound.rb \
#   out=relay.wav amp=0.05 msec=30 hz=500
bundle exec ruby gen_noise.rb \
  out=relay_2.wav amp=0.015 msec=100 hz=1

fodg_path="$1"; shift
page="$1"; shift

ruby preprocess.rb "$fodg_path" > data.rb

if [ "$BROWSER" = "1" ]; then
  bundle exec dxopal server
else
  PAGE="$page" \
    bundle exec ruby main.rb
fi
