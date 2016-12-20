#!/bin/bash

echo 'Setting up iOS examples...'
cd Examples-iOS/
pod install
echo ''
cd ..

echo 'Setting up tvOS examples...'
cd Examples-tvOS/
pod install
echo ''
cd ..

echo 'Setting up macOS examples...'
cd Examples-macOS/
pod install
echo ''
cd ..

echo 'Done!'
echo ''
