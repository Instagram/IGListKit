Pod::Spec.new do |s|
  s.name = 'IGListKit'
  s.version = '1.0.0'
  s.summary = 'A data-driven UICollectionView framework.'
  s.homepage = 'https://github.com/Instagram/IGListKit'
  s.documentation_url = 'https://instagram.github.io/IGListKit'
  s.description = 'A data-driven UICollectionView framework for building fast and flexible lists.'

  s.license =  { :type => 'BSD' }
  s.authors = 'Instagram'
  s.social_media_url = 'https://twitter.com/fbOpenSource'
  s.source = {
    :git => 'https://github.com/Instagram/IGListKit.git',
    :tag => s.version.to_s,
    :branch => 'stable'
  }

  s.ios.source_files = 'Source/**/*.{h,m,mm}'
  s.ios.private_header_files = 'Source/Internal/*.h'

  s.tvos.source_files = 'Source/**/*.{h,m,mm}'
  s.tvos.private_header_files = 'Source/Internal/*.h'

  s.osx.source_files = [
    'Source/IGListIndexSetResult.{h,m}',
    'Source/IGListDiff.{h,mm}',
    'Source/NSNumber+IGListDiffable.{h,m}',
    'Source/NSString+IGListDiffable.{h,m}',
    'Source/IGListMoveIndexPath.{h,m}',
    'Source/IGListMoveIndex.{h,m}',
    'Source/IGListIndexPathResult.{h,m}',
    'Source/IGListDiffable.h',
    'Source/IGListMacros.h',
    'Source/IGListExperiments.h',
    'Source/IGListKit.h',
    'Source/Internal/IGListMoveIndexInternal.h',
    'Source/Internal/IGListIndexPathResultInternal.h',
    'Source/Internal/IGListIndexSetResultInternal.h',
    'Source/Internal/IGListMoveIndexPathInternal.h'
  ]
  s.osx.private_header_files = [
    'Source/Internal/IGListMoveIndexInternal.h',
    'Source/Internal/IGListIndexPathResultInternal.h',
    'Source/Internal/IGListIndexSetResultInternal.h',
    'Source/Internal/IGListMoveIndexPathInternal.h'
  ]

  s.requires_arc = true

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'

  s.ios.frameworks = 'UIKit'
  s.tvos.frameworks = 'UIKit'
  s.osx.frameworks = 'Cocoa'
  
  s.library = 'c++'
  s.pod_target_xcconfig = {
       'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
       'CLANG_CXX_LIBRARY' => 'libc++'
  }
end
