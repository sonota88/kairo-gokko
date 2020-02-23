#!/bin/bash

set -o errexit

ruby preprocess.rb "$@" > data.rb

bundle exec dxopal server
