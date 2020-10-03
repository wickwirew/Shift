Pod::Spec.new do |s|
    s.name         = "ShiftTransitions"
    s.version      = "0.1.2"
	s.swift_version = '5.1'
    s.summary      = "Shift is a simple, delarative animation library for building complex view controller and view transitions in UIKit."
    s.description  = <<-DESC
    Shift can automatically transition matched views from one view controller to the next, by simply providing an id to the source and destination views. Transitions like these can make transition feel very fluid and natural and can help give context to the destination screen. Additional animations can be applied to the unmatched views that will be run during the transition.
    DESC
    s.homepage     = "https://github.com/wickwirew/Shift"
    s.license      = "MIT"
    s.author       = { "Wesley Wickwire" => "wickwirew@gmail.com" }
    s.platform     = :ios, "11.0"
    s.source       = { :git => "https://github.com/wickwirew/Shift.git", :tag => s.version }
    s.source_files = 'Shift/**/*.{swift,h}'
end
