#!/bin/bash

set -o errexit

bundle exec ruby gen_sound.rb \
  out=click.wav amp=0.1 msec=30 hz=1000

ruby preprocess.rb "$@" > data.rb

if [ "$BROWSER" = "1" ]; then
  bundle exec dxopal server
else
  bundle exec ruby main.rb
fi
