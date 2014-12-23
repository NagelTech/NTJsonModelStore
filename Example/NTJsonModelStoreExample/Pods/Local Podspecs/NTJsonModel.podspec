Pod::Spec.new do |s|
  s.name                = "NTJsonModel"
  s.version             = "0.50"
  s.summary             = "[In development] "
  s.homepage            = "https://github.com/NagelTech/NTJsonModel"
  s.license             = { :type => 'MIT', :file => 'LICENSE' }
  s.author              = { "Ethan Nagel" => "eanagel@gmail.com" }
  s.platform            = :ios, '6.0'
  s.source              = { :git => "https://github.com/NagelTech/NTJsonModel.git", :branch => "feature/explicit-mutability" }
  s.requires_arc        = true

  s.source_files        = 'classes/ios/*.{h,m}'
  s.public_header_files = 'NTJsonModel.h', 'NTJsonPropertyInfo.h', 'NTJsonPropertyConversion.h', 'NSArray+NTJsonModel.h', 'NSDictionary+NTJsonModel.h'

end
