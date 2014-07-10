Pod::Spec.new do |s|
  s.name                = "NTJsonModel"
  s.version             = "0.20"
  s.summary             = "[In development] "
  s.homepage            = "https://github.com/NagelTech/NTJsonModel"
  s.license             = { :type => 'MIT', :file => 'LICENSE' }
  s.author              = { "Ethan Nagel" => "eanagel@gmail.com" }
  s.platform            = :ios, '6.0'
  s.source              = { :git => "https://github.com/NagelTech/NTJsonModel.git", :tag => "0.20" }
  s.requires_arc        = true

  s.source_files        = 'classes/ios/*.{h,m}'
  s.public_header_files = 'NTJsonModel.h', 'NTJsonModelArray.h', 'NTJsonPropertyInfo.h', 'NTJsonPropertyConversion.h'
end
