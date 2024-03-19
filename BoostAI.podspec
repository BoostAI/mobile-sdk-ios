Pod::Spec.new do |s|
  s.name             = 'BoostAI'
  s.version          = '1.1.13'
  s.summary          = 'An SDK for boost.ai backend + an extendable chat panel'

  s.homepage         = 'https://github.com/BoostAI/mobile-sdk-ios'
  s.license          = { :type => 'GPLv3', :file => 'LICENSE' }
  s.author           = { 'boost.ai' => 'contact@boost.ai' }
  s.source           = { :git => 'https://github.com/BoostAI/mobile-sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_versions = ['5.1', '5.2', '5.3', '5.4', '5.5', '5.6']

  s.source_files = 'BoostAI/**/*.swift'
  s.resource_bundles = {
    'BoostAI' => ['BoostAI/**/*.xcassets']
  }
end
