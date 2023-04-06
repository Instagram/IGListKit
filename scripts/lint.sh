#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

# Adds support for Apple Silicon brew directory
if test -d "/opt/homebrew/bin/"; then
  PATH="/opt/homebrew/bin/:${PATH}"
  export PATH
fi

VERSION="0.50.3"
FOUND=$(swiftlint version)

if which swiftlint >/dev/null; then
    swiftlint lint --config ../.swiftlint.yml
else
    echo "
    Warning: SwiftLint not installed!
    You should download SwiftLint to verify your Swift code.
    Download from https://github.com/realm/SwiftLint,
    or brew install swiftlint.
    "
    exit
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
