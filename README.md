KFURLBar
=========

KFURLBar is a NSView subview that mimics Safari's url bar with a progress background.


![Alt Example Screenshots](/Images/screenshot.png "KFURLBar in Action with a positioned Alert Sheet")

#Installation
Add
```
pod 'KFURLBar'
```
to your podfile and run
```
pod install
```

#Usage

Drop a NSView in Interface Builder and change it's class to KFUrlBar. Set the delegate and you are ready.

You can customise the validation of an URL by implementing
```obj-c
- (void)urlBar:(KFURLBar *)urlBar isValidRequestStringValue:(NSString *)requestString
```

A detailed example is included. Checkout the master branch and run the Xcode project.

#License
This code is distributed under the terms and conditions of the MIT license.

#Author
Rico Becker  
@ricobeck  
<https://twitter.com/ricobeck>