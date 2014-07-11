Pod::Spec.new do |s|
  s.name                = "NTJsonModelStore"
  s.version             = "0.20"
  s.summary             = "[In development]"
  s.homepage            = "https://github.com/NagelTech/NTJsonModelStore"
  s.license             = { :type => 'MIT', :file => 'LICENSE' }
  s.author              = { "Ethan Nagel" => "eanagel@gmail.com" }
  s.platform            = :ios, '6.0'
  s.source              = { :git => "https://github.com/NagelTech/NTJsonModelStore.git", :branch => "develop" }
  s.requires_arc        = true
  s.libraries           = 'sqlite3'

  s.source_files        = 'Classes/ios/*.{h,m}'
  s.public_header_files = 'NTJsonModelStore.h', 'NTJsonModelCollection.h', 'NTJsonModel+NTJsonModelStore.h'
  
  s.dependency 'NTJsonStore'
  s.dependency 'NTJsonModel'

end

