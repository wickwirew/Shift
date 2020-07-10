# Shift

Shift is a simple, delarative animation library for building complex view controller and view transitions in UIKit.

Shift can automatically transition matched views from one view controller to the next, by simply providing an `id` to the source and destination views. Transitions like these can make transition feel very fluid and natural and can help give context to the destination screen. Additional animations can be applied to both the matched and unmatched views that will be run during the transition.

Shift is very similar to [Hero](https://github.com/HeroTransitions/Hero) in that it can animate view controller transitions. It differs in that it is not tied to view controllers only. The animations can be applied to two different `UIView`s regardless of whether an actual transition is occurring. Which can be useful if you are transitioning between two child view controllers, or just two plain `UIView` subviews. It can also be plugged easily into custom transitions where you need to supply your own `UIViewControllerAnimatedTransitioning` or `UIPresentationController`. This can be very useful if the destination view controller maybe does not cover the full screen.

## Matched Views
A matched view is where you have a view on the source view, that needs to be animated to a view on the destination view. This can be done by supplying a matching `id` to each view. During the transition, the source view's frame, and other common properties, will be animated to match the destinations.
```swift
sourceView.shift.id = "view"
destinationView.shift.id = "view"
```
Thats it! The `sourceView` will now be magically moved to match the `destinationView`.
Note: None of the views are actually edited, snapshots of each are used.

## Additional animations
If one view does not have a match, but needs to maybe slide in from offscreen, or fade in, you can apply additional animations to accomplish that.

For example. If we want a view to fade in, and slide in from the right by 300 points, it can be done by applying the animations like so:
```swift
view.shift.animations
    .fade()
    .move(x: 300, y: 0)
```

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
Thats about all the code needed. See the default [modal transition animator](https://github.com/wickwirew/Shift/blob/8c4f806a776bcbcb3a729688ec77d79599e08e3b/Shift/Transitions/Modal/ModalTransitionPresenting.swift#L30) supplied for the full example.

# Credits
* [Hero](https://github.com/HeroTransitions/Hero) was obviously a huge inspiration behind this library, so a ton of credit goes to [lkzhao](https://github.com/lkzhao) and the [Contributors](https://github.com/HeroTransitions/Hero/graphs/contributors). This is merely another option if Hero does not nessecarily do everything you need.
* [IDK] on Dribbble for the concept of the space example design.
