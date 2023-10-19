platform :osx, '10.14'
use_frameworks!
inhibit_all_warnings!

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.13'
    end
  end
end

target 'Sphinx' do
   pod 'Alamofire', '~> 5.6.4'
   pod 'ReachabilitySwift'
   pod 'SwiftyJSON'
   pod 'SDWebImage'
   pod 'RNCryptor', '~> 5.0'
   pod 'KeychainAccess'
   pod 'Starscream', '~> 3.1'
   pod 'Tor', podspec: 'https://raw.githubusercontent.com/iCepa/Tor.framework/v405.8.1/Tor.podspec'
   pod 'ObjectMapper'
   pod 'HDWalletKit'
   pod 'CocoaMQTT'
   pod 'MessagePack.swift', '~> 4.0'
end
