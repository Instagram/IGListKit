#!/bin/bash

# Docs by jazzy
# https://github.com/realm/jazzy
# ------------------------------
SOURCE=Source
SOURCE_TMP=IGListKit

# temporary workaround when using SPM dir format
# https://github.com/realm/jazzy/issues/667
mv $SOURCE $SOURCE_TMP

jazzy \
	--objc \
	--clean \
	--author 'Instagram' \
    --author_url 'https://twitter.com/fbOpenSource' \
    --github_url 'https://github.com/Instagram/IGListKit' \
    --sdk iphonesimulator \
    --module 'IGListKit' \
    --framework-root . \
    --umbrella-header $SOURCE_TMP/IGListKit.h \
    --readme README.md \
    --documentation "Guides/*.md" \
    --output docs/

# restore the dir per the jazzy issue
mv $SOURCE_TMP $SOURCE
