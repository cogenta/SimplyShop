platform :ios, '6.0'
pod 'CSApi'
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
