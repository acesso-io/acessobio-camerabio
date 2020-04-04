Pod::Spec.new do |spec|

  spec.name         = "CameraBio"
  spec.version      = "1.0.10"
  spec.summary      = "A short description of CameraBio."
  spec.description = 'A short description about the project'
  spec.homepage     = "http://EXAMPLE/CameraBio"
  spec.license      = "MIT"
  spec.author             = { "MatheusDomingos" => "matheus_cancao@hotmail.com" }
  spec.platform     = :ios, "9.0"

  spec.source       = { :git => "https://github.com/acesso-io/acessobio-camerabio.git", :tag => "1.0.9" }
  spec.source_files  =  "CameraBio/**/*.{h,m}"

  spec.resource  = "icon.png","CameraBio/CameraBio/*.{png}", "*.{png}", "CameraBio/*.{png}"
  spec.resources = "CameraBio/CameraBio/*.{png}", "*.{png}", "CameraBio/*.{png}"

  spec.dependency "GoogleMobileVision/FaceDetector"

  spec.static_framework = true
end
