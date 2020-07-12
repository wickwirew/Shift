<p align="center">
    <img src="https://github.com/wickwirew/Shift/blob/master/Resources/Shift.png" width="400"/>
</p>

Shift is a simple, delarative animation library for building complex view controller and view transitions in UIKit.

![Swift 5.0](https://img.shields.io/badge/Swift-5.0-green.svg)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org)

Shift can automatically transition matched views from one view controller to the next, by simply providing an `id` to the source and destination views. Transitions like these can make transition feel very fluid and natural and can help give context to the destination screen. Additional animations can be applied to the unmatched views that will be run during the transition.

Shift is very similar to [Hero](https://github.com/HeroTransitions/Hero) in that it can animate view controller transitions. It differs in that it is not tied to view controllers only. The animations can be applied to two different `UIView`s regardless of whether an actual transition is occurring. Which can be useful if you are transitioning between two child view controllers, or just two plain `UIView` subviews. It can also be plugged easily into custom transitions where you need to supply your own `UIViewControllerAnimatedTransitioning` or `UIPresentationController`. This can be very useful if the destination view controller maybe does not cover the full screen.

## Examples
All examples can be found in the `/Examples` folder, and can be run via the `/Examples/Examples.xcworkspace`.

<img src="https://github.com/wickwirew/Shift/blob/master/Resources/SpaceGif.gif" width="240"/> <img src="https://github.com/wickwirew/Shift/blob/master/Resources/MusicGif.gif" width="240"/> <img src="https://github.com/wickwirew/Shift/blob/master/Resources/MovieGif.gif" width="240"/>

## Matched Views
A matched view is where you have a view on the source view, that needs to be animated to a view on the destination view. This can be done by supplying a matching `id` to each view. During the transition, the source view's frame, and other common properties, will be animated to match the destinations.

![Match](https://github.com/wickwirew/Shift/blob/master/Resources/Match.gif)

```swift
sourceView.shift.id = "view"
destinationView.shift.id = "view"
```
Thats it! The `sourceView` will now be magically moved to match the `destinationView`.
Note: None of the views are actually edited, snapshots of each are used.

### Content Animation
When views are matched, their content may be different. How it is transitioned from the initial content to the new content can be customized. There are two different options for content animations, `fade` and `none`. This option can be changed via the `view.shift.contentAnimation` and is only valid on matched view, since unmatched views do not have content changes.

On `fade` the initial content will be faded out and the new content will be faded in.

![Match](https://github.com/wickwirew/Shift/blob/master/Resources/Fade.gif)

On `none` the content will immediately show the final content.

![Match](https://github.com/wickwirew/Shift/blob/master/Resources/NoFade.gif)

### Content Sizing
Matched views may change size during the transition. Since snapshots of the views are used, when they are resized the content may warp and stretch. You can customize the behavior of how the content is sized view the `shift.contentSizing` property. There are two different sizing options, `stretch` and `final`.
With `stretch`, the content's size will directly match the view as it is changed to its new final frame.

![Stretch](https://github.com/wickwirew/Shift/blob/master/Resources/StretchSize.gif)

With `final`, the content's size will be set to it's final size instantly, and any size changes will not affect it.

![Final](https://github.com/wickwirew/Shift/blob/master/Resources/FinalSize.gif)

## Additional animations
If one view does not have a match, but needs to be animated during the transition, you can provide a number of addition animations. These animations will be applied during the transition, and will be automatically reversed on dismissal.

For example. If we want a view to fade in, and slide in from the left by 150 points, it can be done by applying the animations like so:

```swift
item.shift.animations
    .fade()
    .move(.right(150))
```

![Final](https://github.com/wickwirew/Shift/blob/master/Resources/AdditionalAnimation.gif)

## Superview
`shift.superview`
When a view is animated during a transition, it's snapshot must be added to a view within the transition. There are two different options for the `superview`, `parent` and `container`. Each different superview can affect how the view appears to make it to it's final position. 

With **parent**, it's `superview` will be a view that most closly relates to the view's actual `superview` in the original view heirarchy. If its `superview`s position, is being animated, it will also be animated since it's a subview of the the view being animated.

```swift
view.shift.superview = .parent
```

![Parent](https://github.com/wickwirew/Shift/blob/master/Resources/Parent.gif)

On **container** it will be added directly to the transition's `container` view, and it will not be affected by the original `superview`s position. `parent` is the default choice, however matched views will always use `container` regardless of the choice.

```swift
view.shift.superview = .container
```

![Container](https://github.com/wickwirew/Shift/blob/master/Resources/Container.gif)

## Custom Transitions
If you need to supply your own `UIViewControllerAnimatedTransitioning` or `UIPresentationController`, it is very simply to incorporate shift into the transition.
At the heart of every transition is the `Animator`. It is responsible for performing the animations.
In your `UIViewControllerAnimatedTransitioning` subclass declare a new animator:
```swift
let animator = Animator()
```
Then in `animateTransition(using transitionContext:)` call the animators `animate` method:
```swift
self.animator.animate(
    fromView: fromViewController.view,
    toView: toViewController.view,
    container: transitionContext.containerView,
    completion: { complete in
        transitionContext.completeTransition(complete)
    }
)
```
Thats about all the code needed. See the default [modal transition animator](https://github.com/wickwirew/Shift/blob/master/Shift/Transitions/Modal/ModalTransitionDismissing.swift) supplied for the full example.

In the examples project, the "Movie" view uses a custom `UIPresentationController` to present a non-fullscreen context menu.

# Credits
* [Hero](https://github.com/HeroTransitions/Hero) was obviously a huge inspiration behind this library, so a ton of credit goes to [lkzhao](https://github.com/lkzhao) and the [Contributors](https://github.com/HeroTransitions/Hero/graphs/contributors). This is merely another option if Hero does not nessecarily do everything you need.
* [SamAtmoreMedia](https://dribbble.com/SamAtmoreMedia) on Dribbble for the [concept](https://dribbble.com/shots/4475042-Space-app-transition-experiement) of the space example design.
