Pod::Spec.new do |s|
  s.name             = 'JKLoger'
  s.version          = '1.0.2'
  s.summary          = 'A lightweight and extensible logging library for iOS'
  s.description      = <<-DESC
                       JKLoger is a lightweight, high-performance Objective-C logging library 
                       designed for iOS applications. It provides multiple log levels, extensible 
                       output destinations, customizable formatters, and thread-safe logging 
                       capabilities. Similar to CocoaLumberjack but more lightweight and easier to use.
                       
                       Features:
                       • Multiple log levels (Fatal, Error, Warning, Info, Debug)
                       • Extensible output destinations (Console, File, Remote)
                       • Customizable log formatters
                       • Thread-safe logging with serial queue
                       • Simple macro interface for easy usage
                       • iOS 13+ support
                       DESC

  s.homepage         = 'https://github.com/xingjiahe/JKLoger'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xingjiahe' => 'jakerxing@foxmail.com' }
  s.source           = { :git => 'https://github.com/xingjiahe/JKLoger.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '13.0'
  s.requires_arc = true

  s.source_files = 'JKLoger/**/*.{h,m}'
  s.public_header_files = 'JKLoger/**/*.h'

  s.frameworks = 'Foundation', 'SystemConfiguration'
  s.static_framework = true

  s.pod_target_xcconfig = {
    'ENABLE_BITCODE' => 'NO',
    'DEFINES_MODULE' => 'YES'
  }
end