#!/bin/bash

set -o errexit

ruby preprocess.rb "$@" > data.rb

bundle exec ruby viewer.rb
