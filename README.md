<p align="center">
<img src="https://static1.squarespace.com/static/592df079893fc0e042b0e585/t/592df28c3e00be8e7a34d733/1498102982326/?format=1500w" alt="Icon"/>
</p>

[![CI Status](http://img.shields.io/travis/kronos317/USeek.svg?style=flat)](https://travis-ci.org/kronos317/USeek)
[![Version](https://img.shields.io/cocoapods/v/USeek.svg?style=flat)](http://cocoapods.org/pods/USeek)
[![License](https://img.shields.io/cocoapods/l/USeek.svg?style=flat)](http://cocoapods.org/pods/USeek)
[![Platform](https://img.shields.io/cocoapods/p/USeek.svg?style=flat)](http://cocoapods.org/pods/USeek)

## What is USeek?

The USeek interactive advertising solution turns your videos into engaging experiences full of rewards...

[![Rewards](https://static1.squarespace.com/static/592df079893fc0e042b0e585/t/59496cddbe6594e7cda66c6a/1497984245701/?format=1500w)](https://www.landing.useek.com/)

...Increasing viewer attention while searching your creative for objects.

## USeek Library

`USeek` library is designed to help developers easily add the enjoyable features of USeek in their own application.

## Warning

- **USeek** utilizes the power of `safari`'s interactive video feature, and this is only available from iOS 10.0 or later. 

## Requirements

[![Platform iOS](https://img.shields.io/badge/Platform-iOS-blue.svg?style=fla)]()

#### USeek:-
[![Objective-c](https://img.shields.io/badge/Language-Objective%20C-blue.svg?style=flat)](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html)

Minimum iOS Target: iOS 10.0

Minimum Xcode Version: Xcode 8.0

Installation
==========================

#### From CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like `USeek` in your projects. First, add the following line to your [Podfile](http://guides.cocoapods.org/using/using-cocoapods.html):

```ruby
pod 'USeek', :git => 'https://github.com/kronos317/USeek.git'
```

This pulls from the `master` branch directly.

Second, install `USeek` into your project:

```ruby
pod install
```

#### Carthage 

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate `USeek` into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "kronos317/USeekFramework"
```

Run `carthage update` to build the framework and drag the built `USeek.framework` (in Carthage/Build/iOS folder) into your Xcode project (Linked Frameworks and Libraries in `Targets`).


#### Manually

* Drag the `kronos317/USeekFramework` folder into your project.
* Take care that `USeek.framework` is added to `Targets->Build Phases->Embeded Frameworks`.


## Usage

(see sample Xcode project in `/USeekDemo`)

There are 3 main classes.
 * USeekManager
 * USeekPlayerView
 * USeekPlayerViewController

`USeekManager` is singleton class, with which you can do the following actions
 * Set / Retrieve publisher ID
 * Request for the points of certain user

`USeekPlayerView` and `USeekPlayerViewController` classes are designed to load & play the embeded video in UIView or as a standalone UIViewController.

#### Set Publisher ID
 
```objective-c
[[USeekManager sharedManager] setPublisherId: @"{your publisher ID}"];
```

#### How to use USeekPlayerViewController

1. Instantiate USeekPlayerViewController

```objective-c
USeekPlayerViewController *vc = [[USeekPlayerViewController alloc] init];
```

2. Load video

```objective-c
[vc loadVideoWithGameId:@"{game id}" UserId:@"{user id, can be empty}"];
```

3. Customize View Controller `[optional]`

```objective-c
// show / hide `close` button
[vc setCloseButtonHidden:YES];

// customize loading text
vc.loadingTitleLabel.text = @"Please wait while loading video...";          

// set delegate
vc.delegate = self;
```
4. Present View Controller

```objective-c
dispatch_async(dispatch_get_main_queue(), ^{
    [self presentViewController:vc animated:YES completion:nil];
});
```

5. Get notified when USeekPlayerViewController is closed `[optional]`

USeekPlayerViewControllerDelegate defines several useful delegate methods (optional), and one of them is `useekPlayerViewControllerDidClose:` which will be called when the USeekPlayerViewController is closed.

```objective-c
- (void)useekPlayerViewControllerDidClose:(USeekPlayerViewController *)playerViewController{
    // Do anything here
}

```


#### How to use USeekPlayerView

USeekPlayerView inherits UIView, thus you can directly add it in storyboard or add as subview programmatically.

 - Add as a subview programmatically

```objective-c
USeekPlayerView *playerView = [[USeekPlayerView alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
[self.view addSubview:playerView];
```

 - Add in storyboard

Just change the class name of the view to USeekPlayerView in storyboard.
Now you can add the view as IBOutlet and use.

#### How to get points from server

By calling `[[USeekManager sharedManager] requestPointsWithGameId:UserId:Success:Failure]`, we can get the points the user gained while playing the gamified video.

```objective-c
[[USeekManager sharedManager] requestPointsWithGameId:@"game id" UserId:@"user id" Success:^(int points) {
    // Do anything here
} Failure:^(NSError *error) {
    // Do anything here
}];
```

## License

USeek is available under the USEEK license. See the LICENSE file for more info.
