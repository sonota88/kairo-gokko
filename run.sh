#!/bin/bash

set -o errexit

ruby preprocess.rb "$@" > data.json

bundle exec ruby viewer.rb
