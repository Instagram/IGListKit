# Copyright (c) Meta Platforms, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

Pod::Spec.new do |s|
  s.name = 'IGListSwiftKit'
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

  s.dependency 'IGListKit', "= #{s.version}"

  [s.ios, s.tvos].each do |os|
    os.source_files = [
      'Source/IGListSwiftKit/**/*.{swift}',
    ]
  end

  s.requires_arc = true

  s.swift_versions = ['4.0', '5.0', '5.1']

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'

  s.ios.frameworks = 'UIKit'
  s.tvos.frameworks = 'UIKit'
end
