#!/bin/bash

# Docs by jazzy
# https://github.com/realm/jazzy
# ------------------------------

jazzy \
	--objc \
	--clean \
	--author 'Instagram' \
    --author_url 'https://twitter.com/fbOpenSource' \
    --github_url 'https://github.com/Instagram/IGListKit' \
    --sdk iphonesimulator \
    --module 'IGListKit' \
    --framework-root . \
    --umbrella-header Source/IGListKit.h \
    --readme README.md \
    --output docs/
