platform :ios, '6.0'
pod 'CSApi', :path => '../CSApi/'
pod 'MBCategory'
pod 'SDWebImage'
pod 'PBWebViewController',
    :git => 'git://github.com/wharris/PBWebViewController.git',
    :branch => 'dismiss-popover'
pod 'ARChromeActivity',
    :git => 'git://github.com/wharris/ARChromeActivity.git',
    :branch => 'set-activity-title'
pod 'TUSafariActivity'

target :test, :exclusive => true do
    link_with 'SimplyShopTests'
    pod 'OCMock'
end
