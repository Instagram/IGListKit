source 'https://cdn.cocoapods.org'
use_frameworks!
inhibit_all_warnings!

workspace 'IGListKit'

target 'IGListKitTests' do
    platform :ios, '9.0'
    pod 'OCMock', '~> 3.8.1'
end

target 'IGListKit-tvOSTests' do
    platform :tvos, '10.0'
    pod 'OCMock', '~> 3.8.1'
end

post_install do |installer|
    puts "Running OCMock bitcode workaround. https://github.com/erikdoe/ocmock/issues/475"
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            # Disable bitcode for OCMock. See: https://github.com/erikdoe/ocmock/issues/475
            if target.name.start_with?('OCMock')
                config.build_settings['ENABLE_BITCODE'] = 'NO'
              end
        end
    end
end