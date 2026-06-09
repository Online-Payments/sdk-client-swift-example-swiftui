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

import Foundation
import OnlinePaymentsKit
import UIKit

extension EndScreen {

    class ViewModel: ObservableObject {

        // MARK: - Properties
        @Published var showEncryptedFields: Bool = false

        var encryptedRequest: EncryptedRequest?

        // MARK: - Init
        init(encryptedRequest: EncryptedRequest?) {
            self.encryptedRequest = encryptedRequest
        }

        // MARK: - Functions
        func copyToClipboard() {
            UIPasteboard.general.string = self.encryptedRequest?.encryptedCustomerInput ?? ""
        }

        func returnToStart() {
            NavigationUtil.popToRootView()
        }

    }
}
