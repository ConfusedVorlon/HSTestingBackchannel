
Pod::Spec.new do |s|


  s.name         = "HSTestingBackchannel"
  s.version      = "1.2.0"

  s.summary      = "Send notifications directly from your UITesting classes to your running app."

  s.description  = <<-DESC
                   Sometimes you want to cheat in your UITesting. 

                   HSTestingBackchannel provides an easy way for you to send notifications to your running app. You can use these to set things up for tests, screenshots, etc
                   DESC

  s.homepage     = "https://github.com/ConfusedVorlon/HSTestingBackchannel"


  s.license      = { :type => "MIT", :file => "LICENSE" }


  s.author             = { "Rob" => "Rob@HobbyistSoftware.com" }

  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/ConfusedVorlon/HSTestingBackchannel.git", :tag => "1.2.0" }


  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.dependency 'GCDWebServer'

end
