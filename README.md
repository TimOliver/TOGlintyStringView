![TOGlintyStringView](screenshot.jpg)

# TOGlintyStringView
`TOGlintyStringView` is a complete re-implementation of [`_UIGlintyStringView`](https://github.com/JaviSoto/iOS9-Runtime-Headers/blob/51598b5f73399e4737bc067ed6b9bd5bd9a8b0d1/Frameworks/UIKit.framework/_UIGlintyStringView.h), the internal UIKit `UIView` responsible for the '> slide to unlock' text on every iOS device's lock screen.

It was created by copying the `UIView` / `CALayer` configuration of `_UIGlintyStringView` after introspecting it via [Reveal app](http://revealapp.com) as well as lot of console logging.

As this library (most likely) cannot be used in shipping iOS apps, it's being presented here without warranty in the hopes it may have educational value to fellow developers!

# How does it work?

I'll improve this section down the line, but in a nutshell, it is comprised of 6 discrete `CALayer` objects:

* The top layer contains a bitmap of the text, used as a mask to clip the rest of the content.
* The second layer is a flat, partially transparent grey layer used as the base color of the effect.
* The third layer is the white 'sheen' gradient that results in the pure white section of the effect.
* The fourth layer is a simple `CAGradientLayer` that when blended with the other two gradients, creates a wedge shape falloff on either side of the sheen effect.
* The fifth layer is a much wider, and less opaque gradient that creates the 'build-up' effect on either side of the sheen.
* The sixth layer is a `CAShapeLayer` that takes a `CGPath` outline of the text, and produces a blurred, dashed-line outline, that is then blended with the gradients to produce that subtle 'fractal' effect.

All of this is possible in an (officially unsupported on iOS) feature of Core Animation allowing layers to be blended together using a variety of filters.

# Is it safe for the App Store?
HAHAHAHA absolutely not. In order to make this effect possible, two private APIs needed to be invoked:

* To enable blending on `CALayer` objects, the `allowsGroupBlending` property must be set to NO. This property is not officially exposed, but trivial to access, and probably easy to obfuscate from the app submission scanner.
* To create the blurring of the dashes in the `CAShapeLayer`, it is necessary to instantiate a `CAFilter` instance. As this class definitely isn't exposed on iOS, using it would immediately be caught by the automatic private API detection system Apple uses in app submissions.

While you're free to try, I wouldn't recommend trying to submit an app to the App Store using this view.

# Credits

`TOGlintyStringView` was created by Tim Oliver as a Core Animation experiment.

It also incorporates the [`string-to-CGPathRef`](https://github.com/aderussell/string-to-CGPathRef) library, created by Adrian Russell, 2014

# License

`TOGlintyStringView` is available under the MIT license. Please see the [LICENSE] file for more information
