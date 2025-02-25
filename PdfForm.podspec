Pod::Spec.new do |spec|
  spec.name         = "PdfForm"
  spec.version      = "1.0.0"
  spec.summary      = "A React Native library to detect and fill PDF forms"
  spec.homepage     = "https://github.com/allenaapp/react-native-pdf-form"
  spec.license      = "MIT"
  spec.author       = { "Samin Shams" => "support@formsign.app" }
  spec.platform     = :ios, "11.0"
  spec.source       = { :path => "." }
  spec.source_files  = "*.swift"
  spec.dependency "React"
end