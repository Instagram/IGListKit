#!/bin/bash

echo 'Running bundle install...'
bundle install

echo 'Running pod install...'
bundle exec pod install

echo 'Setting up example projects...'
./scripts/pod_setup.sh

echo 'Done!'
echo
