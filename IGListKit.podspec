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

  s.source_files = 'Source/**/*.{h,m,mm}'
  s.private_header_files = 'Source/Internal/*.h'

  s.requires_arc = true

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'

  s.frameworks = 'UIKit'
  s.library = 'c++'
  s.pod_target_xcconfig = {
       'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
       'CLANG_CXX_LIBRARY' => 'libc++'
  }
end
