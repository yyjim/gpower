platform :ios, '7.0'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/cardinalblue/CocoaPodsSpecs'

pod 'Tweaks'
pod 'SpriteKit-Components', '~> 1.0'
pod 'CBToolkit/Core', '~>0.2.0'
pod 'SOMotionDetector', :git => 'git@github.com:SocialObjects-Software/SOMotionDetector.git'
pod 'PBJVision', '~> 0.4'

# This enables Tweaks on experimental and test flight builds.
post_install do |installer_representation|
  installer_representation.project.targets.each do |target|
    if target.name.include? "Tweaks"
      target.build_configurations.each do |config|
        if config.name == 'AdHoc'
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'FB_TWEAK_ENABLED=1']
        end
      end
    end
  end
end
