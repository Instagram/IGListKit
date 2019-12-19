#!/bin/bash
# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

VERSION="0.24.2"
FOUND=$(swiftlint version)

if which swiftlint >/dev/null; then
    swiftlint lint --config ../.swiftlint.yml
else
    echo "
    Error: SwiftLint not installed!
    Download from https://github.com/realm/SwiftLint,
    or brew install swiftlint.
    "
    exit 1
fi

if [ $(swiftlint version) != $VERSION ]; then
    echo "
    Warning: incorrect SwiftLint installed!
    Expected: $VERSION
    Found: $FOUND
    Download from https://github.com/realm/SwiftLint,
    or brew upgrade swiftlint.
    "
fi

exit
