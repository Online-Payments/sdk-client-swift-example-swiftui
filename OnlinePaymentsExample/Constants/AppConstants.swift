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
import OnlinePaymentsKit

struct AppConstants {
    static let applicationIdentifier = "SwiftUI Example Application/v1.2.1"

    // Constants used for saving input to UserDefaults
    static let clientSessionId = "ClientSessionId"
    static let customerId = "CustomerId"
    static let merchantId = "MerchantId"
    static let baseURL = "BaseURL"
    static let assetURL = "AssetURL"
    static let amount = "Amount"
    static let countryCode = "CountryCode"
    static let currencyCode = "CurrencyCode"

    // Apple Pay identifier
    static let applePayIdentifier = 302

    // Constants used to identify Card product fields
    static let cardField = "cardNumber"
    static let cvvField = "cvv"
    static let securityCodeField = "PinCode"
    static let expiryDateField = "expiryDate"
    static let cardHolderField = "cardholderName"
}
