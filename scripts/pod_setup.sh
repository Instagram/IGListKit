#!/bin/bash

echo 'Setting up iOS examples...'
cd Examples/Examples-iOS/
bundle exec pod install
echo ''
cd ../..

echo 'Setting up tvOS examples...'
cd Examples/Examples-tvOS/
bundle exec pod install
echo ''
cd ../..

echo 'Setting up macOS examples...'
cd Examples/Examples-macOS/
bundle exec pod install
echo ''
cd ../..

echo 'Done!'
echo ''
