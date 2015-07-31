#
# Be sure to run `pod lib lint toxcore-ios.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "objcTox"
  s.version          = "0.1.0"
  s.summary          = "Objective-C wrapper for Tox"
  s.homepage         = "https://github.com/Antidote-for-Tox/objcTox"
  s.license          = "MIT"
  s.author           = { "Dmytro Vorobiov" => "d@dvor.me" }
  s.source           = {
      :git => "https://github.com/Antidote-for-Tox/objcTox.git",
      :tag => s.version.to_s,
      :submodules => false
  }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Classes/**/*.{m,h}'
  s.public_header_files = 'Classes/Public/**/*.h'
  s.dependency 'toxcore-ios', '0.1.8'
  s.dependency 'CocoaLumberjack', '1.9.2'
  s.dependency 'Realm', '0.93.2'
  s.dependency 'RBQFetchedResultsController', '1.8.9.3'
end