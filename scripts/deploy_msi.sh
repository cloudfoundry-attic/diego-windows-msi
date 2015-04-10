#!/usr/bin/env sh

# chruby 2.1.2
gem install bundler --no-rdoc --no-ri
export BUNDLE_GEMFILE=$(dirname $0)/Gemfile
mkdir -p $(dirname $0)/vendor/cache
bundle install --path $(dirname $0)vendor/cache
bundle exec $(dirname $0)/deploy_msi.rb "$@"
