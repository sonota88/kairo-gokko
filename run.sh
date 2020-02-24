#!/bin/bash

set -o errexit

bundle exec ruby gen_sound.rb \
  out=click.wav amp=0.1 msec=30 hz=1000

ruby preprocess.rb "$@" > data.rb

bundle exec dxopal server
