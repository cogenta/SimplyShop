platform :ios, '6.0'
pod 'CSApi', :git => 'https://github.com/cogenta/CSApi.git', :tag => '0.1.2'
pod 'MBCategory'
pod 'SDWebImage'
pod 'PBWebViewController'
pod 'ARChromeActivity'
pod 'TUSafariActivity'

post_install do | installer |
  require 'fileutils'
  FileUtils.copy 'Pods/Pods-Acknowledgements.plist',
    'SimplyShop/Settings.bundle/Acknowledgements.plist'
end

target :test, :exclusive => true do
    link_with 'SimplyShopTests'
    pod 'OCMock', :head
end
