#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
# Remove these lines if you don't have assets:
# bundle exec rake assets:precompile
# bundle exec rake assets:clean
bundle exec rake db:migrate