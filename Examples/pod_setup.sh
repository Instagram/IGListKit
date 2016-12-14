#!/bin/bash

echo 'Setting up iOS examples...'
cd Examples-iOS/
pod install
cd ..

echo 'Setting up tvOS examples...'
cd Examples-tvOS/
pod install
cd ..

echo 'Setting up macOS examples...'
cd Examples-macOS/
pod install
cd ..

echo 'Done!'
echo ''
