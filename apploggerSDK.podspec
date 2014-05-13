#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "apploggerSDK"
  s.version          = "0.1.0"
  s.summary          = "Log your app to the web"
  s.description      = <<-DESC
                       An optional longer description of apploggerSDK

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "http://applogger.io"
  s.license          = 'MIT'
  s.author           = { "io" => "info@applogger.io" }

  s.source   = { :git => 'https://github.com/applogger/applogger-ios-sdk.git', :submodules => true }
  s.platform     = :ios, '6.0'
  s.ios.deployment_target = '6.0'
  s.requires_arc = true
  s.ios.frameworks     = %w{CFNetwork Security}
  s.osx.frameworks     = %w{CoreServices Security}
  s.osx.compiler_flags = '-Wno-format'
  s.libraries          = "icucore"
  s.framework    = 'AppKit'
  
  s.source_files = 'Classes/iOS/*.{h,m}', "socket.io/*.{h,m}", "socket.io/submodules/socket-rocket/SocketRocket/*.{h,m,c}"

  s.dependency 'CocoaAsyncSocket', '~> 7.3.4'
  s.dependency 'CocoaLumberjack'

  s.prepare_command = <<-CMD
			git submodule update --init --recursive
                  CMD
end
