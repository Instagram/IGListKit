#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

echo 'Running bundle install...'
bundle install

echo 'Running pod install...'
pod install

echo 'Setting up example projects...'
./scripts/pod_setup.sh

echo 'Done!'
echo ''
