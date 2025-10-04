#
# Be sure to run `pod lib lint core-objc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name                  = 'DIMCore'
    s.version               = '1.0.1'
    s.summary               = 'Decentralized Instant Messaging Protocol'
    s.description           = <<-DESC
            Decentralized Instant Messaging Protocol (Objective-C)
                              DESC
    s.homepage              = 'https://github.com/dimchat/core-objc'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'Albert Moky' => 'albert.moky@gmail.com' }
    s.source                = { :git => 'https://github.com/dimchat/core-objc.git', :tag => s.version.to_s }
    # s.platform            = :ios, "12.0"
    s.ios.deployment_target = '12.0'

    s.source_files          = 'Classes', 'Classes/**/*.{h,m}'
    # s.exclude_files       = 'Classes/Exclude'
    s.public_header_files   = 'Classes/**/*.h'

    # s.frameworks          = 'Security'
    # s.requires_arc        = true

    s.dependency 'DaoKeDao', '~> 1.0.2'
    s.dependency 'MingKeMing', '~> 1.0.3'
end
