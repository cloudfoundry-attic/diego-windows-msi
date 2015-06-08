#!/usr/bin/env bash

GEM_HOME=~/.gems
GEM_PATH=$GEM_HOME:$GEM_PATH
chruby 2.1.2
gem install bundler --no-rdoc --no-ri
export BUNDLE_GEMFILE=$(dirname $0)/Gemfile
bundle install
ruby_script=$1
shift
bundle exec ${ruby_script} "$@"
