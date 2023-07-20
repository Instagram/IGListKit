/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var isLaunched = false
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let demosViewController = DemosViewController()
        let splitViewController = UISplitViewController()
        splitViewController.delegate = self
        splitViewController.viewControllers = [UINavigationController(rootViewController: demosViewController)]
        splitViewController.preferredDisplayMode = .oneBesideSecondary

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = splitViewController
        window?.makeKeyAndVisible()
        UICollectionView.appearance().backgroundColor = UIColor.background

        return true
    }
}

extension AppDelegate: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        // We set up 2 view controllers on launch to enable the split view controller when launching on iPad.
        // However, for iPhone, discard the second view controller so the Demos view controller is visible at launch.
        if !isLaunched {
            isLaunched = true
            return true
        }
        return false
    }
}
