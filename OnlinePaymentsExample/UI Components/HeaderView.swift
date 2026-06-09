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

import SwiftUI

struct HeaderView: View {

    // MARK: - Body
    var body: some View {
        VStack(spacing: 10) {
            Image("MerchantLogo")
                .resizable()
                .scaledToFit()
                .padding(.top, 40)
                .frame(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.height * 0.15)
            HStack {
                Spacer()
                HStack {
                    Image("SecurePaymentIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                    Text("SecurePayment".localized)
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
        }.padding(.horizontal, 20)
    }
}

// MARK: - Previews
#Preview {
    HeaderView()
}
