<p align="center">
    <img src="https://github.com/wickwirew/Shift/blob/master/Resources/Shift.png" width="400"/>
</p>

Shift is a simple, declarative animation library for building complex view controller and view transitions in UIKit.

![Swift 5.0](https://img.shields.io/badge/Swift-5.0-green.svg)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org)

Shift can automatically transition matched views from one view controller to the next, by simply providing an `id` to the source and destination views. Transitions like these can make transitions feel very fluid and natural and can help give context to the destination screen. Additional animations can be applied to the unmatched views that will be run during the transition.

Shift is very similar to [Hero](https://github.com/HeroTransitions/Hero) in that it can animate view controller transitions. It differs in that it is not tied to view controllers only. The animations can be applied to two different `UIView`s regardless of whether an actual transition is occurring. Which can be useful if you are transitioning between two child view controllers, or just two plain `UIView` subviews. It can also be plugged easily into custom transitions where you need to supply your own `UIViewControllerAnimatedTransitioning` or `UIPresentationController`. This can be very useful if the destination view controller does not cover the full screen.

## Examples
All examples can be found in the `/Examples` folder, and can be run via the `/Examples/Examples.xcworkspace`.

<img src="https://github.com/wickwirew/Shift/blob/master/Resources/SpaceGif.gif" width="240"/> <img src="https://github.com/wickwirew/Shift/blob/master/Resources/MusicGif.gif" width="240"/> <img src="https://github.com/wickwirew/Shift/blob/master/Resources/MovieGif.gif" width="240"/>

## Start
To begin using **Shift**, you must enable it before presenting the view controller.

```swift
viewController.shift.enable()
present(viewController, animated: true, completion: nil)
```

This will cause **Shift** to take over for any transitions for the view controller. If you stop here, when presenting the view controller you will see that the view is presented with a fade animation. This is the `defaultAnimation`, and is customizable. If none is desired it can be stopped by setting it to `nil`. There are also multiple other [defaults provided](https://github.com/wickwirew/Shift/blob/master/Shift/DefaultShiftAnimation.swift).

```swift
viewController.shift.defaultAnimation = DefaultAnimations.Scale(.down)
```

You can make your own custom default animations as well by conforming to `DefaultShiftAnimation`, and setting the desired animations on the views. How to add custom additional animations will be [covered later](#additional-animations).

### Baseline Duration
The duration of the transition animation is determinded by the `baselineDuration` provided. This is a baseline for the duration and not the actual value that will be used. Each view will calculate a duration for its animations based off the animations being applied. In other words, the `baselineDuration` is the minimum duration, and each view will add additional time on top if need be.

```swift
// Transition will now take about 1 second.
viewController.shift.baselineDuration = 1
```

### View Order
The "toViews" and "fromViews", or the views that we are transitioning from and to, need to be added to the transition container. The order in which they are added can be tweaked, to give you control over which views are on top or bottom. This is done by the `viewOrder` property. By default this will be `auto`. Auto adds the views in the order you would expect. The view being transitioned to will be on top, and on dismissal the view that is being dismissed will be on top. However this may not be what you want. Using view order you can choose which views should be on top.

```swift
viewController.shift.viewOrder = .fromViewsOnTop
```

## Matched Views
A matched view is where you have a view on the source view that needs to be animated to a view on the destination view. This can be done by supplying a matching `id` to each view. During the transition, the source view's frame, and other common properties, will be animated to match the destinations.

![Match](https://github.com/wickwirew/Shift/blob/master/Resources/Match.gif)

```swift
firstView.shift.id = "blueView"
secondView.shift.id = "blueView"
```
That's it! The `sourceView` will now be magically moved to match the `destinationView`.
Note: None of the views are actually edited, snapshots of each are used.

### Content Animation
When views are matched, their content may be different. How it is transitioned from the initial content to the new content can be customized. There are two different options for content animations, `fade` and `final`. This option is only valid on matched views, since unmatched views do not have content changes.

On **fade** the initial content will be faded out and the new content will be faded in.

```swift
view.shift.contentAnimation = .fade
```

![Match](https://github.com/wickwirew/Shift/blob/master/Resources/Fade.gif)

On **final** the content will immediately show the final content.

```swift
view.shift.contentAnimation = .final
```

![Match](https://github.com/wickwirew/Shift/blob/master/Resources/NoFade.gif)

### Content Sizing
Matched views may change size during the transition. Since snapshots of the views are used when they are resized, the content may warp and stretch. You can customize the behavior of how the content is sized. There are two different sizing options, `stretch` and `final`.

With **stretch**, the content's size will directly match the view as it is changed to its new final frame.

```swift
view.shift.contentSizing = .stretch
```

![Stretch](https://github.com/wickwirew/Shift/blob/master/Resources/StretchSize.gif)

With **final**, the content's size will be set to its final size instantly, and any size changes will not affect it.


```swift
view.shift.contentSizing = .final
```

![Final](https://github.com/wickwirew/Shift/blob/master/Resources/FinalSize.gif)

## Additional animations
If one view does not have a match, but needs to be animated during the transition, you can provide a number of additional animations. These animations will be applied during the transition, and will be automatically reversed on dismissal.

For example, if we want a view to fade and slide in from the left by 150 points, it can be done by applying the animations like so:

```swift
view.shift.animations
    .fade()
    .move(.right(150))
```

![AdditionalAnimation](https://github.com/wickwirew/Shift/blob/master/Resources/AdditionAnimation.gif)

To view a full list of potential animations, please [see](https://github.com/wickwirew/Shift/blob/master/Shift/Animations.swift)

These animations can be setup to **conditionally** run based on some predicate. Each animation function has an optional parameter to supply a `Condition`; it is always the last parameter. If the condition is not met, the animation will not be added.

To only have a view scale up when the view appears, but not scale back down while disappearing, do:

```swift
view.animations.scale(2, .onAppear)
```

To provide a custom condition, you can use the `.filter`.

```swift
view.animations.scale(2, .filter{ ... })
```

## Superview
When a view is animated during a transition, its snapshot must be added to a view within the transition. There are two different options for the `superview`, `parent` and `container`. Each different superview can affect how the view appears to make it to its final position. 

With **parent**, its `superview` will be a view that most closly relates to the view's actual `superview` in the original view heirarchy. If its `superview`'s position, is being animated, it will also be animated since it's a subview of the view being animated.

```swift
star.shift.superview = .parent
```

![Parent](https://github.com/wickwirew/Shift/blob/master/Resources/Parent.gif)

On **container** it will be added directly to the transition's `container` view, and it will not be affected by the original `superview`'s position. `parent` is the default choice, however matched views will always use `container` regardless of the choice.

```swift
star.shift.superview = .container
```

![Container](https://github.com/wickwirew/Shift/blob/master/Resources/Container.gif)

## Custom Transitions
If you need to supply your own `UIViewControllerAnimatedTransitioning` or `UIPresentationController`, it is very simply to incorporate **Shift** into the transition.
At the heart of every transition is the `Animator`. It is responsible for performing the animations.
In your `UIViewControllerAnimatedTransitioning` subclass, in the `animateTransition(using transitionContext:)` function declare a new animator, and call animate.
```swift
let animator = Animator(
    fromView: fromViewController,
    toView: toViewController,
    container: transitionContext.containerView,
    isPresenting: true
)

animator.animate { complete in
    toViewController.view.alpha = 1
    transitionContext.completeTransition(complete)
}
```
See the default [modal transition animator](https://github.com/wickwirew/Shift/blob/master/Shift/Transitions/Modal/ModalTransitionDismissing.swift) supplied for the full example.

In the examples project, the "Movie" view uses a custom `UIPresentationController` to present a non-fullscreen context menu.

## Installation

### Swift Package Manager

**Shift** is available through [Swift Package Manager](https://github.com/apple/swift-package-manager/).

To add it via SPM, simply add `https://github.com/wickwirew/Shift.git` to your list of packages in Xcode.

### Carthage

Shift is available through [Carthage](https://github.com/Carthage/Carthage). To install
it, simply add the following line to your Cartfile:

`github "wickwirew/Shift"`

### CocoaPods

**Shift** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following lines to your Podfile:

```ruby
use_frameworks!
pod 'ShiftTransitions'
```

## Credits
* [Hero](https://github.com/HeroTransitions/Hero) was obviously a huge inspiration behind this library, so a ton of credit goes to [lkzhao](https://github.com/lkzhao) and the [Contributors](https://github.com/HeroTransitions/Hero/graphs/contributors). This is merely another option if Hero does not nessecarily do everything you need.
* [SamAtmoreMedia](https://dribbble.com/SamAtmoreMedia) on Dribbble for the [concept](https://dribbble.com/shots/4475042-Space-app-transition-experiement) of the space example design.
