#!/usr/bin/env bash

export GEM_HOME=~/.gems
export GEM_PATH=$GEM_HOME:$GEM_PATH
export BUNDLE_GEMFILE=$(dirname $0)/Gemfile
bundle install
ruby_script=$1
shift
bundle exec ${ruby_script} "$@"
