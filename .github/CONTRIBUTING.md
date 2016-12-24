# Contributing to IGListKit

We want to make contributing to this project as easy and transparent as
possible, and actively welcome your pull requests.  If you run into problems,
please open an issue on GitHub.

## Pull Requests

1. Fork the repo and create your branch from `master`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. If you haven't already, complete the Contributor License Agreement ("CLA").
7. Add an entry to the `CHANGELOG.md` for any breaking changes, enhancements, or bug fixes.

## Experimental changes

If your change can't be unit tested, we might ask that you add your change as an experiment so that we can verify your change works. To do this, first add a new option to [IGListExperiment](https://github.com/Instagram/IGListKit/blob/master/Source/Common/IGListExperiments.h#L17).

Then, use an `experiments` bitmask wherever your change is and wrap it in a check to see if it is enabled:

```swift
IGListExperimentEnabled(self.experiments, IGListExperimentMyAwesomeChange) {
    // your code here
}
```

Once your experiment is confirmed we will remove the option and wrapping check!

## Contributor License Agreement ("CLA")

In order to accept your pull request, we need you to submit a CLA. You only need
to do this once to work on any of Facebook's open source projects.

Complete your CLA here: <https://code.facebook.com/cla>

## Issues

We use GitHub issues to track public bugs. Please ensure your description is
clear and has sufficient instructions to be able to reproduce the issue.

Facebook has a [bounty program](https://www.facebook.com/whitehat/) for the safe
disclosure of security bugs. In those cases, please go through the process
outlined on that page and do not file a public issue.

## Coding Style

* 4 spaces for indentation rather than tabs
* Public classes and methods must contain header documentation
* Use plain C functions whenever possible (as opposed to class methods)

## Updating Testing Dependencies

If you need a different version of one of the testing dependencies, you will need to first [install Cocoapods](https://guides.cocoapods.org/using/getting-started.html):

```
$ [sudo] gem install cocoapods
```

Then within the project directory, run `pod install` to update the dependency to that version.

## License

By contributing to `IGListKit`, you agree that your contributions will be licensed under the LICENSE file in the root directory of this source tree.
