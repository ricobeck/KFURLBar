Pod::Spec.new do |s|
  s.name         = "KFURLBar"
  s.version      = "0.0.5"
  s.summary      = "KFURLBar is a NSView subview that mimics Safari's url bar with a progress background."
  
  s.authors      = { "Rico Becker" => "rico.becker@kf-interactive.com", "Gunnar Herzog" => "gunnar.herzog@kf-interactive.com" }  
  s.source       = { :git => "https://github.com/ricobeck/KFURLBar.git", :tag => "0.0.7" }

  s.platform     = :osx
  s.osx.deployment_target = '10.7'
  
  s.source_files = 'KFURLBar/Sources/**/*.{h,m}'
  s.requires_arc = true
end
