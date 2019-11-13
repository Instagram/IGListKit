#!/bin/bash

cd "$(dirname "$(dirname "$0")")" || exit 1

exec defaults read "$(pwd)/Source/Info" CFBundleShortVersionString
