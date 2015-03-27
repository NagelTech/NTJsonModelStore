Pod::Spec.new do |s|
  s.name                = "NTJsonModelStore"
  s.version             = "0.50"
  s.summary             = "[In development]"
  s.homepage            = "https://github.com/NagelTech/NTJsonModelStore"
  s.license             = { :type => 'MIT', :file => 'LICENSE' }
  s.author              = { "Ethan Nagel" => "eanagel@gmail.com" }
  s.platform            = :ios, '6.0'
  s.source              = { :git => "https://github.com/NagelTech/NTJsonModelStore.git", :branch => "develop" }
  s.requires_arc        = true
  s.libraries           = 'sqlite3'

  s.source_files        = 'Pod/Classes/*.{h,m}'
  s.public_header_files = 'NTJsonModelStore.h', 'NTJsonModelCollection.h', 'NTJsonStorableModel.h'
  
  s.dependency 'NTJsonStore', '~> 1.00'
  s.dependency 'NTJsonModel', '~> 1.00'

end

