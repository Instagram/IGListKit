# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

Pod::Spec.new do |s|
  s.name = 'IGListKit'
  s.version = `scripts/version.sh`
  s.summary = 'A data-driven UICollectionView framework.'
  s.homepage = 'https://github.com/Instagram/IGListKit'
  s.documentation_url = 'https://instagram.github.io/IGListKit'
  s.description = 'A data-driven UICollectionView framework for building fast and flexible lists.'

  s.license =  { :type => 'MIT' }
  s.authors = 'Instagram'
  s.social_media_url = 'https://twitter.com/fbOpenSource'
  s.source = {
    :git => 'https://github.com/Instagram/IGListKit.git',
    :tag => s.version.to_s,
    :branch => 'stable'
  }

  s.dependency 'IGListDiffKit', "= #{s.version}"

  [s.ios, s.tvos].each do |os|
    os.source_files = 'Source/IGListKit/**/*.{h,m,mm}'
    os.public_header_files = 'Source/IGListKit/include/*.h'
    os.private_header_files = 'Source/IGListKit/*.h'
  end

  s.osx.source_files = 'Source/IGListKit/include/IGListKit.h'

  s.requires_arc = true

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'

  s.ios.frameworks = 'UIKit'
  s.tvos.frameworks = 'UIKit'
  s.osx.frameworks = 'Cocoa'

  s.library = 'c++'
  s.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
    'CLANG_CXX_LIBRARY' => 'libc++',
  }
end
