Pod::Spec.new do |s|
  s.name     = 'AFNetworkingLogger'
  s.version  = '0.0.5'
  # s.license  = 'MIT'
  # s.summary  = ''
  s.homepage = 'https://github.com/stanislaw/AFNetworkingLogger'
  # s.authors  = { 'Stanislaw Pankevich' => 's.pankevich@gmail.com', 'Mattt Thompson' => 'm@mattt.me' }
  s.source   = { :git => 'https://github.com/stanislaw/AFNetworkingLogger.git', :tag => s.version.to_s }
  s.source_files = 'AFNetworkingLogger/*.{h,m}'
  s.private_header_files = 'AFNetworkingLogger/AFNetworkingLogger_Private.h'

  s.requires_arc = true

  s.dependency 'AFNetworking'
end
