Pod::Spec.new do |s|
  s.name     = 'AFNetworkingLogger'
  s.version  = '0.0.8'
  s.license  = 'MIT'

  s.summary  = 'AFNetworking plugin providing network logging for iOS / Mac OS X applications'

  s.homepage = 'https://github.com/stanislaw/AFNetworkingLogger'
  s.authors  = { 'Stanislaw Pankevich' => 's.pankevich@gmail.com' }
  s.source   = { :git => 'https://github.com/stanislaw/AFNetworkingLogger.git', :tag => s.version.to_s }

  s.source_files = 'AFNetworkingLogger/*.{h,m}'
  s.private_header_files = 'AFNetworkingLogger/AFNetworkingLogger_Private.h'

  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.requires_arc = true

  s.dependency 'AFNetworking'
end
