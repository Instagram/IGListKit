#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

cd "$(dirname "$(dirname "$0")")" || exit 1

exec /usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$(pwd)/Source/Info.plist"
