/*
 * Do not remove or alter the notices in this preamble.
 *
 * This software is owned by Worldline and may not be be altered, copied, reproduced, republished, uploaded, posted, transmitted or distributed in any way, without the prior written consent of Worldline.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

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
