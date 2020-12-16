#!/bin/bash
# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

if ! which jazzy >/dev/null; then
  echo "Jazzy not detected: You can download it from https://github.com/realm/jazzy"
  exit
fi

# Docs by jazzy
# https://github.com/realm/jazzy
# ------------------------------
SOURCE=Source
SOURCE_TMP=IGListKit
SOURCEDIR=Source/

jazzy \
	--objc \
	--clean \
	--author 'Instagram' \
    --author_url 'https://twitter.com/fbOpenSource' \
    --github_url 'https://github.com/Instagram/IGListKit' \
    --sdk iphonesimulator \
    --module 'IGListKit' \
    --framework-root $SOURCEDIR/ \
    --umbrella-header $SOURCEDIR/$SOURCE_TMP/include/IGListKit.h \
    --readme README.md \
    --documentation "Guides/*.md" \
    --output docs/
