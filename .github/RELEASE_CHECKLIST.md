# Release Checklist

Here are the steps for creating and publishing a new release for `IGListKit`.

- Final review and update of header docs and guides
- Final review of changelog
- Regenerate docs
- Update pod spec version
- Update xcodeproj version
- Run `pod install` on all examples (**must happen on FB internal** because of sync issues)
- Merge `master` into `stable` via cmd-line and push
- Confirm `stable` is `0|0` [ahead/behind](https://github.com/Instagram/IGListKit/branches)
- Create [GitHub release](https://github.com/Instagram/IGListKit/releases) from `stable`
- Paste changelog into GH release notes
- Publish GitHub release
- Run `pod lib lint`
- Push updated podspec: `pod trunk push IGListKit.podspec`
- Verify new release on [CocoaPods](https://cocoapods.org/pods/IGListKit)
- Tweet all the tweets
