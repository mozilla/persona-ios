Pod::Spec.new do |spec|
  spec.name = 'PersonaSDK'
  spec.summary = 'Using Persona in an iOS app.'
  spec.homepage = 'https://github.com/mozilla/persona-ios'
  spec.authors = { 'Dan Walkowski' => 'dwalkowski@mozilla.com' }
  spec.version = '0.0.1'
  spec.license = { :type => 'Mozilla Public License v2', :text => "This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/." }
  spec.source = { :git => 'https://github.com/mozilla/persona-ios.git', :commit => 'bce9bebfa35b428a44e22a6d21e1a16eb3e2717c' }
  spec.requires_arc = true

  spec.platform = :ios, '5.0'
  spec.source_files = 'PersonaSDK/*.{h,m}'
  spec.resources = 'PersonaSDK/*.{js}'
end

