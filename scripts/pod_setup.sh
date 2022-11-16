#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

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
