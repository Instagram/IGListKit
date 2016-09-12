#!/bin/bash

# Docs by jazzy
# https://github.com/realm/jazzy
# ------------------------------

jazzy --objc \
      --module 'IGListKit' \
      --framework-root . \
      --umbrella-header Source/IGListKit.h \
      --readme README.md \
      --author 'Instagram' \
      --author_url 'https://twitter.com/fbOpenSource' \
      --github_url 'https://github.com/Instagram/IGListKit' \
      --output docs/ \
