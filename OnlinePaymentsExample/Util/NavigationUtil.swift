//
// Do not remove or alter the notices in this preamble.
// This software code is created for Online Payments on 09/02/2024
// Copyright © 2024 Global Collect Services. All rights reserved.
// 

import UIKit

struct NavigationUtil {
    static func popToRootView() {
        guard let keyWindow = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive })?
                .windows
                .first(where: { $0.isKeyWindow })
        else {
            return
        }

        findNavigationController(viewController: keyWindow.rootViewController)?
            .popToRootViewController(animated: true)
    }


    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController
        else {
            return nil
        }

        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }

        if !viewController.children.isEmpty {
            let childViewController = viewController.children[0]
            return findNavigationController(viewController: childViewController)
        }

        return nil
    }
}
