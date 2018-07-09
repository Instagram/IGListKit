Pod::Spec.new do |s|
  s.name = 'IGListKit'
  s.version = '3.4.0'
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

  s.subspec 'Diffing' do |ds|
    ds.source_files = 'Source/Common/**/*.{h,m,mm}'
    ds.private_header_files = 'Source/Common/Internal/*.h'
  end

  s.subspec 'Default' do |cs|
    cs.dependency 'IGListKit/Diffing'

    cs.ios.source_files = 'Source/**/*.{h,m,mm}'
    cs.ios.private_header_files = ['Source/Internal/*.h', 'Source/Common/Internal/*.h']

    cs.tvos.source_files = 'Source/**/*.{h,m,mm}'
    cs.tvos.private_header_files = ['Source/Internal/*.h', 'Source/Common/Internal/*.h']
  end

  s.default_subspec = 'Default'
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
