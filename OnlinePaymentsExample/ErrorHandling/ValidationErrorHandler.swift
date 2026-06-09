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

struct ValidationErrorHandler {
    static let errorMessageFormat = "ValidationErrors.%@"
    static func errorMessage(for error: ValidationErrorMessage, withCurrency: Bool) -> String {
        if !error.errorMessage.isEmpty {
            let key = String(format: errorMessageFormat, error.errorMessage)
            
            return (key.localized == key) ? error.errorMessage : key.localized
        }
        
        if let type = error.type, !type.isEmpty {
            let key = String(format: errorMessageFormat, type)
            
            return (key.localized == key) ? type : key.localized
        }
        
        return ""
    }
}
