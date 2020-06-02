#
# Be sure to run `pod lib lint dkd-objc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DIMCore'
  s.version          = '0.4.0'
  s.summary          = 'Decentralized Instant Messaging Protocol (Objective-C)'
  s.homepage         = 'https://github.com/dimchat'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'DIM' => 'john.chen@infothinker.com' }
  s.source           = { :git => 'https://github.com/dimchat/core-objc.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'

  s.source_files = 'Classes/**/*'

  s.dependency 'DaoKeDao', '~> 0.4.4'
  s.dependency 'MingKeMing', '~> 0.4.4'
end
