#!/bin/bash

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
COMMONDIR=Source/Common/

# store all the file names in Common folder
COMMONFILES=($(find Source/Common -maxdepth 1 -type f -exec basename {} \;))

# move files in Common folder to Source folder
for f in "${COMMONFILES[@]}"
do
  mv $COMMONDIR$f $SOURCE
done

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

# move files back to Common folder
for f in "${COMMONFILES[@]}"
do
  mv $SOURCEDIR$f $COMMONDIR
done
