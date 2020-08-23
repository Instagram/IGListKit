#!/bin/bash
# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

cd "$(dirname "$(dirname "$0")")" || exit 1

/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "$(pwd)/Source/Info.plist"
