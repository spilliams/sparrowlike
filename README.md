This is an updated version of my original attempt at getting table cells to pan, like they do in the Sparrow app. There were a few problems with the original implementation:

- the pan logic was in the table view controller, not the cell controller
- it didn't use the cell's views the way they're meant to be used (ie it ignored `backgroundView` and `contentView`, and created two new views--unsustainable from a Plug-n-Play philosophy)
- the logic was all tightly married to itself. there was no delegate protocol or notification center to allow developers to hook into the UI changes.
- the demo didn't make use of a subclass pattern (or [library linking](https://gist.github.com/spilliams/5273740)), thus developers may have been confused about how to properly use the library and classes.

This version attempts to rectify all of that.

Requirements: this was built using Xcode 4.6.2, but version with Storyboards should work? Also this requires ARC, for now.
