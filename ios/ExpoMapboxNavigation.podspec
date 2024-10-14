require "json"
require "net/http"
require "uri"
require "base64"

package = JSON.parse(File.read(File.join(__dir__, "..", "package.json")))

MAPBOX_USERNAME = "mapbox"
MAPBOX_TOKEN = $RNMapboxMapsDownloadToken || ENV["MAPBOX_TOKEN"]
BASE_URL = "https://api.mapbox.com/downloads/v2"

BINARIES = [
  {
    name: "MapboxNavigationNative",
    package: "dash-native",
    version: "311.0.0",
  },
  {
    name: "MapboxDirections",
    package: "navsdk-v3-ios",
    version: "3.1.1",
  },
  {
    name: "MapboxNavigationCore",
    package: "navsdk-v3-ios",
    version: "3.1.1",
  },
  {
    name: "MapboxNavigationUIKit",
    package: "navsdk-v3-ios",
    version: "3.1.1",
  },
  {
    name: "Turf",
    package: "navsdk-v3-ios",
    version: "3.1.1",
  },
  {
    name: "_MapboxNavigationUXPrivate",
    package: "navsdk-v3-ios",
    version: "3.1.1",
  },
]

Pod::Spec.new do |s|
  s.name = "ExpoMapboxNavigation"
  s.version = package["version"]
  s.summary = package["description"]
  s.description = package["description"]
  s.license = package["license"]
  s.author = package["author"]
  s.homepage = package["homepage"]
  s.platforms = { :ios => "13.4", :tvos => "13.4" }
  s.swift_version = "5.9"
  s.source = { git: "https://github.com/YoussefHenna/expo-mapbox-navigation" }
  s.static_framework = true

  s.dependency "ExpoModulesCore"
  s.dependency "MapboxMaps", $RNMapboxMapsVersion

  s.source_files = "**/*.{h,m,swift}"
  s.exclude_files = ["Frameworks/*.xcframework/**/*.h"]
  s.preserve_paths = [
    "Frameworks/*.xcframework",
    "**/*.h",
    "Frameworks/*.xcframework/**/*.h",
  ]

  s.vendored_frameworks = [
    "Frameworks/MapboxNavigationCore.xcframework",
    "Frameworks/MapboxDirections.xcframework",
    "Frameworks/MapboxNavigationUIKit.xcframework",
    "Frameworks/_MapboxNavigationUXPrivate.xcframework",
    "Frameworks/Turf.xcframework",
    "Frameworks/MapboxNavigationNative.xcframework",
  ]

  # Swift/Objective-C compatibility
  s.pod_target_xcconfig = {
    "DEFINES_MODULE" => "YES",
    "SWIFT_COMPILATION_MODE" => "wholemodule",
    "OTHER_SWIFT_FLAGS" => "$(inherited)",
  }

  binary_names = BINARIES.map { |binary|
    "\"#{binary[:name]}\""
  }.join(" ")

  binary_urls = BINARIES.map { |binary|
    "\"#{BASE_URL}/#{binary[:package]}/" \
    "releases/ios/packages/#{binary[:version]}/" \
    "#{binary[:name]}.xcframework.zip\""
  }.join(" ")

  s.prepare_command = <<-SCRIPT
      #!/bin/bash
      binary_names=(#{binary_names})
      binary_urls=(#{binary_urls})
      username="#{MAPBOX_USERNAME}"
      token="#{MAPBOX_TOKEN}"
  
      for i in "${!binary_names[@]}"; do
        name="${binary_names[$i]}"
        url="${binary_urls[$i]}"
        sh -c "./download-framework.sh $name $url $username $token"
      done
    SCRIPT
end
