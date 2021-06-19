#!/bin/bash
# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

cd "$(dirname "$(dirname "$0")")" || exit 1

exec plutil -extract CFBundleShortVersionString xml1 -o - "$(pwd)/Source/Info.plist" | sed -n "s/.*<string>\(.*\)<\/string>.*/\1/p"
